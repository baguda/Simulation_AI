classdef Agent < MapObject
    properties
        name           % Agent's name
        age            % Age of the agent
        energy         % Current energy level
        location       % Current location of the agent on the map
        LTM = {};      % Long Term Memory (LTM), a list of generalized memories
        STM = {};      % Short Term Memory (STM), a list of detailed recent memories
        mood           % Current mood of the agent
        map            % Reference to the map the agent exists in
        socialMemories = {};  % List of social memories (profile-based memories)
    end
    
    methods
        % Constructor
        function obj = Agent(Name, Location, Map)
            obj.name = Name;
            obj.age = 0;
            obj.location = Location;
            obj.map = Map;
        end
        
        % Method to increment age
        function obj = TickAge(obj)
            obj.age = obj.age + 1;
        end
        
        % Modify energy
        function obj = ModifyEnergy(obj, Value)
            obj.energy = obj.energy + Value;
        end
        
        % Set energy
        function obj = SetEnergy(obj, Value)
            obj.energy = Value;
        end
        
        % Set mood
        function obj = SetMood(obj, Value)
            obj.mood = Value;
        end
        
        % Add a new perceptual memory to STM
        function obj = AddMemoryToSTM(obj, location, netSurprise, vectorsToObjects)
            % Memory structure: {location, netSurprise, vectorsToObjects, decay, startTime, decayRate}
            startTime = obj.age;
            decay = 100;
            decayRate = 1;
            newMemory = {location, netSurprise, vectorsToObjects, decay, startTime, decayRate};
            obj.STM{end+1} = newMemory;
        end
        
        % Add or Update Social Memory
        function obj = AddOrUpdateSocialMemory(obj, otherAgentName, interactionScore)
            index = obj.GetMemoryIndexByAgent('social', otherAgentName);
            if index > 0
                % Update the existing social memory
                obj.socialMemories{index}{3}(end+1) = interactionScore;
                obj.socialMemories{index}{2} = max(min(obj.socialMemories{index}{2} + interactionScore, 5), -5);
            else
                % Create a new social memory if it doesn't exist
                affinity = interactionScore;
                interactionHistory = [interactionScore];
                startTime = obj.age;
                decay = 100;
                decayRate = 0.5;
                newSocialMemory = {otherAgentName, affinity, interactionHistory, decay, startTime, decayRate};
                obj.socialMemories{end+1} = newSocialMemory;
            end
        end
        
        % Update social memories and apply decay
        function obj = UpdateSocialMemories(obj)
            currentAge = obj.age;
            for i = length(obj.socialMemories):-1:1
                memory = obj.socialMemories{i};
                memoryAge = currentAge - memory{5};
                memory{4} = memory{4} - (memoryAge * memory{6});  % Apply decay
                
                % Move to LTM or remove if decay is complete
                if memory{4} <= 0
                    if rand() > 0.5
                        obj.LTM{end+1} = memory;
                    end
                    obj.socialMemories(i) = [];
                else
                    obj.socialMemories{i} = memory;
                end
            end
        end
        
        % Query social memory by agent name (returns index)
        function index = GetMemoryIndexByAgent(obj, memoryType, agentName)
            index = -1;  % Default index if memory isn't found
            if strcmp(memoryType, 'social')
                for i = 1:length(obj.socialMemories)
                    if strcmp(obj.socialMemories{i}{1}, agentName)
                        index = i;
                        return;
                    end
                end
            else
                error('Invalid memory type. Choose "social".');
            end
        end

        % Function to retrieve the index of a memory by location (STM or LTM)
        function index = GetMemoryIndexByLocation(obj, memoryType, queryLocation)
            index = -1;
            if strcmp(memoryType, 'STM')
                for i = 1:length(obj.STM)
                    if isequal(obj.STM{i}{1}, queryLocation)
                        index = i;
                        return;
                    end
                end
            elseif strcmp(memoryType, 'LTM')
                for i = 1:length(obj.LTM)
                    if isequal(obj.LTM{i}{1}, queryLocation)
                        index = i;
                        return;
                    end
                end
            else
                error('Invalid memory type. Choose "STM" or "LTM".');
            end
        end
        
        % Function to retrieve the index of a memory by age (STM or LTM)
        function index = GetMemoryIndexByAge(obj, memoryType, queryAge)
            index = -1;
            currentAge = obj.age;
            if strcmp(memoryType, 'STM')
                for i = 1:length(obj.STM)
                    memoryAge = currentAge - obj.STM{i}{5};
                    if memoryAge == queryAge
                        index = i;
                        return;
                    end
                end
            elseif strcmp(memoryType, 'LTM')
                for i = 1:length(obj.LTM)
                    memoryAge = currentAge - obj.LTM{i}{5};
                    if memoryAge == queryAge
                        index = i;
                        return;
                    end
                end
            else
                error('Invalid memory type. Choose "STM" or "LTM".');
            end
        end
        
        % Remove a memory by index (STM, LTM, or social)
        function obj = RemoveMemory(obj, memoryType, memoryIndex)
            if strcmp(memoryType, 'STM')
                if memoryIndex > 0 && memoryIndex <= length(obj.STM)
                    obj.STM(memoryIndex) = [];
                else
                    error('Invalid memory index for STM.');
                end
            elseif strcmp(memoryType, 'LTM')
                if memoryIndex > 0 && memoryIndex <= length(obj.LTM)
                    obj.LTM(memoryIndex) = [];
                else
                    error('Invalid memory index for LTM.');
                end
            elseif strcmp(memoryType, 'social')
                if memoryIndex > 0 && memoryIndex <= length(obj.socialMemories)
                    obj.socialMemories(memoryIndex) = [];
                else
                    error('Invalid memory index for social memories.');
                end
            else
                error('Invalid memory type. Choose "STM", "LTM", or "social".');
            end
        end
        
    end
end

