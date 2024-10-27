classdef Gripper < RobotBaseClass


    properties(Access = public)              
        plyFileNameStem = 'Gripper';
    end

    methods
%% Define robot Function 
function self = Gripper(baseTr)
			self.CreateModel();
            if nargin < 1			
				baseTr = transl(0,0,0);				
            end
            self.model.base =  self.model.base.T * baseTr  ;
            self.PlotAndColourRobot();         
        end

%% Create the robot model
        function CreateModel(self)   
            link(1) = Link('d',-0.01,'a',0.05,'alpha',0,'qlim',deg2rad([0 0]),'offset',deg2rad(0));   
            link(2) = Link('d',-0.01,'a',0.05,'alpha',0,'qlim',deg2rad([0 0]),'offset',deg2rad(0));
            self.model = SerialLink(link,'name',self.name);
            self.model.plotopt3d = {'noarrow','nowrist','nojaxes'};
        end

    end
end




