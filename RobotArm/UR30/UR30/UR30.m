classdef UR30 < RobotBaseClass

    properties(Access = public)   
        plyFileNameStem = 'UR30';
    end
    
    methods
%% Constructor
function self = UR30(baseTr)
			self.CreateModel();
            if nargin < 1			
				baseTr = eye(4);				
            end
            self.model.base = self.model.base.T * baseTr  ;
            
            self.PlotAndColourRobot();         
        end

%% CreateModel
        function CreateModel(self)
            link(1) = Link('d',0.1519,'a',0,'alpha',pi/2,'qlim',deg2rad([-200 200]), 'offset',0);
            link(2) = Link('d',0.0130,'a',-0.32,'alpha',0,'qlim', deg2rad([-60 60]), 'offset', -pi/2);
            link(3) = Link('d',0,'a',-0.25,'alpha',0,'qlim', deg2rad([-90 90]), 'offset', 0);
            link(4) = Link('d',0.103,'a',0,'alpha',pi/2,'qlim',deg2rad([-180 180]),'offset', -pi/2);
            link(5) = Link('d',0.07,'a',0,'alpha',-pi/2,'qlim',deg2rad([-180 180]), 'offset',0);
            link(6) = Link('d',0.134,'a',0,'alpha',0,'qlim',deg2rad([-180 180]), 'offset', 0);
    
            self.model = SerialLink(link,'name',self.name);
        end      
    end
end
