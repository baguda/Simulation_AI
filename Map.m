classdef Map
    properties
        mapSize        % The size of the map grid
        edificeGrid    % The grid representing terrain difficulty (0 to 10)
        objects = {};  % A cell array to store MapObject instances
    end
    
    methods
        % Constructor
        function obj = Map(Size)
            obj.mapSize = Size;
        end
        function obj = CreateMap(obj,foodCount,clusterCount,clusterRange)
            obj.edificeGrid = zeros(obj.mapSize);  % Initialize the grid with zeros
            obj = obj.populateEdificeGrid(clusterCount,clusterRange);  % Populate the grid with terrain values
            obj = obj.PopulateFood(foodCount);
        end
        
        % Function to populate the edificeGrid with terrain values
        function obj = populateEdificeGrid(obj,clusterCount,clusterRange)
            obj.edificeGrid = zeros(obj.mapSize);  % Start with zeros for all terrain values

            numClusters = clusterCount;  % Number of impassable terrain clusters
            impassableLocations = [];

            % Place clusters of impassable terrain
            for i = 1:numClusters
                clusterSize = randi(clusterRange);  % Random size for clusters
                x = randi([1, obj.mapSize(1)]);
                y = randi([1, obj.mapSize(2)]);
                
                for j = -clusterSize:clusterSize
                    for k = -clusterSize:clusterSize
                        % Ensure we don't go out of the grid's bounds
                        if (x+j > 0 && x+j <= obj.mapSize(1)) && (y+k > 0 && y+k <= obj.mapSize(2))
                            obj.edificeGrid(x+j, y+k) = 10;  % Set impassable terrain
                            impassableLocations = [impassableLocations; x+j, y+k];  % Track impassable locations
                        end
                    end
                end
            end

            % Calculate terrain difficulty based on distance from impassable areas
            for x = 1:obj.mapSize(1)
                for y = 1:obj.mapSize(2)
                    if obj.edificeGrid(x, y) ~= 10
                        distances = sqrt(sum((impassableLocations - [x, y]).^2, 2));
                        minDistance = min(distances);
                        obj.edificeGrid(x, y) = min(max(9 - round(minDistance), 0), 9);  % Clamp between 0 and 9
                    end
                end
            end
        end
        
        % AddFood method
        function obj = AddFood(obj, id, name, nutrition, location)
            if obj.edificeGrid(location(1), location(2)) < 10
                newFood = Food(id, name, nutrition, location);  % Create a new food object
                obj = obj.addObject(newFood);  % Add food to the map
            else
                error('Cannot place food on an impassable cell');
            end
        end
        
        % PopulateFood method
        function obj = PopulateFood(obj, numFood)
            % Randomly place a specified number of food objects on non-impassable terrain
            foodCounter = 0;
            while foodCounter < numFood
                x = randi([1, obj.mapSize(1)]);
                y = randi([1, obj.mapSize(2)]);
                
                if obj.edificeGrid(x, y) < 10
                    foodID = ['food_', num2str(foodCounter + 1)];
                    foodName = ['Food_', num2str(foodCounter + 1)];
                    nutritionValue = randi([5, 15]);  % Random nutrition value between 5 and 15
                    obj = obj.AddFood(foodID, foodName, nutritionValue, [x, y]);
                    foodCounter = foodCounter + 1;
                end
            end
        end

        % Function to calculate the terrain value based on distance from impassable areas
        function terrainValue = calculateTerrainValue(obj, x, y)
            maxDistance = 5;  % Define how far the influence of impassable terrain extends
            minTerrainValue = 0;  % Easiest terrain value
            terrainValue = 9;  % Default to the hardest terrain except impassable
            
            for i = max(-maxDistance, 1-x):min(maxDistance, obj.mapSize(1)-x)
                for j = max(-maxDistance, 1-y):min(maxDistance, obj.mapSize(2)-y)
                    if obj.edificeGrid(x+i, y+j) == 10
                        distance = sqrt(i^2 + j^2);
                        terrainValue = min(terrainValue, round(distance));  % Round to nearest integer
                    end
                end
            end
            
            terrainValue = max(minTerrainValue, terrainValue);  % Ensure terrain value is not negative
        end
        
        % Function to add a new object (Agent or Food) to the map
        function obj = addObject(obj, newObject)
            obj.objects{end + 1} = newObject;
        end
        
        % Function to retrieve a MapObject based on its ObjectID
        function mapObject = getMapObject(obj, id)
            for i = 1:length(obj.objects)
                if strcmp(obj.objects{i}.objectID, id)
                    mapObject = obj.objects{i};
                    return;
                end
            end
            error('Object with ID %s not found', id);
        end
        
        % Function to update the graphical display of the map
        function UpdateGraphic(obj)
            cmap = [linspace(1, 0.5, 10)', linspace(1, 0.5, 10)', linspace(1, 0.5, 10)']; % Grey-scale for terrain
            cmap(end, :) = [0, 0, 0];  % Black for impassable terrain (value 10)
            
            figure(1);
            clf;
            colormap(cmap);
            imagesc(obj.edificeGrid);
            colorbar;
            axis equal tight;
            hold on;
            
            % Overlay the objects on the grid
            for i = 1:length(obj.objects)
                mapObj = obj.objects{i};
                [row, col] = obj.getObjectPosition(mapObj);
                
                if isa(mapObj, 'Agent')
                    scatter(col, row, 100, 'r', 'filled');  % Agent as red dot
                elseif isa(mapObj, 'Food')
                    scatter(col, row, 100, 'g', 'filled');  % Food as green dot
                end
            end
            
            hold off;
            title('Map Terrain and Objects');
            drawnow;
        end
        
        % Function to get object position
        function [row, col] = getObjectPosition(~, mapObj)
            row = mapObj.location(1);  % Assume location is a property
            col = mapObj.location(2);
        end

        % Function to remove a MapObject based on its ObjectID
        function obj = RemoveObject(obj, id)
            indexToRemove = [];
            
            % Find the object by its ID
            for i = 1:length(obj.objects)
                if strcmp(obj.objects{i}.objectID, id)
                    indexToRemove = i;
                    break;
                end
            end
            
            % If object found, remove it
            if ~isempty(indexToRemove)
                obj.objects(indexToRemove) = [];  % Remove object from cell array
            else
                error('Object with ID %s not found', id);
            end
        end
    end
end

