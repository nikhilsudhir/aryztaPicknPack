clear;
clf;
clc;

%% Plot the environment
PlotEnvironment1();
hold on;

%% Plot the LinearUR3e
% UR3e1 = UR3eLinearRail(transl(-6.5,0.6,0.65)*trotx(pi/2)*troty(-pi/2));
% UR3e2 = UR3eLinearRail(transl(-4.5,0.6,0.65)*trotx(pi/2)*troty(-pi/2));

%% Plot the UR30
UR30 = UR30(transl(1.4, -0.30, 0.6)*trotz(pi/2));
hold on;

%% Move pancakes to be picked up by UR3e
% PancakeCollectionTest(UR3e1, 8, -15, -10, -6);
% PancakeCollectionTest(UR3e2, 4, -13, -10, -4);

% %% Move boxes to be picked up by UR30

CollisionDetectionUR30(UR30, -1.4, 1, 1.4, 1.85, -0.3, 0.7, 1.5);
