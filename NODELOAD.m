classdef NODELOAD < handle
    %classe figlia per i carichi nodali (forze e momenti puntuali)
    %------------------------------------------------------------------
    properties
        node_id;
        type_load;
        load = [];   
    end
    %------------------------------------------------------------------
    methods
        function this = NODELOAD(type_load,load,node_id)
            this.node_id = node_id;
            this.type_load = type_load;
            this.load = load;
        end
    end
    %------------------------------------------------------------------    
end
    

    