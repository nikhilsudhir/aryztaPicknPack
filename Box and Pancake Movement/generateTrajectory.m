function [trajectory] = generateTrajectory(robot, targetPosition, initialGuess)
    % Set the number of steps for trajectory interpolation
    numSteps = 100;

    % Get the current joint positions of the robot
    currentJointPositions = robot.model.getpos();

    % Define the transformation matrix to reach the target position
    transformationMatrix = transl(targetPosition) * trotx(pi);

    % Solve inverse kinematics to find the required joint positions
    targetJointPositions = wrapToPi(robot.model.ikcon(transformationMatrix, initialGuess));

    % Generate a joint trajectory from the current to the target joint positions
    trajectory = jtraj(currentJointPositions, targetJointPositions, numSteps);
end
