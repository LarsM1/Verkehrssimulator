classdef road < handle
    % road represents a one way street with X lanes
    
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
        function obj = road(roadID,from,to,start_coordinate,end_coordinate,v_max,lanes,bounds,cellLengthInMeters)
            obj.roadID=roadID;
            obj.from=from;
            obj.to=to;
            obj.start_coordinate=start_coordinate;
            obj.end_coordinate=end_coordinate;
            obj.v_max=v_max;
            obj.lanes=lanes;
            %length of the street in meters divided by one car length
            %if the street is going up or down make it longer
            %(langitude/latitude ratio is different)
            if mod(obj.getDirection(bounds),2) == 0 
                factor = cellLengthInMeters/(3 +1/3);
            else
                factor = cellLengthInMeters;
            end
            obj.cells=zeros(lanes,round(obj.getLength/factor));
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

            if (angle > 225 && angle <= 315)
                dir = 4;
            elseif (angle>45 && angle<=135)
                dir = 2;
            elseif (angle>135 && angle<=225)
                dir = 3;
            else
                dir = 1;
            end
        end
        
        function carArrows = draw(obj,carArrows,ax,bounds,vehicles)
            %x/y distance from start to fin
            xdist=(obj.start_coordinate(1)-obj.end_coordinate(1));
            ydist=(obj.start_coordinate(2)-obj.end_coordinate(2));
            for j=1:length(obj.cells)
                for lane=1:obj.lanes
                    if (obj.cells(lane,j) ~= 0)                        
                        temp1=(xdist/length(obj.cells))*j;
                        temp2=(ydist/length(obj.cells))*j;
                        dir = obj.getDirection(bounds);

                        offsetX = 0;
                        offsetY = 0;
                        if dir==1
                            dirString='>';
                            offsetY = -0.00007*lane;
                        elseif dir==2
                            dirString='^';
                            offsetX = 0.00007*lane;
                        elseif dir==3
                            dirString='<';
                            offsetY = 0.00007*lane;
                        else
                            dirString='v';
                            offsetX = -0.00007*lane;
                        end

                        %get vehicle
                        for a=1:length(vehicles)
                            if (obj.cells(lane,j) == vehicles(a).vehicleID)
                                vehicID = a;
                                break;
                            end
                        end
                        
                        if vehicles(vehicID).v == vehicles(vehicID).v_max && vehicles(vehicID).v_max~=0 %max vehicle speed
                            color = 'g';
                        elseif vehicles(vehicID).v == obj.v_max %max road speed
                            color = 'y';
                        elseif vehicles(vehicID).v == 0 || vehicles(vehicID).v_max == 0 %standing
                            color = 'k';
                        elseif vehicles(vehicID).status == 1 %accelerating
                            color = 'b';
                        elseif vehicles(vehicID).status == 2 %tr�deln
                            color = 'm';
                        else %breaking
                            color = 'r';
                        end
                        
                        carArrows=[carArrows line('Parent', ax,'XData',obj.start_coordinate(1)-temp1+offsetX, 'YData',obj.start_coordinate(2)-temp2+offsetY, 'Color','r', ...
                                   'Marker',dirString, 'MarkerSize',6, 'MarkerFaceColor', color, 'MarkerEdgeColor', 'k')];
                    end
                end
            end
        end
        
        function [roads,vehicles] = generate(obj,vehicles,roads,settings,exitRoadID)
            %beschleunigen
            for cell=1:length(obj.cells)
                for lane = 1:obj.lanes
                    if obj.cells(lane,cell) > 0
                        for a = 1:length(vehicles)
                            if obj.cells(lane,cell) == vehicles(a).vehicleID
                                vehicID = a ;
                                break;
                            end
                        end

                        %did the vehicle generate already? skip this cell
                        if vehicles(vehicID).switchToThisRoad == -2
                            continue;
                        end

                        vehicles(vehicID).v = min([vehicles(vehicID).v+1, obj.v_max, vehicles(vehicID).v_max]);
                        vehicles(vehicID).status = 1;
                    end
                end
            end

            %% bremsen
            for alpha=1:length(obj.cells)
                for lane=1:obj.lanes
                    %empty?
                    if obj.cells(lane,alpha) <= 0
                        continue;
                    end

                    %not empty, search vehicleID
                    for a=1:length(vehicles)
                        if (obj.cells(lane,alpha) == vehicles(a).vehicleID)
                            vehicID = a;
                            break;
                        end
                    end

                    %did the vehicle generate already? skip this cell
                    if vehicles(vehicID).switchToThisRoad == -2
                        continue;
                    end

                    freeDrive = true;
                    %calculate the gap on the current road
                    gap = 0;
                    for x = alpha+1:length(obj.cells)
                        if obj.cells(lane,x) == 0
                            gap = gap+1;
                        else
                            freeDrive = false;
                            break;
                        end
                    end

                    %will the vehicle reach the end of the road in this
                    %generation? determinate the new road and block the place
                    %where the vehicle is going to be
                    gapOnNewStreet = 0;
                    if (alpha+vehicles(vehicID).v) > length(obj.cells) && freeDrive
                        if vehicles(vehicID).switchToThisRoad == -1
                            %opportunities to drive next
                            tempNeighbours = get_neighbours(roads, obj.to);
                            %remove exit road if despawning if disabled
                            if settings.despawnVehicles == false
                                tempNeighbours = tempNeighbours(tempNeighbours ~= exitRoadID);
                            end
                            %is there no road to drive to? -->vehicle is on
                            %an exit road: delete it
                            if isempty(tempNeighbours)
                                obj.cells(lane,alpha) = 0;
                                vehicles = vehicles(vehicles ~= vehicles(vehicID));
                                continue;
                            else
                                vehicles(vehicID).switchToThisRoad = tempNeighbours(randi(length(tempNeighbours)));
                            end
                        end
                        %choose a new lane randomly each time
                        vehicles(vehicID).switchToThisLane = randi(roads(vehicles(vehicID).switchToThisRoad).lanes);

                        for a = 1:length(roads)
                            if roads(a).roadID == vehicles(vehicID).switchToThisRoad
                                tempRoadID = a;
                                break;
                            end
                        end

                        %the number of cells the car would drive too far on the
                        %current road                    
                        XCellsTooFar = (alpha+vehicles(vehicID).v) - length(obj.cells);
                        if XCellsTooFar > length(roads(tempRoadID).cells)
                            XCellsTooFar = length(roads(tempRoadID).cells);
                        end
                        
                        for i=1:XCellsTooFar
                            if roads(tempRoadID).cells(vehicles(vehicID).switchToThisLane,i) == 0
                                %block the road segments where the vehicle is going to
                                %drive so no other car is turning into this street at
                                %the same time
                                gapOnNewStreet = gapOnNewStreet + 1;
                                %reserve this cell
                                roads(tempRoadID).cells(vehicles(vehicID).switchToThisLane,i) = -(vehicles(vehicID).vehicleID);
                            else
                                break;
                            end
                        end
                    end

                    %vehicle needs to break
                    if (vehicles(vehicID).switchToThisRoad == -1 || (gap == 0 && freeDrive==false) || freeDrive==false)
                        if (vehicles(vehicID).v > gap)
                            vehicles(vehicID).v = gap;
                            vehicles(vehicID).status = 3;
                        end
                    else
                        if gapOnNewStreet == 0
                            vehicles(vehicID).switchToThisRoad = -1;
                            vehicles(vehicID).switchToThisLane = -1;
                        end
                        vehicles(vehicID).v = gap+gapOnNewStreet;
                    end
                end
            end

            %% tr�deln
            for alpha=1:length(obj.cells)
                for lane=1:obj.lanes
                    if obj.cells(lane,alpha) > 0
                        for a=1:length(vehicles)
                            if (obj.cells(lane,alpha) == vehicles(a).vehicleID)
                                vehicID = a;
                                break;
                            end
                        end
                        
                        %did the vehicle generate already? skip this cell
                        if vehicles(vehicID).switchToThisRoad == -2 || vehicles(vehicID).switchToThisLane == -2
                            continue;
                        end
                        
                        %barlovic model
                        if vehicles(vehicID).v == 1 && vehicles(vehicID).status == 1
                            p = settings.p0;
                        else
                            p = settings.p;
                        end
                        
                        if rand(1) < p
                            %if the vehicle isnt standing and not about to
                            %switch roads/lanes
                            if (vehicles(vehicID).v) > 0 && (vehicles(vehicID).switchToThisRoad == -1) && (vehicles(vehicID).switchToThisLane == -1)
                            	vehicles(vehicID).v = vehicles(vehicID).v - 1;
                            end
                        end
                    end
                end
            end

            %% bewegen
            for alpha=length(obj.cells):-1:1
                for lane=1:obj.lanes
                    if obj.cells(lane,alpha) > 0
                        for a=1:length(vehicles)
                            if (obj.cells(lane,alpha) == vehicles(a).vehicleID)
                                vehicID = a;
                                break;
                            end
                        end

                        %did the vehicle generate already? skip this cell
                        if vehicles(vehicID).switchToThisRoad == -2 || vehicles(vehicID).switchToThisLane == -2
                            continue;
                        end
                       

                        if vehicles(vehicID).switchToThisRoad == -1
                            if (obj.cells(lane,alpha+vehicles(vehicID).v) == 0)
                                obj.cells(lane,alpha+vehicles(vehicID).v) = vehicles(vehicID).vehicleID;
                            end
                        else %vehicle is changing road
                            %get roadID
                            for a = 1:length(roads)
                                if roads(a).roadID == vehicles(vehicID).switchToThisRoad
                                    tempRoadID = a;
                                    break;
                                end
                            end

                            %if the vehicle is able to drive to the next road
                            if alpha+vehicles(vehicID).v > length(obj.cells)
                                XCellsTooFar = (alpha+vehicles(vehicID).v) - length(obj.cells);

                                for b=1:XCellsTooFar
                                    %road is reserved, but for which vehicle?
                                    if -1 * (roads(tempRoadID).cells(vehicles(vehicID).switchToThisLane,b)) == vehicles(vehicID).vehicleID
                                        if b == XCellsTooFar %vehicle can drive all the way on the new road
                                            roads(tempRoadID).cells(vehicles(vehicID).switchToThisLane,XCellsTooFar) = vehicles(vehicID).vehicleID;
                                            %-2 indicates that the vehicle just
                                            %moved to prevent a vehicle moving
                                            %several times in one generation
                                            vehicles(vehicID).switchToThisRoad = -2;
                                            vehicles(vehicID).switchToThisLane = -2;
                                            
                                        else %delete reservation
                                            roads(tempRoadID).cells(vehicles(vehicID).switchToThisLane,b) = 0;    
                                        end
                                    end
                                end
                            end                       
                        end

                        %remove the vehicle from its old position
                        if vehicles(vehicID).v > 0
                            obj.cells(lane, alpha) = 0;
                        end

                        
                    end
                end
            end
        end
        
        function overtake(obj, vehicles)
            for alpha=1:length(obj.cells)
                for lane=1:obj.lanes
                    %empty?
                    if obj.cells(lane,alpha) <= 0
                        continue;
                    end
                    
                    %not empty, search vehicleID
                    for a=1:length(vehicles)
                        if (obj.cells(lane,alpha) == vehicles(a).vehicleID)
                            vehicID = a;
                            break;
                        end
                    end

                    %did the vehicle generate already? skip this cell
                    if vehicles(vehicID).switchToThisRoad == -2
                        continue;
                    end
                    
                    %do not overtake at the start/end of a road
                    if obj.lanes > 1 && vehicles(vehicID).switchToThisLane < 0 && alpha > 6 && alpha+vehicles(vehicID).v+2 < length(obj.cells)
                        %vehicle in front?
                        inFront = 0;
                        if vehicles(vehicID).v == 0
                            stepsForward = 1;
                        else
                            stepsForward = vehicles(vehicID).v;
                        end
                        
                        for r = alpha+1:alpha+stepsForward
                            if obj.cells(lane,r) ~= 0
                                inFront = obj.cells(lane,r);
                                break;
                            end
                        end
                        
                        if inFront <= 0
                            continue;
                        else
                            %not empty, search vehicleID
                            for a=1:length(vehicles)
                                if inFront == vehicles(a).vehicleID
                                    vehicIDinFront = a;
                                    break;
                                end
                            end
                            %vehicle in front of us faster/equally fast
                            %than our vehicle?
                            if vehicles(vehicIDinFront).v_max >= vehicles(vehicID).v_max
                                continue;
                            end
                        end

                        possibleSwitchLanes=[];

                        if lane == 1
                            possibleSwitchLanes = 2;
                        elseif lane == obj.lanes
                            possibleSwitchLanes = lane - 1;
                        else %3 or more lanes
                            possibleSwitchLanes=[lane+1, lane-1];
                        end

                        for k=1:length(possibleSwitchLanes)
                            %check if there's a car behind/in front of us in
                            %the different lane
                            vehicleIDBehind = 0;
                            distanceBehind = 0;

                            for x = alpha-1:-1:alpha-6
                                if obj.cells(possibleSwitchLanes(k),x) ~= 0
                                    if obj.cells(possibleSwitchLanes(k),x) < 0
                                        distanceBehind = -1;
                                        break;
                                    end
                                    distanceBehind = alpha - x;
                                    %get reference ID
                                    for a=1:length(vehicles)
                                        if obj.cells(possibleSwitchLanes(k),x) == vehicles(a).vehicleID
                                            vehicleIDBehind = a;
                                            break;
                                        end
                                    end
                                    break;
                                end
                            end

                            vehicleInFront = false;
                            for x = alpha:alpha+vehicles(vehicID).v+2
                                if obj.cells(possibleSwitchLanes(k),x) ~= 0
                                    vehicleInFront = true;
                                    break;
                                end
                            end

                            %vehicle is driving too fast in
                            %relation to the gap size?
                            if distanceBehind > 0
                                if vehicles(vehicleIDBehind).v > distanceBehind
                                    continue;
                                end
                            end

                            if vehicleInFront ~= false
                                continue;
                            end

                            %change is possible and meaningful, do it
                            obj.cells(possibleSwitchLanes(k),alpha) = vehicles(vehicID).vehicleID;
                            obj.cells(lane,alpha) = 0;
                            break;
                        end
                    end
                end
            end
        end
        
        %pass lane=0 to get result of all lanes
        %pass from=to=0 to get the whole road
        function [vehicleIDs,positions] = getVehiclePositionRelation(obj,from,to,lane)
            if (from == 0) || (to == 0)
               from = 1;
               to = length(obj.cells);
            end
            
            vehicleIDs = [];
            positions = [];
            laneFrom = 1;
            laneTo = obj.lanes;
            for i = from:to
                if lane ~= 0
                    laneFrom  = lane;
                    laneTo = lane;
                end
                
                for j = laneFrom:laneTo
                    if obj.cells(j,i) > 0
                        vehicleIDs = [vehicleIDs obj.cells(j,i)];
                        positions = [positions i];
                    end
                end
            end
        end
        
                %pass lane=0 to get result of all lanes
        %pass from=to=0 to get the whole road
        function vehicleCount = getVehicleCount(obj,from,to,lane)
            if (from == 0) || (to == 0)
               from = 1;
               to = length(obj.cells);
            end
            
            vehicleCount = 0;
            laneFrom = 1;
            laneTo = obj.lanes;
            for i = from:to
                if lane ~= 0
                    laneFrom  = lane;
                    laneTo = lane;
                end
                
                for j = laneFrom:laneTo
                    if obj.cells(j,i) > 0
                        vehicleCount = vehicleCount + 1;
                    end
                end
            end
        end
        
    end
    
end

