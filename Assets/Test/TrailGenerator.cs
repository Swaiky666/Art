using UnityEngine;
using System.Collections.Generic;

public class TrailGenerator : MonoBehaviour
{
    [SerializeField] private List<Transform> targetTransforms = new List<Transform>();
    [SerializeField] private GameObject prefabToSpawn;
    [SerializeField] private float yOffset = 0f;
    [SerializeField] private float movementThreshold = 0.01f; // 移动阈值，避免浮点误差
    
    [Header("生成间隔设置")]
    [SerializeField] private float baseSpawnInterval = 0.3f; // 基础生成间隔（速度为0时）
    [SerializeField] private float minSpawnInterval = 0.05f; // 最小生成间隔（速度很快时）
    [SerializeField] private float speedInfluenceWeight = 0.1f; // 速度影响权重（越大速度影响越明显）
    [SerializeField] private float speedSmoothTime = 0.1f; // 速度平滑时间，避免抖动

    private Dictionary<Transform, Vector3> lastPositions = new Dictionary<Transform, Vector3>();
    private Dictionary<Transform, float> timeSinceLastSpawn = new Dictionary<Transform, float>();
    private Dictionary<Transform, float> currentSpeeds = new Dictionary<Transform, float>();
    private Dictionary<Transform, float> smoothVelocity = new Dictionary<Transform, float>(); // 用于平滑速度

    private void Start()
    {
        // 初始化每个transform的追踪数据
        foreach (Transform target in targetTransforms)
        {
            if (target != null)
            {
                lastPositions[target] = target.position;
                timeSinceLastSpawn[target] = 0f;
                currentSpeeds[target] = 0f;
                smoothVelocity[target] = 0f;
            }
        }
    }

    private void Update()
    {
        float deltaTime = Time.deltaTime; // 存储到局部变量
        
        foreach (Transform target in targetTransforms)
        {
            if (target == null)
                continue;

            // 计算移动距离和速度
            float distanceMoved = Vector3.Distance(target.position, lastPositions[target]);
            float instantSpeed = distanceMoved / deltaTime;
            
            // 平滑速度，避免抖动
            float smoothVel = smoothVelocity[target];
            float smoothedSpeed = Mathf.SmoothDamp(
                currentSpeeds[target], 
                instantSpeed, 
                ref smoothVel, 
                speedSmoothTime
            );
            currentSpeeds[target] = smoothedSpeed;
            smoothVelocity[target] = smoothVel;
            
            bool isMoving = distanceMoved > movementThreshold;

            if (isMoving)
            {
                timeSinceLastSpawn[target] += deltaTime;
                
                // 根据速度动态计算生成间隔
                float dynamicInterval = CalculateSpawnInterval(currentSpeeds[target]);

                if (timeSinceLastSpawn[target] >= dynamicInterval)
                {
                    SpawnPrefab(target);
                    timeSinceLastSpawn[target] = 0f;
                }

                lastPositions[target] = target.position;
            }
            else
            {
                timeSinceLastSpawn[target] = 0f;
                currentSpeeds[target] = 0f;
                smoothVelocity[target] = 0f;
            }
        }
    }

    // 根据速度计算生成间隔
    private float CalculateSpawnInterval(float speed)
    {
        // 速度越快，间隔越短
        // 使用公式: interval = baseInterval / (1 + speed * weight)
        float interval = baseSpawnInterval / (1f + speed * speedInfluenceWeight);
        
        // 限制在最小间隔和基础间隔之间
        return Mathf.Clamp(interval, minSpawnInterval, baseSpawnInterval);
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
            currentSpeeds[newTarget] = 0f;
            smoothVelocity[newTarget] = 0f;
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
            currentSpeeds.Remove(target);
            smoothVelocity.Remove(target);
        }
    }

    // 清空所有目标
    public void ClearTargets()
    {
        targetTransforms.Clear();
        lastPositions.Clear();
        timeSinceLastSpawn.Clear();
        currentSpeeds.Clear();
        smoothVelocity.Clear();
    }

    // Debug：在Scene视图中显示当前速度和间隔
    private void OnDrawGizmosSelected()
    {
        if (!Application.isPlaying) return;

        foreach (Transform target in targetTransforms)
        {
            if (target == null) continue;

            float speed = currentSpeeds.ContainsKey(target) ? currentSpeeds[target] : 0f;
            float interval = CalculateSpawnInterval(speed);

            // 在Scene视图中显示信息
            #if UNITY_EDITOR
            UnityEditor.Handles.Label(
                target.position + Vector3.up * 2f,
                $"Speed: {speed:F2}\nInterval: {interval:F3}s"
            );
            #endif
        }
    }
}