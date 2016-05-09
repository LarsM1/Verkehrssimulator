function [ vehiclePositionMatching ] = create_raum_zeit_data(vehicleIDs, positions, vehiclePositionMatching, count)
%create_raum_zeit_diagramm create and update the data structure containing
%the vehicle IDs and their positions in relation to the iteration

 %initial cell setup
    if isempty(vehiclePositionMatching)
        if isempty(vehicleIDs) == false
            vehiclePositionMatching{1,1} = vehicleIDs;
            vehiclePositionMatching{2,1} = [count, positions];
        end
    else
        %delete vehicles that left the area
        toFind=cell2mat(vehiclePositionMatching(1,:));
        for i=1:length(toFind)
            %vehicle is still saved, but not on the road anymore
            if isempty(find(toFind(i) == vehicleIDs)) && size(vehiclePositionMatching,2) <= i
                vehiclePositionMatching(:,i)=[];
            end
        end
            
        for i=1:length(vehicleIDs)
            %new vehicle entered the road?
            if isempty(find([vehiclePositionMatching{1,:}] == vehicleIDs(i)))
                vehiclePositionMatching{1,size(vehiclePositionMatching,2)+1}=vehicleIDs(i);
            end
            
            %add [time, position] vector to the corresponding vehicleID
            index = find([vehiclePositionMatching{1,:}] == vehicleIDs(i));
            vehiclePositionMatching{2,index}=[vehiclePositionMatching{2,index};count,positions(i)];
        end
    end
end

