classdef Person < handle
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
        onBus
        onCar
        walking
        vehicle % This holds the reference to the vehicle belonging to the
                % person
        home % Coordinates of the nede that this person considers to be
             % their home
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
                                      'ko', 'Markerfacecolor', 'g');
            
        end
        
        function stepForward(obj, mapGraph, map)
            if obj.arrived
                %do nothing
                return
            elseif obj.onCar
                if obj.vehicle.arrived
                    obj.coordinate = obj.vehicle.coordinate;
                    set(obj.graphicsHandle,'XData',obj.coordinate(1),'YData',obj.coordinate(2));
                    set(obj.vehicle.graphicsHandle,'XData',-1,'YData',-1);
                    obj.arrived = 1;
                    obj.onCar = 0;
                else
                    obj.vehicle.stepForward(mapGraph, map);
                end
            elseif ~isempty(obj.xPath)
                if obj.xPath(1) ~= obj.coordinate(1) || obj.yPath(1) ~= obj.coordinate(2)
                   set(obj.graphicsHandle,'XData',obj.xPath(1),'YData',obj.yPath(1));
                end
                obj.coordinate(1) = obj.xPath(1);
                obj.coordinate(2) = obj.yPath(1);
            end
            % Should find a way to make these checks more compact, but as
            % it stands now they need to be separate so that when it is
            % just starting out it will initialize the path properly, as
            % well as cover the case of when it is nearing a node.
            if (length(obj.xPath) < 2 & obj.walking)
                obj.onLink = 0;
                obj.onNode = 1;
                current_node = map(obj.coordinate(1), obj.coordinate(2));
                path = shortestpath(mapGraph, current_node.id, obj.destination);
                
                if length(path) == 1
                    obj.arrived = 1;                  
                    return
                end
                
                next_node = map([map.id] == path(2));
                if next_node.id == current_node.id
                    obj.arrived = 1;
                    obj.walking = 0;
                    return
                end
                
                link = intersect([current_node.links{:}], [next_node.links{:}]);
                linkTime = link.travel_time * 6;
                obj.xPath = linspace(current_node.coordinate(1),...
                                     next_node.coordinate(1), linkTime);
                obj.yPath = linspace(current_node.coordinate(2),...
                                     next_node.coordinate(2), linkTime);
                obj.yPath = [ones(1,current_node.wait_time)*obj.yPath(1) obj.yPath];
                obj.xPath = [ones(1,current_node.wait_time)*obj.xPath(1) obj.xPath];
                obj.stepForward(mapGraph, map);
                
            elseif obj.walking
                obj.onLink = 1;
                obj.onNode = 0;
                obj.xPath = obj.xPath(2:end);
                obj.yPath = obj.yPath(2:end);
            end
            
            
            
        end
        
        function decideMode(obj, mapGraph, map)
            % Should run some calculations on how to get to destination,
            % and should get ready for that to happen. Right now it decides
            % randomly
            
            decision = rand();
            if decision < 0.5
                % Car Case
                obj.vehicle.coordinate = obj.coordinate;
                obj.vehicle.destination = obj.destination;
                obj.vehicle.stepForward(mapGraph, map);
                obj.onCar = 1;
                obj.onLink = 0;
                obj.onNode = 0;
                set(obj.graphicsHandle,'XData',-1,'YData',-1);
                set(obj.vehicle.graphicsHandle,...
                    'XData', obj.vehicle.coordinate(1),...
                    'YData', obj.vehicle.coordinate(2));
            else
                obj.onLink = 0;
                obj.onNode = 1;
                obj.walking = 1;
                
            end
            
            
            
            
        end
    end
end