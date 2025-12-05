using UnityEngine;

/// <summary>
/// 挂载到植物实例上，使其根部跟随水面高度浮动。
/// 优化：使用 SmoothDamp 实现更平滑的阻尼效果。
/// </summary>
public class WaterPlant : MonoBehaviour
{
    // 移除了 plantFollowSpeed，使用 smoothDampTime 代替
    [Tooltip("阻尼平滑时间。值越小，跟随越快/阻尼越小。")]
    public float smoothDampTime = 0.1f; 

    private FloatingObjectController waterController;
    
    // SmoothDamp 必须使用一个私有变量来跟踪 Y 轴的速度
    private float yVelocity = 0.0f; 

    void Start()
    {
        waterController = FindObjectOfType<FloatingObjectController>();
        if (waterController == null)
        {
            Debug.LogError("场景中缺少 FloatingObjectController，植物无法跟随水面。");
            enabled = false;
        }
    }

    void Update()
    {
        if (waterController == null) return;

        // 1. 查询目标 Y 轴高度
        float targetY = waterController.GetScaledWaterHeight(transform.position);

        Vector3 currentPos = transform.position;
        
        // 2. 使用 Mathf.SmoothDamp 平滑过渡 Y 轴
        // SmoothDamp 会根据当前速度 (yVelocity) 和阻尼时间 (smoothDampTime) 自动计算新的 Y 坐标。
        float newY = Mathf.SmoothDamp(
            currentPos.y, 
            targetY, 
            ref yVelocity, // ref 关键字表示 yVelocity 会被函数内部更新，用于下次计算
            smoothDampTime 
        );

        // 3. 应用新的位置 (X和Z保持不变)
        transform.position = new Vector3(currentPos.x, newY, currentPos.z);
    }
}