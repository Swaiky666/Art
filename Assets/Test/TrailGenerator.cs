using UnityEngine;
using System.Collections.Generic;

public class TrailGenerator : MonoBehaviour
{
    [SerializeField] private List<Transform> targetTransforms = new List<Transform>();
    [SerializeField] private GameObject prefabToSpawn;
    [SerializeField] private float yOffset = 0f;
    [SerializeField] private float movementThreshold = 0.01f; // 移动阈值，避免浮点误差
    [SerializeField] private float spawnInterval = 0.1f; // 生成间隔时间

    private Dictionary<Transform, Vector3> lastPositions = new Dictionary<Transform, Vector3>();
    private Dictionary<Transform, float> timeSinceLastSpawn = new Dictionary<Transform, float>();

    private void Start()
    {
        // 初始化每个transform的追踪数据
        foreach (Transform target in targetTransforms)
        {
            if (target != null)
            {
                lastPositions[target] = target.position;
                timeSinceLastSpawn[target] = 0f;
            }
        }
    }

    private void Update()
    {
        foreach (Transform target in targetTransforms)
        {
            if (target == null)
                continue;

            // 检测是否在移动
            float distanceMoved = Vector3.Distance(target.position, lastPositions[target]);
            bool isMoving = distanceMoved > movementThreshold;

            if (isMoving)
            {
                timeSinceLastSpawn[target] += Time.deltaTime;

                if (timeSinceLastSpawn[target] >= spawnInterval)
                {
                    SpawnPrefab(target);
                    timeSinceLastSpawn[target] = 0f;
                }

                lastPositions[target] = target.position;
            }
            else
            {
                timeSinceLastSpawn[target] = 0f;
            }
        }
    }

    private void SpawnPrefab(Transform target)
    {
        if (prefabToSpawn == null)
        {
            Debug.LogWarning("Prefab to spawn is not assigned!");
            return;
        }

        // 获取target的x和z位置，y轴使用yOffset
        Vector3 spawnPosition = new Vector3(
            target.position.x,
            yOffset,
            target.position.z
        );

        // 生成prefab
        Instantiate(prefabToSpawn, spawnPosition, Quaternion.identity);
    }

    // 添加新的目标transform
    public void AddTargetTransform(Transform newTarget)
    {
        if (newTarget != null && !targetTransforms.Contains(newTarget))
        {
            targetTransforms.Add(newTarget);
            lastPositions[newTarget] = newTarget.position;
            timeSinceLastSpawn[newTarget] = 0f;
        }
    }

    // 移除目标transform
    public void RemoveTargetTransform(Transform target)
    {
        if (targetTransforms.Contains(target))
        {
            targetTransforms.Remove(target);
            lastPositions.Remove(target);
            timeSinceLastSpawn.Remove(target);
        }
    }

    // 清空所有目标
    public void ClearTargets()
    {
        targetTransforms.Clear();
        lastPositions.Clear();
        timeSinceLastSpawn.Clear();
    }
}