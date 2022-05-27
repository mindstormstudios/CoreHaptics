using UnityEngine;
using UnityEditor;
using UnityEditor.Callbacks;
using System.IO;
using UnityEditor.iOS.Xcode;

public class CoreHapticsPostProcess : MonoBehaviour
{
    [PostProcessBuildAttribute(int.MaxValue)]
    public static void OnPostProcessBuild(BuildTarget buildTarget, string buildPath)
    {
#if UNITY_IOS
        string xcodeProjectPath = buildPath + "/Unity-iPhone.xcodeproj/project.pbxproj";
        PBXProject xcodeProject = new PBXProject();
        xcodeProject.ReadFromFile(xcodeProjectPath);
        string xcodeTarget = xcodeProject.GetUnityFrameworkTargetGuid();

        //CoreHaptics framework
        xcodeProject.AddFrameworkToProject(xcodeTarget, "CoreHaptics.framework", true);

        xcodeProject.WriteToFile(xcodeProjectPath);
#endif
    }
}
