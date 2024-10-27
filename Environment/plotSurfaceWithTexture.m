%% Helper function to plot surfaces with texture and hide gridlines
    function plotSurfaceWithTexture(X, Y, Z, textureImage)
        surf(X, Y, Z, 'CData', imread(textureImage), 'FaceColor', 'texturemap', ...
            'EdgeColor', 'none', 'FaceLighting', 'gouraud');  % Remove gridlines and apply lighting
    end