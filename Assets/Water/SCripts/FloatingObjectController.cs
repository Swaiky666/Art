using UnityEngine;

/// <summary>
/// Core water surface controller.
/// Periodically reads dynamic water height data from a GPU RenderTexture,
/// stores it on the CPU, and provides public height queries for floating objects
/// such as boats or plants.
/// </summary>
public class FloatingObjectController : MonoBehaviour
{
    // --- External References ---

    [Header("Water Parameters")]
    [Tooltip("RenderTexture output by the HeightmapRenderer, containing dynamic water height data.")]
    public RenderTexture waterHeightRT;

    [Tooltip("Renderer of the water plane, used to obtain bounds and map world positions to RT UVs.")]
    public Renderer waterPlaneRenderer;

    [Header("Buoyancy / Height Settings")]
    [Tooltip("Height scaling factor applied to sampled wave height. 1.0 means default intensity.")]
    public float heightScaleFactor = 1.0f;

    [Header("Performance Control")]
    [Tooltip("Time interval (seconds) between GPU readbacks. Smaller values are more accurate but more expensive.")]
    public float readInterval = 0.3f;

    [Header("UV Fix (If ripple direction looks mirrored)")]
    [Tooltip("Flip U (left-right). Enable if the effect is mirrored horizontally.")]
    public bool flipU = false;

    [Tooltip("Flip V (up-down). Enable if the effect is mirrored vertically. This is commonly needed.")]
    public bool flipV = true;

    // --- Internal Variables ---
    private Texture2D cpuHeightMap;
    private float nextReadTime = 0f;
    private float baseWaterLevel; // Base Y level of the water surface
    private Bounds waterBounds;   // World-space bounds of the water plane

    void Start()
    {
        if (waterHeightRT == null || waterPlaneRenderer == null)
        {
            Debug.LogError("waterHeightRT and waterPlaneRenderer must be assigned.");
            enabled = false;
            return;
        }

        baseWaterLevel = waterPlaneRenderer.transform.position.y;
        waterBounds = waterPlaneRenderer.bounds;

        // Initialize CPU-side Texture2D to store GPU readback data.
        // RHalf format (half-precision float) is suitable for height data.
        TextureFormat targetFormat = TextureFormat.RHalf;

        cpuHeightMap = new Texture2D(
            waterHeightRT.width,
            waterHeightRT.height,
            targetFormat,
            false
        );
    }

    void Update()
    {
        // Periodically perform GPU → CPU readback
        if (Time.time >= nextReadTime)
        {
            ReadHeightmapFromGPU();
            nextReadTime = Time.time + readInterval;
        }
    }

    /// <summary>
    /// Performs a synchronous GPU readback.
    /// This operation blocks the CPU, so the call frequency should be limited.
    /// </summary>
    void ReadHeightmapFromGPU()
    {
        if (waterHeightRT == null) return;
        if (waterHeightRT.width == 0 || waterHeightRT.height == 0) return;

        RenderTexture.active = waterHeightRT;

        // Read the entire RenderTexture into the CPU Texture2D
        cpuHeightMap.ReadPixels(
            new Rect(0, 0, waterHeightRT.width, waterHeightRT.height),
            0,
            0
        );

        cpuHeightMap.Apply(); // Apply changes so GetPixel is valid
        RenderTexture.active = null;
    }

    /// <summary>
    /// Public query function.
    /// Allows scene objects (e.g., water plants) to query the scaled water height.
    /// </summary>
    /// <param name="worldPos">World-space position to sample.</param>
    /// <returns>Final world-space water height at this position.</returns>
    public float GetScaledWaterHeight(Vector3 worldPos)
    {
        if (cpuHeightMap == null || waterHeightRT == null) return baseWaterLevel;

        // 1) World position -> UV (0..1) using water plane bounds
        float u = (worldPos.x - waterBounds.min.x) / waterBounds.size.x;
        float v = (worldPos.z - waterBounds.min.z) / waterBounds.size.z;

        // Optional UV flipping to match RenderTexture orientation
        if (flipU) u = 1f - u;
        if (flipV) v = 1f - v;

        // 2) UV -> pixel coordinates
        int x = Mathf.Clamp(Mathf.FloorToInt(u * waterHeightRT.width), 0, waterHeightRT.width - 1);
        int y = Mathf.Clamp(Mathf.FloorToInt(v * waterHeightRT.height), 0, waterHeightRT.height - 1);

        // 3) Sample raw height offset from CPU texture
        float originalOffset = cpuHeightMap.GetPixel(x, y).r;

        // 4) Apply user-defined scaling
        float scaledOffset = originalOffset * heightScaleFactor;

        // 5) Compute final world-space height
        return baseWaterLevel + scaledOffset;
    }

    void OnDestroy()
    {
        if (cpuHeightMap != null)
        {
            Destroy(cpuHeightMap);
        }
    }
}
