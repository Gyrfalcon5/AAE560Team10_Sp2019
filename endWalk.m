function [minLength, egressNode] = endWalk(G, endNode)
B1 = [1 2 3 4 5 6 7 8 9 10 20 30 40 50 60 70 80 90 100 99 98 97 96 95 94 93 92 91 81 71 61 51 41 31 21 11]; %bus paths
B2 = [3 13 23 33 43 53 63 73 74 75 76 77 78 79 80 70 60 50 40 30 20 10 9 8 7 6 5 4];
B3 = [21 22 23 24 25 26 27 28 38 48 58 68 78 88 98 97 96 95 94 93 92 91 81 71 61 51 41 31];
B4 = [10 20 30 40 50 49 48 47 46 36 26 16 6 7 8 9];
B5 = [95 85 75 65 55 54 53 52 51 61 71 81 91 92 93 94];

[p, d] = shortestpathtree(G, B1, endNode, "OutputForm", "cell", "Method", "positive");
[minLength(1), index] = min(d);
egressNode(1) = p{index}(end);

[p, d] = shortestpathtree(G, B2, endNode, "OutputForm", "cell", "Method", "positive");
[minLength(2), index] = min(d);
egressNode(2) = p{index}(end);

[p, d] = shortestpathtree(G, B3, endNode, "OutputForm", "cell", "Method", "positive");
[minLength(3), index] = min(d);
egressNode(3) = p{index}(end);

[p, d] = shortestpathtree(G, B4, endNode, "OutputForm", "cell", "Method", "positive");
[minLength(4), index] = min(d);
egressNode(4) = p{index}(end);

[p, d] = shortestpathtree(G, B5, endNode, "OutputForm", "cell", "Method", "positive");
[minLength(5), index] = min(d);
egressNode(5) = p{index}(end);

