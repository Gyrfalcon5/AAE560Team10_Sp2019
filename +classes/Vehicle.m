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