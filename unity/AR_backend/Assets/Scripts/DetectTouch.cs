using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using FlutterUnityIntegration;

public class DetectTouch : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {
        
    }
    // TODO: ここでFlutterへメッセージの送信を行う
    public void onClickAct() 
    {
        gameObject.SetActive(false);
        UnityMessageManager.Instance.SendMessageToFlutter(gameObject.name);
    }
}