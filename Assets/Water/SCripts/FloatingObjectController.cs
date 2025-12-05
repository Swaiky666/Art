using UnityEngine;

/// <summary>
/// 核心水面控制器，负责周期性地从 GPU 的 RenderTexture 读取动态水波高度数据，
/// 并通过公共方法将这些高度信息提供给场景中的浮动物体（如船只和植物）。
/// </summary>
public class FloatingObjectController : MonoBehaviour
{
    // --- 外部引用 ---
    
    [Header("水面参数")]
    [Tooltip("由 HeightmapRenderer 输出的 RenderTexture，包含动态水波高度。")]
    public RenderTexture waterHeightRT;
    
    [Tooltip("水面 Plane 的 Renderer 组件，用于获取边界信息，将世界坐标映射到 RT UV。")]
    public Renderer waterPlaneRenderer;

    [Header("浮力/高度设置")]
    [Tooltip("高度缩放系数。读取到的水波高度会乘以此系数再作用于物体。1.0 为默认强度。")]
    public float heightScaleFactor = 1.0f; 

    [Header("性能控制")]
    [Tooltip("每隔多少秒从 GPU 读取一次数据。值越小越精确，性能开销越大。")]
    public float readInterval = 0.3f; 
    
    // --- 内部变量 ---
    private Texture2D cpuHeightMap;
    private float nextReadTime = 0f;
    private float baseWaterLevel; // 水面基准Y轴高度
    private Bounds waterBounds;   // 水面边界

    void Start()
    {
        if (waterHeightRT == null || waterPlaneRenderer == null)
        {
            Debug.LogError("请设置 waterHeightRT 和 waterPlaneRenderer 引用。");
            enabled = false;
            return;
        }

        baseWaterLevel = waterPlaneRenderer.transform.position.y;
        waterBounds = waterPlaneRenderer.bounds;

        // 初始化 CPU 端的 Texture2D 副本，用于存储 GPU 读取的数据。
        // 使用 RHalf 格式（半精度浮点数），适用于高度数据。
        TextureFormat targetFormat = TextureFormat.RHalf; 
        
        // 构造函数: (宽度, 高度, 格式, 是否生成Mips)
        cpuHeightMap = new Texture2D(waterHeightRT.width, waterHeightRT.height, targetFormat, false);
    }

    void Update()
    {
        // 周期性地执行 GPU 到 CPU 的数据回读 (Readback)
        if (Time.time >= nextReadTime)
        {
            ReadHeightmapFromGPU();
            nextReadTime = Time.time + readInterval;
        }
    }

    /// <summary>
    /// 执行同步的 GPU 数据回读。此操作会阻塞 CPU，因此要控制频率。
    /// </summary>
    void ReadHeightmapFromGPU()
    {
        // 确保 RT 数据有效
        if (waterHeightRT.width == 0 || waterHeightRT.height == 0) return;
        
        RenderTexture.active = waterHeightRT;
        // 将整个 RenderTexture 的像素数据读取到 CPU 的 Texture2D 副本中
        cpuHeightMap.ReadPixels(new Rect(0, 0, waterHeightRT.width, waterHeightRT.height), 0, 0);
        cpuHeightMap.Apply(); // 应用更改，使 GetPixel 可用
        RenderTexture.active = null;
    }

    /// <summary>
    /// 【公共查询函数】供场景中的物体（如水植物）查询缩放后的水面高度。
    /// </summary>
    /// <param name="worldPos">查询点的世界坐标。</param>
    /// <returns>该点的世界水面高度（包含缩放偏移）。</returns>
    public float GetScaledWaterHeight(Vector3 worldPos)
    {
        // 检查数据是否已准备好
        if (cpuHeightMap == null) return baseWaterLevel; 

        // 1. 世界坐标到 UV (0-1) 的映射
        // 使用水面边界将世界坐标映射到 0 到 1 的 UV 范围
        float u = (worldPos.x - waterBounds.min.x) / waterBounds.size.x;
        float v = (worldPos.z - waterBounds.min.z) / waterBounds.size.z;
        
        // 2. UV 坐标到像素坐标的映射
        int x = Mathf.Clamp(Mathf.FloorToInt(u * waterHeightRT.width), 0, waterHeightRT.width - 1);
        int y = Mathf.Clamp(Mathf.FloorToInt(v * waterHeightRT.height), 0, waterHeightRT.height - 1);

        // 3. 从 CPU 副本中获取原始高度偏移值
        float originalOffset = cpuHeightMap.GetPixel(x, y).r;
        
        // 4. 应用用户定义的缩放系数 (heightScaleFactor)
        float scaledOffset = originalOffset * heightScaleFactor;
        
        // 5. 计算最终目标世界高度
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