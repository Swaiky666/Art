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

        // 1. Clear old objects
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

        // **Modification 1: Removed pre-calculation of spawnHeightY. Y height will be calculated in SpawnFlower.**

        // 2. Iterate through sample points
        for (int i = 0; i < sampleResolution; i++)
        {
            for (int j = 0; j < sampleResolution; j++)
            {
                // Calculate the world center coordinates of the current grid point
                float gridX = startX + i * stepSize + stepSize / 2f;
                float gridZ = startZ + j * stepSize + stepSize / 2f;

                // 3. Sample the noise map (logic remains unchanged)
                float u = (float)i / sampleResolution;
                float v = (float)j / sampleResolution;

                int pixelX = Mathf.FloorToInt(u * noiseRes);
                int pixelY = Mathf.FloorToInt(v * noiseRes);

                pixelX = Mathf.Clamp(pixelX, 0, noiseRes - 1);
                pixelY = Mathf.Clamp(pixelY, 0, noiseRes - 1);

                float noiseValue = noiseTexture.GetPixel(pixelX, pixelY).r;

                // 4. Apply density/threshold control (probabilistic spawning)
                if (noiseValue >= minSpawnThreshold)
                {
                    float spawnProbability = (noiseValue - minSpawnThreshold) / (1.0f - minSpawnThreshold);

                    if (Random.value < spawnProbability)
                    {
                        // 5. Add random offset (Jittering)
                        float maxJitter = stepSize * maxJitterPercentage;

                        float offsetX = Random.Range(-maxJitter, maxJitter);
                        float offsetZ = Random.Range(-maxJitter, maxJitter);

                        Vector3 spawnPositionXZ = new Vector3(
                            gridX + offsetX,
                            0, // Y temporarily set to 0, adjusted based on Prefab in SpawnFlower
                            gridZ + offsetZ
                        );

                        // 6. Spawn the flower
                        SpawnFlower(spawnPositionXZ);
                    }
                }
            }
        }
    }

    private void SpawnFlower(Vector3 positionXZ)
    {
        // Randomly select a Prefab
        int prefabIndex = Random.Range(0, flowerPrefabs.Count);
        GameObject selectedPrefab = flowerPrefabs[prefabIndex];

        if (selectedPrefab == null) return;

        // **Modification 2: Y-axis height calculation**

        // Get the world Y coordinate of the container
        float containerY = transform.position.y;

        // Get the local Y offset of the Prefab (i.e., the Y coordinate of the Prefab relative to its own origin)
        float prefabOffsetY = selectedPrefab.transform.position.y;

        // Final world Y coordinate = Container Y + Prefab Y offset
        float finalYPosition = containerY + prefabOffsetY;

        // Combine the final world coordinates
        Vector3 finalPosition = new Vector3(positionXZ.x, finalYPosition, positionXZ.z);


        // --- Rotation Logic (remains unchanged) ---

        // Get the Euler angles of the Prefab
        Vector3 prefabEuler = selectedPrefab.transform.rotation.eulerAngles;

        // Randomly generate rotation angle around the Y-axis (World Z-axis)
        float randomYRotation = Random.Range(0f, 360f);

        // Construct the final rotation: keep Prefab's X and Z, randomize Y
        Quaternion finalRotation = Quaternion.Euler(
            prefabEuler.x,
            randomYRotation,
            prefabEuler.z
        );

        // Instantiate the flower, and set the current object (transform) as the parent (container)
        GameObject flower = Instantiate(selectedPrefab, finalPosition, finalRotation, transform);

        flower.name = $"Flower (Threshold:{minSpawnThreshold:F2}, X:{finalPosition.x:F1}, Z:{finalPosition.z:F1})";
    }

    // --- Cleanup Method ---
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