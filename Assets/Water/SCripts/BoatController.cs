using UnityEngine;

public class BoatController : MonoBehaviour
{
    [Header("移动设置")]
    public float moveSpeed = 10f;          // 基础移动速度
    public float rotationSpeed = 50f;      // 旋转速度
    public float boostMultiplier = 2f;     // 加速倍数
    
    // 移除了所有与 Y 轴起伏相关的字段

    void Update()
    {
        // 船只现在只处理 X 和 Z 轴的移动和旋转。
        HandleMovement();
        
        // Y 轴的高度更新将由 WaterPlant.cs (或其他浮动组件) 负责。
    }

    void HandleMovement()
    {
        // 获取输入
        float horizontal = Input.GetAxis("Horizontal"); 
        float vertical = Input.GetAxis("Vertical");     
        bool isBoosting = Input.GetKey(KeyCode.Space);  

        // 计算当前速度
        float currentSpeed = isBoosting ? moveSpeed * boostMultiplier : moveSpeed;

        // 前进/后退移动 (只改变 X/Z 投影)
        Vector3 moveDirection = transform.forward * vertical;
        transform.position += moveDirection * currentSpeed * Time.deltaTime;

        // 左右旋转
        float rotation = horizontal * rotationSpeed * Time.deltaTime;
        transform.Rotate(0, rotation, 0);
    }

    
}