function boxCollection(robot2, startPos, EndPos, BoxCollected, PlaceX, PlaceY, PlaceZ)
    % Initialize x positions for each box (starting off-screen to the left)
    xPositions = linspace(EndPos, startPos, 1); % Initial x positions

    y = 0.05; % Fixed y position for all boxes
    z = 0.95; % Base z position to lift boxes off the floor

    % Load the box model
    [boxFaceData, boxVertexData, ~] = plyread('BoxClosed.ply', 'tri');

    % Scaling and rotation parameters
    scaleFactor = 1;
    rotationMatrixZ = [cosd(90), -sind(90), 0; sind(90), cosd(90), 0; 0, 0, 1];
    rotationMatrixX = [1, 0, 0; 0, cosd(90), -sind(90); 0, sind(90), cosd(90)];

    % Store handles for the boxes
    h = gobjects(1);

    % Scale and rotate the box vertices initially
    scaledVertices = boxVertexData * scaleFactor;
    rotatedVertices = (rotationMatrixZ * rotationMatrixX * scaledVertices')';

    % Plot the boxes initially at their starting positions
    for i = 1
        boxVertices = rotatedVertices + [xPositions(i), y, z];
        h(i) = trisurf(boxFaceData, boxVertices(:, 1), boxVertices(:, 2), boxVertices(:, 3), ...
                       'FaceColor', '#D9B98B', 'EdgeColor', 'none');
    end

    % Movement parameters
    xMove = 0.01;
    frameRate = 30;
    timePerFrame = 1 / frameRate;

    % Define the timer object
    moveTimer = timer('ExecutionMode', 'fixedRate', 'Period', timePerFrame, 'TimerFcn', @moveBoxes);

    % Count of picked boxes
    pickedCount = 0;
    isCarrying = false; % Flag to indicate if the robot is carrying a box
    currentBox = 1; % Track the current box being processed

    % Start the timer
    start(moveTimer);

    function moveBoxes(~, ~)
        % Move boxes
        for i = 1
            % Move the box along the conveyor if it has not been picked up
            if ~isCarrying && ishandle(h(i))
                if xPositions(i) < BoxCollected
                    xPositions(i) = min(xPositions(i) + xMove, BoxCollected);
                    newVertices = rotatedVertices + [xPositions(i), y, z];
                    set(h(i), 'Vertices', newVertices);
                end
            end

            % Check for pickup if the robot is not currently carrying a box
            if ~isCarrying && xPositions(i) >= BoxCollected && ishandle(h(i))
                % Move robot end effector to box top position (above the box)
                targetPos = [xPositions(i), y, z]; % Adjust z to reach the top of the box + offset
                qTraj = generateTrajectory(robot2, targetPos, robot2.model.getpos()); % Generate trajectory

                % Animate the robot moving above the box position
                for q = qTraj'
                    robot2.model.animate(q');
                    pause(0.01); % Brief pause for smooth animation
                end

                % Mark that the robot is now carrying the box
                isCarrying = true;
                currentBox = i; % Keep track of the box being picked
            end

            % If the robot is carrying a box, move to the drop-off location
            if isCarrying && ishandle(h(currentBox))
                % Get the current pose of the end effector
                qNow = robot2.model.getpos();
                endEffectorPose = robot2.model.fkineUTS(qNow);
                boxPosition = endEffectorPose(1:3, 4)'; % Extract translation from pose%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                % Update the vertices of the box relative to the end effector
                newVertices = rotatedVertices + boxPosition; % Add vertical offset%%%%%%%%%%%%%%%%%%%%%%
                set(h(currentBox), 'Vertices', newVertices);

                % Move the robot to the drop-off location
                dropOffPos = [PlaceX, PlaceY, PlaceZ]; % Define drop-off position
                qTraj = generateTrajectory(robot2, dropOffPos, robot2.model.getpos()); % Generate trajectory to drop-off position

                % Animate the robot moving to the drop-off position
                for q = qTraj'
                    robot2.model.animate(q');
                    % Update the end effector position
                    endEffectorPose = robot2.model.fkineUTS(q'); % Update the end effector pose
                    boxPosition = endEffectorPose(1:3, 4)'; % Extract translation from pose
                    newVertices = rotatedVertices + boxPosition; % Keep the offset during movement%%%%%%%%%%%%%%%%%%
                    set(h(currentBox), 'Vertices', newVertices);
                    pause(0.01); % Brief pause for smooth animation
                end

                % Release the box at the drop-off location without deleting it
                %finalDropPos = [dropOffPos(1), dropOffPos(2), dropOffPos(3) + pickupOffset]; % Adjust Z to match the height of the box + offset
                %newVertices = rotatedVertices + finalDropPos;
                set(h(currentBox), 'Vertices', newVertices);

                % Mark that the box is no longer being carried
                isCarrying = false;
                pickedCount = pickedCount + 1; % Increment picked count
            end
        end

        % Stop the timer when all boxes are picked up
        if pickedCount >= 1
            stop(moveTimer);
            delete(moveTimer);
        end

        drawnow; % Update the figure
    end
end
