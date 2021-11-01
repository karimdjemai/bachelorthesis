 bool mainDoorIsRight = mainDoorPosition > 0.5f; // main door is more right than left
        this.sideDoorIsRight = !mainDoorIsRight;

        Vector3 innerLeftToRight = leftToRight + Vector3.Normalize(rightToLeft) * wallThickness * 2;

        Vector3 innerDoorGenSpanLeftToRight =
            innerLeftToRight + Vector3.Normalize(rightToLeft) * rotationPointDistance * 2;

        //leftToRight but less long: whole length - inner - rotpointdistance - doorwith
        Vector3 innerDoorGenSpanLeftToRightDoorPadding =
            innerDoorGenSpanLeftToRight + Vector3.Normalize(rightToLeft) * doorWidth;

        Vector3 toBehindRotPointLeftRight = Vector3.Normalize(leftToRight) * rotationPointDistance * 2;

        Vector3 sideDoorCornerBehindRotPoint = sideDoorIsRight ? boRiFrCorner + -toBehindRotPointLeftRight : boLeFrCorner + toBehindRotPointLeftRight;

        Vector3 innerCrossDirection = sideDoorIsRight ? -innerDoorGenSpanLeftToRightDoorPadding : innerDoorGenSpanLeftToRightDoorPadding;

        Vector3 sideDoorCornerBehindRotPointDoorPadding =
            sideDoorCornerBehindRotPoint + Vector3.Normalize(innerCrossDirection) * doorWidth / 2;
        //main door origin is generated between sideDoorCornerBehindRotPoint and the other corner - inner - half of the door width

        if (sideDoorIsRight)
        {
            mainDoorPosition = 1 - mainDoorPosition;
        }

        Vector3 mainDoorOrigin = sideDoorCornerBehindRotPointDoorPadding
                                 + innerCrossDirection * mainDoorPosition;