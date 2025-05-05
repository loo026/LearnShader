using System;
using UnityEngine;
using UnityEngine.UI;

[ExecuteAlways]
public class MatrixController : MonoBehaviour
{
    public Material targetMaterial;
    private Matrix4x4 transformMatrix;

    void Update()
    {
        UpdateMatrix();
    }

    private void UpdateMatrix()
    {
        // row 1, row 2, row3, row4
        transformMatrix.m00 = 1; transformMatrix.m01 = 0; transformMatrix.m02 = 0; transformMatrix.m03 = 0;  // Column 1 :x
        transformMatrix.m10 = 0; transformMatrix.m11 = 1; transformMatrix.m12 = 0; transformMatrix.m13 = 0; ;  // Column 2  : y
        transformMatrix.m20 = 0; transformMatrix.m21 = 0; transformMatrix.m22 = 1; transformMatrix.m23 = 0; ;  // Column 3 : z
        transformMatrix.m30 = 0; transformMatrix.m31 = 0; transformMatrix.m32 = 0; transformMatrix.m33 = 1;  // Column 4 

        //m00,m11,m22： x,y,z scale
        //m00,m01,m010,m11,m20,m21: x,y,z rotation
        //m03, m13, m23 : x,y,z translation

        float rotationSpeed = 30f;

        // Rotation quaternions
        Quaternion rotationX = Quaternion.AngleAxis(Time.time * 0, Vector3.right);
        Quaternion rotationY = Quaternion.AngleAxis(Time.time * rotationSpeed, Vector3.up);
        Quaternion rotationZ = Quaternion.AngleAxis(Time.time * 0, Vector3.forward);

        Quaternion combinedRotation = rotationZ * rotationY * rotationX;
        Matrix4x4 rotationMatrix = Matrix4x4.Rotate(combinedRotation);


        transformMatrix = transformMatrix * rotationMatrix;

        // Printing the matrix in a readable format
        Debug.Log("Matrix:\n" + transformMatrix);

        targetMaterial.SetMatrix("_TransformMatrix", transformMatrix);
    }
}