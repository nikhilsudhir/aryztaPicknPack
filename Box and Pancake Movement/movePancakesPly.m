function movePancakesPly(robot, finger1, finger2)
    % Number of pancakes
    numPancakes = 8;

    % Initialize x positions for each pancake (starting off-screen to the left)
    xPositions = linspace(-15, -10, numPancakes); % Initial x positions

    y = 1.4; % Fixed y position for all pancakes
    z = 0.65; % Fixed z position to lift pancakes off the floor (adjust this value)

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
    xMove = 0.1;
    stopPosition = 15;
    moveDuration = 0.05;
    stopDuration = 2;
    frameRate = 60;
    timePerFrame = 1 / frameRate;

    lastTime = tic;
    elapsedMoveTime = 0;
    elapsedStopTime = 0;
    isMoving = true;

    stoppingPositions = linspace(0, stopPosition, numPancakes);

    % Move pancakes in a loop
    while ishandle(h(1))
        elapsedTime = toc(lastTime);

        if isMoving
            for i = 1:numPancakes
                if xPositions(i) < stoppingPositions(i)
                    nextXPosition = xPositions(i) + xMove;
                    if i < numPancakes && nextXPosition >= xPositions(i + 1)
                        nextXPosition = xPositions(i + 1);
                    end
                    xPositions(i) = nextXPosition;
                end

                newVertices = rotatedVertices + [xPositions(i), y, z];
                set(h(i), 'Vertices', newVertices);
            end

            elapsedMoveTime = elapsedMoveTime + elapsedTime;
            lastTime = tic;

            if elapsedMoveTime >= moveDuration
                isMoving = false;
                elapsedMoveTime = 0;
            end
        else
            elapsedStopTime = elapsedStopTime + elapsedTime;
            lastTime = tic;

            if elapsedStopTime >= stopDuration
                isMoving = true;
                elapsedStopTime = 0;
            end
        end

        % Check if the robot is near a pancake and initiate pickup
        for i = 1:numPancakes
            % Define the position where the robot can reach a pancake
            robotReachPosition = xPositions(i) > -1 && xPositions(i) < 0;
            if robotReachPosition && ishandle(h(i))
                % Call the function to pick up the pancake
                PickUpPancake(robot, h(i), finger1, finger2, [xPositions(i), y, z]);
                delete(h(i)); % Remove the pancake from the conveyor
            end
        end

        drawnow;
    end

    hold off;
end






%% function movePancakesPly(robot, finger1, finger2)
% %     % Number of pancakes
% %     numPancakes = 8;
% % 
% %     % Initialize x positions for each pancake (starting off-screen to the left)
% %     xPositions = linspace(-15, -10, numPancakes); % Initial x positions
% % 
% %     y = 1.35; % Fixed y position for all pancakes
% %     z = 0.65; % Fixed z position to lift pancakes off the floor (adjust this value)
% % 
% %     % Load the pancake model
% %     [pancakeFaceData, pancakeVertexData, ~] = plyread('Pancake.ply', 'tri');
% % 
% %     % Scaling factor
% %     scaleFactor = 0.5;
% % 
% %     % Store handles for the pancakes
% %     h = gobjects(1, numPancakes);
% % 
% %     % Scale the pancake vertices initially
% %     scaledVertices = pancakeVertexData * scaleFactor;
% % 
% %     % Plot the pancakes initially at their starting positions
% %     for i = 1:numPancakes
% %         pancakeVertices = scaledVertices + [xPositions(i), y, z];
% %         h(i) = trisurf(pancakeFaceData, pancakeVertices(:, 1), pancakeVertices(:, 2), pancakeVertices(:, 3), ...
% %                        'FaceColor', '#D1A054', 'EdgeColor', 'none');
% %     end
% % 
% %     % Movement parameters
% %     xMove = 0.1;
% %     stopPosition = 15;
% %     moveDuration = 0.05;
% %     stopDuration = 2;
% %     frameRate = 60;
% %     timePerFrame = 1 / frameRate;
% % 
% %     lastTime = tic;
% %     elapsedMoveTime = 0;
% %     elapsedStopTime = 0;
% %     isMoving = true;
% % 
% %     stoppingPositions = linspace(0, stopPosition, numPancakes);
% % 
% %     % Move pancakes in a loop
% %     while ishandle(h(1))
% %         elapsedTime = toc(lastTime);
% % 
% %         if isMoving
% %             for i = 1:numPancakes
% %                 if xPositions(i) < stoppingPositions(i)
% %                     nextXPosition = xPositions(i) + xMove;
% %                     if i < numPancakes && nextXPosition >= xPositions(i + 1)
% %                         nextXPosition = xPositions(i + 1);
% %                     end
% %                     xPositions(i) = nextXPosition;
% %                 end
% % 
% %                 % Update positions
% %                 newVertices = scaledVertices + [xPositions(i), y, z];
% %                 set(h(i), 'Vertices', newVertices);
% %             end
% % 
% %             elapsedMoveTime = elapsedMoveTime + elapsedTime;
% %             lastTime = tic;
% % 
% %             if elapsedMoveTime >= moveDuration
% %                 isMoving = false;
% %                 elapsedMoveTime = 0;
% %             end
% %         else
% %             elapsedStopTime = elapsedStopTime + elapsedTime;
% %             lastTime = tic;
% % 
% %             if elapsedStopTime >= stopDuration
% %                 isMoving = true;
% %                 elapsedStopTime = 0;
% %             end
% %         end
% % 
% %         % Check if the robot is near a pancake and initiate pickup
% %         for i = 1:numPancakes
% %             % Define the position where the robot can reach a pancake
% %             robotReachPosition = xPositions(i) > -1 && xPositions(i) < 0;
% %             if robotReachPosition && ishandle(h(i))
% %                 % Call the function to pick up the pancake
% %                 PickUpPancake(robot, h(i), finger1, finger2, [xPositions(i), y, z]);
% %                 delete(h(i)); % Remove the pancake from the conveyor
% %             end
% %         end
% % 
% %         drawnow;
% %     end
% % 
% %     hold off;
% % end

