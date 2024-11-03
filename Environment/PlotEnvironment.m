function PlotEnvironment()
    %% Load Images
    groundImage = 'Floor.png';
    wallImage1 = 'FactoryWall.png'; 
    wallImage2 = 'ExitWall.png'; 

    % Load sign images
    safetySign = 'Saftey.jpg'; 
    robotOperationSign = 'RobotOperation.jpg';
    emergencyStopSign = 'EmergencyStop.jpg';
    cautionRoboticSign = 'CautionRobotic.jpg';
    eyeProtectionSign = 'EyeProtection.png';
    hairContainedSign = 'HairContained.png';

    %% Create the figure window

    hold on;
    %% Sets axis properties
    axis equal;
    xlabel('X');
    ylabel('Y');
    zlabel('Z');
    view(3);
    grid off;  % Turn off the grid

    %% Set axis limits and camera properties
    xmin=-10;
    xmax=4;

    ymin=-4;
    ymax=4;

    zmin=0;
    zmax=3;
    
    xlim([xmin, xmax]);
    ylim([ymin, ymax]);
    zlim([zmin, zmax]);
    
    camlight('headlight');  
    lighting phong;

    %% Create the ground plane
    [xGround, yGround] = meshgrid(-10:0.1:4, -4:0.1:4); 
    zGround = zeros(size(xGround));

    %% Create the first wall plane along the y-axis
    [xWall1, zWall1] = meshgrid(-10:0.1:4.2, 0:0.1:4);
    yWall1 = 4 * ones(size(xWall1));

    %% Create the second wall plane along the x-axis
    [yWall2, zWall2] = meshgrid(-8:0.1:4, 0:0.1:4);
    xWall2 = 4 * ones(size(yWall2));

    %% Plot the ground and walls using the helper function
    plotSurfaceWithTexture(xGround, yGround, zGround, groundImage);
    plotSurfaceWithTexture(xWall1, yWall1, zWall1, wallImage1);
    plotSurfaceWithTexture(xWall2, yWall2, zWall2, wallImage2);

    %% Plot objects using placeAndTransformObject

    % Plot the table
    placeAndTransformObject('tableBrown2.1x1.4x0.5m.ply', [2.4, 3, 0], [0.8, 0.3, 1.6], 90, [0.4, 0.4, 0.4]);

    % Plot the fire extinguisher
    placeAndTransformObject('fireExtinguisher.ply', [2.4, 1.9, 0.01], [1, 1, 1], 0);

    % Plot the person
    placeAndTransformObject('personMaleCasual.ply', [3.4, 3, 0.01], [0.8, 0.8, 0.8], 180);

    % Plot the emergency stop button
    placeAndTransformObject('emergencyStopButton.ply', [2.5, 3, 0.8], [0.5, 0.5, 0.5], 0);

    % Plot the boxes conveyor
    placeAndTransformObject('ConveyerBeltBoxes.ply', [0, 1.69, 0], [1, 1, 1], -90);

    % Plot the pancake conveyor
    placeAndTransformObject('ConveyerBeltPancake.ply', [-3, 2.79, 0], [1, 1, 1], -90);

    % Plot the barriers
    placeAndTransformObject('SafetyWall.ply', [4, 0.6, 0.01], [0.01, 0.01, 0.01], 0, [0.5, 0.5, 0.5]); %Wall without Door
    placeAndTransformObject('PlasticStripDoor.ply', [2.2, 1.8, 0.01], [0.01, 0.01, 0.01], 270, [0.5, 0.5, 0.5]); %Wall with Door

    % Plot the box closer
    placeAndTransformObject('AutoBoxCloser.ply', [-2, -0.325, 0.6], [1, 1, 1], 90, [0.6, 0.6, 0.6]);

    % Plot the boxes
    placeAndTransformObject('BoxOpen.ply', [-6,0.09,0], [1, 1, 1], 90, [0.851, 0.722, 0.545]);
    placeAndTransformObject('BoxOpen.ply', [-4,0.09,0], [1, 1, 1], 90, [0.851, 0.722, 0.545]);

    %Plot the pallet
    placeAndTransformObject('Pallet.ply', [2.3,-0.7,0], [1.2, 1.2, 1.2], 0, [0.851, 0.722, 0.545]);
    placeAndTransformObject('Pallet.ply', [2.3,-0.7,0.15], [1.2, 1.2, 1.2], 90, [0.851, 0.722, 0.545]);
    placeAndTransformObject('Pallet.ply', [2.3,-0.7,0.3], [1.2, 1.2, 1.2], 0, [0.851, 0.722, 0.545]);

    %Plot the forklift
    placeAndTransformObject('Forklift.ply', [2.3,-2.3,0], [1, 1, 1], 0);

    %Plot the Light Curtains
    placeAndTransformObject('LightCurtain.ply', [1.5,-0.35 ,0], [1.6, 1.6, 1], 0, [0.8, 0.0, 0.0], 0.2);
    placeAndTransformObject('LightCurtain.ply', [-5.2,0.6,0], [5, 1.9, 1], 0, [0.8, 0.0, 0.0], 0.2);

    %% Define sign positions and sizes
    signWidth = 0.8;  
    signHeight = 0.6;  
    signLift1 = 0.8;  % Amount to lift the signs above the ground for row 1
    signLift2 = 1.5;  % Amount to lift the signs above the ground for row 2
    
    %Saftey Sign
    safetySignX = -3;
    safetySignY = 3.99;

    %RobotOperation
    robotOperationSignX = -4.3;
    robotOperationSignY = 3.99;

    %RobotOperation
    emergencyStopSignX = -3;
    emergencyStopSignY = 3.99;

    %RobotOperation
    cautionRoboticSignX = -4.3;
    cautionRoboticSignY = 3.99;

    %EyeProtection
    EyeProtectionSignX = 2.75;
    EyeProtectionSignY = 3.99;

    %HairContained
    HairContainedSignX = 2.75;
    HairContainedSignY = 3.99;


    % Plot the sign with the texture
    plotImageOnSurface([safetySignX, safetySignY, signLift1 + signHeight], [safetySignX + signWidth, safetySignY, signLift1 + signHeight], [safetySignX, safetySignY, signLift1], [safetySignX + signWidth, safetySignY, signLift1], safetySign);
    
    plotImageOnSurface([robotOperationSignX, robotOperationSignY, signLift1 + signHeight], [robotOperationSignX + signWidth, robotOperationSignY, signLift1 + signHeight], [robotOperationSignX, robotOperationSignY, signLift1], [robotOperationSignX + signWidth, robotOperationSignY, signLift1], robotOperationSign);

    plotImageOnSurface([emergencyStopSignX, emergencyStopSignY, signLift2 + signHeight], [emergencyStopSignX + signWidth, emergencyStopSignY, signLift2 + signHeight], [emergencyStopSignX, emergencyStopSignY, signLift2], [emergencyStopSignX + signWidth, emergencyStopSignY, signLift2], emergencyStopSign);

    plotImageOnSurface([cautionRoboticSignX, cautionRoboticSignY, signLift2 + signHeight], [cautionRoboticSignX + signWidth, cautionRoboticSignY, signLift2 + signHeight], [cautionRoboticSignX, cautionRoboticSignY, signLift2], [cautionRoboticSignX + signWidth, cautionRoboticSignY, signLift2], cautionRoboticSign);

    plotImageOnSurface([EyeProtectionSignX, EyeProtectionSignY, signLift1 + signHeight], [EyeProtectionSignX + 0.5, EyeProtectionSignY, signLift1 + signHeight], [EyeProtectionSignX, EyeProtectionSignY, signLift1], [EyeProtectionSignX + 0.5, EyeProtectionSignY, signLift1], eyeProtectionSign);

    plotImageOnSurface([HairContainedSignX, HairContainedSignY, signLift2 + signHeight], [HairContainedSignX + 0.5, HairContainedSignY, signLift2 + signHeight], [HairContainedSignX, HairContainedSignY, signLift2], [HairContainedSignX + 0.5, HairContainedSignY, signLift2], hairContainedSign);

    hold off;
end

