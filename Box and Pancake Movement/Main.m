clear gloabl;
clf;
clc;


%% Plot the environment
PlotEnvironment();
hold on;

%% Plot the LinearUR3 and define the end effector position

% Initialise the LinearUR3
robot = UR3eLinearRail(transl(-6,0.6,0.6)*trotx(pi/2)*troty(pi/2));
hold on;

%% Move pancakes and pick them up
movePancakesPly(robot); % Pass the robot to the pancake function

    % % Initialize the gripper and plot at the robot's end-effector position
    % qNow = robot.model.getpos();
    % base = robot.model.fkineUTS(qNow);
    % finger1 = Gripper(base * trotx(pi/2)); % Initialize gripper
