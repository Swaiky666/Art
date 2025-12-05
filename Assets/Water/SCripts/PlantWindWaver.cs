using UnityEngine;

/// <summary>
/// 挂载到植物根物体上，用于计算风力摇摆的强度，并传递给植物 Shader。
/// 摇摆效果本身在 Shader 中实现，此脚本负责提供动态参数。
/// </summary>
public class PlantWindWaver : MonoBehaviour
{
    // 静态只读属性 ID，避免每帧获取字符串哈希
    private static readonly int WindStrengthID = Shader.PropertyToID("_WindStrength");
    private static readonly int WindFrequencyID = Shader.PropertyToID("_WindFrequency");

    [Header("风力设置")]
    [Tooltip("基础摇摆强度，会根据植物的整体高度缩放。")]
    public float baseWindStrength = 0.05f; 
    
    [Tooltip("风的摇摆频率，影响摇摆速度。")]
    public float windFrequency = 1.0f; 
    
    [Header("高度缩放设置")]
    [Tooltip("预制体设计时的植物基准高度。")]
    public float basePlantHeight = 1.5f; 
    
    [Tooltip("摇摆对高度的敏感度系数（越高摇摆越大的乘数）。")]
    public float heightSensitivity = 1.0f;

    private Renderer plantRenderer;
    private Material plantMaterial;
    
    void Start()
    {
        plantRenderer = GetComponent<Renderer>();
        if (plantRenderer != null)
        {
            // 获取材质实例，以防修改影响其他使用相同材质的植物
            plantMaterial = plantRenderer.material;
            // 确保 Shader 中有对应的属性，否则会报错。
        }
        else
        {
            Debug.LogError("PlantWindWaver 需要一个 Renderer 组件来获取材质。");
            enabled = false;
        }
    }

    void Update()
    {
        if (plantMaterial == null) return;
        
        // 1. 获取当前植物在Y轴上的整体缩放（基于父物体）
        float currentScaleY = transform.lossyScale.y;
        
        // 2. 计算高度因子：当前高度 / 基准高度
        // 这个因子代表了当前植物相对于标准尺寸的大小。
        float currentHeightFactor = currentScaleY * basePlantHeight; 
        
        // 3. 计算最终摇摆强度
        // 强度 = 基础强度 * 相对高度 * 敏感度
        float finalStrength = baseWindStrength * currentHeightFactor * heightSensitivity;
        
        // 4. 将参数传递给 Shader
        plantMaterial.SetFloat(WindStrengthID, finalStrength);
        plantMaterial.SetFloat(WindFrequencyID, windFrequency);
        
        // 5. (可选) 传递一个世界空间位置偏移，以让相邻植物的摇摆不同步
        // 可以传递给 Shader 中的一个时间偏移变量
        // plantMaterial.SetFloat("_WindTimeOffset", transform.position.x * 0.05f + transform.position.z * 0.05f);
    }
}