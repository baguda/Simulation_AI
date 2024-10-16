classdef SensoryMemory < Memory
    properties
        name        % Name of the encountered object (e.g., another agent)
        objectID    % ID of the encountered object
        affinity    % Integer between -100 (hated) and 100 (loved) that indicates relation
        history     % List of vectors that track the turn and value of interactions (-10 to 10)
    end
    
    methods
        % Constructor to initialize a ProfileMemory instance
        function obj = SensoryMemory(location, startTurn, strength, decayFunc, name, objectID, affinity, history)
            % Call the superclass constructor
            obj@Memory(location, startTurn, strength, decayFunc);
            % Initialize specific profile memory properties
            obj.name = name;
            obj.objectID = objectID;
            obj.affinity = affinity;
            obj.history = history;
        end
        
        % AddInteraction - Update interaction history and adjust affinity
        function obj = AddInteraction(obj, turn, interactionValue)
            % Append a new interaction to the history
            obj.history(end+1, :) = [turn, interactionValue];
            % Adjust affinity (clamp between -100 and 100)
            obj.affinity = max(min(obj.affinity + interactionValue, 100), -100);
        end
        
        % Additional profile-specific methods can be added here
    end
end
