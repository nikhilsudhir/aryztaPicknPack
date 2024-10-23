function PlotEnvironment()
    %% Load Images
    groundImage = 'concrete.jpg';
    wallImage1 = 'MetalWall.jpg'; 
    wallImage2 = 'MetalWall.jpg'; 

    % Load sign images
    safetySign = 'Saftey.jpg'; 
    robotOperationSign = 'RobotOperation.jpg';
    emergencyStopSign = 'EmergencyStop.jpg';
    cautionRoboticSign = 'CautionRobotic.jpg';
    emergencyExitDoor = 'EmergencyExit.jpg';

    %% Create the figure window
    figure;
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

    camproj('perspective');  
    campos([0, -3, 1.5]);  
    camtarget([0, 0, 1]);  
    camva(6);  
    camlight('headlight');  
    lighting phong;

    %% Create the ground plane
    [xGround, yGround] = meshgrid(xmin:0.1:4, xmin:0.1:4); 
    zGround = zeros(size(xGround));

    %% Create the first wall plane along the y-axis
    [xWall1, zWall1] = meshgrid(xmin:0.1:4, 0:0.1:4);
    yWall1 = 4 * ones(size(xWall1));

    %% Create the second wall plane along the x-axis
    [yWall2, zWall2] = meshgrid(ymin:0.1:4, 0:0.1:4);
    xWall2 = 4 * ones(size(yWall2));

    %% Plot the ground and walls using the helper function
    plotSurfaceWithTexture(xGround, yGround, zGround, groundImage);
    plotSurfaceWithTexture(xWall1, yWall1, zWall1, wallImage1);
    plotSurfaceWithTexture(xWall2, yWall2, zWall2, wallImage2);

    %% Plot objects using placeAndTransformObject

    % Plot the table
    placeAndTransformObject('tableBrown2.1x1.4x0.5m.ply', [2.4, 3, 0], [0.8, 0.3, 1.6], 90, [0.4, 0.4, 0.4]);

    % Plot the fire extinguisher
    placeAndTransformObject('fireExtinguisher.ply', [3.5, 3.5, 0.01], [1, 1, 1], 0);

    % Plot the person
    placeAndTransformObject('personMaleCasual.ply', [3.4, 3, 0.01], [0.8, 0.8, 0.8], 180);

    % Plot the emergency stop button
    placeAndTransformObject('emergencyStopButton.ply', [2.5, 3, 0.8], [0.5, 0.5, 0.5], 0);

    % Plot the boxes conveyor
    placeAndTransformObject('ConveyerBeltBoxes.ply', [1, 1.5, 0], [1, 1, 1], -90);

    % Plot the pancake conveyor
    placeAndTransformObject('ConveyerBeltPancake.ply', [-3, 3, 0], [1, 1, 1], -90);

    % Plot the barriers
    placeAndTransformObject('SafetyWall.ply', [4, 0.6, 0.01], [0.01, 0.01, 0.01], 0, [0.5, 0.5, 0.5]); %Wall without Door
    placeAndTransformObject('PlasticStripDoor.ply', [2.2, 1.8, 0.01], [0.01, 0.01, 0.01], 270, [0.5, 0.5, 0.5]); %Wall with Door

    % Plot the box closer
    placeAndTransformObject('AutoBoxCloser.ply', [-2, -0.525, 0.6], [1, 1, 1], 90, [0.6, 0.6, 0.6]);

    placeAndTransformObject('Pancake.ply', [0, -0.525, 0.6], [1, 1, 1], 90, [0.6, 0.6, 0.6]);


    %% Define sign positions and sizes
    signWidth = 0.8;  
    signHeight = 0.8;  
    signLift = 0.8;  % Amount to lift the signs above the ground
    
    % Define 4 corners for the sign
    
    corner1 = [-4.5, 4, signLift + signHeight];       % Top-left corner
    corner2 = [-4.5 + signWidth, 4, signLift + signHeight];  % Top-right corner
    corner3 = [-4.5, 4, signLift];                    % Bottom-left corner
    corner4 = [-4.5 + signWidth, 4, signLift];        % Bottom-right corner
    
    % Plot the sign with the texture
    plotImageOnSurface(corner1, corner2, corner3, corner4, 'Saftey.jpg');

    hold off;
end

