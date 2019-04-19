function [minLength, onboardNode] = startWalk(G, startNode)
B1 = [1 2 3 4 5 6 7 8 9 10 20 30 40 50 60 70 80 90 100 99 98 97 96 95 94 93 92 91 81 71 61 51 41 31 21 11]; %bus paths
B2 = [3 13 23 33 43 53 63 73 74 75 76 77 78 79 80 70 60 50 40 30 20 10 9 8 7 6 5 4];
B3 = [21 22 23 24 25 26 27 28 38 48 58 68 78 88 98 97 96 95 94 93 92 91 81 71 61 51 41 31];
B4 = [10 20 30 40 50 49 48 47 46 36 26 16 6 7 8 9];
B5 = [95 85 75 65 55 54 53 52 51 61 71 81 91 92 93 94];
for idx = 1:length(B1) %gets shortest path to each node in bus loop 1
    p = shortestpath(G,startNode,B1(idx));
    pathList(idx) = {p};
    pathLength1(idx) = length(p);
end
[minLength(1), index] = mink(pathLength1,1);
path = pathList(index);
path = cell2mat(path);
onboardNode(1) = path(end);


for idx = 1:length(B2) %gets shortest path to each node in bus loop 2
    p = shortestpath(G,startNode,B2(idx));
    pathList(idx) = {p};
    pathLength2(idx) = length(p);
end
[minLength(2), index] = mink(pathLength2,1);
path = pathList(index);
path = cell2mat(path);
onboardNode(2) = path(end);

for idx = 1:length(B3) %gets shortest path to each node in bus loop 3
    p = shortestpath(G,startNode,B3(idx));
    pathList(idx) = {p};
    pathLength3(idx) = length(p);
end
[minLength(3), index] = mink(pathLength3,1);
path = pathList(index);
path = cell2mat(path);
onboardNode(3) = path(end);

for idx = 1:length(B4) %gets shortest path to each node in bus loop 4
    p = shortestpath(G,startNode,B4(idx));
    pathList(idx) = {p};
    pathLength4(idx) = length(p);
end
[minLength(4), index] = mink(pathLength4,1);
path = pathList(index);
path = cell2mat(path);
onboardNode(4) = path(end);

for idx = 1:length(B5) %gets shortest path to each node in bus loop 5
    p = shortestpath(G,startNode,B5(idx));
    pathList(idx) = {p};
    pathLength5(idx) = length(p);
end
[minLength(5), index] = mink(pathLength5,1);
path = pathList(index);
path = cell2mat(path);
onboardNode(5) = path(end);

minLength = minLength - 1;