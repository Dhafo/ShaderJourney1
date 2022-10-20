using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(MeshFilter))]
public class MeshGenerator : MonoBehaviour
{
    public int GridX = 20;
    public int GridZ = 20;

    Mesh mesh;

    Vector3[] vertices;
    int[] triangles;
    // Start is called before the first frame update
    void Start()
    {
        mesh = new Mesh();
        GetComponent<MeshFilter>().mesh = mesh;
        CreateShape();
        UpdateMesh();
    }

    void CreateShape()
    {
        vertices = new Vector3[(GridX + 1) * (GridZ + 1)];
        int i = 0;
        for (int z = 0; z <= GridZ; z++) 
        {
            for(int x = 0; x <= GridX; x++) 
            {
                float y = Mathf.PerlinNoise(x * .01f, z * .01f) * 30f;
                vertices[i] = new Vector3(x, y, z);
                i++;
            }
        }

        triangles = new int[GridX * GridZ * 6];
        int vert = 0;
        int tris = 0;
        for (int z = 0; z < GridZ; z++)
        {
            for (int x = 0; x < GridX; x++)
            {
                triangles[tris + 0] = vert + 0;
                triangles[tris + 1] = vert + GridX + 1;
                triangles[tris + 2] = vert + 1;
                triangles[tris + 3] = vert + 1;
                triangles[tris + 4] = vert + GridX + 1;
                triangles[tris + 5] = vert + GridX + 2;
                vert++;
                tris += 6;
            }
            vert++;
        }


    }

    void UpdateMesh() 
    {
        mesh.Clear();

        mesh.vertices = vertices;
        mesh.triangles = triangles;
        mesh.RecalculateNormals();
        mesh.RecalculateBounds();

        MeshCollider meshCollider = gameObject.GetComponent<MeshCollider>();
        meshCollider.sharedMesh = mesh;
    }

    //private void OnDrawGizmos() 
    //{

    //    if(vertices == null) 
    //    {
    //        return;
    //    }
    //    for(int i = 0; i < vertices.Length; i++) 
    //    {
    //        Gizmos.DrawSphere(vertices[i], .1f);
    //    }  
    //}
}
