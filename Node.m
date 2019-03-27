classdef Node
    properties
        coordinate
        links
        wait_time
        users
    end
    methods
        function plotNode(obj)
            plot(obj.coordinate(1), obj.coordinate(2),'b o')
        end
    end
end

    