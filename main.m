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


%create road objects out of the parsed data
[roads] = create_roads(connectivity_matrix,uniquend.id, intersection_node_indices);

%% create test vehicle and place on street
vehicles = vehicle(1,6,1);
vehicles = [vehicles vehicle(2,3,3)];
vehicles = [vehicles vehicle(3,2,3)];
vehicles = [vehicles vehicle(4,2,3)];
vehicles = [vehicles vehicle(5,2,3)];

roads(3).cells(1) = vehicles(2).vehicleID;
roads(3).cells(5) = vehicles(1).vehicleID;
roads(9).cells(5) = vehicles(3).vehicleID;
roads(11).cells(1) = vehicles(4).vehicleID;
roads(17).cells(1) = vehicles(4).vehicleID;

%% move cars
circles=[];
while(true)
    pause(1);
	for i = 1:length(circles)
        delete(circles(i));
	end
	circles=[];

	for i=1:length(roads)
        roads(i).generate(vehicles);
        circles = roads(i).draw(circles, ax,parsed_osm.bounds);
	end
end

%% testing
for i=1:length(intersection_node_indices)
    disp(['neighbous of ' num2str(intersection_node_indices(i)) ':' num2str(get_neighbours(connectivity_matrix,intersection_node_indices(i)))]);
end


%aaa=([parsed_osm.bounds(1),parsed_osm.bounds(3)]);
%bbb=([parsed_osm.bounds(2),parsed_osm.bounds(4)]);
%from=find(intersection_node_indices==arr(1).from)
%to=find(intersection_node_indices==arr(1).to)

%start=stuff(:,from)
%endd=stuff(:,to)


%%
% stuff = uniquend.id
% for i=1:length(stuff)
%     disp(stuff(1,i)) 
%     disp(stuff(2,i))
%     
%     disp(intersection_node_indices(i))
%     disp('---')
% end
