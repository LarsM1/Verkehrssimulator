function [ neighbours ] = get_neighbours( roads, node )
%get_neighbours returns the neighbour IDs (from osm) to which a vehicle
%can drive

neighbours=[];
for i=1:length(roads)
    if roads(i).from == node
        neighbours=[neighbours roads(i).roadID];
    end
end

end

