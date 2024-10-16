classdef MemoryStructure
   properties 
       LTM = {};      % Long Term Memory (list of PerceptualMemory/ProfileMemory instances)
       STM = {};      % Short Term Memory (list of PerceptualMemory/ProfileMemory instances)
       
   end
   methods
       
       function obj = MemoryStructure(obj)
            
       end
        
       %% ------- Memory Management Methods -------
       
        % Add a new PerceptualMemory to STM
        function obj = AddPerceptualMemoryToSTM(obj, location, hidden, objects, terrain, strength, decayFunc)
            startTurn = obj.age;
            newMemory = PerceptualMemory(location, startTurn, strength, decayFunc, hidden, objects, terrain);
            obj.STM{end+1} = newMemory;  % Add to STM
        end

        % Add or update a ProfileMemory (social memory) to STM
        function obj = AddOrUpdateProfileMemory(obj, name, objectID, interactionValue)
            % Check if a profile memory for the agent already exists
            index = obj.GetMemoryIndexByAgent(name, 'STM');
            if index > 0
                % Update existing memory
                obj.STM{index} = obj.STM{index}.AddInteraction(obj.age, interactionValue);
            else
                % Create a new profile memory
                affinity = interactionValue;
                history = [obj.age, interactionValue];
                decayFunc = @(age, strength) strength - age * 0.1;  % Example decay function
                newProfileMemory = ProfileMemory(obj.location, obj.age, 100, decayFunc, name, objectID, affinity, history);
                obj.STM{end+1} = newProfileMemory;
            end
        end

        % Update all memories in STM by applying decay
        function obj = UpdateSTM(obj)
            for i = length(obj.STM):-1:1
                memory = obj.STM{i};
                % Apply decay
                obj.STM{i} = memory.DegradeMemory(obj.age);
                % Move to LTM or remove if strength is zero
                if obj.STM{i}.strength <= 0
                    % Random chance to move memory to LTM
                    if rand() > 0.5
                        obj.LTM{end+1} = obj.STM{i};
                    end
                    obj.STM(i) = [];
                end
            end
        end
        
        % Update all memories in LTM by applying decay
        function obj = UpdateLTM(obj)
            for i = length(obj.LTM):-1:1
                memory = obj.LTM{i};
                % Apply decay
                obj.LTM{i} = memory.DegradeMemory(obj.age);
                % Remove if strength is zero
                if obj.LTM{i}.strength <= 0
                    obj.LTM(i) = [];
                end
            end
        end
        
        %% ------- Query Methods for Memory -------

        % Get the index of a memory by location (STM or LTM)
        function index = GetMemoryIndexByLocation(obj, memoryType, queryLocation)
            index = -1;
            if strcmp(memoryType, 'STM')
                for i = 1:length(obj.STM)
                    if isequal(obj.STM{i}.location, queryLocation)
                        index = i;
                        return;
                    end
                end
            elseif strcmp(memoryType, 'LTM')
                for i = 1:length(obj.LTM)
                    if isequal(obj.LTM{i}.location, queryLocation)
                        index = i;
                        return;
                    end
                end
            end
        end

        % Get the index of a ProfileMemory by name (in STM or LTM)
        function index = GetMemoryIndexByAgent(obj, name, memoryType)
            index = -1;
            if strcmp(memoryType, 'STM')
                for i = 1:length(obj.STM)
                    if isa(obj.STM{i}, 'ProfileMemory') && strcmp(obj.STM{i}.name, name)
                        index = i;
                        return;
                    end
                end
            elseif strcmp(memoryType, 'LTM')
                for i = 1:length(obj.LTM)
                    if isa(obj.LTM{i}, 'ProfileMemory') && strcmp(obj.LTM{i}.name, name)
                        index = i;
                        return;
                    end
                end
            end
        end

        % Remove a memory by index (STM or LTM)
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
            else
                error('Invalid memory type. Choose "STM" or "LTM".');
            end
        end
        
   end
    
end