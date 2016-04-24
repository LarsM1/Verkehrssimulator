function [ neighbours ] = get_neighbours( connectivity_matrix, node )
%get_neighbours gibt die Nachbarn zur�ck, zu denen ein Fahrzeug fahren
%k�nnte von Punkt <node> aus

neighbours=[];
for i=1:length(connectivity_matrix)
    if (connectivity_matrix(node,i)==1)
        neighbours=[neighbours i];
    end
end

end

