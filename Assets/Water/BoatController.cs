using UnityEngine;

public class BoatController : MonoBehaviour
{
    [Header("移动设置")]
    public float moveSpeed = 10f;          // 基础移动速度
    public float rotationSpeed = 50f;      // 旋转速度
    public float boostMultiplier = 2f;     // 加速倍数
    
    [Header("上下起伏设置")]
    public float bobSpeed = 1f;            // 起伏速度
    public float bobHeight = 0.3f;         // 起伏高度
    
    private float originalY;               // 初始Y坐标
    private float bobTimer;                // 起伏计时器

    void Start()
    {
        // 记录船只的初始Y坐标
        originalY = transform.position.y;
    }

    void Update()
    {
        HandleMovement();
        HandleBobbing();
    }

    void HandleMovement()
    {
        // 获取输入
        float horizontal = Input.GetAxis("Horizontal"); // A/D 或 左右箭头
        float vertical = Input.GetAxis("Vertical");     // W/S 或 上下箭头
        bool isBoosting = Input.GetKey(KeyCode.Space);  // 空格加速

        // 计算当前速度（是否加速）
        float currentSpeed = isBoosting ? moveSpeed * boostMultiplier : moveSpeed;

        // 前进/后退移动
        Vector3 moveDirection = transform.forward * vertical;
        transform.position += moveDirection * currentSpeed * Time.deltaTime;

        // 左右旋转
        float rotation = horizontal * rotationSpeed * Time.deltaTime;
        transform.Rotate(0, rotation, 0);
    }

    void HandleBobbing()
    {
        // 使用正弦波创建上下起伏效果
        bobTimer += Time.deltaTime * bobSpeed;
        float newY = originalY + Mathf.Sin(bobTimer) * bobHeight;
        
        // 只更新Y坐标，保持X和Z坐标不变
        Vector3 newPosition = transform.position;
        newPosition.y = newY;
        transform.position = newPosition;
    }
}