using UnityEngine;
using System.Collections.Generic;
using Random = UnityEngine.Random;

public class LotusGenerator : MonoBehaviour
{
    [Header("Input")]
    [Tooltip("Reference to the NoiseGenerator script to get the texture data.")]
    public NoiseGenerator noiseSource;

    [Header("Flower Prefabs")]
    [Tooltip("List of full flower prefabs to be randomly selected for spawning.")]
    public List<GameObject> flowerPrefabs;

    [Header("Generation Area & Density")]
    [Tooltip("The size of the square area in world units (X and Z) where flowers will spawn.")]
    public float generationAreaSize = 20f;

    [Tooltip("Number of sample points (resolution) to check within the area.")]
    [Range(20, 200)]
    public int sampleResolution = 100;

    [Tooltip("Minimum noise value (0.0 to 1.0) required to spawn a flower.")]
    [Range(0f, 1f)]
    public float minSpawnThreshold = 0.1f;

    [Tooltip("The maximum percentage of the step size to apply as random position offset (Jitter). 0.5 = 50% deviation.")]
    [Range(0f, 0.5f)]
    public float maxJitterPercentage = 0.4f;

    [Header("Generation Settings")]
    [Tooltip("Destroy existing flowers before generating new ones.")]
    public bool destroyExisting = true;

    // --- Generation Method ---

    public void GenerateLotusField()
    {
        if (noiseSource == null || noiseSource.noiseTexture == null)
        {
            Debug.LogError("Error: Noise Source or Noise Texture is missing! Please assign the NoiseGenerator in the Inspector.");
            return;
        }

        if (flowerPrefabs == null || flowerPrefabs.Count == 0)
        {
            Debug.LogError("Error: Flower Prefabs list is empty or null! Please assign at least one prefab.");
            return;
        }

        // 1. 清理旧对象
        if (destroyExisting)
        {
            ClearGeneratedFlowers();
        }

        Texture2D noiseTexture = noiseSource.noiseTexture;
        int noiseRes = noiseTexture.width;

        float stepSize = generationAreaSize / sampleResolution;

        Vector3 containerCenter = transform.position;
        float startX = containerCenter.x - generationAreaSize / 2f;
        float startZ = containerCenter.z - generationAreaSize / 2f;

        // **修改点 1: 移除 spawnHeightY 的预先计算，Y 高度将在 SpawnFlower 中计算**

        // 2. 遍历采样点
        for (int i = 0; i < sampleResolution; i++)
        {
            for (int j = 0; j < sampleResolution; j++)
            {
                // 计算当前网格点的世界中心坐标
                float gridX = startX + i * stepSize + stepSize / 2f;
                float gridZ = startZ + j * stepSize + stepSize / 2f;

                // 3. 采样噪声图 (逻辑不变)
                float u = (float)i / sampleResolution;
                float v = (float)j / sampleResolution;

                int pixelX = Mathf.FloorToInt(u * noiseRes);
                int pixelY = Mathf.FloorToInt(v * noiseRes);

                pixelX = Mathf.Clamp(pixelX, 0, noiseRes - 1);
                pixelY = Mathf.Clamp(pixelY, 0, noiseRes - 1);

                float noiseValue = noiseTexture.GetPixel(pixelX, pixelY).r;

                // 4. 应用密度/阈值控制 (概率生成)
                if (noiseValue >= minSpawnThreshold)
                {
                    float spawnProbability = (noiseValue - minSpawnThreshold) / (1.0f - minSpawnThreshold);

                    if (Random.value < spawnProbability)
                    {
                        // 5. 添加随机偏差 (Jittering)
                        float maxJitter = stepSize * maxJitterPercentage;

                        float offsetX = Random.Range(-maxJitter, maxJitter);
                        float offsetZ = Random.Range(-maxJitter, maxJitter);

                        Vector3 spawnPositionXZ = new Vector3(
                            gridX + offsetX,
                            0, // Y 暂时设为 0，在 SpawnFlower 中根据 Prefab 调整
                            gridZ + offsetZ
                        );

                        // 6. 生成花朵
                        SpawnFlower(spawnPositionXZ);
                    }
                }
            }
        }
    }

    private void SpawnFlower(Vector3 positionXZ)
    {
        // 随机选择一个 Prefab
        int prefabIndex = Random.Range(0, flowerPrefabs.Count);
        GameObject selectedPrefab = flowerPrefabs[prefabIndex];

        if (selectedPrefab == null) return;

        // **修改点 2: Y 轴高度计算**

        // 获取容器的世界 Y 坐标
        float containerY = transform.position.y;

        // 获取 Prefab 预设的局部 Y 偏移 (即 Prefab 相对于其自身原点的 Y 坐标)
        float prefabOffsetY = selectedPrefab.transform.position.y;

        // 最终的世界 Y 坐标 = 容器 Y + Prefab 预设的 Y 偏移
        float finalYPosition = containerY + prefabOffsetY;

        // 组合最终的世界坐标
        Vector3 finalPosition = new Vector3(positionXZ.x, finalYPosition, positionXZ.z);


        // --- 旋转逻辑 (保持不变) ---

        // 获取 Prefab 预设的欧拉角
        Vector3 prefabEuler = selectedPrefab.transform.rotation.eulerAngles;

        // 随机生成绕 Y 轴（世界Z轴）的旋转角度
        float randomYRotation = Random.Range(0f, 360f);

        // 构造最终的旋转：保留 Prefab 的 X 和 Z，随机化 Y
        Quaternion finalRotation = Quaternion.Euler(
            prefabEuler.x,
            randomYRotation,
            prefabEuler.z
        );

        // 实例化花朵，并设置当前对象 (transform) 为父级 (容器)
        GameObject flower = Instantiate(selectedPrefab, finalPosition, finalRotation, transform);

        flower.name = $"Flower (Threshold:{minSpawnThreshold:F2}, X:{finalPosition.x:F1}, Z:{finalPosition.z:F1})";
    }

    // --- 清除方法 ---
    public void ClearGeneratedFlowers()
    {
        int childCount = transform.childCount;
        for (int i = childCount - 1; i >= 0; i--)
        {
            DestroyImmediate(transform.GetChild(i).gameObject);
        }
        Debug.Log($"Cleared {childCount} existing flowers from the container.");
    }
}