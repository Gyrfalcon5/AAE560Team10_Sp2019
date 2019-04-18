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
        personID
        numOfBusStops
        numOfBusStopsIDX
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
            if(obj.numOfBusStops == 4)
                obj.graphicsHandle = plot(obj.coordinate(1),obj.coordinate(2),...
                                          'ko', 'Markerfacecolor', 'y');
            
            elseif(obj.numOfBusStops == 3)
                obj.graphicsHandle = plot(obj.coordinate(1),obj.coordinate(2),...
                                          'ko', 'Markerfacecolor', 'r');
            else
                obj.graphicsHandle = plot(obj.coordinate(1),obj.coordinate(2),...
                                          'ko', 'Markerfacecolor', 'g');
            end
        end
        
        function stepForward(obj, mapGraph, map, buses)
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
                    if(obj.onBus == 0)
                        if(map(obj.coordinate(1),obj.coordinate(2)).busHere == 1)
                            obj.onBus = 1;
                            obj.walking = 0;
                            num_buses = length(buses);
                            for idx = num_buses:-1:1
                                if(buses(idx).coordinate(1) == obj.coordinate(1) && buses(idx).coordinate(2) == obj.coordinate(2))
                                    buses(idx).numberOfPeopleOn = buses(idx).numberOfPeopleOn + 1;
                                    buses(idx).arrayOfPeople(buses(idx).numberOfPeopleOn) = obj.personID;
                                    break;
                                end

                            end
                            if(obj.onBus == 1)
                                obj.coordinate(1) = -1;
                                obj.coordinate(2) = -1;
                                set(obj.graphicsHandle,'XData',obj.coordinate(1),'YData',obj.coordinate(2));
                                disp("hi");
                            end
                        end
                    end
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