function CollisionDetectionUR30(robot2, startPos, EndPos, BoxCollected, PlaceX, PlaceY, PlaceZ, midwayXCoord)
    % Initialize x positions for each box (starting off-screen to the left)
    xPositions = linspace(EndPos, startPos, 1); % Initial x positions
    y = 0.05; % Fixed y position for all boxes
    z = 0.95; % Base z position to lift boxes off the floor

    % Load the box model
    [boxFaceData, boxVertexData, ~] = plyread('BoxClosed.ply', 'tri');
    [palletFaceData, palletVertexData, ~] = plyread('Pallet.ply', 'tri');

    % Scaling and rotation parameters
    scaleFactor = 1;
    palletScaleFactor = 1.2;
    rotationMatrixZ = [cosd(90), -sind(90), 0; sind(90), cosd(90), 0; 0, 0, 1]; % Rotate 90 degrees around Z
    rotationMatrixX = [1, 0, 0; 0, cosd(90), -sind(90); 0, sind(90), cosd(90)]; % Rotate 90 degrees around X

    % Initialize and scale the pallet
    palletStartPos = [2.3, -0.7, 0.3];
    palletTargetZ = 2;  %Lift up to Z 1.7
    scaledPalletVertices = palletVertexData * palletScaleFactor;

    % Store handles for the boxes and pallet
    hBox = gobjects(1);
    hPallet = trisurf(palletFaceData, scaledPalletVertices(:, 1) + palletStartPos(1), ...
                      scaledPalletVertices(:, 2) + palletStartPos(2), ...
                      scaledPalletVertices(:, 3) + palletStartPos(3), ...
                      'FaceColor', '#D9B98B', 'EdgeColor', 'none');

    % Scale and rotate the box vertices initially
    scaledVertices = boxVertexData * scaleFactor;
    rotatedVertices = (rotationMatrixZ * rotationMatrixX * scaledVertices')'; % Correct rotation

    % Plot the boxes initially at their starting positions
    for i = 1
        boxVertices = rotatedVertices + [xPositions(i), y, z];
        hBox(i) = trisurf(boxFaceData, boxVertices(:, 1), boxVertices(:, 2), boxVertices(:, 3), ...
                          'FaceColor', '#D9B98B', 'EdgeColor', 'none');
    end

    % Movement parameters
    xMove = 0.01; % Movement increment for boxes and pallet
    frameRate = 30; % Frames per second
    timePerFrame = 1 / frameRate; % Time per frame

    % Define the timer object
    moveTimer = timer('ExecutionMode', 'fixedRate', 'Period', timePerFrame, 'TimerFcn', @moveBoxes);

    % Count of picked boxes
    pickedCount = 0;
    isCarrying = false; % Flag to indicate if the robot is carrying a box
    currentBox = 1; % Track the current box being processed
    originalPositions = zeros(1, 3); % Store original position
    palletDirection = 1; % 1 for up, -1 for down
    palletPositionZ = palletStartPos(3); % Starting Z position of the pallet
    waitForBoxPosition = false; % Wait flag

    % Start the timer
    start(moveTimer);

    function moveBoxes(~, ~)
        % Move boxes
        for i = 1
            % Move the box along the conveyor if it has not been picked up
            if ~isCarrying && ishandle(hBox(i))
                if xPositions(i) < BoxCollected
                    xPositions(i) = min(xPositions(i) + xMove, BoxCollected);
                    newVertices = rotatedVertices + [xPositions(i), y, z]; % Update position with rotation
                    set(hBox(i), 'Vertices', newVertices);
                end
            end
    
            % Check for pickup if the robot is not currently carrying a box
            if ~isCarrying && xPositions(i) >= BoxCollected && ishandle(hBox(i))
                targetPos = [xPositions(i), y, z];
                qTraj = generateTrajectory(robot2, targetPos, robot2.model.getpos());
    
                for q = qTraj'
                    robot2.model.animate(q');
                    pause(0.01); % Brief pause for smooth animation
                end
    
                % Store original position of the box before picking it up
                originalPositions = [xPositions(i), y, z];
                isCarrying = true;
                currentBox = i;
            end
    
            % If the robot is carrying a box, move towards the drop-off location
            if isCarrying && ishandle(hBox(currentBox))
                qNow = robot2.model.getpos();
                endEffectorPose = robot2.model.fkineUTS(qNow);
                boxPosition = endEffectorPose(1:3, 4)';
    
                newVertices = rotatedVertices + boxPosition; % Maintain orientation when moving
                set(hBox(currentBox), 'Vertices', newVertices);
    
                dropOffPos = [PlaceX, PlaceY, PlaceZ];
                qTraj = generateTrajectory(robot2, dropOffPos, robot2.model.getpos());
    
                for q = qTraj'
                    robot2.model.animate(q');
                    endEffectorPose = robot2.model.fkineUTS(q');
                    boxPosition = endEffectorPose(1:3, 4)';
                    newVertices = rotatedVertices + boxPosition; % Ensure orientation is consistent
                    set(hBox(currentBox), 'Vertices', newVertices);
                    pause(0.01);
    
                    % Check if the end effector has reached the midway X coordinate
                    if boxPosition(1) >= midwayXCoord
                        disp('Midway X coordinate reached! Reversing back to pickup location.');
                        qTrajToOriginal = generateTrajectory(robot2, originalPositions, robot2.model.getpos());
                        for q = qTrajToOriginal'
                            robot2.model.animate(q');
                            endEffectorPose = robot2.model.fkineUTS(q');
                            boxPosition = endEffectorPose(1:3, 4)';
                            newVertices = rotatedVertices + boxPosition; % Maintain box orientation
                            set(hBox(currentBox), 'Vertices', newVertices);
                            pause(0.01);
                        end
    
                        set(hBox(currentBox), 'Vertices', rotatedVertices + originalPositions); % Reset to original position
                        disp('Box placed back to original position!');
                        isCarrying = false;
                        pickedCount = pickedCount + 1;
                        break;
                    end
                end
    
                set(hBox(currentBox), 'Vertices', newVertices); % Final update
                isCarrying = false;
                pickedCount = pickedCount + 1;
                break;
            end
            break;
        end
    
        % Move the pallet up or down continuously
        if palletDirection == 1 && palletPositionZ < palletTargetZ
            palletPositionZ = min(palletPositionZ + xMove, palletTargetZ);
    
            % When the pallet reaches the top, reverse direction
            if palletPositionZ >= palletTargetZ
                palletDirection = -1;
            end
        elseif palletDirection == -1 && palletPositionZ > palletStartPos(3)
            palletPositionZ = max(palletPositionZ - xMove, palletStartPos(3));
            pause(0.03);
            
        end
    
        % Update pallet position
        newPalletVertices = scaledPalletVertices + [palletStartPos(1), palletStartPos(2), palletPositionZ];
        set(hPallet, 'Vertices', newPalletVertices);
    
        % Stop the timer when all boxes are picked up
        if pickedCount >= 1
            stop(moveTimer);
            delete(moveTimer);
        end
    
        drawnow;
    end

end
