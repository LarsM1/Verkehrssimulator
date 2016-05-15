function [ roads ] = create_roads( connectivity_matrix, node_positions, intersection_node_indices,bounds)
%create_roads creates road objects out of the connectivity
%   each track has an own object

    roads=[];
    count=1;
    for i=1:length(connectivity_matrix)
        for j=1:length(connectivity_matrix)
            if connectivity_matrix(i,j) == 1
                a=find(intersection_node_indices == i);
                b=find(intersection_node_indices == j);
                                                                                    
                tempRoad=road(count,i,j,node_positions(:,a),node_positions(:,b),5,randi(2),bounds);
                
                count=count+1;
                roads=[roads tempRoad];
            end
        end
    end

end

