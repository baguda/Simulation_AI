classdef MapObject
    properties
        objectID    % Unique string identifier for each object
        location    % A two-element vector [row, col] for the object's position on the map
        objectType  % A string or identifier for the object type (e.g., 'Agent', 'Food')
        name        % Name of the object (e.g., Agent's name)
        age         % Age of the object, initialized to 1
    end
    
    methods
        % Constructor
        function obj = MapObject(id, initialLocation, objType, name)
            if nargin > 0
                obj.objectID = id;              % Assign ObjectID during construction
                obj.location = initialLocation; % Assign initial location [row, col]
                obj.objectType = objType;       % Assign the object type (Agent, Food, etc.)
                obj.name = name;                % Assign the name of the object
                obj.age = 1;                    % Initialize age to 1
            end
        end
        
        % Method to move the object to a new location
        function obj = moveTo(obj, newLocation, mapSize)
            % Update the location of the object, checking against map bounds
            if isWithinBounds(mapSize, newLocation)
                obj.location = newLocation;
            else
                error('Location is out of bounds');
            end
        end
        
        % Helper function to check if a location is within map bounds
        function valid = isWithinBounds(mapSize, loc)
            if loc(1) > 0 && loc(1) <= mapSize(1) && loc(2) > 0 && loc(2) <= mapSize(2)
                valid = true;
            else
                valid = false;
            end
        end
        
        % Method to increment the age of the object
        function obj = TickAge(obj)
            obj.age = obj.age + 1;
        end        
    end
end

