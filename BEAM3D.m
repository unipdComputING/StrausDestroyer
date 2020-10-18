classdef BEAM3D < handle
    %script finale
  properties(Constant)
    DIMDOF = 6;
    TOTNODES = 2;
  end
    %-------------------------------------------------------
    %proprietà dei nodi e dell'elemento
    %-------------------------------------------------------
    properties
        nodes_id=[];
        prop_id;
        X = [];
    end
    %-------------------------------------------------------
    methods
        function this=BEAM3D(nodes_id,property_id)
            this.nodes_id=nodes_id;
            this.prop_id=property_id;
        %-------------------------------------------------------
        %-------------------------------------------------------
        end
            %-----------------------------------------------------------
    %----lunghezza da calcolare in BEAM3D o aggiungere un ciclo... ---
    %----...diverso in GLOBAL...--------------------------------
    %     function [L]=elementlenght(x1,y1,z1,x2,y2,z2)
    %                 L=sqrt((x1-x2)^2+(y1-y2)^2+(z1-z2)^2);
    %     end
    %-----------------------------------------------------------
    %--------------definizione di k locale----------------------
    %---E,A,L:lunghezza elemento,Iy,Iz,coordinatelocali(x,y,z) nel nodo---
    %-----------------------------------------------------------
    %          function [kglobal]=localstiffnes(this,E,A,L,Iy,Iz,G,J,...
    %                                   x1,y1,z1,x2,y2,z2)
    
        function lambda = lambdaForT(this,X)
             x1 = X(1,1);
             y1 = X(1,2);
             z1 = X(1,3);
             x2 = X(2,1);
             y2 = X(2,2);
             z2 = X(2,3);
             gl = GLOBAL();
             L = gl.distance(X(1,:), X(2,:));
            if (x1==x2)&&(y1==y2)
                if z2>z1
                    lambda=[0 0 1
                            0 1 0
                            -1 0 0];
                else
                    lambda=[0 0 -1
                            0 1 0
                            1 0 0];
                end
            else
                CXx = (x2-x1)/L;
                CYx = (y2-y1)/L;
                CZx = (z2-z1)/L;
                D = sqrt(CXx*CXx + CYx*CYx);
                CXy = -CYx/D;
                CYy = CXx/D;
                CZy = 0;
                CXz = -CXx*CZx/D;
                CYz = -CYx*CZx/D;
                CZz = D;
                lambda = [CXx CYx CZx ;CXy CYy CZy ;CXz CYz CZz];
            end
        end 
        
         function [kglobal]=localstiffnes(this,prop,X)
                  this.X = X;
                  x1 = X(1,1);
                  y1 = X(1,2);
                  z1 = X(1,3);
                  x2 = X(2,1);
                  y2 = X(2,2);
                  z2 = X(2,3);
                  E = prop.mat.E;
                  nu = prop.mat.nu;
                  G = E /(2 * (1+nu));
                  A = prop.sec.A;
                  Iy = prop.sec.I11;
                  Iz = prop.sec.I22;
                  J  = prop.sec.J;
                  gl = GLOBAL();
                  L = gl.distance(X(1,:), X(2,:));
                  
                  k=zeros(this.DIMDOF*2,this.DIMDOF*2);
    %-----------------------------------------------------------       
    %-----------------------------------------------------------
    %---- knma,b definite come elementi delle sottomatrici -----
    %----con n righe, m colonne, a primoquad, b secondoquad-----
    %-----------------------------------------------------------
                k11=E*A/L;
                k22=12*E*Iz/L^3;
                k33=12*E*Iy/L^3;
                k44=G*J/L;
                k55=4*E*Iy/L;
                k66=4*E*Iz/L;
                k26=6*E*Iz/L^2;
                k35=6*E*Iy/L^2;
                k552=2*E*Iy/L;
                k662=2*E*Iz/L;
    %-----------------------------------------------------------
                ka=[k11 0 0 0 0 0
                    0 k22 0 0 0 k26
                    0 0 k33 0 -k35 0
                    0 0 0 k44 0 0
                    0 0 -k35 0 k55 0
                    0 k26 0 0 0 k66];
                kb=[-k11 0 0 0 0 0
                    0 -k22 0 0 0 k26
                    0 0 -k33 0 -k35 0
                    0 0 0 -k44 0 0
                    0 0 k35 0 k552 0
                    0 -k26 0 0 0 k662];
                kc=[-k11 0 0 0 0 0
                    0 -k22 0 0 0 -k26
                    0 0 -k33 0 k35 0
                    0 0 0 -k44 0 0
                    0 0 -k35 0 k552 0
                    0 k26 0 0 0 k662];
                kd=[k11 0 0 0 0 0
                    0 k22 0 0 0 -k26
                    0 0 k33 0 k35 0
                    0 0 0 k44 0 0
                    0 0 k35 0 k55 0
                    0 -k26 0 0 0 k66];
    %-----------------------------------------------------------
    %--k locale del singolo elemento, assemblaggio trammite sottomatrici--
    %-----------------------------------------------------------
                k=[ka kb
                    kc kd];
%     %-----------------------------------------------------------
%     %----- costruzione della matrice di rotazione T, tramite lambda ----
%     %-----------------------------------------------------------          
                lambda = this.lambdaForT(X);
                
    %-------------------------------------------------------------
    %--- assemblo T ----------------------------------------------
    %-------------------------------------------------------------
  
                T=  [lambda zeros(3,9)
                     zeros(3) lambda zeros(3,6)
                     zeros(3,6) lambda zeros(3)
                     zeros(3,9) lambda]; 
    
    %-------------------------------------------------------------
    %-----rotazione k locale a k globale -------------------------
    %-------------------------------------------------------------
    
                kglobal= T'*k*T;
         end
         
    function write(this)
      fprintf('nodes: [%i, %i]; ',this.nodes_id(1),this.nodes_id(2));
      fprintf('property ID: %i\n', this.prop_id);
     
    end
    
   
end
    
   
end