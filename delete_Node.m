function [ connectivity_matrix, intersection_node_indices, uniquend] = delete_Node( nodeID, connectivity_matrix, intersection_node_indices ,uniquend)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

%map nodeID to intersection_node_incodes
node_index=find(intersection_node_indices==nodeID);
if isempty(node_index)
    disp('Node not found.')
    return;
end
% delete connectivity matrix elements
for i=1:length(connectivity_matrix)
    connectivity_matrix(nodeID,i)=0;
    connectivity_matrix(i,nodeID)=0;
end

%delete lon,lat positions of the node
id =uniquend.id;
xys=uniquend.xys;

id (:,node_index)=[];
xys(:,node_index)=[];

uniquend.id = id;
uniquend.xys = xys;

%delete the node ID
intersection_node_indices = intersection_node_indices(intersection_node_indices~=nodeID);

end

