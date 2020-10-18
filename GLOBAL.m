classdef GLOBAL
  %........................................................................
  properties(Constant)
    DIMSPACE = 3; %dimensione dello spazio geometrico
    TOTDOF = 6; %dimensione massima dei gradi di libertà di ogni nodo
  end
  
  properties
  end
  %........................................................................
  
  %........................................................................
  methods
    %---------------------------COSTRUTTORE--------------------------------
    function this = GLOBAL()
    end
    %----------------------------------------------------------------------
    
    %-----------------------------DISTANZA---------------------------------
    function d = distance(this, x1, x2)
      d = 0.0;
      len = length(x1);
      if (len == length(x2))
        for i=1:len
          d = d + (x2(i)-x1(i))^2;
        end
        d = sqrt(d);
      end
    end
    %----------------------------------------------------------------------
    
    %----------------------------ROTAZIONE 3D------------------------------
    function R=rot3D(this, nz,phiz)
        %INPUT
        %  nz:   versore dell'asse z del sistema di riferimento ruotato
        %  phiz: rotazione attorno all'asse z
        
        %OUTPUT
        %  R:    matrice 3x3 di rotazione
        
        nz=nz*(1/sqrt(nz(1)^2+nz(2)^2+nz(3)^2));
        phiz=phiz*(pi/180);
        phiy=asin(nz(1));
        phix=asin(-nz(2)/cos(phiy));
        R1=[1     0          0 
            0 cos(phix) -sin(phix)
            0 sin(phix)  cos(phix)];
        R2=[ cos(phiy) 0 sin(phiy)
                  0    1     0
            -sin(phiy) 0 cos(phiy)];
        R3=[cos(phiz) -sin(phiz) 0
            sin(phiz)  cos(phiz) 0
                  0         0    1];
        R=R1*R2*R3; 
    end
     
   
  end
  %........................................................................

end