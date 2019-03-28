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


%bulkNodePlot(map(:))
%bulkLinkPlot([links{:}])

axis([0 x_dim+1 0 y_dim+1])
axis equal;
