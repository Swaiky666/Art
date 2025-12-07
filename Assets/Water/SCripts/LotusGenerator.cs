using UnityEngine;
using System.Collections.Generic;
// 必须在 Editor 脚本中运行
// #if UNITY_EDITOR 必须保留

/// <summary>
/// 核心生成器脚本，包含所有生成参数和 Editor 调用逻辑。
/// 使用 Perlin 噪声来影响 XZ 平面的生成位置，实现群落分布。
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
    
    [Header("噪声影响设置")]
    [Tooltip("Perlin噪声的缩放因子。值越小，群落越大，过渡越平滑。")]
    public float noiseScale = 0.1f; // 推荐 0.1 到 0.5 之间的较小值 
    
    [Tooltip("生成物体的最小噪声阈值。噪声值高于此阈值才允许生成。")]
    [Range(0f, 1f)]
    public float noiseThreshold = 0.5f;
    
    [Header("运行时组件参数")]
    [Tooltip("用于初始化 WaterPlant 组件的平滑阻尼时间。")]
    public float defaultSmoothDampTime = 0.2f; 
    
    // 噪声的随机偏移量，确保每次生成都是不同的图案
    private float noiseOffsetX;
    private float noiseOffsetZ;

    void Awake()
    {
        // 确保容器存在
        if (container == null)
        {
            GameObject containerGO = new GameObject("GeneratedPlantsContainer");
            container = containerGO.transform;
            container.SetParent(transform.parent);
        }
        
        // 初始化噪声偏移量，使每次生成都有一个独特的图案
        noiseOffsetX = Random.Range(0f, 1000f);
        noiseOffsetZ = Random.Range(0f, 1000f);
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
        
        // 固定Y轴高度为生成器自身的高度
        float fixedYPosition = transform.position.y;
        
        int successCount = 0;
        int safetyBreak = spawnCount * 50; // 提高尝试次数，因为噪声筛选会丢弃大量尝试
        int attempts = 0;
        
        #if UNITY_EDITOR
        while (successCount < spawnCount && attempts < safetyBreak)
        {
            attempts++;
            
            // 1. 随机采样一个 X-Z 区域内的坐标
            float randomX = Random.Range(-spawnAreaSize.x / 2, spawnAreaSize.x / 2);
            float randomZ = Random.Range(-spawnAreaSize.y / 2, spawnAreaSize.y / 2);
            
            // 2. 计算 Perlin 噪声值
            // 我们基于生成器世界位置加上随机偏移，再乘以 noiseScale
            float noiseCoordX = (transform.position.x + randomX) * noiseScale + noiseOffsetX;
            float noiseCoordZ = (transform.position.z + randomZ) * noiseScale + noiseOffsetZ;
            
            float noiseValue = Mathf.PerlinNoise(noiseCoordX, noiseCoordZ);
            
            // 3. 噪声阈值判断：如果噪声值太低 (低于阈值)，跳过这次尝试
            if (noiseValue < noiseThreshold) continue;
            
            // --- 噪声测试通过，继续定位 ---
            
            // 4. 确定最终位置
            Vector3 randomPos = transform.position + new Vector3(
                randomX,
                fixedYPosition - transform.position.y, // 确保 Y 轴是正确的绝对值
                randomZ
            );

            // 5. 碰撞检测 (使用 OverlapSphere 检查间距)
            // 注意：这可能在 Editor 中需要场景中有 Colliders 才能工作
            if (Physics.OverlapSphere(randomPos, minSpacing / 2f).Length > 0) continue;
            
            // 6. 实例化
            GameObject prefabToSpawn = plantPrefabs[Random.Range(0, plantPrefabs.Count)];
            GameObject newPlant = (GameObject)UnityEditor.PrefabUtility.InstantiatePrefab(prefabToSpawn, container);
            
            // 设置位置
            newPlant.transform.position = randomPos;

            // --- 7. 旋转逻辑 (X/Y不变, Z随机) ---
            
            // a. 获取 Prefab 自身的预设旋转
            Quaternion originalRotation = newPlant.transform.localRotation; 
            // b. 将原始旋转转换为 Euler 角度
            Vector3 originalEuler = originalRotation.eulerAngles;

            // c. 创建随机 Z 轴角度 (0到360度)
            float randomZAngle = Random.Range(0f, 360f);

            // d. 合成新的旋转 Quaternion：保留 X 和 Y，替换 Z
            newPlant.transform.localRotation = Quaternion.Euler(
                originalEuler.x,         // 保留 Prefab 自身的 X 轴旋转
                originalEuler.y,         // 保留 Prefab 自身的 Y 轴旋转
                randomZAngle             // 替换为完全随机的 Z 轴旋转 (0-360)
            );
            
            // --- 旋转逻辑结束 ---

            // 8. 添加并初始化运行时组件
            
            // a. 浮动跟随组件
            WaterPlant floater = newPlant.GetComponent<WaterPlant>();
            if (floater == null) floater = newPlant.AddComponent<WaterPlant>();
            floater.smoothDampTime = defaultSmoothDampTime; 
            
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