Vector2[] GenerateUV(Vector3[] vertices, int[] triangles)
    {
        Vector2[] uv = new Vector2[vertices.Length];

        for (int i = 0; i < triangles.Length; i += 3)
        {
            int vi0 = triangles[i + 0];
            int vi1 = triangles[i + 1];
            int vi2 = triangles[i + 2];

            Vector3 normal = CalculateNormal(vertices[vi0], vertices[vi1], vertices[vi2]);

            if (VectorsAreParallel(normal, toFrontWall))
            {
                //DebugHighlightFace(vertices[vi0], vertices[vi1], vertices[vi2], Color.magenta);

                Vector3 v0 = vertices[vi0];
                Vector3 v1 = vertices[vi1];
                Vector3 v2 = vertices[vi2];

                v0 = gameObject.transform.TransformPoint(v0);
                v1 = gameObject.transform.TransformPoint(v1);
                v2 = gameObject.transform.TransformPoint(v2);

                Quaternion rotation = Quaternion.FromToRotation(leftToRight, Vector3.forward);

                v0 = rotation * v0;
                v1 = rotation * v1;
                v2 = rotation * v2;

                uv[vi0] = new Vector2(v0.z, v0.y);
                uv[vi1] = new Vector2(v1.z, v1.y);
                uv[vi2] = new Vector2(v2.z, v2.y);
            }
            else if (VectorsAreParallel(normal, leftToRight))
            {
                // DebugHighlightFace(vertices[vi0], vertices[vi1], vertices[vi2], Color.magenta);

                Vector3 v0 = vertices[vi0];
                Vector3 v1 = vertices[vi1];
                Vector3 v2 = vertices[vi2];

                Quaternion rotation = Quaternion.FromToRotation(leftToRight, Vector3.forward);

                v0 = rotation * v0;
                v1 = rotation * v1;
                v2 = rotation * v2;

                uv[vi0] = new Vector2(v0.x, v0.y);
                uv[vi1] = new Vector2(v1.x, v1.y);
                uv[vi2] = new Vector2(v2.x, v2.y);
            }
            else if (VectorsAreParallel(normal, Vector3.up))
            {
                Vector3 v0 = vertices[vi0];
                Vector3 v1 = vertices[vi1];
                Vector3 v2 = vertices[vi2];

                Quaternion rotation = Quaternion.FromToRotation(leftToRight, Vector3.forward);

                v0 = rotation * v0;
                v1 = rotation * v1;
                v2 = rotation * v2;

                uv[vi0] = new Vector2(v0.z, v0.x);
                uv[vi1] = new Vector2(v1.z, v1.x);
                uv[vi2] = new Vector2(v2.z, v2.x);
            }
        }

        return uv;
    }