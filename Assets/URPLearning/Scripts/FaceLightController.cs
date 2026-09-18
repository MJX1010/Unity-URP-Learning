using UnityEngine;

namespace URPLearning
{
    [ExecuteAlways]
    public class FaceLightController : MonoBehaviour
    {
        public Transform headForward;
        public Material faceMaterial;
        public string propertyName = "_LightDirOffset";
        public Light directionalLight;

        void LateUpdate()
        {
            if (faceMaterial == null) return;
            Transform basis = headForward != null ? headForward : transform;
            Vector3 forward = Vector3.ProjectOnPlane(basis.forward, Vector3.up).normalized;
            Vector3 right = Vector3.ProjectOnPlane(basis.right, Vector3.up).normalized;
            Light light = directionalLight != null ? directionalLight : RenderSettings.sun;
            if (light == null) return;
            Vector3 lightDir = Vector3.ProjectOnPlane(-light.transform.forward, Vector3.up).normalized;
            float offset = Vector3.Dot(lightDir, right);
            float front = Vector3.Dot(lightDir, forward);
            offset *= Mathf.Lerp(1f, 0.25f, Mathf.Max(0f, -front));
            faceMaterial.SetFloat(propertyName, Mathf.Clamp(offset, -1f, 1f));
        }
    }
}
