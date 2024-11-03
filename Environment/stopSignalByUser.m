function stopSignalByUser(startPos, collision, angle, robot)
    % Load person model with scaling
    scale = 0.8; % Scaling factor
    [personFaceData, personVertexData, personData] = plyread('personMaleCasual.ply', 'tri');

    % Initialize Y position and collision flags
    yPosition = startPos(2); % Set initial Y position based on startPos
    UR30EStop = false; % Collision flag for UR30
    UR3eEStop = false; % Collision flag for UR3e

    % Scale the person vertices
    scaledVertices = personVertexData * scale;

    % Define the rotation matrix for angle degrees around the Z-axis
    rotationMatrixZ = [cosd(angle), -sind(angle), 0;
                       sind(angle), cosd(angle), 0;
                       0, 0, 1];

    % Rotate the scaled vertices
    rotatedVertices = (rotationMatrixZ * scaledVertices')';

    % Determine the color field in personData
    if isfield(personData.vertex, 'red') && ...
       isfield(personData.vertex, 'green') && ...
       isfield(personData.vertex, 'blue')
        % Original colors from vertex data
        colors = [personData.vertex.red, personData.vertex.green, personData.vertex.blue] / 255;
    else
        error('No color field found in the vertex data.');
    end

    % Plot the person using the original vertex colors
    h = trisurf(personFaceData, rotatedVertices(:, 1), rotatedVertices(:, 2), rotatedVertices(:, 3), ...
                'FaceVertexCData', colors, 'EdgeColor', 'none');

    % Determine movement direction based on collision value
    if collision < 0
        yMove = 0.01; % Positive movement if collision is negative
    else
        yMove = -0.01; % Negative movement if collision is positive
    end

    frameRate = 30;
    timePerFrame = 1 / frameRate;

    % Define the timer object
    moveTimer = timer('ExecutionMode', 'fixedRate', 'Period', timePerFrame, 'TimerFcn', @movePersonStep);

    % Start the timer and wait for it to complete
    start(moveTimer);

    function movePersonStep(~, ~)
        % Move the person incrementally along the Y-axis
        if (yMove > 0 && yPosition < collision) || (yMove < 0 && yPosition > collision)
            yPosition = yPosition + yMove; % Update position toward collision
            newVertices = rotatedVertices + [startPos(1), yPosition, startPos(3)];
            set(h, 'Vertices', newVertices);
        end

        % Check for collision with the light curtain
        if (yMove > 0 && yPosition >= collision) || (yMove < 0 && yPosition <= collision)
            if ~UR30EStop && strcmp(robot, "UR30")
                UR30EStop = true; % Set collision flag for UR30
                assignin('base', 'stopUR30', true); % Update in the base workspace
                disp('Collision detected with the Light Curtain! E-Stop triggered for UR30');
            elseif ~UR3eEStop && strcmp(robot, "UR3e")
                UR3eEStop = true; % Set collision flag for UR3e
                assignin('base', 'stopUR3e', true); % Update in the base workspace
                disp('Collision detected with the Light Curtain! E-Stop triggered for UR3e');
            end
        end

        % Stop the timer when the person reaches the end position
        if (yMove > 0 && yPosition >= collision) || (yMove < 0 && yPosition <= collision)
            stop(moveTimer);
            delete(moveTimer);
        end

        drawnow; % Update the figure
    end
end
