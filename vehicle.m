classdef vehicle < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        vehicleID
        v_max
        v
        switchToThisRoad %changes to this road when the end of the current road is reached
    end
    
    methods
        %constructor
        function obj = vehicle(vehicleID,v_max, v)
            obj.vehicleID = vehicleID;
            obj.v_max = v_max;
            obj.v = v;
            obj.switchToThisRoad = -1;
        end
        
        %returns the position on the road
        function out = getPositionOnRoad(obj, roads)

        end
    end
    
end

