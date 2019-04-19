classdef Bus < handle
    % Class that defines a vehicle

    properties
        coordinate
        onLink
        onNode
        graphicsHandle
        xPath
        yPath
        destination
        destinationArray % Will be an array of node IDs
        destinationCurrent
        arrived
        numberOfPeopleOn
        waitTime
        speeds % Records the velocity of the bus over time for efficiecy 
               % calculations
        efficiency % function that determines the emissions based on speed
        routeID % Tells you what route the bus is on
        arrayOfPeople
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
            
            
            greyHolder = 192/255;
            colorGrey = [greyHolder,greyHolder,greyHolder];
            obj.graphicsHandle = plot(obj.coordinate(1),obj.coordinate(2),...
                                      'ko', 'Markerfacecolor',colorGrey,...
                                      "Markersize", 10);
            
        end
        
        function stepForward(obj, mapGraph, map, people)
            if ~isempty(obj.xPath)
                if obj.xPath(1) ~= obj.coordinate(1) || obj.yPath(1) ~= obj.coordinate(2)
                    set(obj.graphicsHandle,'XData',obj.xPath(1),'YData',obj.yPath(1));
                end
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
                else
                    next_node = map([map.id] == path(2));
                end
                
                if(obj.arrived == 1)
                    %{
                    if(obj.waitTime <= 25)
                       obj.waitTime = obj.waitTime + 1;
                       map(obj.coordinate(1),obj.coordinate(2)).busHere = 1;
                       return
                    end
                    %}
                    numOfdestination = size(obj.destinationArray);
                    if(numOfdestination(2) == obj.destinationCurrent)
                        obj.destinationCurrent = 1;
                    
                    elseif(numOfdestination(2) ~= obj.destinationCurrent)
                        obj.destinationCurrent = obj.destinationCurrent + 1;                        
                    end
                    obj.destination = obj.destinationArray(obj.destinationCurrent);
                    
                    %map(obj.coordinate(1),obj.coordinate(2)).busHere = 0;
                    obj.arrived = 0;
                    %{
                    for idx = obj.numberOfPeopleOn:-1:1
                        currentPerson = obj.arrayOfPeople(idx);
                        for jdx = length(people):-1:1
                            if(people(jdx).personID == currentPerson && people(jdx).numOfBusStopsIDX == 0)
                                people(jdx).onBus = 0;
                                people(jdx).coordinate(1) = obj.coordinate(1); 
                                people(jdx).coordinate(2) = obj.coordinate(2);
                                people(jdx).xPath = obj.coordinate(1);
                                people(jdx).yPath = obj.coordinate(2);
                                people(jdx).destination = map(obj.coordinate(1),obj.coordinate(2)).id;
                                map(obj.coordinate(1),obj.coordinate(2)).busHere = 0;
                                obj.numberOfPeopleOn = obj.numberOfPeopleOn - 1;
                                for kdx = length(obj.arrayOfPeople):-1:1
                                    if(people(jdx).personID == obj.arrayOfPeople(kdx))
                                        obj.arrayOfPeople(kdx) = [];
                                    end
                                end
                                people(jdx).numOfBusStopsIDX = people(jdx).numOfBusStops;
                                disp("wrong");
                            else
                                if(people(jdx).personID == currentPerson)
                                    people(jdx).numOfBusStopsIDX = people(jdx).numOfBusStopsIDX - 1;
                                end
                            end
                        end
                    end
                    %}
                    %obj.waitTime = 0;
                    %return
                end
                next_node = map([map.id] == obj.destination);
                link = intersect([current_node.links{:}], [next_node.links{:}]);
                obj.xPath = linspace(current_node.coordinate(1),...
                                     next_node.coordinate(1), link.travel_time);
                obj.yPath = linspace(current_node.coordinate(2),...
                                     next_node.coordinate(2), link.travel_time);
                obj.speeds = [obj.speeds zeros(1, current_node.wait_time)];
                obj.speeds = [obj.speeds norm([obj.xPath(2) - obj.xPath(1), obj.yPath(2) - obj.yPath(1)])*ones(1,link.travel_time)];                
                obj.yPath = [ones(1,current_node.wait_time)*obj.yPath(1) obj.yPath];
                obj.xPath = [ones(1,current_node.wait_time)*obj.xPath(1) obj.xPath];
                %obj.stepForward(mapGraph, map, people);
                
            else
                obj.onLink = 1;
                obj.onNode = 0;
                obj.xPath = obj.xPath(2:end);
                obj.yPath = obj.yPath(2:end);
            end
            
            
            
        end
    end
end
