choiceRecord = zeros(1,1000);
for idx = 1:1000
    costPref = randi(3);
    timePref = randi(3);
    vehiclePref = randi(3);
    startNode = randi(100);
    endNode = randi(100);

    efficiency = 30; %efficiency of car, miles per gallon
    walkSpeed = 1; %blocks per minute
    carSpeed = 5; %blocks per minute
    timeValue = (0.38/2)*timePref; %value of individual's time, in dollars per minute, based on average for Indy
    gasPrice = 2.8; %dollars per gallon
    BlocksPerMile = 17;
    busFare = 1;

    n = 10;
    A = delsq(numgrid('S', (n+2)));
    B = full(A);
    C = abs(B);
    G = graph(C,'omitselfloops');
    %h = plot(G);
    P = shortestpath(G,startNode, endNode); %this is the straight line path from start node to end node
    %highlight(h,P,'NodeColor','g','EdgeColor','g')

    costCar = (((length(P)-1)/BlocksPerMile)/efficiency)*gasPrice + (length(P)-1) * timeValue / carSpeed + 1;
    %carbonEmiss = efficiency * length(P)

    if length(P) < 6 %sets walking cost to inf if the walking distance is more than 5 blocks
        costWalk = (length(P)-1) * timeValue / walkSpeed;
    else
        costWalk = inf;
    end

    [startMins, startPaths] = startWalk(G, startNode); %gets the paths and path lengths to all bus loops from start node
    [endMins, endPaths] = endWalk(G, endNode); %gets the paths and path lengths from all bus loops to end node
    [busWalkDist, bestLoop] = mink(startMins+endMins,1); %adds the min path lengths for start and end walks to find "best" bus loop
    busWalkDist = busWalkDist-1; %adjusts bus walk distance from num of nodes to num of blocks you'd have to walk

    costBus = inf; %temporary

    costs = [costCar costWalk costBus];
    costs(vehiclePref) = costs(vehiclePref)*0.75; %makes the preferred vehicle less expensive by an arbitrary 0.75
    [transportCost, vehicleChoice] = mink(costs, 1); %outputs best vehicle choice and cost of that choice
    choiceRecord(idx) = vehicleChoice;
    idx
end
figure;
histogram(choiceRecord)
