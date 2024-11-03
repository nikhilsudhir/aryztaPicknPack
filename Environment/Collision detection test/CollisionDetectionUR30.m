function CollisionDetectionUR30(robot2, startPos, EndPos, numBoxes, PlaceX, PlaceY, PlaceZ, palletTargetZ, collision, PalletMovementDirection)
    % Initialize x positions for each box (starting off-screen to the left)
    xPositions = linspace(EndPos, startPos, 1); % Initial x positions
    y = 0.05; % Fixed y position for all boxes
    z = 0.95; % Base z position to lift boxes off the floor

    % Load the box model
    [boxFaceData, boxVertexData, ~] = plyread('BoxClosed.ply', 'tri');
    [palletFaceData, palletVertexData, data] = plyread('PalletWithForklift.ply', 'tri');

    % Scaling and rotation parameters
    scaleFactor = 1;
    palletScaleFactor = 1;
    rotationMatrixZ = [cosd(90), -sind(90), 0; sind(90), cosd(90), 0; 0, 0, 1]; % Rotate 90 degrees around Z
    rotationMatrixX = [1, 0, 0; 0, cosd(90), -sind(90); 0, sind(90), cosd(90)]; % Rotate 90 degrees around X

    % Initialize and scale the pallet
    palletStartPos = [PlaceX, PlaceY, PlaceZ]; % Pallet original position 2.3, -0.7, 0.3
    scaledPalletVertices = palletVertexData * palletScaleFactor;
    PalletvertexColors = [data.vertex.red, data.vertex.green, data.vertex.blue] / 255;
    % Store handles for the boxes and pallet
    hBox = gobjects(1);
    if size(PalletvertexColors, 1) == size(scaledPalletVertices, 1)
        hPallet = trisurf(palletFaceData, scaledPalletVertices(:, 1) + palletStartPos(1), ...
                          scaledPalletVertices(:, 2) + palletStartPos(2), ...
                          scaledPalletVertices(:, 3) + palletStartPos(3), ...
                          'FaceVertexCData', PalletvertexColors, 'EdgeColor', 'none');
    end
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
    palletPositionZ = palletStartPos(3); % Starting Z position of the pallet
    BoxCollected = 1.4;

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
                    if numBoxes == 1
                        set(hBox(i), 'Vertices', newVertices);
                    end
                end
            end
    
            % Check for pickup if the robot is not currently carrying a box
            if ~isCarrying && xPositions(i) >= BoxCollected && ishandle(hBox(i)) && palletPositionZ == palletTargetZ
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
    
                dropOffPos = [1.85, -0.3, 0.89];
                qTraj = generateTrajectory(robot2, dropOffPos, robot2.model.getpos());
    
                for q = qTraj'
                    robot2.model.animate(q');
                    endEffectorPose = robot2.model.fkineUTS(q');
                    boxPosition = endEffectorPose(1:3, 4)';
                    newVertices = rotatedVertices + boxPosition; % Ensure orientation is consistent
                    set(hBox(currentBox), 'Vertices', newVertices);
                    pause(0.01);
    
                    % Check if the end effector has reached the midway X coordinate
                    if boxPosition(1) >= collision
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
        if  PalletMovementDirection == 1
            palletPositionZ = min(palletPositionZ + xMove, palletTargetZ);
    
        elseif PalletMovementDirection == -1
            palletPositionZ = max(palletPositionZ - xMove, palletTargetZ);
            
        end
    
        % Update pallet position
        newPalletVertices = scaledPalletVertices + [palletStartPos(1), palletStartPos(2), palletPositionZ];
        set(hPallet, 'Vertices', newPalletVertices);
    
        % Stop the timer when all boxes are picked up
        if pickedCount >= 1
            stop(moveTimer);
            delete(moveTimer);
            if numBoxes == 1
                delete(hBox); % Delete box model from environment
                delete(hPallet); % Delete pallet model from environment
            end
        end
    
        drawnow;
    end
end

