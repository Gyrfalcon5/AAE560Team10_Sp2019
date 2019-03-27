count = 1;
for i = 1:5
    for j = 1:5
        map(count) = Node;
        map(count).coordinate = [i j];
        plotNode(map(count))
        hold on
        count = count+1;
    end
end
