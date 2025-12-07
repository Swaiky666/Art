using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(NoiseGenerator))]
public class NoiseGeneratorEditor : Editor
{
    private NoiseGenerator generator;

    private void OnEnable()
    {
        generator = (NoiseGenerator)target;
        generator.GenerateNoiseTexture();
    }

    public override void OnInspectorGUI()
    {
        DrawPropertiesExcluding(serializedObject, new string[] { "m_Script", "noiseTexture" });

        // Seed Management Buttons
        EditorGUILayout.Space(10);
        EditorGUILayout.LabelField("Seed Management", EditorStyles.boldLabel);

        if (GUILayout.Button("Apply Seed"))
        {
            generator.GenerateNoiseTexture();
        }

        if (GUILayout.Button("Randomize Seed (and apply)"))
        {
            generator.RandomizeSeed();
            generator.GenerateNoiseTexture();
        }

        // Texture Preview
        EditorGUILayout.Space(20);
        EditorGUILayout.LabelField("Noise Texture Preview", EditorStyles.boldLabel);

        if (generator.noiseTexture != null)
        {
            float previewSize = EditorGUIUtility.currentViewWidth - 40;
            Rect rect = GUILayoutUtility.GetRect(previewSize, previewSize);
            EditorGUI.DrawPreviewTexture(rect, generator.noiseTexture);
        }

        // Listen for changes and force refresh
        if (GUI.changed)
        {
            generator.GenerateNoiseTexture();
            EditorUtility.SetDirty(generator);
            Repaint();
        }
    }
}