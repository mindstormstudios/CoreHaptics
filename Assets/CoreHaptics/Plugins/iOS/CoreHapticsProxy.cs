using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;

using UnityEngine;

namespace CoreHaptics
{
    public static class CoreHapticsProxy
    {
		public static bool IsSupported => _isSupported;

		private static readonly bool _isSupported;

#if !UNITY_EDITOR && UNITY_IOS
        [DllImport("__Internal")]
        public static extern bool CoreHapticsIsSupported();

        [DllImport("__Internal")]
        public static extern void LowImpact();
        
        [DllImport("__Internal")]
        public static extern void MediumImpact();
        
        [DllImport("__Internal")]
        public static extern void SoftImpact();
        
        [DllImport("__Internal")]
        public static extern void SuccessImpact();
        
        [DllImport("__Internal")]
        public static extern void FailureImpact();

#else
		public static bool CoreHapticsIsSupported()
		{
			return false;
		}

		public static void LowImpact()
        {
            Debug.Log("LowHapticImpact");
        }

        public static void MediumImpact()
        {
            Debug.Log("MediumHapticImpact");
        }

        public static void SoftImpact()
        {
            Debug.Log("SoftImpact");
        }

        public static void SuccessImpact()
        {
            Debug.Log("SuccessImpact");
        }

        public static void FailureImpact()
        {
            Debug.Log("FailureImpact");
        }
#endif

        static CoreHapticsProxy()
		{
#if !UNITY_EDITOR && UNITY_IOS
			_isSupported = Application.platform == RuntimePlatform.IPhonePlayer && CoreHapticsIsSupported();		
#else
            _isSupported = false;
#endif
		}
	}
}