%function [costs, times] = routeCost(G, buses)
startNode = randi(100);
endNode = randi(100);

efficiency = 15; %efficiency of car, miles per gallon
walkSpeed = 1; %blocks per minute
carSpeed = 5; %blocks per minute
busSpeed = 5;
gasPrice = 3; %dollars per gallon
BlocksPerMile = 17;
ticketCost = 1;

n = 10;
A = delsq(numgrid('S', (n+2)));
B = full(A);
C = abs(B);
G = graph(C,'omitselfloops');
h = plot(G)
P = shortestpath(G,startNode, endNode); %this is the straight line path from start node to end node
highlight(h,P,'NodeColor','g','EdgeColor','g')

costCar = (((length(P)-1)/BlocksPerMile)/efficiency)*gasPrice + 1;
timeCar = (length(P)-1) / carSpeed;

if length(P) < 6 %sets walking cost to inf if the walking distance is more than 5 blocks
    costWalk = 0;
    timeWalk = (length(P)-1) / walkSpeed;
else
    costWalk = inf;
    timeWalk = inf;
end

[startMins, onboardNode] = startWalk(G, startNode); %gets the paths and path lengths to all bus loops from start node
startMins = [startMins startMins];
onboardNode = [onboardNode onboardNode];

[endMins, egressNode] = endWalk(G, endNode); %gets the paths and path lengths from all bus loops to end node
endMins = [endMins endMins];
egressNode = [egressNode egressNode];

costBus = ticketCost;
busWalkDist = startMins + endMins;
busCoord = {buses.coordinate};
for idx = 1:2 %change for num of buses active
    busCoordInd = busCoord(idx);
    busCoordInd = cell2mat(busCoordInd);
    busCoordInd = round(busCoordInd);
    nodeInd = map(busCoordInd(1),busCoordInd(2));
    busList(idx) = nodeInd.id;
end

busDriveDist = busDist([1 3 21 10 95 1 3 21 10 95], onboardNode, egressNode);
timeBus = (busWalkDist / walkSpeed) + (busDriveDist / busSpeed); %need to add real bus times eventually
[bestBusTime, bestBus] = mink(timeBus,1);

costs = [costCar costWalk costBus]
times = [timeCar timeWalk bestBusTime]