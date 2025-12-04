using UnityEngine;

public class ItemDestroy : MonoBehaviour
{
    [Header("销毁设置")]
    public float lifeTime = 5f;
    
    [Header("缩放设置")]
    public float startScale = 0.1f;
    public float targetScale = 1f;
    public float scaleSpeed = 2f;
    
    [Header("透明度设置")]
    public float fadeStartTime = 3f;
    public float fadeEndTime = 5f;
    public bool fadeOut = true;
    
    private float timer = 0f;
    private Material[] materials;
    private Color[] originalColors;

    void Start()
    {
        transform.localScale = Vector3.one * startScale;
        
        if (fadeEndTime > lifeTime)
        {
            fadeEndTime = lifeTime;
        }
        
        Renderer renderer = GetComponent<Renderer>();
        if (renderer != null)
        {
            materials = renderer.materials;
            originalColors = new Color[materials.Length];
            
            // 保存每个材质的原始颜色
            for (int i = 0; i < materials.Length; i++)
            {
                if (materials[i].HasProperty("_Color"))
                {
                    originalColors[i] = materials[i].GetColor("_Color");
                    Debug.Log($"✓ Material {materials[i].name} 找到_Color属性");
                }
                else
                {
                    originalColors[i] = Color.white;
                    Debug.LogWarning($"✗ Material {materials[i].name} 没有_Color属性");
                }
            }
        }
    }

    void Update()
    {
        timer += Time.deltaTime;
        HandleScaling();
        
        if (fadeOut)
        {
            HandleFading();
        }
        
        if (timer >= lifeTime)
        {
            Destroy(gameObject);
        }
    }

    void HandleScaling()
    {
        float currentScale = Mathf.Lerp(startScale, targetScale, timer * scaleSpeed / lifeTime);
        transform.localScale = Vector3.one * currentScale;
    }

    void HandleFading()
    {
        if (materials == null) return;
        
        float alpha = 1f;
        
        // 计算当前的alpha值
        if (timer < fadeStartTime)
        {
            alpha = 1f;
        }
        else if (timer >= fadeStartTime && timer < fadeEndTime)
        {
            float fadeDuration = fadeEndTime - fadeStartTime;
            float fadeProgress = (timer - fadeStartTime) / fadeDuration;
            alpha = Mathf.Lerp(1f, 0f, fadeProgress);
        }
        else
        {
            alpha = 0f;
        }
        
        // 应用到所有材质
        for (int i = 0; i < materials.Length; i++)
        {
            if (materials[i].HasProperty("_Color"))
            {
                Color newColor = originalColors[i];
                newColor.a = alpha;
                materials[i].SetColor("_Color", newColor);
            }
        }
    }
}