function [tracks,active] = PruneTracksMidWay(tracks,fitwidth,active)
disp('Pruning Tracks Midway')
bool = [tracks.len] >= (2*fitwidth+1);
f = fieldnames(tracks)';
f{2,1} = {};

ActiveTracks = struct(f{:});
ActiveTracks(numel(active)) = tracks(active(1));

for i = 1:numel(active)
    ActiveTrackNumber = active(i);
    ActiveTracks(i) = tracks(ActiveTrackNumber);

    if bool(ActiveTrackNumber) == 0
        bool(ActiveTrackNumber) = 1;
    end
end

tracks = tracks(bool);

for i = 1:numel(active)
    for j = numel(tracks):-1:1
        
        if isequal(ActiveTracks(i),tracks(j))
            active(i) = j; %Assign active track the new number
            break %break out of j loop to go to next active loop
        end
    end
end
end