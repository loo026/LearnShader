using UnityEngine;

[ExecuteAlways]
public class LightController : MonoBehaviour
{
    [SerializeField] private Light _lightDirection;
    [SerializeField] private Material _toonMaterial;

    private void Update()
    {
        if (_lightDirection && _toonMaterial)
        {
            _toonMaterial.SetVector("_LightDirection", _lightDirection.transform.forward);
        }
    }
}
