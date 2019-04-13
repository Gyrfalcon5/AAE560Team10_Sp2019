function [distList] = busDist(busNode, paxNode, destNode)
B1 = [1 2 3 4 5 6 7 8 9 10 20 30 40 50 60 70 80 90 100 99 98 97 96 95 94 93 92 91 81 71 61 51 41 31 21 11]; %bus paths
B2 = [3 13 23 33 43 53 63 73 74 75 76 77 78 79 80 70 60 50 40 30 20 10 9 8 7 6 5 4];
B3 = [21 22 23 24 25 26 27 28 38 48 58 68 78 88 98 97 96 95 94 93 92 91 81 71 61 51 41 31];
B4 = [10 20 30 40 50 49 48 47 46 36 26 16 6 7 8 9];
B5 = [95 85 75 65 55 54 53 52 51 61 71 81 91 92 93 94];
B1R = flip(B1);
B2R = flip(B2);
B3R = flip(B3);
B4R = flip(B4);
B5R = flip(B5);
loops  = {B1; B2; B3; B4; B5; B1R; B2R; B3R; B4R; B5R};
for idx = 1:10
    B = loops(idx);
    B = cell2mat(B);
    busIndex = find(B == busNode(idx));
    paxIndex = find(B == paxNode(idx));
    destIndex = find(B == destNode(idx));
    if isempty(busIndex)
        distList(idx) = inf;
        continue
    end
    
    if isempty(paxIndex)
        distList(idx) = inf;
        continue
    end
    
    if isempty(destIndex)
        distList(idx) = inf;
        continue
    end
  
    dist = 0;

    while busIndex ~= paxIndex
        dist = dist + 1;
        busIndex = busIndex + 1;
        if busIndex > length(B)
            busIndex = 1;
        end
    end
    while paxIndex ~= destIndex
        dist = dist + 1;
        paxIndex = paxIndex + 1;
        if paxIndex > length(B)
            paxIndex = 1;
        end
    end
    distList(idx) = dist;
end