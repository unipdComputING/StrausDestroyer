classdef LOAD < handle
  %------------------------------------------------------------------------
  properties
    type_load;   %tipo di carico:
                 %              1) carico nodale
                 %              2) carico puntuale
                 %              3) carico superficiale
                 
    load = [];   %vettore con le componenti del carico lungo x,y,z 
    node_id;     %numero identificativo del nodo
    el_id;       %identificativo dell'elemento su cui applica il carico
    a;           %distanza di applicazione del carico puntuale
    loading;     %classe del carico
  end
  %------------------------------------------------------------------------
  methods
    %----------------------------------------------------------------------
    function this=LOAD(type_load,load,varargin)
        this.type_load = type_load;
        this.load = load;
        if type_load == 1 
          this.node_id = varargin{1};
          this.loading = NODELOAD(type_load,load,this.node_id);
        elseif type_load == 2
          this.el_id = varargin {1};
          this.a = varargin{2};
          this.loading = POINTLOAD(type_load,load,this.el_id,this.a);
        elseif type_load == 3
            this.el_id = varargin {1};
            this.loading = DISTRLOAD(type_load,load,this.el_id);
        elseif type_load == 4
          this.el_id = varargin {1};
          this.loading = FACELOAD(type_load,load,this.el_id);
        end
    end
    %----------------------------------------------------------------------
    function el_id = getelement_id(this) 
        el_id = this.el_id; 
    end
    %----------------------------------------------------------------------
    function node_id = getnodes(this)
        node_id = this.node_id;
    end
    %----------------------------------------------------------------------
    function load = getload(this)
        load = this.load;
    end
    %----------------------------------------------------------------------
    function a = geta(this)
        a = this.a;
    end
    %----------------------------------------------------------------------  
  end
  %------------------------------------------------------------------------
end
