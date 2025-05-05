using UnityEngine;

[ExecuteAlways]
public class DepthVisualizer : MonoBehaviour
{
    public Camera mainCamera;
    public Color nearColor = Color.white;
    public Color farColor = Color.black;

    private void Update()
    {
        Matrix4x4 VP = mainCamera.projectionMatrix * mainCamera.worldToCameraMatrix;
        Vector4 clipPos = VP * new Vector4(transform.position.x, transform.position.y, transform.position.z, 1f);
        float depth01 = Mathf.Clamp01(clipPos.z / clipPos.w);

        Color color = Color.Lerp(nearColor, farColor, depth01);
        Debug.Log("Depth: " + depth01);

        var renderer = GetComponent<Renderer>();

#if UNITY_EDITOR
        Material mat = renderer.sharedMaterial;
#else
        Material mat = renderer.material;
#endif
        mat.SetColor("_BaseColor", color);

    }
}
