classdef road < handle
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        roadID
        from
        to
        start_coordinate %coordinates
        end_coordinate %coordinates
        v_max
        lanes 
        cells %where the vehicles are stored
    end
    %test commit
    methods
        %constructor
        function obj = road(roadID,from,to,start_coordinate,end_coordinate,v_max,lanes)
            obj.roadID=roadID;
            obj.from=from;
            obj.to=to;
            obj.start_coordinate=start_coordinate;
            obj.end_coordinate=end_coordinate;
            obj.v_max=v_max;
            obj.lanes=lanes;
            obj.cells=zeros(10);
        end
        
        %returns length in meters
        function out = getLength(obj)
            out = 1000*lldistkm(obj.start_coordinate(1),obj.start_coordinate(2),obj.end_coordinate(1),obj.end_coordinate(2));
        end
    end
    
end

