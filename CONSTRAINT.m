classdef CONSTRAINT
    % classe per la specificazione delle condizioni di vincolo e dei spostamenti imposti

    %......................................................................
    properties
        %INPUT
        node_id;       %indice di nodo
        
        gdl_fixed=[];  %vettore lungo gdlmax contenete elementi non nulli (ad esempio 1) solo in 
                       %    corrispondenza del grado di libertà bloccato o imposto in quel nodo
                       
        u_fixed=[];    %vettore lungo gdlmax contentente gli spostamenti che si vogliono imporre 
                       %    (0 se si vuole bloccare lo spostamento)
                       
                       % ATTENZIONE: le componenti del vettore u_fixed che
                       % non hanno un corrispondente non nullo nel vettore
                       % gdl_fixed verranno ignorate!!
                       
        gdlmax;        %variabile che contiene il numero di gradi di libertà che può 
                       %    assumere un nodo
        
        %OUTPUT
        ind_u_vinc;  %vettore contenente gl'indici di posizione, nel
                     %    sistema lineare Ku=f, degli spostamenti vincolati
                     
        u_vinc;      %vettore contente le componenti di spostamento bloccate 
                     %    o imposte 
    end
    %......................................................................
    
    %......................................................................
    methods
        %--------------------COSTRUTTORE-----------------------------------
        function this = CONSTRAINT(node_id, gdl_fixed, u_fixed)
            this.node_id=node_id;
            this.gdl_fixed=gdl_fixed;
            this.u_fixed=u_fixed; 
            gl=GLOBAL();
            this.gdlmax=gl.TOTDOF;
            
            %check su possibili errori di INPUT
            size_a=length(gdl_fixed);
            size_u=length(u_fixed);
            if (size_a~=this.gdlmax)||(size_u~=this.gdlmax)
                fprintf('ATTENZIONE!! errore sui gdlmax  \n')
            end
            
            %costruzione dei vettore ind_u_vinc e u_vinc
            cont=0; % variabile contatore per gli spostamenti vincolati
            for j=1:this.gdlmax
                if(this.gdl_fixed(j)~=0)
                    cont=cont+1;
                    this.ind_u_vinc(cont)=(this.node_id-1)*this.gdlmax+j;
                    this.u_vinc(cont)=this.u_fixed(j);
                end
            end
        end
        %------------------------------------------------------------------
    end
    %......................................................................
end

