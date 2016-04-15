function [ roads ] = create_roads( connectivity_matrix, node_positions, intersection_node_indices)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    roads=[];
    count=1;
    for i=1:length(connectivity_matrix)
        for j=1:length(connectivity_matrix)
            if connectivity_matrix(i,j)==1
                a=find(intersection_node_indices==i)
                b=find(intersection_node_indices==j)
                
                tempRoad=road(count,i,j,node_positions(:,a),node_positions(:,b),5,1);
                count=count+1;
                roads=[roads tempRoad];
            end
        end
    end

end
