classdef LazerCollisionDetector < handle

    methods
        function self = laser()
            set(0, 'DefaultFigureWindowStyle', 'docked');
            self.LaserDetection();
        end
    end

    methods (Static)

        %% LaserDetection
        % Simulate a laser beam and detect intersections with objects (e.g., plane)
        function LaserDetection()
            % Define the plane's normal and point (e.g., position of an object)
            planeNormal = [-1, 0, 0];
            planePoint = [0.7, 0, 0]; % Position of a person or object in the scene

            % Define the laser beam as a line with a start and end point
            laserStartPoint = [0.7, 0.8, 0.5]; % Start point of the laser (e.g., robot's end effector)
            laserEndPoint = [0.7, -3.3, 0.5]; % End point of the laser (direction of the beam)

            % Calculate the intersection point between the laser and the plane
            [intersectionPoint, check] = LinePlaneIntersection(planeNormal, planePoint, laserStartPoint, laserEndPoint);

            % Display the results
            disp('Intersection Point:');
            disp(intersectionPoint);
            disp('Intersection Check Status:');
            disp(check);

            % Visualize the plane, laser beam, and intersection point
            PlaceObject('personMaleCasual.ply', [0.7, 0, 0]); % Position the object (e.g., person) in the scene

            hold on;
            % Plot laser beam start and end points
            plot3(laserStartPoint(1), laserStartPoint(2), laserStartPoint(3), 'ro', 'MarkerSize', 8);
            plot3(laserEndPoint(1), laserEndPoint(2), laserEndPoint(3), 'bo', 'MarkerSize', 8);
            % Draw the laser beam as a line
            plot3([laserStartPoint(1), laserEndPoint(1)], [laserStartPoint(2), laserEndPoint(2)], [laserStartPoint(3), laserEndPoint(3)], 'r', 'LineWidth', 2);
            % Highlight the intersection point if there's an intersection
            if check == 1 || check == 2 % Check if there's an intersection
                plot3(intersectionPoint(1), intersectionPoint(2), intersectionPoint(3), 'g*', 'MarkerSize', 10);
            end

            axis equal;
            xlabel('X');
            ylabel('Y');
            zlabel('Z');
            title('Laser Collision Detection Visualization');
        end

        %% CheckCollision
        % Check for collisions with a spherical object (e.g., proximity to an object)
        function isCollision = CheckCollision(robot, sphereCenter, radius)
            % Get the current position of the robot's end effector
            tr = robot.fkine(robot.getpos).T;
            endEffectorToCenterDist = sqrt(sum((sphereCenter - tr(1:3, 4)').^2));

            % Check if the distance is less than or equal to the radius (collision detected)
            if endEffectorToCenterDist <= radius
                disp('Collision detected with the object!');
                isCollision = 1;
            else
                disp(['SAFE: Distance (', num2str(endEffectorToCenterDist), 'm) is greater than the radius (', num2str(radius), 'm).']);
                isCollision = 0;
            end
        end

    end
end
