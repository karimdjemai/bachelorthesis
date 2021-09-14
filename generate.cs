  public void Generate()
    {
        this.redirection = this.locomotionType == LocomotionType.Redirection;

        Vector3[] corners = initalCorners;
        int direction = startingDirection;
        bool forceLeftDoor = false;
        bool forceRightDoor = false;

        bool outCorridorSet = false;
        Vector3 frontInCorridorCorner = default;
        Vector3 backInCorridorCorner = default;
        int entranceCornerIndex = default;

        roomAndProgressManager.rooms = new List<GameObject>();
        roomAndProgressManager.showAllWalls = !this.redirection;

        Quaternion rotation = Quaternion.identity;
        bool rotationWasSet = false;

        bool wasOnShortSide = false;

        Vector3 debugLastRotationPoint = Vector3.zero;

        for (int i = 0; i < this.levelLength; i++)
        {
            GameObject room = new GameObject();
            room.AddComponent<RoomGenerator>();

            float doorPosition = GenerateRandomDoorPosition(forceLeftDoor, forceRightDoor);

            var script = room.GetComponent<RoomGenerator>();

            script.Generate(
                i,
                corners,
                direction,
                corridorDepth,
                corridorHeight,
                eyeHeight,
                wallThickness,
                doorPosition,
                doorWidth,
                doorHeight,
                wallMaterial,
                doorMaterial,
                dissolveMaterial,
                doorTransitionLength,
                wallPrefab
            );

            if (!redirection)
            {
                room.AddComponent<MeshCollider>();
            }

            Vector3 center = script.CalculateCenterOfRoom();

            if (!rotationWasSet)
            {
                rotation = Quaternion.LookRotation(script.corners[0] - script.corners[1]);
                rotationWasSet = true;
            }

            GameObject rotationRedirector = Instantiate(rotationRedirectorPrefab, center, rotation);
            rotationRedirector.transform.SetParent(room.transform);
            rotationRedirector.AddComponent<RotationRedirectorCollision>();

            var rotationRedirectorScript = rotationRedirector.GetComponent<RotationRedirector>();
            rotationRedirectorScript.PlayAreaDimensions = new Vector2(roomDepth, roomWidth);
            rotationRedirectorScript.redirectionObject = redirectionObject.transform;

            var rotationCollider = rotationRedirector.AddComponent<BoxCollider>();
            float colliderWidth = corridorDepth;
            rotationCollider.isTrigger = true;
            rotationCollider.size = new Vector3(colliderWidth, corridorHeight, colliderWidth);

            Vector3 localRotationPoint = Quaternion.Inverse(rotation) * (script.rotationPoint - center);
            rotationRedirectorScript.RotationPoint = localRotationPoint;
            rotationCollider.center = localRotationPoint + Vector3.up * corridorHeight / 2;
            rotationRedirector.layer = 8;

            roomAndProgressManager.rooms.Add(room);
            roomAndProgressManager.roomScripts.Add(script);

            //calculate numpad position and rotation
            (Vector3 numPadPos, Quaternion numPadRot) = script.CalculateNumPadPosRot();
            GameObject numPad = Instantiate(numPadPrefab, numPadPos, numPadRot, room.transform);

            (Vector3 boardPos, Quaternion boardRot) = script.CalculateBoardPosRot();
            GameObject board = Instantiate(boardPrefab, boardPos, boardRot, room.transform);

            var localBoardScale = board.transform.localScale;
            var newBoardX = corridorDepth - wallThickness * 2;
            var newBoardY = localBoardScale.y / localBoardScale.x * newBoardX;

            board.transform.localScale = new Vector3(newBoardX, newBoardY, localBoardScale.z);
            room.AddComponent<RotationGainMechanism>().Init(numPad, board, rotationRedirector.GetComponent<RotationRedirector>(), this.redirection);

            if (!outCorridorSet)
            {
                if (redirection)
                {
                    script.GenerateWalls();
                }
                else
                {
                    script.GenerateWallsLegacy();
                }
            } else
            {
                bool longerSecondWall = !script.IsCorridorOnShortSide() && !wasOnShortSide;
                bool longerThirdWall = script.IsCorridorOnShortSide() && wasOnShortSide;

                if (redirection || i == levelLength - 1)
                {
                    script.GenerateWalls(frontInCorridorCorner, backInCorridorCorner, entranceCornerIndex, longerSecondWall, longerThirdWall);
                }
                else
                {
                    script.GenerateWallsLegacy(frontInCorridorCorner, backInCorridorCorner, entranceCornerIndex, longerSecondWall, longerThirdWall);
                }

            }

            rotationRedirector.GetComponent<RotationRedirector>().enabled = this.redirection;

            // calculations for the next room
            if (script.sideDoorIsRight)
            {
                rotationRedirectorScript.RotationDegrees = 270;
                rotation = rotation * Quaternion.Euler(0, 270, 0);
            }
            else
            {
                rotationRedirectorScript.RotationDegrees = 90;
                rotation = rotation * Quaternion.Euler(0, 90, 0);
            }

            Vector3 outOfDoor = script.sideDoorIsRight ? script.leftToRight : -script.leftToRight;
            frontInCorridorCorner = script.corridorCornerInFrontOfRotationPoint;
            backInCorridorCorner = script.corridorCornerBehindRotationPoint;
            entranceCornerIndex = script.sideDoorIsRight ? 0 : 3;
            outCorridorSet = true;

            int secondDirectionBlock;

            if (script.sideDoorIsRight)
            {
                secondDirectionBlock = 0;
            }
            else
            {
                secondDirectionBlock = 2;
            }

            direction = RandomDirectionBlocked(new List<int>() {3, secondDirectionBlock}); // 3: side would be where the current door is,

            if (script.sideDoorIsRight)
            {
                if (direction == 1)
                {
                    forceRightDoor = true;
                    forceLeftDoor = false;
                }
                else if (direction == 2)
                {
                    forceLeftDoor = true;
                    forceRightDoor = false;
                }
            }
            else
            {
                if (direction == 0)
                {
                    forceRightDoor = true;
                    forceLeftDoor = false;
                } else if (direction == 1)
                {
                    forceRightDoor = false;
                    forceLeftDoor = true;
                }
            }

            corners = CalculateNewCorners(outOfDoor, script.toFrontWall, script.rotationPoint, script.sideDoorIsRight, this.CorridorIsOnWidthSide(script.leftToRight.magnitude));
            wasOnShortSide = script.IsCorridorOnShortSide();

            Debug.DrawLine(script.rotationPoint, debugLastRotationPoint, Color.yellow, 10000f, false);
            debugLastRotationPoint = script.rotationPoint;

        }

        roomAndProgressManager.Init();
    }