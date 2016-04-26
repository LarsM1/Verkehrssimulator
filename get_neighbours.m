function [ neighbours ] = get_neighbours( roads, node )
%get_neighbours gibt die Nachbarn zur�ck, zu denen ein Fahrzeug fahren
%k�nnte von Punkt <node> aus
% <node> ist dabei der index von OSM, neighbours beinhaltet die IDs von den
% road-Objekten (1-x)

neighbours=[];
for i=1:length(roads)
    if roads(i).from == node
        neighbours=[neighbours roads(i).roadID];
    end
end

end

