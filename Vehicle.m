classdef Vehicle < handle
    % Class that defines a vehicle

    properties
        coordinate
        onLink
        onNode
        graphicsHandle
        xPath
        yPath
        destination % Will be the node id
        arrived
    end
    
    methods
       
        function obj = Vehicle(coordinate,onLink,onNode)
            
            if nargin == 0
                args{1} = [0 0];
                args{2} = 0;
                args{3} = 0;
            else
                args{1} = coordinate;
                args{2} = onLink;
                args{3} = onNode;
 
            end

            obj.coordinate = args{1};
            obj.onLink = args{2};
            obj.onNode = args{3};
            obj.xPath = [];
            obj.yPath = [];
           
        end
        
        % Initializes the graphics handle, don't call this until you want
        % to plot things
        function initializePlot(obj)
            
            obj.graphicsHandle = plot(obj.coordinate(1),obj.coordinate(2),...
                                      'ko', 'Markerfacecolor', 'k');
            
        end
        
        % This is all we'll use for now with the random business, once we
        % have pathing this can get rolled in to continue its current task
        function setDirection(obj, direction, map)
            
            % Check to make sure we aren't adding a waypoint at a stupid
            % time
            if (obj.onLink == 1)
                ME = MException("Vehicle:cantAddWaypoint",...
             "The Vehicle is on a link and can't accept a new destination");
                throw(ME)
            end
            
            curr_node = map(obj.coordinate(1), obj.coordinate(2));
            
            % This finds the node you want to get to and complains if you
            % tell it to go to a node that doesn't exist
            switch direction
                case 'n'
                    if (obj.coordinate(1)+1 > size(map, 1))
                         ME = MException("Vehicle:cantAddWaypoint",...
                                        "The destination is out of bounds: %s", 'n');
                         throw(ME)
                    end
                    next_node = map(obj.coordinate(1)+1, obj.coordinate(2));
                case 's'
                    if (obj.coordinate(1)-1 < 1)
                         ME = MException("Vehicle:cantAddWaypoint",...
                                        "The destination is out of bounds: %s", 's');
                         throw(ME)
                    end
                    next_node = map(obj.coordinate(1)-1, obj.coordinate(2));
                case 'w'
                     if (obj.coordinate(2)+1 < 1)
                         ME = MException("Vehicle:cantAddWaypoint",...
                                        "The destination is out of bounds: %s", 'w');
                         throw(ME)
                    end
                    next_node = map(obj.coordinate(1), obj.coordinate(2)+1);
                case 'e'
                    if (obj.coordinate(2)-1 > size(map, 2))
                         ME = MException("Vehicle:cantAddWaypoint",...
                                        "The destination is out of bounds: %s", 'e');
                         throw(ME)
                    end
                    next_node = map(obj.coordinate(1), obj.coordinate(2)-1);
            end
            
            % Find our link and get set up for plotting accounting for the
            % travel time
            % TODO add extra time for moving through nodes
            link = intersect([curr_node.links{:}], [next_node.links{:}]);
            obj.xPath = linspace(curr_node.coordinate(1),...
                                 next_node.coordinate(1), link.travel_time);
            obj.yPath = linspace(curr_node.coordinate(2),...
                                 next_node.coordinate(2), link.travel_time);
            obj.stepForward()
        end
        
        function stepForward(obj, mapGraph, map)
            if ~isempty(obj.xPath)
                set(obj.graphicsHandle,'XData',obj.xPath(1),'YData',obj.yPath(1));
                obj.coordinate(1) = obj.xPath(1);
                obj.coordinate(2) = obj.yPath(1);
            end
            % TODO add an arrival flag
            if (length(obj.xPath) < 2)
                obj.onLink = 0;
                obj.onNode = 1;
                current_node = map(obj.coordinate(1), obj.coordinate(2));
                path = shortestpath(mapGraph, current_node.id, obj.destination);
                % This still has problems, need to fix it somehow
                if length(path) == 1
                    obj.arrived = 1;
                    return
                end
                next_node = map([map.id] == path(2));
                if next_node.id == current_node.id
                    obj.arrived = 1;
                    return
                end
                
                link = intersect([current_node.links{:}], [next_node.links{:}]);
                obj.xPath = linspace(current_node.coordinate(1),...
                                     next_node.coordinate(1), link.travel_time);
                obj.yPath = linspace(current_node.coordinate(2),...
                                     next_node.coordinate(2), link.travel_time);
                obj.stepForward();
                
            else
                obj.onLink = 1;
                obj.onNode = 0;
                obj.xPath = obj.xPath(2:end);
                obj.yPath = obj.yPath(2:end);
            end
            
            
            
        end
    end
end