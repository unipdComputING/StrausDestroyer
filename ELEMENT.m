%classe madre per gli elementi dovrà gestire la libreria di elementi
%implementati nel codice.
classdef ELEMENT < handle
  %------------------------------------------------------------------------
  properties(Constant)
    draw_linewidth = 1.0;
  end
  %------------------------------------------------------------------------
  properties
    id; %numero identificativo
    type_id; %tipo di elemento
    el; %elemento
  end
  %------------------------------------------------------------------------
  methods
    %----------------------------------------------------------------------
    function this=ELEMENT(id, type_id, nodes_id, prop_id)
      this.id = id;
      this.type_id = type_id;
      %inizializzazione dell'elemento
      this.elementInitialization(nodes_id, prop_id);
    end
    %----------------------------------------------------------------------
    function elementInitialization(this, nodes_id, prop_id)
      switch this.type_id
        case 1 %TRUSS
          this.el = TRUSS3D(nodes_id, prop_id);
        case 2 %BEAM EB
          this.el = BEAM3D(nodes_id, prop_id);
        case 3 %Q8 MINDLIN
          this.el = Q8MINDLIN(nodes_id, prop_id);
        case 4 %PLATE
          %under construction
      end
    end
    %----------------------------------------------------------------------
    function Kel = stiffness(this, prop, X)
      Kel = [];
      %gl = GLOBAL();
      switch this.type_id
        case 1 %TRUSS
          Kel = this.el.globalStiffness(prop,X);
        case 2 %BEAM EB
          Kel = this.el.localstiffnes(prop,X);
        case 3 %Q8 MINDLIN
          Kel = this.el.localstiffnes(prop,X);
        case 4 %PLATE
          %under construction
      end
    end
    %----------------------------------------------------------------------
    %----------------------------------------------------------------------
    %----------------------------------------------------------------------
    %----------------------------------------------------------------------
    function write(this)
      fprintf('ELEMENT ID: %i; ', this.id);
      switch this.type_id
        case 1 %TRUSS
          fprintf('Type: TRUSS  \t');
        case 2 %BEAM EB
          fprintf('Type: BEAM EB\t');
        case 3 %BEAM T
          fprintf('Type: Q8MINDLIN\t');
        case 4 %PLATE
          %under construction
      end
      this.el.write();
    end
    %----------------------------------------------------------------------
    function draw(this,nodes)
      X = zeros(2,1);
      Y = zeros(2,1);
      cont = 1;
      for i = this.el.nodes_id
        X(cont,1) = nodes(i).x(1);
        Y(cont,1) = nodes(i).x(2);
        cont = cont + 1;
      end
      
      color = 'k';
      
      switch this.type_id
        case 1 %TRUSS
          color = 'red';
        case 2 %BEAM EB
          color = 'blue';
        case 3 %Q8MINDLIN
          color = 'yellow';
        case 4 %PLATE
          %under construction
      end
      
      %patch(X,Y,color,'LineWidth',this.draw_linewidth);
      line(X,Y,'Color',color,'LineWidth',this.draw_linewidth);
      
      for i = this.el.nodes_id
        nodes(i).draw();
      end
    end
    function element = getelement(this)
        element = this.el;
    end 
     %----------------------------------------------------------------------
    function tot = getTotNodes(this)
      tot = 0;
      %gl = GLOBAL();
      switch this.type_id
        case 1 %TRUSS
          tot = this.el.TOTNODES;
        case 2 %BEAM EB
          tot = this.el.TOTNODES;
        case 3 %BEAM T
          %under construction
        case 4 %PLATE
          %under construction
      end
    end
    %----------------------------------------------------------------------
    function tot = propID(this)
      tot = 0;
      %gl = GLOBAL();
      switch this.type_id
        case 1 %TRUSS
          tot = this.el.prop_id;
        case 2 %BEAM EB
          tot = this.el.prop_id;
        case 3 %BEAM T
          %under construction
        case 4 %PLATE
          %under construction
      end
    end
    %----------------------------------------------------------------------
    function id = nodeID(this, index)
      id = 0;
      totNodes = this.getTotNodes();
      if ((index < 1) || (index > totNodes))
        return
      end
     
      %gl = GLOBAL();
      switch this.type_id
        case 1 %TRUSS
          id = this.el.nodes_id(index);
        case 2 %BEAM EB
          id = this.el.nodes_id(index);
        case 3 %BEAM T
          %under construction
        case 4 %PLATE
          %under construction
      end
    end
    %----------------------------------------------------------------------
   
  end
  %------------------------------------------------------------------------
end