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

% Making cars
num_cars = 750;
for idx = num_cars:-1:1
    cars(idx) = Vehicle;
    cars(idx).coordinate = [randi([1,x_dim]) randi([1,y_dim])];
    cars(idx).onNode = 1;
    cars(idx).onLink = 0;
    cars(idx).initializePlot();
    cars(idx).destination = randi([1, numel(map)]);
    idle = rand()/4+0.25;
    driving = 1/(rand()*10 + 20);
    cars(idx).efficiency = @(speed) (idle + speed .* driving) ./ 3600;
end

recording = 0;
% Stuff for recording
if recording == 1 
    v = VideoWriter("../animation2.avi", "Motion JPEG AVI");
    open(v);
end

while (1)
    nodeCars = cars([cars.onNode] == 1);
    linkCars = cars([cars.onLink] == 1);
    if ~isempty(linkCars)
        arrayfun(@(x) x.stepForward(mapGraph, map), linkCars);
    end
    
    nodeCarsCoords = [nodeCars.coordinate];
    nodeCarsX = nodeCarsCoords(1:2:end);
    nodeCarsY = nodeCarsCoords(2:2:end);
    if ~isempty(nodeCars)
        arrayfun(@(x) x.stepForward(mapGraph, map), nodeCars);
    end
    
    % This needs to be better when nodes don't take constant time
    travel_times = [links.travel_time] + nodes(1).wait_time;
    mapGraph = graph(s, t, [links.travel_time]);
    
    if sum([cars.arrived]) == length(cars)
        break;
    end
    
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

figure;
hold on;
for car = cars
    plot(car.speeds)
end

speeds = [cars.speeds];
figure;
histogram(speeds)

for idx = length(cars):-1:1
    fuel(idx) = sum(cars(idx).efficiency(cars(idx).speeds));
end
emissions = fuel.* 8.887;
figure;
histogram(emissions)