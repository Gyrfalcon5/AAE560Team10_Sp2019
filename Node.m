classdef Node < handle
    % Class that defines a single node in a network

    properties
        coordinate % Location of the node on the map
        links % Links that connect to this node
        wait_fun % Anonymous function that defines wait time
        users % List of vehicle at the node
        id % Identifies this node
        busHere
    end

    properties (Dependent)
        wait_time % Will have a functions that calculates wait time
    end
    
    methods
        % For plotting individual nodes
        function plotNode(obj)
            plot(obj.coordinate(1), obj.coordinate(2),'b o')
        end
        
        % For fast plotting of identical nodes
        function bulkNodePlot(objs)
            coords = [objs.coordinate];
            x_coords = coords(1:2:end);
            y_coords = coords(2:2:end);
            plot(x_coords, y_coords, 'b o');
        end

        function time = get.wait_time(obj)
            time = 1;
        end

        function obj = Node(coordinate, links, wait_fun, users)
            
            if nargin == 0
                args{1} = [0 0];
                args{2} = {};
                args{3} = @(x) 1;
                args{4} = 0;
            else
                args{1} = coordinate;
                args{2} = links;
                args{3} = wait_fun;
                args{4} = users;
            end

            obj.coordinate = args{1};
            obj.links = args{2};
            obj.wait_fun = args{3};
            obj.users = args{4};

        end
    end
end

    