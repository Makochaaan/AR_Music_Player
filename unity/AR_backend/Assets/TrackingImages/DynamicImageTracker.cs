// using UnityEngine;
// using UnityEngine.XR.ARFoundation;
// using UnityEngine.XR.ARSubsystems;
// using System.Collections;

// public class DynamicImageTracker : MonoBehaviour
// {
//     [SerializeField] ARTrackedImageManager trackedImageManager;
//     [SerializeField] Texture2D newImage;  // 動的に追加したい画像
//     [SerializeField] string imageName;  // 画像の名前
//     [SerializeField] float widthInMeters = 0.1f;  // 画像の物理的な幅をメートル単位で設定

//     void Start()
//     {
//         if (trackedImageManager.referenceLibrary is MutableRuntimeReferenceImageLibrary mutableLibrary)
//         {
//             StartCoroutine(AddImageToLibrary(mutableLibrary));
//         }
//         else
//         {
//             Debug.LogError("Reference Library is not mutable.");
//         }
//     }

//     IEnumerator AddImageToLibrary(MutableRuntimeReferenceImageLibrary mutableLibrary)
//     {
//         // 新しい画像を追加する
//         var job = mutableLibrary.ScheduleAddImageWithValidationJob(newImage, imageName, widthInMeters);

//         if (job.status == AddReferenceImageJobStatus.Success)
//         {
//             Debug.Log($"Image '{imageName}' added successfully.");
//         }
//         else
//         {
//             Debug.LogError($"Failed to add image '{imageName}': {job.status}");
//         }
//     }
// }

