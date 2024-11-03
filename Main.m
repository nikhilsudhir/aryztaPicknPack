clear;
clf;
clc;

%% Plot the environment
PlotEnvironment();
hold on;

%% Plot the LinearUR3e
UR3e1 = UR3eLinearRail(transl(-6.5,0.6,0.65)*trotx(pi/2)*troty(-pi/2));
UR3e2 = UR3eLinearRail(transl(-4.5,0.6,0.65)*trotx(pi/2)*troty(-pi/2));

%% Plot the UR30
UR30 = UR30(transl(1.4, -0.30, 0.6)*trotz(pi/2));
hold on;

%% Move pancakes to be picked up by UR3e
movePancakes(UR3e1, 8, -15, -10, -6);
movePancakes(UR3e2, 4, -13, -10, -4);

%% Move boxes to be picked up by UR30
boxCollection(UR30, 0, 1, 1.4, 2.8, -1.5, 0.5);
boxCollection(UR30, -1.4, 1, 1.4, 1.85, -0.3, 0.7);

% %% Testing collision detection of UR30
% CollisionDetectionUR30(UR30, -1.4, 1, 1, 2.3, -0.7, 0.45, 0.8, 1.5, 1);
% pause(11.5);
% CollisionDetectionUR30(UR30, 1.4, 1.4, 0, 2.3, -0.7, 0.8, 0.45, 3, -1);


% %% Testing Light Curtain Object detection
% stopSignalByUser([1.1, -3, 0],-1.7, 90, "UR30");
% 
% stopSignalByUser([-6.9, 3.8, 0],2.1, -90, "UR3e");
