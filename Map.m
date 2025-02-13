classdef Map
    properties
        mapSize        % The size of the map grid
        edificeGrid    % The grid representing terrain difficulty (0 to 10)
        objects = {};  % A cell array to store MapObject instances
        tempGrid       % The grid representing temp 
        seed
        foodCount
    end
    
    methods
        % Constructor
        function obj = Map(Size,FoodCount,Seed)
            obj.mapSize = Size;
            obj.seed = Seed;
            
            obj.foodCount = FoodCount;
        end
        function obj = GenerateMap(obj)
            noise = PerlinNoise2D(obj.mapSize(2), obj.mapSize(1), obj.mapSize(2)*0.15, 1, 0.005, 5, 0, 10, obj.seed,6.5,2.5);
            % Generate terrain and temperature using MapUtility
            obj.edificeGrid = noise.grid;
            obj=obj.PopulateFood(obj.foodCount);
            obj=obj.AddAgent('007',[10 10]);
        end
        % Create the map (including terrain and food)
        function obj = CreateMap(obj, foodCount, clusterCount, clusterRange)
            % Call the static method from MapUtility to generate the edificeGrid
            obj.edificeGrid = MapUtility.generateEdificeGrid(obj.mapSize, clusterCount, clusterRange);
            
            % Populate the map with food after generating terrain
            obj = obj.PopulateFood(foodCount);
        end        
        % AddFood method
        function obj = AddFood(obj, name, nutrition, location)
            if obj.edificeGrid(location(1), location(2)) < 9.5
                newFood = Food(obj.GenObjectID(name), name, nutrition, location);  % Create a new food object
                obj = obj.addObject(newFood);  % Add food to the map
            else
                error('Cannot place food on an impassable cell');
            end
        end
        
        function obj = AddAgent(obj, name, location)
            if obj.edificeGrid(location(1), location(2)) < 10
                newAgent = Agent(obj.GenObjectID(name), name, location, obj);  % Create a new food object
                obj = obj.addObject(newAgent); 
            else
                error('Cannot place Agent on an impassable cell');
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
                    obj = obj.AddFood(foodName, nutritionValue, [x, y]);
                    foodCounter = foodCounter + 1;
                end
            end
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
            cmap(end, :) = [100/256,65/256,23/256];  % Black for impassable terrain (value 10)
            cmap(1, :) = [0, 0, 0.6];
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
                    scatter(col, row, 10, 'r', 'filled');  % Agent as red dot
                elseif isa(mapObj, 'Food')
                    scatter(col, row, 10, 'g', 'filled');  % Food as green dot
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
        
        function result = GenObjectID(obj, ObjectName)
                % Generate a random integer between 1 and 10000
                randomInt = randi(10000);
                % Concatenate the input string with the random integer
                result = strcat(ObjectName, num2str(randomInt));
        end
        

    end
end

