startup

%% name file
openstreetmap_filename = 'map.osm';
map_img_filename = 'map.png'; % image file saved from online, if available

%convert XML -> MATLAB struct
[parsed_osm, osm_xml] = parse_openstreetmap(openstreetmap_filename);

%% plot
fig = figure;
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
connectivity_matrix(210,189)=1;
connectivity_matrix(208,192)=1;
connectivity_matrix(191,194)=1;
connectivity_matrix(210,195)=1;
while(true)
%create road objects out of the parsed data
roads = create_roads(connectivity_matrix,uniquend.id, intersection_node_indices,parsed_osm.bounds);

%create roads to enter/exit the network
%enter road
enterRoad=road(length(roads)+1,-1,188,[parsed_osm.bounds(1,1);uniquend.id(2,1)],uniquend.id(:,1),5,1,parsed_osm.bounds);
exitRoad=road(length(roads)+2,195,-2,[uniquend.id(1,6);parsed_osm.bounds(2,2)-0.001],uniquend.id(:,6),5,1,parsed_osm.bounds);
roads=[roads enterRoad exitRoad];
entryExitRoads = [length(roads); length(roads)-1];
%% create test vehicles and place on street
%  speed1=randi(5);
%  speed2=randi(5);
%  speed3=randi(5);
%  speed4=randi(5);
%  speed5=randi(5);
%  speed6=randi(5);
%  speed7=randi(5);
 
%vehicles = vehicle(1,1,1);
% vehicles = [vehicles vehicle(2,speed1,1)];
% vehicles = [vehicles vehicle(3,speed2,1)];
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

%roads(17).cells(roads(17).lanes,length(roads(17).cells)-2) = vehicles(1).vehicleID;

% roads(r(1)).cells(length(roads(r(1)).cells)-yo1) = vehicles(1).vehicleID;
% roads(r(1)).cells(length(roads(r(1)).cells)-yo5) = vehicles(2).vehicleID;
% roads(r(2)).cells(length(roads(r(2)).cells)-yo2) = vehicles(3).vehicleID;
% roads(r(2)).cells(length(roads(r(2)).cells-yo6)) = vehicles(4).vehicleID;
% roads(r(3)).cells(length(roads(r(3)).cells)-yo3) = vehicles(5).vehicleID;
% roads(r(3)).cells(length(roads(r(3)).cells)-yo7) = vehicles(6).vehicleID;
% roads(r(4)).cells(length(roads(r(4)).cells)-yo4) = vehicles(7).vehicleID;

%% move cars
circles=[];
vehicles=[];
count=0;
while(true)
    pause(0.05);
    %disp('loop');
    count = count+1;
    if count>50
        %break;
    end
    %spawn random vehicles on random roads
    if (rand(1) > 0.2)
        %spawn random cars in the entering street (bottom left)
        if roads(18).cells(1) == 0 
            vehicles = [vehicles vehicle(length(vehicles)+1,2,2)];
            roads(18).cells(1) = vehicles(length(vehicles)).vehicleID;
        end
        title (ax,['Vehicle count: ' num2str(length(vehicles))]);
    end
    %generate
	for i=1:length(roads)
        [roads,vehicles] = roads(i).generate(vehicles,roads);
	end
    
    %delete old car arrows
    for i = 1:length(circles)
        delete(circles(i));
    end
	circles=[];
    carCount =[];

    %remove reservation cells (== -1) and update map
    for i=1:length(roads)
        for k=1:roads(i).lanes
            for j=1:length(roads(i).cells)
                if roads(i).cells(k,j) == -1
                    roads(i).cells(k,j) = 0;
                    error('ERROR - cell -1');
                end

                %test if car disappeared
                if roads(i).cells(k,j) >0
                    carCount = [carCount roads(i).cells(k,j)];
                end
            end
        end
        circles = roads(i).draw(circles, ax,parsed_osm.bounds);
    end
    
	if length(carCount) ~= length(vehicles)
        error(['vehicles disappeared' num2str(length(carCount)) '--' num2str(length(vehicles))]);
	end
    %reset already-moved-status of vehicles (switchToThisRoad == -2) 
    for i=1:length(vehicles)
        if vehicles(i).switchToThisRoad == -2
            vehicles(i).switchToThisRoad = -1; 
            vehicles(i).switchToThisLane = -1;
        end
    end
end
end
main
return;

%% testing
for i=1:length(intersection_node_indices)
    disp(['neighbous of ' num2str(intersection_node_indices(i)) ':' num2str(get_neighbours(roads,intersection_node_indices(i)))]);
end


%aaa=([parsed_osm.bounds(1),parsed_osm.bounds(3)]);
%bbb=([parsed_osm.bounds(2),parsed_osm.bounds(4)]);
%from=find(intersection_node_indices==arr(1).from)
%to=find(intersection_node_indices==arr(1).to)
