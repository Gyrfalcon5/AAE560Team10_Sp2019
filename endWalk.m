function [minLength, egressNode] = endWalk(G, endNode)

persistent busRoutes
if isempty(busRoutes)
    load("./busRoutes.mat", "busRoutes")
end

for idx = length(busRoutes):-1:1
    [p, d] = shortestpathtree(G, busRoutes{idx}, endNode, "OutputForm", "cell", "Method", "positive");
    [minLength(idx), index] = min(d);
    egressNode(idx) = p{index}(end);
end