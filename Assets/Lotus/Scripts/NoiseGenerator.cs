using UnityEngine;

public class NoiseGenerator : MonoBehaviour
{
    [Header("Noise Settings")]
    [Tooltip("The unique seed value for the noise generation.")]
    public int seed = 0;

    [Tooltip("The scale/zoom level of the noise. Smaller values zoom out.")]
    [Range(0.01f, 10f)]
    public float scale = 1f;

    [Tooltip("The number of layers (octaves) of noise to combine.")]
    [Range(1, 8)]
    public int octaves = 4;

    [Tooltip("Controls the amplitude decay of successive octaves.")]
    [Range(0f, 1f)]
    public float persistence = 0.5f;

    [Tooltip("Controls the frequency increase of successive octaves.")]
    [Range(1f, 4f)]
    public float lacunarity = 2f;

    [Header("Texture Output")]
    [Tooltip("The resolution of the generated texture.")]
    public int textureResolution = 256;

    [HideInInspector]
    public Texture2D noiseTexture;

    void Awake()
    {
        GenerateNoiseTexture();
    }

    public void RandomizeSeed()
    {
        seed = Random.Range(int.MinValue, int.MaxValue);
    }

    public void GenerateNoiseTexture()
    {
        if (noiseTexture == null || noiseTexture.width != textureResolution)
        {
            noiseTexture = new Texture2D(textureResolution, textureResolution);
        }

        System.Random prng = new System.Random(seed);
        Vector2[] octaveOffsets = new Vector2[octaves];
        for (int i = 0; i < octaves; i++)
        {
            float offsetX = prng.Next(-100000, 100000);
            float offsetY = prng.Next(-100000, 100000);
            octaveOffsets[i] = new Vector2(offsetX, offsetY);
        }

        for (int x = 0; x < textureResolution; x++)
        {
            for (int y = 0; y < textureResolution; y++)
            {
                float amplitude = 1;
                float frequency = 1;
                float noiseHeight = 0;
                float totalAmplitude = 0;

                for (int i = 0; i < octaves; i++)
                {
                    float sampleX = (x / (float)textureResolution) * scale * frequency + octaveOffsets[i].x;
                    float sampleY = (y / (float)textureResolution) * scale * frequency + octaveOffsets[i].y;

                    float perlinValue = Mathf.PerlinNoise(sampleX, sampleY) * 2 - 1;

                    noiseHeight += perlinValue * amplitude;
                    totalAmplitude += amplitude;

                    amplitude *= persistence;
                    frequency *= lacunarity;
                }

                float finalValue = (noiseHeight / totalAmplitude) * 0.5f + 0.5f;
                noiseTexture.SetPixel(x, y, new Color(finalValue, finalValue, finalValue));
            }
        }

        noiseTexture.Apply();
    }
}