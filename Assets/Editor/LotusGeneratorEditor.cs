using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(LotusGenerator))]
public class LotusGeneratorEditor : Editor
{
    public override void OnInspectorGUI()
    {
        DrawDefaultInspector();

        LotusGenerator generator = (LotusGenerator)target;

        EditorGUILayout.Space(15);

        // 1. 清除按钮
        GUI.backgroundColor = Color.red;
        if (GUILayout.Button("Clear Generated Flowers"))
        {
            generator.ClearGeneratedFlowers();
        }
        GUI.backgroundColor = Color.white;

        EditorGUILayout.Space(10);

        // 2. 生成按钮
        if (GUILayout.Button("Generate Lotus Field"))
        {
            generator.GenerateLotusField();
        }
    }
}