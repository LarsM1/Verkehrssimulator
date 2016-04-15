close all
clear all
%% name file
openstreetmap_filename = 'map.osm';
map_img_filename = 'map.png'; % image file saved from online, if available

%% convert XML -> MATLAB struct
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

%draw streets
plot_nodes(ax, parsed_osm, intersection_node_indices)

%delete nodes that aren't necessary and visible on map, but get parsed anyway
[connectivity_matrix, intersection_node_indices, uniquend] = delete_Node(9,connectivity_matrix, intersection_node_indices,uniquend)
[connectivity_matrix, intersection_node_indices, uniquend] = delete_Node(196,connectivity_matrix, intersection_node_indices,uniquend)

%delete connections that overlap
connectivity_matrix(188,210)=0;
connectivity_matrix(189,192)=0;
connectivity_matrix(194,195)=0;
connectivity_matrix(207,188)=0;
connectivity_matrix(207,208)=0;
connectivity_matrix(188,210)=0;
connectivity_matrix(208,210)=0;

%create road objects out of the parsed data
[roads] = create_roads(connectivity_matrix,uniquend.id, intersection_node_indices);


%% testing

for i=1:length(roads)
    disp([ 'länge road' num2str(roads(i).roadID) '[' num2str(roads(i).from) '-->' num2str(roads(i).to) '] = ' num2str(roads(i).getLength) ]);
end

%get_neighbours(connectivity_matrix,189)


% for i=1:length(roads)
%     road = roads(i);
%     neighb = get_neighbours(connectivity_matrix,road.from)
%     for j=1:neighb
%         lonlat=
%         lldistkm(road.start_coordinate(1),road.start_coordinate(2),
%         disp(['von ' num2str(j) ' zu: ' num2str(j) ':' ]);
%     end
%     a = road.start_coordinate;
%     
% end

count=1;
arr=[];
testObject = vehicle(count,1,5);
count=count+1;
testObject.v=3;
arr=[arr testObject];
testobject2 = vehicle(count,2,5);
arr=[arr testobject2];
count=count+1;
for i=1:length(arr)
    %disp(arr(i).v)
    %arr(i).drive();
    %disp(arr(i))
end

aaa=([parsed_osm.bounds(1),parsed_osm.bounds(3)]);
bbb=([parsed_osm.bounds(2),parsed_osm.bounds(4)]);
%from=find(intersection_node_indices==arr(1).from)
%to=find(intersection_node_indices==arr(1).to)

%start=stuff(:,from)
%endd=stuff(:,to)

%n=1000
%{for i=n:-5:1
%    plot(i,i,'or','MarkerSize',5,'MarkerFaceColor','r')
%    pause(1)
%end

%%
% stuff = uniquend.id
% for i=1:length(stuff)
%     disp(stuff(1,i)) 
%     disp(stuff(2,i))
%     
%     disp(intersection_node_indices(i))
%     disp('---')
% end
