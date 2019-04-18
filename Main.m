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
        wait = randi([10 30]);
        map(idx, jdx).wait_fun = @(x) wait;
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

load("./busRoutes.mat")
num_buses = 2*length(busRoutes);
for idx = num_buses:-1:1
    buses(idx) = Bus;
    buses(idx).onNode = 1;
    buses(idx).onLink = 0;
    buses(idx).destinationCurrent = 1;
    buses(idx).numberOfPeopleOn = 0;
    % Have to get a bus going each way
    if mod(idx, 2) == 0
        buses(idx).destinationArray = busRoutes{ceil(idx/2)};
    else
        buses(idx).destinationArray = flip(busRoutes{ceil(idx/2)});
    end
    buses(idx).coordinate = [map(buses(idx).destinationArray(1)).coordinate];
    buses(idx).initializePlot();
    buses(idx).destination = buses(idx).destinationArray(buses(idx).destinationCurrent);
    buses(idx).waitTime = 0;
    buses(idx).routeID = ceil(idx/2);
    idle = rand()/4+0.25;
    driving = 1/(normrnd(4, 1)); % Std deviation is made up
    buses(idx).efficiency = @(speed) (idle + speed .* driving) ./ 3600;
end

% Residential is the bottom left quadrant
res_x = 5;
res_y = 5;
map_coords = [map.coordinate];
map_x = map_coords(1:2:end);
map_y = map_coords(2:2:end);
destination_nodes = map(map_x > res_x | map_y > res_y); 

num_people = 750;
for idx = num_people:-1:1
    people(idx) = Person;
    people(idx).coordinate = [randi([1,res_x]) randi([1,res_y])];
    people(idx).home = map(people(idx).coordinate(1), people(idx).coordinate(2)).id;
    people(idx).onNode = 1;
    people(idx).onLink = 0;
    people(idx).initializePlot();
    people(idx).destination = destination_nodes(randi([1, numel(destination_nodes)])).id;
    people(idx).onBus = 0;
    people(idx).onCar = 0;
    people(idx).walking = 0;
    people(idx).vehicle = Vehicle;
    people(idx).vehicle.coordinate = [-1, -1];
    people(idx).vehicle.onNode = 1;
    people(idx).vehicle.onLink = 0;
    people(idx).vehicle.initializePlot();
    idle = rand()/4+0.25;
    driving = 1/(normrnd(24, 5)); % Std deviation is made up
    people(idx).vehicle.efficiency = @(speed) (idle + speed .* driving) ./ 3600;
    
end

arrayfun(@(x) x.decideMode(mapGraph, map), people);

recording = 0;
visualization = 0;
% Stuff for recording
if recording == 1 
    v = VideoWriter("../animation2.avi", "Motion JPEG AVI");
    open(v);
end

commuting_home = 0; % Tells us whether we've done evening rush hour

while (1)

    for idx = 1:num_people
        people(idx).stepForward(mapGraph, map);
    end

    for idx = 1:num_buses
        buses(idx).stepForward(mapGraph, map);
    end

    travel_times = [];
    for idx = length(links):-1:1
        travel_times(idx) = links(idx).link_weight;
    end
    
    mapGraph = graph(s, t, travel_times);
    
    if sum([people.arrived]) == length(people)
        if commuting_home
            break;
        else
            commuting_home = 1;
            for idx = 1:length(people)
                people(idx).destination = people(idx).home;
                people(idx).arrived = 0;
                people(idx).vehicle.arrived = 0;
                people(idx).decideMode(mapGraph, map);
            end
        end
    end
    
    % Stuff for recording
    if recording == 1
        frame = getframe(fig_handle);
        writeVideo(v, frame);
    elseif visualization == 1
        drawnow limitrate
    end

end
%movie(fig_handle, F)
% Stuff for recording
if recording == 1
    close(v)
end
cars = [people.vehicle];
carSpeeds = [cars.speeds];
busSpeeds = [buses.speeds];
speeds = [carSpeeds busSpeeds];

figure;
histogram(speeds)
title("Histogram of Vehicle Speeds")
xlabel("Speed (blocks/sec)")
ylabel("Number of vehicle seconds")

for idx = length(cars):-1:1
    gas(idx) = sum(cars(idx).efficiency(cars(idx).speeds));
end
for idx = length(buses)+length(cars):-1:length(cars)+1
    gas(idx) = sum(buses(idx-length(cars)).efficiency(buses(idx-length(cars)).speeds));
end
    
gasEmissions = 8.887; % kg CO2 / gal
emissions = gas.* gasEmissions;
figure;
histogram(emissions)
title("Histogram of Vehicle Emissions")
xlabel("kg of CO_2")
ylabel("Number of vehicles")
sum(emissions)