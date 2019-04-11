% Main Script
% This script uses the other m files to run the simulation

%% Prepare Workspace

clc, clear, close all;
import classes.*
rng(560)

%% Initialize Simulation

fig_handle = figure;%('units','normalized','outerposition',[0 0 1 1]);
axis equal;
hold on;
% Creat and plot nodes
x_dim = 10;
y_dim = 10;
axis([0 x_dim+1 0 y_dim+1])
map(x_dim, y_dim) = Node;
count = 1;
for idx = 1:x_dim
    for jdx = 1:y_dim
        map(idx, jdx) = Node;
        map(idx, jdx).coordinate = [idx jdx];
        map(idx, jdx).id = count;
        map(idx, jdx).busHere = 0;
        plotNode(map(idx, jdx))
        count = count + 1;
    end
end
xlabel("North ->")
ylabel("West ->")

% Create links between the nodes
links = {};
for idx = 1:x_dim
    for jdx = 1:y_dim

        if idx+1 <= x_dim
            num = randi([5 15]);
            links{2*idx - 1}(jdx) = Link([map(idx, jdx) map(idx+1, jdx)],...
                                         {'all'}, 0, @(x) num);
            plot([map(idx, jdx).coordinate(1), map(idx+1, jdx).coordinate(1)],...
                 [map(idx, jdx).coordinate(2), map(idx+1, jdx).coordinate(2)],...
                 'r');

        end

        if jdx+1 <= y_dim
            num = randi([5 15]);
            links{2*idx}(jdx) = Link([map(idx, jdx) map(idx, jdx+1)],...
                                     {'all'}, 0, @(x) num);
            plot([map(idx, jdx).coordinate(1), map(idx, jdx+1).coordinate(1)],...
                 [map(idx, jdx).coordinate(2), map(idx, jdx+1).coordinate(2)],...
                 'b');

        end
    end
end

links = [links{:}];

% Make sure all the nodes know what links they have
for idx = 1:length(links)
    nodes = links(idx).nodes;

    for jdx = 1:length(nodes)
        nodes(jdx).links{end+1} = links(idx);
    end
end

for idx = numel(links):-1:1
    link = links(idx);
    nodes = link.nodes;
    s(idx) = nodes(1).id;
    t(idx) = nodes(2).id;
    weights(idx) = link.travel_time;
end

mapGraph = graph(s, t, weights);

% Making cars
num_cars = 10;
for idx = num_cars:-1:1
    cars(idx) = Vehicle;
    cars(idx).coordinate = [randi([1,x_dim]) randi([1,y_dim])];
    cars(idx).onNode = 1;
    cars(idx).onLink = 0;
    cars(idx).initializePlot();
    cars(idx).destination = randi([1, numel(map)]);
end

num_buses = 1;
for idx = num_buses:-1:1
    buses(idx) = Bus;
    buses(idx).coordinate = [randi([1,x_dim]) randi([1,y_dim])];
    buses(idx).onNode = 1;
    buses(idx).onLink = 0;
    buses(idx).initializePlot();
    buses(idx).destinationCurrent = 1;
    buses(idx).numberOfPeopleOn = 0;
    %buses(idx).destinationArray = [randi([1, numel(map)]),randi([1, numel(map)]),randi([1, numel(map)]),randi([1, numel(map)])];
    buses(idx).destinationArray = [91,1,10,100,55];
    buses(idx).destination = buses(idx).destinationArray(buses(idx).destinationCurrent);
    buses(idx).waitTime = 0;
    buses(idx).arrayOfPeople = [];
end

num_people = 3;
for idx = num_people:-1:1
    people(idx) = Person;
    people(idx).coordinate = [randi([1,x_dim]) randi([1,y_dim])];
    people(idx).onNode = 1;
    people(idx).onLink = 0;
    %people(idx).initializePlot();
    %people(idx).destination = randi([1, numel(map)]);
    people(idx).destination = (100);
    people(idx).onBus = 0;
    people(idx).onCar = 0;
    people(idx).walking = 1;
    people(idx).personID = idx;
    people(idx).numOfBusStops = 2;
    people(idx).numOfBusStopsIDX = people(idx).numOfBusStops;
    
end
people(1).initializePlot();

people(2).numOfBusStops = 4;
people(2).numOfBusStopsIDX = people(2).numOfBusStops;
people(2).initializePlot();

people(3).numOfBusStops = 3;
people(3).numOfBusStopsIDX = people(3).numOfBusStops;
people(3).initializePlot();

recording = 0;
% Stuff for recording
if recording == 1 
    v = VideoWriter("../animation2.avi", "Motion JPEG AVI");
    open(v);
end

while (1)
    
    
    nodePeople = people([people.onNode] == 1 & [people.onBus] ~= 1);
    linkPeople = people([people.onLink] == 1 & [people.onBus] ~= 1);
    nodeBuses = buses([buses.onNode] == 1);
    linkBuses = buses([buses.onLink] == 1);
    nodeCars = cars([cars.onNode] == 1);
    linkCars = cars([cars.onLink] == 1);
    
    if ~isempty(linkBuses)
        arrayfun(@(x) x.stepForward(mapGraph, map, people), linkBuses);
    end
    
    if ~isempty(linkPeople)
        arrayfun(@(x) x.stepForward(mapGraph, map, buses), linkPeople);
    end
        
    if ~isempty(linkCars)
        arrayfun(@(x) x.stepForward(mapGraph, map), linkCars);
    end
    
    
    nodePeopleCoords = [nodePeople.coordinate];
    nodePeopleX = nodePeopleCoords(1:2:end);
    nodePeopleY = nodePeopleCoords(2:2:end);
    
    nodeBusesCoords = [nodeBuses.coordinate];
    nodeBusesX = nodeBusesCoords(1:2:end);
    nodeBusesY = nodeBusesCoords(2:2:end);
    
    nodeCarsCoords = [nodeCars.coordinate];
    nodeCarsX = nodeCarsCoords(1:2:end);
    nodeCarsY = nodeCarsCoords(2:2:end);
    
    if ~isempty(nodeBuses)
        arrayfun(@(x) x.stepForward(mapGraph, map, people), nodeBuses);
    end
    
    if ~isempty(nodePeople)
        arrayfun(@(x) x.stepForward(mapGraph, map, buses), nodePeople);
    end
    
    if ~isempty(nodeCars)
        arrayfun(@(x) x.stepForward(mapGraph, map), nodeCars);
    end
    % These blocks assign random directions without making anything go out
    % of bounds. This is complicated now but will not be needed so much
    % later
    % Cars that are not on any edge
    %{
    currentCars = nodeCars(nodeCarsX < x_dim &...
                           nodeCarsY < y_dim &...
                           nodeCarsX > 1 &...
                           nodeCarsY > 1);
    directions = {'n', 's', 'e', 'w'};
    arrayfun(@(x) x.setDirection(directions{randi([1, length(directions)])}, map), currentCars)
    
    % Cars on north (right) edge
    currentCars = nodeCars(nodeCarsX == x_dim &...
                           nodeCarsY < y_dim &...
                           nodeCarsX > 1 &...
                           nodeCarsY > 1);
    directions = {'s', 'e', 'w'};
    arrayfun(@(x) x.setDirection(directions{randi([1, length(directions)])}, map), currentCars)
    
    % Cars on west (top) edge
    currentCars = nodeCars(nodeCarsX < x_dim &...
                           nodeCarsY == y_dim &...
                           nodeCarsX > 1 &...
                           nodeCarsY > 1);
    directions = {'s', 'e', 'n'};
    arrayfun(@(x) x.setDirection(directions{randi([1, length(directions)])}, map), currentCars)
    
    % Cars on south (left) edge
    currentCars = nodeCars(nodeCarsX < x_dim &...
                           nodeCarsY < y_dim &...
                           nodeCarsX == 1 &...
                           nodeCarsY > 1);
    directions = {'w', 'e', 'n'};
    arrayfun(@(x) x.setDirection(directions{randi([1, length(directions)])}, map), currentCars)
    
    % Cars on east (bottom) edge
    currentCars = nodeCars(nodeCarsX < x_dim &...
                           nodeCarsY < y_dim &...
                           nodeCarsX > 1 &...
                           nodeCarsY == 1);
    directions = {'w', 's', 'n'};
    arrayfun(@(x) x.setDirection(directions{randi([1, length(directions)])}, map), currentCars)
    
    % Cars on southeast corner
    currentCars = nodeCars(nodeCarsX == 1 & nodeCarsY == 1);
    directions = {'w', 'n'};
    arrayfun(@(x) x.setDirection(directions{randi([1, length(directions)])}, map), currentCars)
    
    % Cars on northeast corner
    currentCars = nodeCars(nodeCarsX == x_dim & nodeCarsY == 1);
    directions = {'w', 's'};
    arrayfun(@(x) x.setDirection(directions{randi([1, length(directions)])}, map), currentCars)
    
    % Cars on southwest corner
    currentCars = nodeCars(nodeCarsX == 1 & nodeCarsY == y_dim);
    directions = {'n', 'e'};
    arrayfun(@(x) x.setDirection(directions{randi([1, length(directions)])}, map), currentCars)
    
    % Cars on nortwest corner
    currentCars = nodeCars(nodeCarsX == x_dim & nodeCarsY == y_dim);
    directions = {'e', 's'};
    arrayfun(@(x) x.setDirection(directions{randi([1, length(directions)])}, map), currentCars)
    %}

    mapGraph = graph(s, t, [links.travel_time]);
    
%     if sum([cars.arrived]) == length(cars)
%         break;
%     end
    
    % Stuff for recording
    if recording == 1
        frame = getframe(fig_handle);
        writeVideo(v, frame);
    else
        pause(0.001)
    end

end

% Stuff for recording
if recording == 1
    close(v)
end