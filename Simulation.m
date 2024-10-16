classdef Simulation 
    
    properties
        map
        timeStep
        maxTime
        
    end
    
    methods
        function obj=Simulation(obj)
            
        end
        function obj=Run(obj,MapSize,foodCount,clusterCount,clusterRange)
            obj.map = Map(MapSize);
            obj.map = obj.map.CreateMap(foodCount,clusterCount,clusterRange);
            obj.map.UpdateGraphic();

        end        
       function Run2(obj,MapSize,foodCount,clusterCount,clusterRange)
            % setup
            obj.map = Map(MapSize);
            obj.map = obj.map.CreateMap(foodCount,clusterCount,clusterRange);
            obj.map.UpdateGraphic();
            run = true;
            turn = 0;
            % loop
            while run
               %Update prepair and plan
                % update objects 
                    %update food
                        % tick age
                    %update agents
                        % tick age
                        % observe
                        % 
                % update map
                    
               %Upkeep do update
                %upkeep objects
                %upkeep map
                turn = turn + 1;
                
            end

        
        % Function to update the graphical display of the map

    end


    
end