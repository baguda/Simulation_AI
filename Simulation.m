classdef Simulation 
    
    properties
        map
        timeStep
        maxTime
        
    end
    
    methods
        function obj=Simulation()
            
        end
        function Run(obj,MapSize,foodCount,clusterCount,clusterRange)
            obj.map = Map(MapSize);
            obj.map = obj.map.CreateMap(foodCount,clusterCount,clusterRange);
            obj.map.UpdateGraphic();

        end        

        
        
        % Function to update the graphical display of the map

    end


    
end