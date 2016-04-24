classdef road < handle
    % road represents a one way road
    
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
            %length of the street in meters divided by one car length
            obj.cells=zeros(1,round(obj.getLength/4));
        end
        
        %returns length in meters
        function out = getLength(obj)
            out = 1000*lldistkm(obj.start_coordinate(1),obj.start_coordinate(2),obj.end_coordinate(1),obj.end_coordinate(2));
        end
        
        %1=right 2=up 3=left 4=down
        function dir = getDirection(obj,bounds)
            %0=rechts 90=unten 180=unten 270=links  
            
            x1=obj.start_coordinate(1)-bounds(1,1);
            y1=obj.start_coordinate(2)-bounds(2,1);
            x2=obj.end_coordinate(1)-bounds(1,1);
            y2=obj.end_coordinate(2)-bounds(2,1);
            
            
            if (x1 == x2)
                if y2 > y1
                	%angle = 0.5*180;
                    dir = 2;
                else
                    %angle = 1.5*180;
                    dir = 4;
                end
                return;
            end

            angle = atan((y2-y1)/(x2-x1));
            if x2 < x1 
                angle = angle + pi;
            end
            
            if angle < 0 
                angle = angle + 2*pi;
            end
            angle = angle * (180/pi);

            if (angle>225 && angle<=315)
                dir = 4;
            elseif (angle>45 && angle<=135)
                dir = 2;
            elseif (angle>135 && angle<=225)
                dir = 3;
            else
                dir = 1;
            end
        end
        
        function circles = draw(obj,circles,ax,bounds)
            %x/y distance from start to fin
            xdist=(obj.start_coordinate(1)-obj.end_coordinate(1));
            ydist=(obj.start_coordinate(2)-obj.end_coordinate(2));
            for j=1:length(obj.cells)
                if (obj.cells(j)~=0)
                    temp1=(xdist/length(obj.cells))*j;
                    temp2=(ydist/length(obj.cells))*j;
                    dir = obj.getDirection(bounds);
                    
                    if dir==1 dirString='>';
                        elseif dir==2 dirString='^';
                        elseif dir==3 dirString='<';
                        else dirString='v';
                    end
                    
                    circles=[circles line(ax,'XData',obj.start_coordinate(1)-temp1, 'YData',obj.start_coordinate(2)-temp2, 'Color','r', ...
                               'Marker',dirString, 'MarkerSize',4)];
                end
            end
        end
        
        function generate(obj,vehicles)
            %beschleunigen
            for t=1:length(obj.cells)
                if (obj.cells(t)~=0)
                    for a=1:length(vehicles)
                        if (obj.cells(t) == vehicles(a).vehicleID)
                            vehicID = vehicles(a).vehicleID;
                            break;
                        end
                    end
                    %set new speed to the vehicle 
                    vehicles(vehicID).v = min([(vehicles(vehicID).v+1), obj.v_max, vehicles(vehicID).v_max]);
                end
            end

            %bremsen
            for alpha=1:length(obj.cells)
                gap=0;
                if obj.cells(alpha)==0
                    continue;
                end
                for x=alpha+1:length(obj.cells)
                    if (obj.cells(x) == 0)
                        gap = gap+1;
                    else
                        break;
                    end
                end                
                for a=1:length(vehicles)
                    if (obj.cells(alpha) == vehicles(a).vehicleID)
                        vehicID = vehicles(a).vehicleID;
                        break;
                    end
                end
                
                if vehicles(vehicID).v > gap
                    vehicles(vehicID).v = gap;
                end
            end

            %trödeln
            for alpha=1:length(obj.cells)
                if (obj.cells(alpha)~=0)
                    if rand(1)>0.9
                        for a=1:length(vehicles)
                            if (obj.cells(alpha) == vehicles(a).vehicleID)
                                vehicID = vehicles(a).vehicleID;
                                break;
                            end
                        end 
                        
                        %if the vehicle isnt standing
                        if (vehicles(vehicID).v) > 0
                            vehicles(vehicID).v = vehicles(vehicID).v - 1;
                        end
                    end
                end
            end

            %bewegen
            for alpha=length(obj.cells):-1:1
                if (obj.cells(alpha)~=0)
                    for a=1:length(vehicles)
                        if (obj.cells(alpha) == vehicles(a).vehicleID)
                            vehicID = vehicles(a).vehicleID;
                            break;
                        end
                    end 
                    
                    disp(['sollte 0 sein: ' num2str(obj.cells(alpha+vehicles(vehicID).v))]);
                    obj.cells(alpha+vehicles(vehicID).v) = vehicles(vehicID).vehicleID;
                    if vehicles(vehicID).v ~= 0
                        obj.cells(alpha) = 0;
                    end
                end
            end
        end
    end
    
end

