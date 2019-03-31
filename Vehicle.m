classdef Vehicle < handle
    % Class that defines a single link in a network

    properties
        coordinate
        onLink
        onNode    
        
    end
    
    methods
       
        function obj = Vehicle(coordinate,onLink,onNode)
            
            if nargin == 0
                args{1} = [];
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
        end
        
        
        
        
        
        function plotVehicle(obj,x,y)
            plot(obj.coordinate(1), obj.coordinate(2),'g *')
        end
    
    end
end