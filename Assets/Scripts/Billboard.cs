using UnityEngine;

[ExecuteAlways]
public class Billboard : MonoBehaviour
{
   [SerializeField] private Camera mainCamera;

    private void Update()
    {
        Vector3 objectPosition = transform.position;
        Vector3 cameraPosition = mainCamera.transform.position;

        /*        // Matrix4x4.LookAt(from, to, up)
                Matrix4x4 viewMatrix = Matrix4x4.LookAt(
                    cameraPosition,
                    objectPosition,
                    Vector3.up
                );

                transform.rotation = viewMatrix.rotation;*/

        //orthonormal
        Vector3 forward =  objectPosition - cameraPosition;
        forward.y = 0;
        forward.Normalize();
        Vector3 right = Vector3.Cross(Vector3.up, forward).normalized;
        Vector3 up = Vector3.Cross(forward, right);  
        Matrix4x4 matrix = Matrix4x4.identity;

        //| right.x   up.x  forward.x  0 |
        //| right.y   up.y  forward.y  0 |
        //| right.z   up.z  forward.z  0 |
        //| 0          0        0      1 |

        matrix.SetColumn(0, new Vector4(right.x, right.y, right.z, 0));
        matrix.SetColumn(1, new Vector4(up.x, up.y, up.z, 0));
        matrix.SetColumn(2, new Vector4(forward.x, forward.y, forward.z, 0));

        transform.rotation = matrix.rotation;

        /*        Vector3 direction = objectPosition - cameraPosition;
                direction.y = 0;
                transform.rotation = Quaternion.LookRotation(direction, Vector3.up);*/
    }
}
