% In MainGuiTest.m
function MainGuiTest(app)
    %% Environment Setup
    clf; % Clears only the figure, without affecting the app
    clc;

     
    %% Plot the environment
    PlotEnvironment();
    hold on;
    %% Plot the LinearUR3e
    UR3e1 = UR3eLinearRail(transl(-6.5,0.6,0.65)*trotx(pi/2)*troty(-pi/2));
    UR3e2 = UR3eLinearRail(transl(-4.5,0.6,0.65)*trotx(pi/2)*troty(-pi/2));
    %%
    % Move pancakes to be picked up by UR3e
    movePancakes(UR3e1, 8, -15, -10, -6);
    movePancakes(UR3e2, 4, -13, -10, -4);
    disp('Working Project.');
         
  
end