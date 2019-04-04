% Main Script
% This script uses the other m files to run the simulation


%% Prepare Workspace

clc, clear, close all;
import classes.*


%% Initialize Simulation

fig_handle = figure;%('units','normalized','outerposition',[0 0 1 1]);
axis equal;
hold on;
% Creat and plot nodes
x_dim = 10;
y_dim = 10;
axis([0 x_dim+1 0 y_dim+1])
map(x_dim, y_dim) = Node;
for idx = 1:x_dim
    for jdx = 1:y_dim
        map(idx, jdx) = Node;
        map(idx, jdx).coordinate = [idx jdx];
        plotNode(map(idx, jdx))
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


% Making cars
num_cars = 100;
for idx = num_cars:-1:1
    cars(idx) = Vehicle;
    cars(idx).coordinate = [randi([1,x_dim]) randi([1,y_dim])];
    cars(idx).onNode = 1;
    cars(idx).onLink = 0;
    cars(idx).initializePlot();
end

% Stuff for recording
%v = VideoWriter("animation.avi", "Motion JPEG AVI");
%open(v);

while(1)
    nodeCars = cars([cars.onNode] == 1);
    linkCars = cars([cars.onLink] == 1);
    arrayfun(@(x) x.stepForward(), linkCars)
    
    nodeCarsCoords = [nodeCars.coordinate];
    nodeCarsX = nodeCarsCoords(1:2:end);
    nodeCarsY = nodeCarsCoords(2:2:end);
    
    % These blocks assign random directions without making anything go out
    % of bounds. This is complicated now but will not be needed so much
    % later
    % Cars that are not on any edge
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
    
    pause(0.001)
    
    % Stuff for recording
    %frame = getframe(fig_handle);
    %writeVideo(v, frame);

end
close(v)