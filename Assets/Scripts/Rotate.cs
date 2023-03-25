using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Rotate : MonoBehaviour
{
    public Vector3 m_Speed = Vector3.one * 10;

    private float m_ElapsedTime = 0f;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        m_ElapsedTime += Time.deltaTime;
        transform.rotation = Quaternion.Euler(m_ElapsedTime * m_Speed);
    }
}
