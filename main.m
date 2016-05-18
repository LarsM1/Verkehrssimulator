startup

%% name file
openstreetmap_filename = 'map.osm';
map_img_filename = 'map.png';

%convert XML -> MATLAB struct
[parsed_osm, osm_xml] = parse_openstreetmap(openstreetmap_filename);

%% plot
fig = figure('name','Traffic Network');
ax = axes('Parent', fig);
hold('on')

% plot the network
plot_way(ax, parsed_osm, map_img_filename) % if you also have a raster image

%% find connectivity
[connectivity_matrix, intersection_node_indices] = extract_connectivity(parsed_osm);
uniquend = get_unique_node_xy(parsed_osm, intersection_node_indices);

%draw indizes on nodes
plot_nodes(ax, parsed_osm, intersection_node_indices)

%% osmFunctions end
%% 

%delete nodes that aren't necessary and visible on map, but get parsed anyway
[connectivity_matrix, intersection_node_indices, uniquend] = delete_Node(9,connectivity_matrix, intersection_node_indices,uniquend);
[connectivity_matrix, intersection_node_indices, uniquend] = delete_Node(196,connectivity_matrix, intersection_node_indices,uniquend);

%delete connections that overlap
connectivity_matrix(188,210)=0;
connectivity_matrix(189,192)=0;
connectivity_matrix(194,195)=0;
connectivity_matrix(207,188)=0;
connectivity_matrix(207,208)=0;
connectivity_matrix(188,210)=0;
connectivity_matrix(208,210)=0;

%add paths that lead down
connectivity_matrix(189,188)=1;
connectivity_matrix(188,194)=1;
connectivity_matrix(194,207)=1;
connectivity_matrix(210,189)=1;
connectivity_matrix(208,192)=1;
connectivity_matrix(191,194)=1;
connectivity_matrix(210,195)=1;

%create road objects out of the parsed data
roads = create_roads(connectivity_matrix,uniquend.id, intersection_node_indices,parsed_osm.bounds);

%create roads to enter/exit the network
%enter road
startID=188;
enterRoad = road(length(roads)+1,-1,startID,...
                [parsed_osm.bounds(1,1); uniquend.id(2,find(intersection_node_indices==startID))],...
                uniquend.id(:,find(intersection_node_indices==startID)),...
                5,1,parsed_osm.bounds);
%exit road
endID = 195;
exitRoad = road(length(roads)+2,endID,-2,...
                uniquend.id(:,find(intersection_node_indices==endID)),...
                [uniquend.id(1,find(intersection_node_indices==endID)); parsed_osm.bounds(2,2)+0.001],...
                5,1,parsed_osm.bounds);
roads = [roads enterRoad exitRoad];

entryExitRoad = [length(roads)-1;length(roads)];
%% create test vehicles and place on street
%  speed1=randi(5);
%  speed2=randi(5);
%  speed3=randi(5);
%  speed4=randi(5);
%  speed5=randi(5);
%  speed6=randi(5);
%  speed7=randi(5);
%  
vehicles =  vehicle(1,0,0);
roads(1).cells(1,1)=1;
% vehicles = [vehicles vehicle(4,speed3,0)];
% vehicles = [vehicles vehicle(5,speed4,1)];
% vehicles = [vehicles vehicle(6,speed5,1)];
% vehicles = [vehicles vehicle(7,speed6,1)];

% yo1=randi(5);
% yo2=randi(5);
% yo3=randi(5);
% yo4=randi(5);
% yo5=randi(5);
% yo6=randi(5);
% yo7=randi(5);
% 
% while yo1==yo5
%     yo5=randi(5);
% end
% 
% while yo2==yo6
%     yo6=randi(5);
% end
% while yo3==yo7
%     yo7=randi(5);
% end
% 
% n=length(roads);
% m=4;
% r=randperm(n);
% r=r(1:m);


% roads(r(1)).cells(length(roads(r(1)).cells)-yo1) = vehicles(1).vehicleID;
% roads(r(1)).cells(length(roads(r(1)).cells)-yo5) = vehicles(2).vehicleID;
% roads(r(2)).cells(length(roads(r(2)).cells)-yo2) = vehicles(3).vehicleID;
% roads(r(2)).cells(length(roads(r(2)).cells-yo6)) = vehicles(4).vehicleID;
% roads(r(3)).cells(length(roads(r(3)).cells)-yo3) = vehicles(5).vehicleID;
% roads(r(3)).cells(length(roads(r(3)).cells)-yo7) = vehicles(6).vehicleID;
% roads(r(4)).cells(length(roads(r(4)).cells)-yo4) = vehicles(7).vehicleID;

%% move cars
circles = [];
%vehicles = [];
count=0;
ID_counter=2;
vehiclePositionMatching={};

analysisRoadID = 2;
analysisRoadLane = roads(analysisRoadID).lanes;

fig2 = figure('name',['road ' num2str(analysisRoadID) ' [' num2str(roads(analysisRoadID).from) '->' num2str(roads(analysisRoadID).to) '] at lane ' num2str(analysisRoadLane)]);
fig3 = figure('name',['road ' num2str(analysisRoadID) ' [' num2str(roads(analysisRoadID).from) '->' num2str(roads(analysisRoadID).to) '] at lane ' num2str(analysisRoadLane)]);
ax2 = axes('Parent', fig2);
ax3 = axes('Parent', fig3);

xlabel(ax2,'Time (iteration)')
ylabel(ax2,'Position (cell index)')
title(ax2,'Ort/Zeit Diagramm');
hold (ax2,'on');

xlabel(ax3,'Dichte p (Fahrzeuge/km)')
ylabel(ax3,'Fluss Q (Fahrzeuge/h)')
title(ax3,'Fundamentaldiagramm');
axis(ax3,[0 inf, 0 inf]);
hold (ax3,'on');

while(true)
    pause(1/100);
    count = count+1;

    %spawn random vehicles on random roads
    if rand(1) > 0.7 && spawnVehicles
        %spawn random cars in the entering street (bottom left)
        if roads(enterRoad.roadID).cells(1) == 0 
            vehicles = [vehicles vehicle(ID_counter,randi([3,5]),2)];
            ID_counter = ID_counter + 1;
            roads(enterRoad.roadID).cells(1) = vehicles(length(vehicles)).vehicleID;
        end
        title (ax,['Traffic Network - vehicles: ' num2str(length(vehicles))]);
    end
    
    %generate
	for i=1:length(roads)
        roads(i).overtake(vehicles);
        [roads,vehicles] = roads(i).generate(vehicles,roads,despawnVehicles,entryExitRoad(2));
	end
    
    %delete old car arrows
    for i = 1:length(circles)
        delete(circles(i));
    end
    
	circles = [];
    carCount = [];

    %remove reservation cells (== -1) and update map
    for i=1:length(roads)
        for k=1:roads(i).lanes
            for j=1:length(roads(i).cells)
                if roads(i).cells(k,j) <0
                    roads(i).cells(k,j) = 0;
                    error('ERROR - cell -1');
                end

                %test if car disappeared
                if roads(i).cells(k,j) > 0
                    carCount = [carCount roads(i).cells(k,j)];
                end
            end
        end
        circles = roads(i).draw(circles, ax,parsed_osm.bounds, vehicles);
    end
    
    %% Ort-Zeit
    %generate the Ort/Zeit data
    [vehicleIDs, positions] = roads(analysisRoadID).getVehiclePositionRelation(0,0,analysisRoadLane);
    
    %create ort/zeit data and match it to the existing data
    vehiclePositionMatching = create_raum_zeit_data(vehicleIDs,positions,vehiclePositionMatching, count);
   
    %subplot(1,2,1);
    axis(ax2,[count-60 count, 0 length(roads(analysisRoadID).cells)]);

    for i=1:size(vehiclePositionMatching,2)
        plot(ax2,vehiclePositionMatching{2,i}(:,1),vehiclePositionMatching{2,i}(:,2));
    end
    
    %% Fundamentaldiagramm
    %dichte. extend the road length to 1000 meters
    vehicleCountTemp = round(roads(analysisRoadID).getVehicleCount(0,0,roads(analysisRoadID).lanes)*(1000/roads(analysisRoadID).getLength)); 

    %average speed 
    v=0;
    for abc=1:length(roads(analysisRoadID).cells)
        if roads(analysisRoadID).cells(analysisRoadLane,abc) <= 0
            continue;
        end
        for a = 1:length(vehicles)
            if roads(analysisRoadID).cells(analysisRoadLane,abc) == vehicles(a).vehicleID
                vehicID = a ;
                break;
            end
        end

        v = v + vehicles(vehicID).v;
    end
    %avg cells / time im km/h
    v = (v / vehicleCountTemp)* 5 *3.6;

    scatter(ax3,vehicleCountTemp,v*vehicleCountTemp,'LineWidth',1.5','Marker','*','MarkerEdgeColor','r');
    
    %%
    %reset already-moved-status of vehicles (switchToThisRoad == -2) 
    for i=1:length(vehicles)
        if vehicles(i).switchToThisRoad == -2 || vehicles(i).switchToThisLane == -2
            vehicles(i).switchToThisRoad = -1; 
            vehicles(i).switchToThisLane = -1;
        end
    end
    
    if length(carCount) ~= length(vehicles)
        error(['vehicles disappeared' num2str(length(carCount)) '--' num2str(length(vehicles))]);
	end
end