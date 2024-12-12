using System.IO;
using UnityEngine;
using UnityEngine.XR.ARFoundation;
using UnityEngine.XR.ARSubsystems;
using System.Collections.Generic;

public class DynamicImageTracker : MonoBehaviour
{
    [SerializeField]
    private ARTrackedImageManager trackedImageManager;

    [SerializeField]
    private GameObject spherePrefab;

    private Dictionary<string, GameObject> trackedObjects = new Dictionary<string, GameObject>();

    private void OnEnable()
    {
        trackedImageManager.trackedImagesChanged += OnTrackedImagesChanged;
    }

    private void OnDisable()
    {
        trackedImageManager.trackedImagesChanged -= OnTrackedImagesChanged;
    }

    // flutter側からデータベースに登録されている画像パスを渡し登録するメソッド
    // imagePathを渡し、その画像をトラッキングするように登録する
    public void RegisterImagePath(string imagePath)
    {
        string fullPath = GetFullPath(imagePath);
        Debug.Log($"Received image path: {fullPath}");

        if (!File.Exists(fullPath))
        {
            Debug.LogError("Image file not found at path: " + fullPath);
            return;
        }

        var imageBytes = File.ReadAllBytes(fullPath);
        var texture = new Texture2D(2, 2);
        if (texture.LoadImage(imageBytes))
        {
            Debug.Log("Texture loaded successfully");

            var library = trackedImageManager.referenceLibrary as MutableRuntimeReferenceImageLibrary;
            if (library != null)
            {
                library.ScheduleAddImageWithValidationJob(texture, Path.GetFileNameWithoutExtension(fullPath), 0.1f); // 例: 物理幅10cm
                Debug.Log("Image added to tracking library");
            }
            else
            {
                Debug.LogError("MutableRuntimeReferenceImageLibrary not available");
            }
        }
        else
        {
            Debug.LogError("Failed to load texture from image bytes");
        }
    }

    private string GetFullPath(string imagePath)
    {
        string fullPath;

        fullPath = Path.Combine(Application.persistentDataPath, imagePath);

        return fullPath;
    }

    private void OnTrackedImagesChanged(ARTrackedImagesChangedEventArgs eventArgs)
    {
        foreach (var trackedImage in eventArgs.added)
        {
            UpdateTrackedImage(trackedImage);
        }

        foreach (var trackedImage in eventArgs.updated)
        {
            UpdateTrackedImage(trackedImage);
        }
    }

    private void UpdateTrackedImage(ARTrackedImage trackedImage)
    {
        if (trackedImage.trackingState == TrackingState.Tracking)
        {
            string objectName = trackedImage.referenceImage.name;
            Debug.Log($"Tracked image: {objectName}");

            if (!trackedObjects.ContainsKey(objectName))
            {
                GameObject newObject = Instantiate(spherePrefab);
                newObject.name = objectName;
                trackedObjects[objectName] = newObject;
            }

            GameObject trackedObject = trackedObjects[objectName];
            trackedObject.transform.position = trackedImage.transform.position;
            trackedObject.transform.rotation = trackedImage.transform.rotation;
            trackedObject.SetActive(true);
        }
        else if (trackedImage.trackingState == TrackingState.None)
        {
            string objectName = trackedImage.referenceImage.name;
            if (trackedObjects.ContainsKey(objectName))
            {
                Destroy(trackedObjects[objectName]);
                trackedObjects.Remove(objectName);
            }
        }
    }
}