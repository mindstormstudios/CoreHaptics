using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class TriggerHaptics : MonoBehaviour
{
    [SerializeField] Text autoButtonText;
    Coroutine autoRoutine;
    public void Tap()
    {
        int random = Random.Range(0, 5);
        switch(random)
        {
            case 0:
                CoreHaptics.CoreHapticsProxy.LowImpact();
                break;

            case 1:
                CoreHaptics.CoreHapticsProxy.SoftImpact();
                break;

            case 2:
                CoreHaptics.CoreHapticsProxy.MediumImpact();
                break;

            case 3:
                CoreHaptics.CoreHapticsProxy.FailureImpact();
                break;

            case 4:
                CoreHaptics.CoreHapticsProxy.SuccessImpact();
                break;

            default:
                CoreHaptics.CoreHapticsProxy.LowImpact();
                break;
        }
    }

    public void StartAuto ()
    {
        if (autoRoutine == null)
        {
            autoRoutine = StartCoroutine(AutoHaptic());
            autoButtonText.text = "Stop Auto Trigger";
        }
        else
        {
            StopCoroutine(autoRoutine);
            autoRoutine = null;
            autoButtonText.text = "Start Auto Trigger";
        }
    }

    IEnumerator AutoHaptic()
    {
        WaitForSeconds waitForSeconds = new WaitForSeconds(0.1f);
        while(true)
        {
            Tap();
            yield return waitForSeconds;
        }
    }
}
