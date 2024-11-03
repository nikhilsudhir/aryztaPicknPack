%% Plotting functions
% Helper function to place and transform objects (scaling, rotation, color, and transparency)
function placeAndTransformObject(filename, position, scale, rotationAngle, color, transparency)
    % Load the PLY file
    [faces, vertices, data] = plyread(filename, 'tri');
    
    % Set the vertex colors
    if nargin >= 5 && ~isempty(color)
        vertexColors = repmat(color, size(vertices, 1), 1);  % Custom color
    else
        vertexColors = [data.vertex.red, data.vertex.green, data.vertex.blue] / 255;  % Original colors
    end

    % Set transparency (default to 1 if not specified)
    if nargin < 6 || isempty(transparency)
        transparency = 1; % Fully opaque
    end
    
    % Apply scaling
    vertices = vertices .* scale;

    % Apply rotation (about the z-axis)
    rotationMatrix = makehgtform('zrotate', deg2rad(rotationAngle));
    vertices = (rotationMatrix(1:3, 1:3) * vertices')';

    % Apply translation
    vertices = vertices + position;

    % Plot the object with transformed vertices, color, and transparency
    trisurf(faces, vertices(:, 1), vertices(:, 2), vertices(:, 3), ...
        'FaceVertexCData', vertexColors, 'EdgeColor', 'none', 'FaceAlpha', transparency);
end
