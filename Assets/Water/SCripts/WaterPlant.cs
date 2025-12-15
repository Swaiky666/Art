using UnityEngine;

/// <summary>
/// Attach to plant instances so their roots follow the water surface height.
/// Uses SmoothDamp for smoother, more natural vertical motion.
/// </summary>
public class WaterPlant : MonoBehaviour
{
    [Tooltip("Damping time for vertical smoothing. Smaller values follow faster with less damping.")]
    public float smoothDampTime = 0.1f;

    private FloatingObjectController waterController;

    // Required by SmoothDamp to track vertical velocity
    private float yVelocity = 0.0f;

    void Start()
    {
        waterController = FindObjectOfType<FloatingObjectController>();
        if (waterController == null)
        {
            Debug.LogError("FloatingObjectController not found in the scene. WaterPlant disabled.");
            enabled = false;
        }
    }

    void Update()
    {
        if (waterController == null) return;

        // 1. Query target water height at current position
        float targetY = waterController.GetScaledWaterHeight(transform.position);

        Vector3 currentPos = transform.position;

        // 2. Smoothly interpolate Y position using damping
        float newY = Mathf.SmoothDamp(
            currentPos.y,
            targetY,
            ref yVelocity,
            smoothDampTime
        );

        // 3. Apply new position (X and Z remain unchanged)
        transform.position = new Vector3(currentPos.x, newY, currentPos.z);
    }
}
