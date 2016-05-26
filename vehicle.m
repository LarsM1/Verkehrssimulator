classdef vehicle < handle
    %vehicle  vehicles are placed on road objects
    
    properties
        vehicleID
        v_max
        v
        switchToThisRoad %changes to this road when the end of the current road is reached
                         %is -1 by default
                         %is -2 after the vehicle changes a lane (to
                         %prevent another lane change/velocity increase in
                         %the same generation
                         %is -3 
        switchToThisLane
        status %1=accelerating 2=trödeln 3=bremsen
    end
    
    methods
        %constructor
        function obj = vehicle(vehicleID,v_max, v)
            obj.vehicleID = vehicleID;
            obj.v_max = v_max;
            obj.v = v;
            obj.switchToThisRoad = -1;
            obj.switchToThisLane = -1;
        end
        
    end
    
end

