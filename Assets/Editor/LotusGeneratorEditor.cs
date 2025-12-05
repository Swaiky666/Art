#if UNITY_EDITOR
using UnityEditor;
using UnityEngine;

/// <summary>
/// LotusGenerator 的定制 Inspector 界面。
/// 必须放在名为 "Editor" 的文件夹内。
/// </summary>
[CustomEditor(typeof(LotusGenerator))]
public class LotusGeneratorEditor : Editor
{
    public override void OnInspectorGUI()
    {
        // 绘制 LotusGenerator 脚本中的公共变量
        DrawDefaultInspector();

        LotusGenerator generator = (LotusGenerator)target;

        GUILayout.Space(15);
        
        // --- 随机生成按钮 ---
        GUI.backgroundColor = Color.green;
        if (GUILayout.Button("随机生成植物群落"))
        {
            if (Application.isPlaying)
            {
                Debug.LogWarning("请停止播放模式后再执行生成操作，以确保持久化修改。");
            }
            else
            {
                generator.GeneratePlants();
            }
        }

        GUILayout.Space(5);
        
        // --- 清除所有按钮 ---
        GUI.backgroundColor = Color.red;
        if (GUILayout.Button("清除所有生成的植物"))
        {
            if (Application.isPlaying)
            {
                Debug.LogWarning("请停止播放模式后再清理场景物体。");
            }
            else
            {
                if (generator.container != null && generator.container.childCount > 0)
                {
                    // 确认对话框
                    if (EditorUtility.DisplayDialog("确认清理", 
                        $"确定要清理容器 '{generator.container.name}' 中的 {generator.container.childCount} 个物体吗？", 
                        "确认清理", "取消"))
                    {
                        generator.ClearPlants();
                    }
                }
                else
                {
                    Debug.Log("容器为空，无需清理。");
                }
            }
        }
        GUI.backgroundColor = Color.white;
    }
}
#endif