classdef Link < handle
    % Class that defines a single link in a network

    properties
        nodes % The nodes that this link connects
        permitted_vehicles % Types of vehicles that can travel on this link
        num_vehicles % The number of vehicles currently traveling on the link
        travel_fun % Anonymous function that defines travel time
                   % This lets us generate a bunch of links that all calculate
                   % the travel time in different ways without too much effort

    end

    properties (Dependent)
        travel_time % Will have a function that calculates travel time

    end

    methods
        
        % TODO make this actually use travel_fun to calculate time
        function time = get.travel_time(obj)
            time = travel_fun(num_vehicles);
        end
        
        % Constructor
        function obj = Link(nodes, permitted_vehicles, num_vehicles, travel_fun)
            
            if nargin == 0
                args{1} = [];
                args{2} = {'all'};
                args{3} = 0;
                args{4} = @(x) 1;
            else
                args{1} = nodes;
                args{2} = permitted_vehicles;
                args{3} = num_vehicles;
                args{4} = travel_fun;
            end

            obj.nodes = args{1};
            obj.permitted_vehicles = args{2};
            obj.num_vehicles = args{3};
            obj.travel_fun = args{4};

        end
        
        % Plots individual node
        function plotLink(obj)
            x(1) = obj.nodes(1).coordinate(1);
            x(2) = obj.nodes(2).coordinate(1);
            y(1) = obj.nodes(1).coordinate(2);
            y(2) = obj.nodes(2).coordinate(2);
            plot(x, y, 'b');
        end
        
        % Plots many nodes quickly
        function bulkLinkPlot(objs)
            nodes = [objs.nodes];
            starts = [nodes(1:2:end).coordinate]; 
            ends = [nodes(2:2:end).coordinate];
            start_x = starts(1:2:end);
            end_x = ends(1:2:end);
            start_y = starts(2:2:end);
            end_y = ends(2:2:end);
            x = [start_x ; end_x];
            y = [start_y ; end_y];
            plot(x, y, 'b')
        end
    end
end