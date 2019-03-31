% Main Script
% This script uses the other m files to run the simulation


%% Prepare Workspace

clc, clear, close all;
import classes.*


%% Initialize Simulation

figure;
hold on;
% Creat and plot nodes
x_dim = 10;
y_dim = 10;
map(x_dim, y_dim) = Node;
for idx = 1:x_dim
    for jdx = 1:y_dim
        map(idx, jdx) = Node;
        map(idx, jdx).coordinate = [idx jdx];
        plotNode(map(idx, jdx))
    end
end


% Create links between the nodes
links = {};
for idx = 1:x_dim
    for jdx = 1:y_dim

        if idx+1 <= x_dim
            
            links{2*idx - 1}(jdx) = Link([map(idx, jdx) map(idx+1, jdx)],...
                                         {'all'}, 0, @(x) 1);
            plot([map(idx, jdx).coordinate(1), map(idx+1, jdx).coordinate(1)],...
                 [map(idx, jdx).coordinate(2), map(idx+1, jdx).coordinate(2)],...
                 'r');

        end

        if jdx+1 <= y_dim

            links{2*idx}(jdx) = Link([map(idx, jdx) map(idx, jdx+1)],...
                                     {'all'}, 0, @(x) 1);
            plot([map(idx, jdx).coordinate(1), map(idx, jdx+1).coordinate(1)],...
                 [map(idx, jdx).coordinate(2), map(idx, jdx+1).coordinate(2)],...
                 'b');

        end
    end
end

% Make sure all the nodes know what links they have
for idx = 1:length(links)
    for jdx = 1:length(links{idx})
        nodes = links{idx}(jdx).nodes;

        for kdx = 1:length(nodes)
            nodes(kdx).links{end+1} = links{idx}(jdx);
        end
    end
end


% Vehicle
x_v = 7;
y_v = 7;
while(1)
%making a car
green_car = Vehicle;
green_car.coordinate = [x_v,y_v];
green_car.onNode = 1;
green_car.onLink = 0;

%getting info on starting cords
currentMapNodeCoordinates = map(x_v,y_v).coordinate;
currentMapNodeLinks = map(currentMapNodeCoordinates(1),currentMapNodeCoordinates(2)).links;

%getting the number of links
clength = size(currentMapNodeLinks);
numberOfLinks = clength(2);

%random number, so to travel
randomPath = randi([1,numberOfLinks],1,1);

%get the nodes of the choosen link
choosenlink = map(currentMapNodeCoordinates(1),currentMapNodeCoordinates(2)).links{1,randomPath};
nextLinkNodes = map(currentMapNodeCoordinates(1),currentMapNodeCoordinates(2)).links{1,randomPath}.nodes;

%getting the end node and the starting node for current link
if(nextLinkNodes(1).coordinate == [currentMapNodeCoordinates(1),currentMapNodeCoordinates(2)])
    startNode = nextLinkNodes(1);
    endNode = nextLinkNodes(2);
else
    startNode = nextLinkNodes(2);
    endNode = nextLinkNodes(1);
end

%a and b is used so i dont have to type such long code :)
a = startNode.coordinate;
b = endNode.coordinate;

% determine the x values
x = linspace(a(1),b(1),500);

% determine the y values
y = linspace(a(2),b(2),500);

% get a handle to a plot graphics object

%ploting a car

%plot(x,y)
%plotVehicle(green_car,x,y);

hPlot = plot(NaN,NaN,'go');
for k=1:length(x)
     % update the plot graphics object with the next position
     set(hPlot,'XData',x(k),'YData',y(k));

     % pause for 0.5 seconds
     pause(.001);
     
     %to stop the plot from leaving behind phantom cars. very spooooky
     if(k == (length(x)-1))
         hPlot = plot(NaN,NaN,'bo');
         set(hPlot,'XData',1,'YData',1);
     end
end
 
x_v = b(1);
y_v = b(2);
end

%bulkNodePlot(map(:))
%bulkLinkPlot([links{:}])

%axis([0 x_dim+1 0 y_dim+1])
%axis equal;
