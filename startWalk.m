function [minLength, onboardNode] = startWalk(G, startNode)

persistent busRoutes
if isempty(busRoutes)
    load("./busRoutes.mat", "busRoutes")
end

for idx = length(busRoutes):-1:1
    [p, d] = shortestpathtree(G, startNode, busRoutes{idx}, "OutputForm", "cell", "Method", "positive");
    [minLength(idx), index] = min(d);
    onboardNode(idx) = p{index}(end);
end