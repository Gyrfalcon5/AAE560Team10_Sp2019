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
        home % Coordinates of the node that this person considers to be
             % their home
        personID
        % I don't really see how to use this, so I am going to do it
        % differently for now - Evan
        numOfBusStops
        numOfBusStopsIDX
        
        boardingStop % stop you go to where you want the bus to get you
        egressStop % stop you get off the bus at
        rodeBus % Tracks if the person has already ridden the bus on this
                % trip
        busLine % Tracks what bus line the person wants to ride so they
                % don't get on the wrong bus. If it's 0, they don't want to
                % ride the bus.
        currentBus % The bus we're riding so we don't have to keep track
        timeValue
        busImOn
        transitCosts % This records how much cost was incurred for transit,
                     % including the cost of the person's time
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
        
        function stepForward(obj, mapGraph, map, buses)
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
                
            elseif obj.busLine
                % Bus riding case, a lot of overlap with walking but that's
                % okay, might be able to reduce it
                if obj.rodeBus
                    obj.walking = 1; % to reuse walking code after the bus
                    for idx = length(buses):-1:1
                        if(buses(idx).busID == obj.busImOn)
                            buses(idx).numberOfPeopleOn = buses(idx).numberOfPeopleOn - 1;
                        end                       
                    end
                else
                    % Check if we are at our stop
                    if obj.onNode
                        currentNode = map(obj.coordinate(1), obj.coordinate(2));
                        if currentNode.id == obj.boardingStop
                            obj.walking = 0;
                            % Look for buses and get on the right one
                            busCoordinates = [buses.coordinate];
                            busX = busCoordinates(1:2:end);
                            busY = busCoordinates(2:2:end);
                            % Get only buses here that are on the route we want to
                            % ride
                            busesHere = buses(busX == obj.coordinate(1) ...
                                            & busY == obj.coordinate(2) ...
                                            & [buses.routeID] == obj.busLine);
                            % TODO finish this, I think its the last thing
                            % we need
                            if ~isempty(busesHere)
                                obj.currentBus = busesHere(1);
                                if(obj.currentBus.numberOfPeopleOn <= 30)
                                
                                    obj.onBus = 1;
                                    obj.onNode = 0;
                                    obj.currentBus.numberOfPeopleOn =  obj.currentBus.numberOfPeopleOn + 1;
                                    obj.busImOn = obj.currentBus.busID;
                                    set(obj.graphicsHandle,'XData',-1,'YData',-1);
                                else
                                    fprintf("GET DAT DOG N SUDS BRAH!\n");
                                end
                            end
                                
                        else
                            % Should be mostly walking code, walk to the
                            % boarding stop
                            obj.walking = 1;
                            destination = obj.boardingStop; % to reuse walking
                        end
                    elseif obj.onLink
                        % More walking code to get to the boarding stop
                        obj.walking = 1;
                        
                    elseif obj.onBus
                        % Code to check if the bus has arrived, and if so,
                        % set rodeBus to 1
                        if obj.currentBus.onNode
                            if map(obj.currentBus.coordinate(1),obj.currentBus.coordinate(2)).id == obj.egressStop
                                % If we are at the stop where we get off
                                obj.coordinate = obj.currentBus.coordinate;
                                set(obj.graphicsHandle,'XData',obj.coordinate(1),'YData',obj.coordinate(2));
                                obj.rodeBus = 1;
                                obj.onBus = 0;
                            end
                            % Just wait if the bus hasn't arrived
                        end
                    else
                        fprintf("There's a unhandled case in person.stepForward!")
                    end 
                end 
            end
            % This lets us use the walking code for bus and just walking
            if exist('destination', 'var') ~= 1
                destination = obj.destination;
            end
            if ~isempty(obj.xPath)
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
                path = shortestpath(mapGraph, current_node.id, destination, "Method", "positive");
                % This still has problems, need to fix it somehow
                
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
                obj.stepForward(mapGraph, map, buses);
                
            elseif obj.walking
                obj.onLink = 1;
                obj.onNode = 0;
                obj.xPath = obj.xPath(2:end);
                obj.yPath = obj.yPath(2:end);
            end
            
            
            
        end
        
        function decideMode(obj, walkGraph, carGraph, map, gasPrice, busFare)
            % Should run some calculations on how to get to destination,
            % and should get ready for that to happen. Right now it decides
            % randomly
            
            blocksPerMile = 17;
            currentNode = map(obj.coordinate(1), obj.coordinate(2)).id;
            [path, time] = shortestpath(carGraph, currentNode, obj.destination, "Method", "positive");
            speed = (length(path)-1)*blocksPerMile / time;
            fuel = obj.vehicle.efficiency(speed)*time;
            
            costCar = fuel*gasPrice + time*obj.timeValue + 1; % The one is for having to own a car, I think
            
            if length(path) < 6 %sets walking cost to inf if the walking distance is more than 5 blocks
                [~, time] = shortestpath(walkGraph, currentNode, obj.destination, "Method", "positive");
                costWalk = time*obj.timeValue;
            else
                costWalk = inf;
            end
            
            [startMins, startPaths] = startWalk(walkGraph, currentNode);
            [endMins, endPaths] = endWalk(walkGraph, obj.destination);
            
            [busWalkDist, bestLoop] = mink(startMins+endMins,1);
            boardingStop = startPaths(bestLoop);
            egressStop = endPaths(bestLoop);
            [startPath, walk1] = shortestpath(walkGraph, currentNode, boardingStop, "Method", "positive");
            [endPath, walk2] = shortestpath(walkGraph, egressStop, obj.destination, "Method", "positive");
            busWalkDist = length(startPath) + length(endPath) - 2; % Adjusts to blocks, not nodes
            % This is an estimate, we will probably want to make this
            % better if we have time
            [~, busTime] = shortestpath(carGraph, boardingStop, egressStop, "Method", "positive");
            % Sets our bus cost to infinite if you have to walk too far
            if busWalkDist < 6
                costBus = (walk1+walk2+busTime)*obj.timeValue + busFare;
            else
                costBus = inf;
            end
            
            costs = [costBus, costCar, costWalk];            
            if min(costs) == costCar
                % Car Case
                obj.vehicle.coordinate = obj.coordinate;
                obj.vehicle.destination = obj.destination;
                obj.onCar = 1;
                obj.onLink = 0;
                obj.onNode = 0;
                obj.busLine = 0;
                set(obj.graphicsHandle,'XData',-1,'YData',-1);
                set(obj.vehicle.graphicsHandle,...
                    'XData', obj.vehicle.coordinate(1),...
                    'YData', obj.vehicle.coordinate(2));
                obj.vehicle.stepForward(carGraph, map);
                obj.transitCosts(end+1) = costCar;
            elseif min(costs) == costBus
                % Bus Case
                obj.busLine = bestLoop;
                obj.walking = 0;
                obj.onCar = 0;
                obj.boardingStop = boardingStop;
                obj.egressStop = egressStop;
                obj.rodeBus = 0;
                obj.onLink = 0;
                obj.onNode = 1;
                obj.transitCosts(end+1) = costBus;
            elseif min(costs) == costWalk
                % Walking Case
                obj.onLink = 0;
                obj.onNode = 1;
                obj.walking = 1;
                obj.busLine = 0;
                obj.transitCosts(end+1) = costWalk;
            else
                fprintf("Something is broken and you don't have a cost match!!\n")
            end
        end
    end
end
