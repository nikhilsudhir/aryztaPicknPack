classdef UR3eLinearRail < RobotBaseClass

    properties(Access = public)   
        plyFileNameStem = 'UR3eLinearRail';
    end
    
    methods
%% Constructor
function self = UR3eLinearRail(baseTr)
			self.CreateModel();
            if nargin < 1			
				baseTr = eye(4);				
            end
            self.model.base = self.model.base.T * baseTr  ;
            
            self.PlotAndColourRobot();         
        end

%% CreateModel
        function CreateModel(self)
            link(1) = Link([pi 0 0 pi/2 1]);
            link(2) = Link('d',0.1519,'a',0,'alpha',pi/2,'qlim',deg2rad([-360 360]), 'offset',0);
            link(3) = Link('d',0,'a',-0.24365,'alpha',0,'qlim', deg2rad([-90 90]), 'offset',0);
            link(4) = Link('d',0,'a',-0.21325,'alpha',0,'qlim', deg2rad([-130 130]), 'offset', 0);
            link(5) = Link('d',0.11235,'a',0,'alpha',pi/2,'qlim',deg2rad([-360 360]),'offset', 0);
            link(6) = Link('d',0.08535,'a',0,'alpha',-pi/2,'qlim',deg2rad([-360 360]), 'offset',0);
            link(7) = Link('d',0.0819,'a',0,'alpha',0,'qlim',deg2rad([-180 180]), 'offset', 0);
             

            link(1).qlim = [-0.8 -0.01];
            link(3).offset = -pi/2;
            link(5).offset = -pi/2;
            self.model = SerialLink(link,'name',self.name);
        end      
    end
end
