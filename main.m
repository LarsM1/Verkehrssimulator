%initialize 
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
roads = create_roads(connectivity_matrix,uniquend.id, intersection_node_indices,parsed_osm.bounds,settings);

%create roads to enter/exit the network
%enter road
startID=188;
enterRoad = road(length(roads)+1,-1,startID,...
                [parsed_osm.bounds(1,1); uniquend.id(2,find(intersection_node_indices==startID))],...
                uniquend.id(:,find(intersection_node_indices==startID)),...
                settings.maximumVehicleSpeed,1,parsed_osm.bounds,settings.cellLengthInMeters);
%exit road
endID = 195;
exitRoad = road(length(roads)+2,endID,-2,...
                uniquend.id(:,find(intersection_node_indices==endID)),...
                [uniquend.id(1,find(intersection_node_indices==endID)); parsed_osm.bounds(2,2)+0.001],...
                settings.maximumVehicleSpeed,1,parsed_osm.bounds,settings.cellLengthInMeters);
roads = [roads enterRoad exitRoad];

entryExitRoad = [length(roads)-1;length(roads)];

%% move cars
carArrows = [];
vehicles = [];
count = 0;
ID_counter=1;
vehiclePositionMatching={};

if settings.raumzeitdiagramm
    fig2 = figure('name',['road ' num2str(settings.analysisRoadID) ' [' num2str(roads(settings.analysisRoadID).from) '->' num2str(roads(settings.analysisRoadID).to) '] at lane ' num2str(settings.analysisRoadLane)]);
    ax2 = axes('Parent', fig2);
    xlabel(ax2,'Time (seconds)')
    ylabel(ax2,'Position (meters)')
    title(ax2,'Raum-Zeit-Diagramm');
    hold (ax2,'on');
end

if settings.fundamentaldiagramm
    fig3 = figure('name',['road ' num2str(settings.analysisRoadID) ' [' num2str(roads(settings.analysisRoadID).from) '->' num2str(roads(settings.analysisRoadID).to) '] at lane ' num2str(settings.analysisRoadLane)]);
    ax3 = axes('Parent', fig3);
    xlabel(ax3,'Dichte p (Fahrzeuge/km)')
    ylabel(ax3,'Fluss Q (Fahrzeuge/h)')
    title(ax3,'Fundamentaldiagramm');
    axis(ax3,[0 inf, 0 inf]);
    hold (ax3,'on');
end

while(true)
    pause(settings.delay);
    count = count+1;

    %spawn random vehicles on random roads
    if rand(1) < settings.vehicleSpawnProbability && settings.spawnVehicles
        %spawn random cars in the entering street (bottom left)
        if roads(enterRoad.roadID).cells(1) == 0 
            vehicles = [vehicles vehicle(ID_counter,randi([settings.minimumVehicleSpeed,settings.maximumVehicleSpeed]),2)];
            ID_counter = ID_counter + 1;
            roads(enterRoad.roadID).cells(1) = vehicles(length(vehicles)).vehicleID;
        end
        title (ax,['Traffic Network - vehicles: ' num2str(length(vehicles))]);
    end
    
    %generate
	for i=1:length(roads)
        roads(i).overtake(vehicles);
        [roads,vehicles] = roads(i).generate(vehicles,roads,settings,entryExitRoad(2));
	end
    
    %delete old car arrows
    for i = 1:length(carArrows)
        delete(carArrows(i));
    end
    
	carArrows = [];
    carCount = [];

    %remove reservation cells (== -1) and update map
    for i=1:length(roads)
        for k=1:roads(i).lanes
            for j=1:length(roads(i).cells)
                if roads(i).cells(k,j) < 0
                    roads(i).cells(k,j) = 0;
                    error('ERROR - cell -1');
                end

                %test if car disappeared
                if roads(i).cells(k,j) > 0
                    carCount = [carCount roads(i).cells(k,j)];
                end
            end
        end
        carArrows = roads(i).draw(carArrows, ax,parsed_osm.bounds, vehicles);
    end
    
    %% Raum-Zeit
    if settings.raumzeitdiagramm
        %generate the Raum/Zeit data
        [vehicleIDs, positions] = roads(settings.analysisRoadID).getVehiclePositionRelation(0,0,settings.analysisRoadLane);

        %create Raum/zeit data and match it to the existing data
        vehiclePositionMatching = create_raum_zeit_data(vehicleIDs,positions,vehiclePositionMatching, count,settings.cellLengthInMeters);

        axis(ax2,[count-60 count, 0 length(roads(settings.analysisRoadID).cells)*settings.cellLengthInMeters]);

        for i=1:size(vehiclePositionMatching,2)
            plot(ax2,vehiclePositionMatching{2,i}(:,1),vehiclePositionMatching{2,i}(:,2));
        end
    end
    
    %% Fundamentaldiagramm
    if settings.fundamentaldiagramm
        %dichte. extend the road length to 1000 meters
        vehicleCountTemp = round(roads(settings.analysisRoadID).getVehicleCount(0,0,roads(settings.analysisRoadID).lanes)*(1000/roads(settings.analysisRoadID).getLength)); 

        %average speed 
        v=0;
        for i=1:length(roads(settings.analysisRoadID).cells)
            if roads(settings.analysisRoadID).cells(settings.analysisRoadLane,i) <= 0
                continue;
            end
            for a = 1:length(vehicles)
                if roads(settings.analysisRoadID).cells(settings.analysisRoadLane,i) == vehicles(a).vehicleID
                    vehicID = a ;
                    break;
                end
            end
            v = v + vehicles(vehicID).v;
        end
        %avg cells / time im km/h
        v = (v / vehicleCountTemp)* settings.cellLengthInMeters *3.6;

        scatter(ax3,vehicleCountTemp,v*vehicleCountTemp,'LineWidth',1.5','Marker','*','MarkerEdgeColor','r');
    end
    
    %% reset already-moved-status of vehicles (switchToThisRoad == -2) 
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