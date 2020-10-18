classdef DISTRLOAD < handle
    % classe figlia per un carico distribuito
    %-------------------------------------------------------------------------
    properties
      el_id;      %numero dell' elemento a cui è applicato il carico 
      load = [];  %vettore contenete le componenti della pressione lungo x,y,z 
      type_load;  %tipo di carico (in questo caso 3)
    end
    %--------------------------------------------------------------------------
    methods
        function this = DISTRLOAD(type_load,load,el_id)
            this.el_id = el_id;
            this.type_load = type_load;
            this.load = load;
        end
    end
    %-------------------------------------------------------------------------
end
