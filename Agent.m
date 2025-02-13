classdef Agent < MapObject
    properties
        energy         % Current energy level
        hydration
        satiety
        heat
        intention 
        map            % Reference to the map the agent exists in
        memory         
        
    end
    
    methods
        % Constructor
        function obj = Agent( id,Name, Location, Map)
            obj@MapObject(id, Location, 'Agent', Name);
            obj.map = Map;
            obj.memory = MemoryStructure();
            obj.energy = 100;
            obj.hydration = 100;
            obj.satiety = 50;
            obj.heat = 0;
            
        end
        
        % Method to increment age
        function  TickAgent(obj)
            obj.age = obj.age + 1;
            
        end
        
        % Modify energy
        function ModifyEnergy(obj, Value)
            obj.energy = obj.energy + Value;
        end
        
        % Set energy
        function  SetEnergy(obj, Value)
            obj.energy = Value;
        end
        
        % Set mood
        function  SetMood(obj, Value)
            obj.mood = Value;
        end
        
        function Observation(obj)
           %setup internal model
           %setup real model
           %take difference
           
        end
        
    end
end

