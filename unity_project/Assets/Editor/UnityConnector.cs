// Unity Scene Setup Configuration
// Location: unity_project/ProjectSettings/UnityConnector.cs

using UnityEngine;
using UnityEditor;
using System.IO;

public class UnityConnector : MonoBehaviour
{
    [MenuItem("Flutter/Export Android Module")]
    public static void ExportAndroid()
    {
        string exportPath = EditorUtility.SaveFolderPanel(
            "Export Unity Android Module",
            "",
            "unityLibrary"
        );

        if (string.IsNullOrEmpty(exportPath))
        {
            Debug.LogWarning("Export cancelled");
            return;
        }

        // Configure build settings
        BuildPlayerOptions buildOptions = new BuildPlayerOptions();
        buildOptions.scenes = new[] { "Assets/Scenes/ARBattle.unity" };
        buildOptions.locationPathName = exportPath;
        buildOptions.target = BuildTarget.Android;
        buildOptions.options = BuildOptions.AcceptExternalModificationsToPlayer;

        Debug.Log($"Exporting Android module to: {exportPath}");

        // Build
        var report = BuildPipeline.BuildPlayer(buildOptions);

        if (report.summary.result == UnityEditor.Build.Reporting.BuildResult.Succeeded)
        {
            Debug.Log($"✅ Export successful! Size: {report.summary.totalSize} bytes");
            Debug.Log($"📂 Copy '{exportPath}' to 'fitness_game_app/android/unityLibrary/'");
            EditorUtility.DisplayDialog(
                "Export Complete",
                $"Android module exported!\n\nNext steps:\n1. Copy '{exportPath}' to 'fitness_game_app/android/unityLibrary/'\n2. Update android/settings.gradle",
                "OK"
            );
        }
        else
        {
            Debug.LogError($"❌ Export failed: {report.summary.result}");
        }
    }

    [MenuItem("Flutter/Export iOS Module")]
    public static void ExportIOS()
    {
        string exportPath = EditorUtility.SaveFolderPanel(
            "Export Unity iOS Module",
            "",
            "UnityLibrary"
        );

        if (string.IsNullOrEmpty(exportPath))
        {
            Debug.LogWarning("Export cancelled");
            return;
        }

        BuildPlayerOptions buildOptions = new BuildPlayerOptions();
        buildOptions.scenes = new[] { "Assets/Scenes/ARBattle.unity" };
        buildOptions.locationPathName = exportPath;
        buildOptions.target = BuildTarget.iOS;
        buildOptions.options = BuildOptions.AcceptExternalModificationsToPlayer;

        Debug.Log($"Exporting iOS module to: {exportPath}");

        var report = BuildPipeline.BuildPlayer(buildOptions);

        if (report.summary.result == UnityEditor.Build.Reporting.BuildResult.Succeeded)
        {
            Debug.Log($"✅ Export successful!");
            Debug.Log($"📂 Copy '{exportPath}' to 'fitness_game_app/ios/UnityLibrary/'");
            EditorUtility.DisplayDialog(
                "Export Complete",
                $"iOS module exported!\n\nNext steps:\n1. Copy '{exportPath}' to 'fitness_game_app/ios/UnityLibrary/'\n2. Update ios/Podfile",
                "OK"
            );
        }
        else
        {
            Debug.LogError($"❌ Export failed: {report.summary.result}");
        }
    }

    [MenuItem("Flutter/Configure AR Settings")]
    public static void ConfigureAR()
    {
        Debug.Log("Configuring AR Foundation settings...");

        // Set required XR settings
        PlayerSettings.Android.minSdkVersion = AndroidSdkVersions.AndroidApiLevel24;
        PlayerSettings.iOS.targetOSVersionString = "11.0";

        Debug.Log("✅ AR settings configured");
        EditorUtility.DisplayDialog(
            "AR Configuration",
            "AR Foundation settings applied:\n\n• Android: Min SDK 24 (ARCore)\n• iOS: Min version 11.0 (ARKit)",
            "OK"
        );
    }
}
