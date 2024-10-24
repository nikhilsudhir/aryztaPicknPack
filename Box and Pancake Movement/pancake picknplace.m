function movePancakesPly(robot)

    % Number of pancakes
    numPancakes = 1;

    % Initialize x positions for each pancake (starting off-screen to the left)
    xPositions = linspace(-15, -10, numPancakes); % Initial x positions

    y = 1.35; % Fixed y position for all pancakes
    z = 0.68; % Fixed z position to lift pancakes off the floor

    % Load the pancake model
    [pancakeFaceData, pancakeVertexData, ~] = plyread('Pancake.ply', 'tri');

    % Scaling and rotation parameters
    scaleFactor = 1;
    rotationMatrixZ = [cosd(180), -sind(180), 0; sind(180), cosd(180), 0; 0, 0, 1];
    rotationMatrixX = [1, 0, 0; 0, cosd(90), -sind(90); 0, sind(90), cosd(90)];

    % Store handles for the pancakes
    h = gobjects(1, numPancakes);

    % Scale and rotate the pancake vertices initially
    scaledVertices = pancakeVertexData * scaleFactor;
    rotatedVertices = (rotationMatrixZ * rotationMatrixX * scaledVertices')';

    % Plot the pancakes initially at their starting positions
    for i = 1:numPancakes
        pancakeVertices = rotatedVertices + [xPositions(i), y, z];
        h(i) = trisurf(pancakeFaceData, pancakeVertices(:, 1), pancakeVertices(:, 2), pancakeVertices(:, 3), ...
                       'FaceColor', '#D1A054', 'EdgeColor', 'none');
    end

    % Movement parameters
    xMove = 0.01;
    stopPosition = -6; % Target position
    frameRate = 30;
    timePerFrame = 1 / frameRate;
    isCarrying = false; % Flag to indicate if the pancake is being carried

    % Define the timer object
    moveTimer = timer('ExecutionMode', 'fixedRate', 'Period', timePerFrame, 'TimerFcn', @movePancakes);

    % Start the timer
    start(moveTimer);

    function movePancakes(~, ~)
        % Move pancakes
        for i = 1:numPancakes
            if ~isCarrying
                % Move the pancake along the conveyor
                if xPositions(i) < stopPosition
                    xPositions(i) = min(xPositions(i) + xMove, stopPosition);
                end

                % Update the vertices of the pancake
                newVertices = rotatedVertices + [xPositions(i), y, z];
                set(h(i), 'Vertices', newVertices);
            end

            % Check for pickup
            if xPositions(i) >= stopPosition && ishandle(h(i)) && ~isCarrying
                % Move robot end effector to pancake position
                targetPos = [xPositions(i), y, z + 0.2]; % Adjust z for pickup
                qTraj = generateTrajectory(robot, targetPos, robot.model.getpos()); % Generate trajectory

                % Animate the robot moving to the target position and picking up pancake
                for q = qTraj'
                    robot.model.animate(q');
                    pause(0.01); % Brief pause for smooth animation
                end

                % Mark that the robot is now carrying the pancake
                isCarrying = true;
            end

            % If the robot is carrying the pancake, update its position to follow the end effector
            if isCarrying && ishandle(h(i))
                % Get the current pose of the end effector
                qNow = robot.model.getpos();
                endEffectorPose = robot.model.fkineUTS(qNow);
                pancakePosition = endEffectorPose(1:3, 4)'; % Extract translation from pose

                % Update the vertices of the pancake relative to the end effector
                newVertices = rotatedVertices + pancakePosition;
                set(h(i), 'Vertices', newVertices);

                % Move the robot to the drop-off location
                dropOffPos = [-6, -0.1, 0.7]; % Define drop-off position
                qTraj = generateTrajectory(robot, dropOffPos, robot.model.getpos()); % Generate trajectory to drop-off position

                % Animate the robot moving to the drop-off position
                for q = qTraj'
                    robot.model.animate(q');
                    endEffectorPose = robot.model.fkineUTS(q'); % Update the end effector pose
                    pancakePosition = endEffectorPose(1:3, 4)'; % Extract translation from pose
                    newVertices = rotatedVertices + pancakePosition;
                    set(h(i), 'Vertices', newVertices);
                    pause(0.01); % Brief pause for smooth animation
                end

                % Drop the pancake at the drop-off location (stop following the end effector)
                finalDropPos = [dropOffPos(1), dropOffPos(2), dropOffPos(3) - 0.05]; % Slightly lower Z to place on surface
                newVertices = rotatedVertices + finalDropPos;
                set(h(i), 'Vertices', newVertices);

                % Mark that the pancake is no longer being carried
                isCarrying = false;
            end
        end

        % Stop the timer when all pancakes are moved off the screen
        if all(xPositions >= stopPosition) && ~isCarrying
            stop(moveTimer);
            delete(moveTimer);
        end

        drawnow; % Update the figure
    end
end
