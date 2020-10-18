classdef Q8MINDLIN

%...........................PROPRIETA'..................................... 
    properties(Constant)
        DIMDOF = 48;    %dimensione della matrice di rigidezza
        TOTNODES = 8;   %totale di nodi che compongono l'elemento
    end
    
    properties
        nodes_id=[];    %id dei nodi che compongono l'elemento (NB la disposizione segue la convenzione di )
        prop_id;        %id della proprietà
    end
%..........................................................................

%..............................METODI......................................
    methods
        %-------------------------COSTRUTTORE------------------------------
        function this=Q8MINDLIN(nodes_id,property_id)
            this.nodes_id=nodes_id;
            this.prop_id=property_id;
        end
        %------------------------------------------------------------------
        
        %-------------ASSEMBLAGGIO MATRICE DI RIGIDEZZA--------------------
        function [kglobal]=localstiffnes(this, prop, X)
            
            %applico una rotazione e mi riconduto ad un sdr locale
            [x,y,R]=this.rotation_plate(X);
            
            %matrice di rotazione per la matrice di rigidezza
            Rk=zeros(48,48);
            for i=1:16
                t1=(i-1)*3+1;
                t2=i*3;
                Rk(t1:t2,t1:t2)=R';
            end
            
            %assemblaggio matrice costitutiva
                E = prop(this.prop_id).mat.E;
                ni = prop(this.prop_id).mat.nu;
                G = E /(2 * (1-ni));
                h = prop(this.prop_id).sec.thickness;
                dp=E/(1-ni^2)*[1 ni 0; ni 1 0; 0 0 (1-ni)/2];
                dG=(5/6)*G*[1 0; 0 1];
                D=zeros(8,8);
                D(1:3,1:3)=h*dp;
                D(4:6,4:6)=(h^3/12)*dp;
                D(7:8,7:8)=h*dG;
            
            %assemblaggio matrice di rigidezza
                %chiamata delle matrici B e dev_N_ptGauss
                cd 'Q8_mindlin'
                L = matfile('B_Q8MINDLIN.mat');
                B = L.B;
                L = matfile('dev_N_ptGauss_Q8MINDLIN.mat');
                dev_N_ptGauss = L.dev_N_ptGauss;
                cd ..\
            
                %calcolo dei jacobiani
                det_J=zeros(4,1);
                for p=1:4
                    a=dev_N_ptGauss(1,:,p)*x';
                    b=dev_N_ptGauss(1,:,p)*y';
                    c=dev_N_ptGauss(2,:,p)*x';
                    d=dev_N_ptGauss(2,:,p)*y';
                    J=[a b; c d];
                    det_J(p)=det(J);
                end
            
                %assemblaggio finale
                klocal=zeros(40,40);  %matrice di rigidezza nel sistema di riferimento locale con 5gdl per nodo
                for p=1:4
                    klocal=klocal+B(:,:,p)'*D*B(:,:,p)/det_J(p);
                end
                
                %ritorno al sdr globale
                kglobal=eye(48,48);    %matrice di rigidezza nel sistema di riferimento globale con 6gdl per nodo
                for i=1:8
                    for j=1:8
                        %intervalli della matrice di rigidezza nel sdr locale da copiare
                        i1=(i-1)*5+1;
                        i2=i*5;
                        j1=(j-1)*5+1;
                        j2=j*5;
                        %intervalli della matrice di rigidezza nel sdr globale su cui incollare
                        I1=(i-1)*6+1;
                        I2=i*6-1;
                        J1=(j-1)*6+1;
                        J2=j*6-1;
                        %copia e incolla di prepotenza
                        kglobal(I1:I2,J1:J2)=klocal(i1:i2,j1:j2);
                    end
                end
                %rotazione applicata alla matrice di rigidezza
                kglobal=Rk'*kglobal*Rk;
        end
        %------------------------------------------------------------------
        
        %------------------------ROTAZIONE DEL PLATE-----------------------
        function [x,y,R]=rotation_plate(this,X)
            
            %versore di z' (normale al plate)
            nz=-cross(X(4,:)'-X(1,:)', X(2,:)'-X(1,:)');
            nz=nz*(1/sqrt(nz(1)^2+nz(2)^2+nz(3)^2));

            %cerco il baricentro dell'elemento per definire il sdr
            O=[0;0;0];
            for i=1:8
                O(1)=O(1)+X(i,1);
                O(2)=O(2)+X(i,2);
                O(3)=O(3)+X(i,3);
            end
            O=O*(1/8);

            %versore di y' (complanare al plate)
            ny=X(8,:)'-O;
            ny=ny*(1/sqrt(ny(1)^2+ny(2)^2+ny(3)^2));

            %versore di x' (complanare al plate)
            nx=cross(ny,nz);

            %matrice di rotazione
            R=[nx, ny, nz];

            %cambio del sistema di riferimento
            for i=1:8    
                x(i)=nx'*X(i,:)';
                y(i)=ny'*X(i,:)';
            end
        end
        %------------------------------------------------------------------
    end
%..........................................................................

end

