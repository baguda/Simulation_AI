classdef Memory
    properties
        location    % List of two vectors, representing a range of x y values
        startTurn   % The global turn when the memory was made
        strength    % Strength of the memory as an integer percentage
        decayFunc   % Function handle for rate of decay of strength per turn
    end
    
    methods
        % Constructor to initialize a memory instance
        function obj = Memory(location, startTurn, strength, decayFunc)
            obj.location = location;
            obj.startTurn = startTurn;
            obj.strength = strength;
            obj.decayFunc = decayFunc;
        end

        % DegradeMemory - Applies the decay function to adjust the memory strength
        function obj = DegradeMemory(obj, currentTurn)
            % Calculate the number of turns since the memory was created
            age = currentTurn - obj.startTurn;
            % Apply the decay function to the strength
            obj.strength = max(0, obj.decayFunc(age, obj.strength));  % Ensure non-negative strength
        end
    end
end
