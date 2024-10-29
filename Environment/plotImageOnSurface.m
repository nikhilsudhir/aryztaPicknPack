function plotImageOnSurface(corner1, corner2, corner3, corner4, textureImage)
    % corner1, corner2, corner3, corner4: 3D coordinates of the 4 corners of the image
    % textureImage: Path to the image file to be used as texture

    % Create matrices of the corner coordinates
    X = [corner1(1), corner2(1); corner3(1), corner4(1)];
    Y = [corner1(2), corner2(2); corner3(2), corner4(2)];
    Z = [corner1(3), corner2(3); corner3(3), corner4(3)];

    % Plot the surface with the provided texture
    surf(X, Y, Z, 'CData', imread(textureImage), 'FaceColor', 'texturemap', ...
        'EdgeColor', 'none', 'FaceLighting', 'gouraud');
end
