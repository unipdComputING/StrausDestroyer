classdef POINTLOAD < handle 
    % classe figlia per i carichi puntuali sugli elementi (forze conc e momenti) 
    %-------------------------------------------------------------------    
    properties
      el_id;      %numero dell' elemento a cui è applicato il carico 
      load = [];  %vettore contenete le componenti del carico lungo x,y,z 
      a;          %distanza di applicazione del carico puntuale
      type_load;  %tipo di carico
    end
    %-------------------------------------------------------------------
    methods
    %-------------------------------------------------------------------
        function this = POINTLOAD(type_load,load,el_id,a)
            this.el_id = el_id;
            this.type_load = type_load;
            this.load = load;
            this.a = a;
        end
    %-------------------------------------------------------------------
    end
end


      