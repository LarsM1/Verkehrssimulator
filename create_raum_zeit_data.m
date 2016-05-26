function [ vehiclePositionMatching ] = create_raum_zeit_data(vehicleIDs, positions, vehiclePositionMatching, count,cellLengthInMeters)
%create_raum_zeit_diagramm create and update the data structure containing
%the vehicle IDs and their positions in relation to the iteration


%convert to meters
positions = positions.*cellLengthInMeters;
%initial cell setup
	if isempty(vehiclePositionMatching)
        if isempty(vehicleIDs) == false
            index1 = 1;

            for i=1:length(vehicleIDs)
                vehiclePositionMatching{1,index1} = vehicleIDs(index1);
                vehiclePositionMatching{2,index1} = [count, positions(index1)];
                index1 = index1 +1;
            end
        end
	else           
        for i=1:length(vehicleIDs)
            %new vehicle entered the road?
            if isempty(find([vehiclePositionMatching{1,:}] == vehicleIDs(i)))
                vehiclePositionMatching{1,size(vehiclePositionMatching,2)+1}=vehicleIDs(i);
            end
            
            %add [time, position] vector to the corresponding vehicleID
            index = find([vehiclePositionMatching{1,:}] == vehicleIDs(i));
            
            vehiclePositionMatching{2,index}=[vehiclePositionMatching{2,index};count,positions(i)];
        end
        
        %delete vehicles that left the area
        toFind = cell2mat(vehiclePositionMatching(1,:));
        for i=length(toFind):-1:1
            %vehicle is still saved, but not on the road anymore
            if isempty(find(toFind(i) == vehicleIDs))
                vehiclePositionMatching(:,i)=[];
            end
        end
	end
end

