using UnityEngine;

[ExecuteAlways]
public class Reflection : MonoBehaviour
{
    public Transform original;
    public float planeY = 0f;
    public float pivotOffsetY = 0f;

    void Update()
    {
        //    [ 1  0  0   0 ]
        //    [ 0 -1  0  m13]
        //    [ 0  0  1   0 ]
        //    [ 0  0  0   1 ]

        float pivotWorldY = original.position.y + pivotOffsetY;
        Matrix4x4 M = Matrix4x4.identity;
        M.m11 = -1f;
        M.m13 = 2f * (planeY - pivotWorldY);

        Matrix4x4 W = original.localToWorldMatrix;
        Matrix4x4 MW = M * W;

        transform.position = MW.GetColumn(3);
/*        transform.rotation = MW.rotation;
        transform.localScale = MW.lossyScale;*/ 

        Vector3 origLocalScale = original.localScale;
        transform.localScale = new Vector3(
            origLocalScale.x,
            -origLocalScale.y,
            origLocalScale.z
        );
    }

}
