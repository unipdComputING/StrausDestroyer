%E -> modulo elastico
%A -> area
%L -> lunghezza asta
%x1-> coordinate del primo   nodo dell'elemento
%x2-> coordinate del secondo nodo dell'elememento
classdef TRUSS3D < handle
  %------------------------------------------------------------------------
  properties(Constant)
    DIMDOF = 3
    TOTNODES = 2
  end
  %------------------------------------------------------------------------
  properties
    nodes_id = [];
    prop_id;
    X = []; %lista di vettori posizione [(x1,y1,z1);(x2,y2,z2)]
  end
  %------------------------------------------------------------------------
  methods
    %----------------------------------------------------------------------
    function this = TRUSS3D(nodes_id, property_id)
      this.nodes_id = nodes_id;
      this.prop_id = property_id;
    end
    %----------------------------------------------------------------------
    function [K]=globalStiffness(this,prop,X)
      this.X = X;
      young = prop.mat.E;
      area = prop.sec.A;
      gl = GLOBAL();
      x1 = X(1,:);
      x2 = X(2,:);
      L = gl.distance(x1, x2);
      if L==0.0
        fprintf('WARNING in globalStiffnessMatrix: elemento\n');
        fprintf('                       di lunghezza nulla\n');
            return
      end
        %computing direction cosins matrix for truss element in a 
        %three-dimensional space

        Cx=(x2(1)-x1(1))/L;
        Cy=(x2(2)-x1(2))/L;
        Cz=(x2(3)-x1(3))/L;
        
        C=[ Cx^2   Cx*Cy  Cx*Cz  -Cx^2   -Cx*Cy  -Cx*Cz;
            Cx*Cy   Cy^2  Cy*Cz  -Cx*Cy   -Cy^2  -Cy*Cz;
            Cx*Cz  Cy*Cz   Cz^2  -Cx*Cz   -Cy*Cz  -Cz^2;
           -Cx^2  -Cx*Cy  -Cx*Cz  Cx^2    Cx*Cy   Cx*Cz;
           -Cx*Cy  -Cy^2  -Cy*Cz  Cx*Cy   Cy^2    Cy*Cz;
           -Cx*Cz  -Cy*Cz  -Cz^2  Cx*Cz   Cy*Cz    Cz^2];
        %global stiffness matrix
        K=area*young/L*C;
        
    end
    %----------------------------------------------------------------------
    %----------------------------------------------------------------------
    %----------------------------------------------------------------------
    %----------------------------------------------------------------------
    %----------------------------------------------------------------------
    %----------------------------------------------------------------------
    %----------------------------------------------------------------------
    function write(this)
      fprintf('nodes: [%i, %i]; ',this.nodes_id(1),this.nodes_id(2));
      fprintf('property ID: %i\n', this.prop_id);
    end
    %----------------------------------------------------------------------
  end
  %------------------------------------------------------------------------
end