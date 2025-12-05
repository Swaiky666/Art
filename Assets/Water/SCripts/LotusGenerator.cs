using UnityEngine;
using System.Collections.Generic;

/// <summary>
/// 核心生成器脚本，包含所有生成参数和 Editor 调用逻辑。
/// 用于随机生成荷花/荷叶群落，并将其智能放置在水面高度上。
/// </summary>
public class LotusGenerator : MonoBehaviour
{
    [Header("预制体设置")]
    [Tooltip("荷花和荷叶的预制体列表。")]
    public List<GameObject> plantPrefabs; 
    
    [Tooltip("生成物体的父级容器。")]
    public Transform container;           
    
    [Header("生成区域与密度")]
    [Tooltip("生成的X-Z平面区域大小。")]
    public Vector2 spawnAreaSize = new Vector2(10f, 10f); 
    
    [Tooltip("尝试放置的物体数量。")]
    public int spawnCount = 50;                          
    
    [Tooltip("物体最小间距（用于碰撞检测）。")]
    public float minSpacing = 0.5f;                      
    
    [Header("运行时组件参数 (将应用于生成的物体)")]
    [Tooltip("植物根部跟随水面目标高度的平滑阻尼时间。值越小，跟随越快。")]
    public float defaultSmoothDampTime = 0.2f; 
    
    [Tooltip("应用于 PlantWindWaver 的基础风力强度。")]
    public float defaultBaseWindStrength = 0.05f;
    
    [Tooltip("应用于 PlantWindWaver 的风力摇摆频率。")]
    public float defaultWindFrequency = 1.0f;
    
    // 脚本引用
    private FloatingObjectController waterController;
    
    void Awake()
    {
        // 尝试在运行时获取水面控制器
        waterController = FindObjectOfType<FloatingObjectController>();
        if (waterController == null)
        {
            Debug.LogWarning("场景中未找到 FloatingObjectController。生成的高度将以 LotusGenerator 的 Y 轴为准。");
        }

        // 确保容器存在
        if (container == null)
        {
            GameObject containerGO = new GameObject("GeneratedPlantsContainer");
            container = containerGO.transform;
            container.SetParent(transform.parent);
        }
    }

    /// <summary>
    /// 核心生成逻辑，在 Editor 脚本中调用。
    /// </summary>
    public void GeneratePlants()
    {
        if (plantPrefabs == null || plantPrefabs.Count == 0)
        {
            Debug.LogError("请将预制体拖入 Plant Prefabs 列表！");
            return;
        }
        
        // 确保运行时引用是最新的
        if (waterController == null)
        {
             waterController = FindObjectOfType<FloatingObjectController>();
        }

        int successCount = 0;
        int safetyBreak = spawnCount * 5; // 设置一个最大尝试次数，避免死循环
        int attempts = 0;
        
        // 确保在 Editor 模式下能正确使用 PrefabUtility
        #if UNITY_EDITOR
        while (successCount < spawnCount && attempts < safetyBreak)
        {
            attempts++;
            
            // 1. 随机位置 (在 X-Z 平面)
            Vector3 randomPos = transform.position + new Vector3(
                Random.Range(-spawnAreaSize.x / 2, spawnAreaSize.x / 2),
                0,
                Random.Range(-spawnAreaSize.y / 2, spawnAreaSize.y / 2)
            );

            // 2. 碰撞检测 (使用 OverlapSphere 检查间距)
            if (Physics.OverlapSphere(randomPos, minSpacing / 2f).Length > 0) continue;
            
            // 3. 确定 Y 轴高度 (智能放置)
            if (waterController != null)
            {
                randomPos.y = waterController.GetScaledWaterHeight(randomPos);
            }
            else
            {
                // 如果没有水面控制器，使用 LotusGenerator 物体的 Y 坐标
                randomPos.y = transform.position.y;
            }

            // 4. 实例化 (使用 PrefabUtility 确保 Editor 流程正确)
            GameObject prefabToSpawn = plantPrefabs[Random.Range(0, plantPrefabs.Count)];
            GameObject newPlant = (GameObject)UnityEditor.PrefabUtility.InstantiatePrefab(prefabToSpawn, container);
            newPlant.transform.position = randomPos;
            newPlant.transform.rotation = Quaternion.Euler(0, Random.Range(0f, 360f), 0); // 随机Y轴旋转

            // 5. 添加并初始化运行时组件
            
            // a. 浮动跟随组件
            WaterPlant floater = newPlant.GetComponent<WaterPlant>();
            if (floater == null) floater = newPlant.AddComponent<WaterPlant>();
            
            // 修复点：使用新的 smoothDampTime 属性名
            floater.smoothDampTime = defaultSmoothDampTime; 

            // b. 风力摇摆组件
            PlantWindWaver waver = newPlant.GetComponent<PlantWindWaver>();
            if (waver == null) waver = newPlant.AddComponent<PlantWindWaver>();
            
            // 随机化摇摆参数增加群落变化
            waver.windFrequency = defaultWindFrequency * Random.Range(0.9f, 1.1f);
            waver.baseWindStrength = defaultBaseWindStrength * Random.Range(0.8f, 1.2f);

            successCount++;
        }
        
        Debug.Log($"尝试生成了 {attempts} 次，成功放置了 {successCount} 个植物。");
        #else
        Debug.LogError("LotusGenerator.GeneratePlants 必须在 Unity Editor 中运行。");
        #endif
    }

    /// <summary>
    /// 用于在 Editor 中清理生成的植物。
    /// </summary>
    public void ClearPlants()
    {
        if (container == null) return;
        
        #if UNITY_EDITOR
        int count = container.childCount;
        for (int i = count - 1; i >= 0; i--)
        {
            // 使用 DestroyImmediate 确保在 Editor 模式下立即清除
            DestroyImmediate(container.GetChild(i).gameObject);
        }
        Debug.Log($"清除了 {count} 个生成的植物。");
        #endif
    }
}