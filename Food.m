classdef Food < MapObject
    properties
        nutrition  % The nutritional value of the food
    end
    
    methods
        % Constructor
        function obj = Food(id, Name, value, location)
            obj@MapObject(id, location, 'Food', Name);  % Call the superclass constructor
            obj.nutrition = value;  % Assign the nutritional value
        end
        
        % Consume method
        function nutrition = Consume(obj, map)
            % Return the nutrition value and remove the food object from the map
            nutrition = obj.nutrition;
            
            % Remove the food from the map
            map = map.RemoveObject(obj.objectID);  % Call RemoveObject from the map
        end
    end
end
