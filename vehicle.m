classdef vehicle < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        vehicleID
        roadID
        v_max
        v
        position
    end
    
    methods
        %constructor
        function obj = vehicle(vehicleID,roadID,v_max)
            obj.vehicleID=vehicleID;
            obj.roadID=roadID;
            obj.v_max=v_max;
            obj.v=0;
            obj.position=0;
        end
        
    end
    
end

