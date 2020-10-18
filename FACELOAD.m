classdef FACELOAD
    % classe figlia per un carico superficiale da applicare ad un plate
    %----------------------------------------------------------------------
    properties
      el_id;      %numero dell' elemento a cui è applicato il carico 
      load = [];  %vettore contenete le componenti della pressione lungo x,y,z 
      type_load;  %tipo di carico (in questo caso 4)
    end
    %----------------------------------------------------------------------
    methods
    %-----------------------COSTRUTTORE------------------------------------
        function this = FACELOAD(type_load,load,el_id)
            this.el_id = el_id;
            this.type_load = type_load;
            this.load = load;
        end
    %----------------------------------------------------------------------

    end
end

