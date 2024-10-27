%% Plotting functions
    % Helper function to place and transform objects (scaling, rotation, and color change)
    function placeAndTransformObject(filename, position, scale, rotationAngle, color)
        % Load the PLY file
        [faces, vertices, data] = plyread(filename, 'tri');
        
        % Set the vertex colors to black if specified
        if nargin == 5 && ~isempty(color)
            vertexColors = repmat(color, size(vertices, 1), 1);  % Set to the desired color (black in this case)
        else
            vertexColors = [data.vertex.red, data.vertex.green, data.vertex.blue] / 255;  % Original colors
        end
    
        % Apply scaling
        vertices = vertices .* scale;
    
        % Apply rotation (about the z-axis)
        rotationMatrix = makehgtform('zrotate', deg2rad(rotationAngle));
        vertices = (rotationMatrix(1:3, 1:3) * vertices')';
    
        % Apply translation
        vertices = vertices + position;
    
        % Plot the object with transformed vertices and new color
        trisurf(faces, vertices(:, 1), vertices(:, 2), vertices(:, 3), ...
            'FaceVertexCData', vertexColors, 'EdgeColor', 'none');
    end
    
    