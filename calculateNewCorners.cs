    private Vector3[] CalculateNewCorners(Vector3 outOfDoor, Vector3 backToFront, Vector3 rotationPoint, bool sideDoorIsRight, bool corridorOnWidthSide)
    {
        //depending on whether the corridor is on the width side or on the depth side this changes
        float xLength = corridorOnWidthSide ? roomWidth : roomDepth;
        float yLength = corridorOnWidthSide ? roomDepth : roomWidth;

        float remainingX = xLength - corridorDepth;

        Vector3 wallBehindRotationPoint = rotationPoint + Vector3.Normalize(outOfDoor) * (corridorDepth / 2) * -1;

        Vector3 backFirstCorner = wallBehindRotationPoint + Vector3.Normalize(backToFront) * corridorDepth / 2 * -1; // toBack (back as in: the direction of the old corridor)

        Vector3 frontFirstCorner = wallBehindRotationPoint + Vector3.Normalize(backToFront) * corridorDepth / 2 + Vector3.Normalize(backToFront) * remainingX; //first as in: nearer to the outdoor

        Vector3 backSecondCorner = backFirstCorner + Vector3.Normalize(outOfDoor) * yLength;

        Vector3 frontSecondCorner = frontFirstCorner + Vector3.Normalize(outOfDoor) * yLength;

        Vector3[] output = new Vector3[]
        {
            backFirstCorner,
            backSecondCorner,
            frontSecondCorner,
            frontFirstCorner,
        };

        if (!sideDoorIsRight)
        {
            Array.Reverse(output);
        }

        return output;
    }