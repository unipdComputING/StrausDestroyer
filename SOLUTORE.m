classdef SOLUTORE
        
    %......................................................................
      properties(Constant)
        Toll=1.00e-4;
    end
    
    properties
        elements=[];
        nodes=[];
        property=[];
        loads;
        constraint;
        gdlmax;
        dim;
    end
    %......................................................................
    %x(s)=K(s,s)\f(s);
    %......................................................................
    methods
        %-----------------------COSTRUTTORE--------------------------------
        function this=SOLUTORE(elem,nod,prop, loads, constraint)
            this.elements=elem;              %elem:       vettore di oggetti di tipo ELEM
            this.nodes=nod;                  %node:       vettore di oggetti di tipo NODES
            this.property=prop;              %prop:       vettore di oggetti di tipo PROPERTY
            this.loads=loads;                %loads:      vettore di oggetti di tipo LOADS
            this.constraint=constraint;      %constraint: vettore ddi oggetti di tipo CONSTRAINT
            gl=GLOBAL();                     %gl:         oggetto di tipo GLOBAL
            this.gdlmax=gl.TOTDOF;           %gdlmax:     variabile per il grado di libertà massimo
            [~,dimnodi]=size(this.nodes);    %dimensione del numero di nodi
            this.dim=this.gdlmax*dimnodi;    %dimensione della matrice di rigidezza
        end
        %------------------------------------------------------------------
        
        %---------------ASSEMBLAGGIO MATRICE DI RIGIDEZZA K----------------
        function[K]=assemblyK(this)
            K=sparse(this.dim,this.dim, 0);       %inizializzazione della matrice di rigidezza
            dimel=length(this.elements);          %dimensione del numero di elementi
            
            %check del warning nel caso K sia vuota
            if dimel==0 || this.dim==0
                fprintf('WARNING sul solutore non ci sono elementi o nodi! \n');
            end
            
            %ciclo sugli elementi
            for e=1:dimel
                n_nod_el=this.elements(e).el.TOTNODES; %numero di nodi definiti nel generico elemento e
                
                %ricostruzione della matrice X contenente le coordinate dei nodi dell'elemento e
                for i=1:n_nod_el
                    X(i,:)=this.nodes(this.elements(e).el.nodes_id(i) ).x;
                end
                
                %chiamata della matrice locale dell'elemento e
                elK=this.elements(e).stiffness(this.property(this.elements(e).el.prop_id),X);
                
                local_dim=length(elK);            %grandezza matrice di rigidezza locale
                gdl=local_dim/n_nod_el;           %gradi di libertà ammessi per nodo
                
                %ciclo di assemblaggio
                for local_i=1:n_nod_el
                    global_i=this.elements(e).el.nodes_id(local_i);
                    for local_j=1:n_nod_el
                        global_j=this.elements(e).el.nodes_id(local_j);

                        %vettori delle coordinate dei valori da assegnare nella matrice globale
                        global_coord_i=[(global_i-1)*this.gdlmax+1:(global_i-1)*this.gdlmax+gdl];
                        global_coord_j=[(global_j-1)*this.gdlmax+1:(global_j-1)*this.gdlmax+gdl];
                        
                        %vettori delle coordinate dei valori da prendere nella matrice locale
                        local_coord_i=[(local_i-1)*gdl+1: local_i*gdl];
                        local_coord_j=[(local_j-1)*gdl+1: local_j*gdl];
                        
                        %finalmente assemblaggio 
                        K(global_coord_i,global_coord_j)=K(global_coord_i,global_coord_j)+elK(local_coord_i,local_coord_j);
                        
                    end
                end
            end
            
            %check sui diagonali nulli
            for i=1:this.dim
                if K(i,i)==0
                    fprintf('elemento nullo trovato in K(%d, %d) \n', i,i);
                    K(i,i)=1; 
                end
            end
            
        end
        %------------------------------------------------------------------
        
        %--------------------APPLICAZIONE CARICHI--------------------------
        function [F_ext]=assemblyF(this)
            totloads = length(this.loads);
            F_ext = zeros(this.dim,1);
            for l=1:totloads
                f_ext = this.loads(l).getload();
                %..........................................................
                if this.loads(l).type_load == 1      %carico nodale
                    node_id = this.loads(l).getnodes(); 
                    for dof = 1:length(f_ext)
                        F_ext((node_id-1)*this.gdlmax+dof) = F_ext((node_id-1)*this.gdlmax+dof) + f_ext(dof);
                    end
                %..........................................................
                %carico puntuale o distribuito sull'elemento beam
                elseif this.loads(l).type_load == 2 || this.loads(l).type_load == 3  
                    el_id = this.loads(l).getelement_id();           
                    element = this.elements(el_id).getelement();     
                    X = element.X;                                   
                    nodes_id = element.nodes_id;                     
                    node_id_1 = nodes_id(1);
                    node_id_2 = nodes_id(2);
                    gl = GLOBAL();
                    x1 = X(1,:);                                     
                    x2 = X(2,:);
                    L = gl.distance(x1, x2);  
                    
                    %------ passare da forze f_ext globali a locali-------
                    lambda = element.lambdaForT(X);
                    T = [lambda zeros(3,3)
                        zeros(3,3) lambda];
                    f_loc = f_ext * T^(-1);

                    %---calcolo di forze e momenti equivalenti sui nodi----
                    
                    F_loc = zeros(12,1); %fx1,fy1,....fx2,fy2...mz2
                    node_1 = node_id_1;
                    node_2 = node_id_2;                    
                    if this.loads(l).type_load == 2  %pointload
                        %coefficienti di moltiplicazione per il calcolo
                        %dei carichi nodali equivalenti per il caso di
                        %doppio incastro
                        a = (this.loads(l).geta())* L;
                        b = L - a; 
                        coff1 = [(b^2*(L+2*a))/L^3,(a^2*(L+2*b))/L^3];
                        coff2 = [(a*b^2)/L^2,-(b*a^2)/L^2];
                        coff3 = [(a^2+b^2-(4*a*b)-L^2)/L^3,-(a^2+b^2-(4*a*b)-L^2)/L^3];
                        coff4 = [-(b*(2*a-b))/L^2,-(a*(2*b-a))/L^2];

                        for dof = 1:length(f_loc)       
                            f_p = f_loc(dof)*coff1;     %forza equivalente dovuta a carico P concentrato
                            m_p = f_loc(dof)*coff2;     %momento equivalente dovuto a carico P concentrato
                            f_M = f_loc(dof)*coff3;     %forza equivalente dovuto a momento M concentrato
                            m_M = f_loc(dof)*coff4;     %momemento equivalente dovuto a momento M concentrato
                            if dof == 1%fx -> fx
                                F_loc(dof) = F_loc(dof) + f_p(1); %nodo1
                                F_loc(dof+6) = F_loc(dof+6) + f_p(2); %nodo2  
                            elseif dof == 2 %fy ->fy,mz
                                %nodo 1
                                F_loc(dof) = F_loc(dof) + f_p(1);
                                F_loc(dof+4)= F_loc(dof+4) + m_p(1);
                                %nodo 2
                                F_loc(dof+6) = F_loc(dof+6) + f_p(2);
                                F_loc(dof+10)= F_loc(dof+10) + m_p(2);
                            elseif dof == 3 %fz -> fz,my
                                %nodo 1
                                F_loc(dof) = F_loc(dof) + f_p(1);
                                F_loc(dof+2)= F_loc(dof+2) - m_p(1);
                                %nodo 2
                                F_loc(dof+6) = F_loc(dof+6) + f_p(2);
                                F_loc(dof+8)= F_loc(dof+8) - m_p(2);
                            elseif dof == 5 %my -> fz,my
                                %nodo 1
                                F_loc(dof-2) = F_loc(dof-2) - f_M(1);
                                F_loc(dof)= F_loc(dof) + m_M(1);
                                %nodo 2
                                F_loc(dof+4) = F_loc(dof+4) - f_M(2);
                                F_loc(dof+6)= F_loc(dof+6) + m_M(2);
                            elseif dof == 6 %Mz -> fy,mz
                                %nodo 1
                                F_loc(dof-4) = F_loc(dof-4) + f_M(1);
                                F_loc(dof)= F_loc(dof) + m_M(1);
                                %nodo 2
                                F_loc(dof+2) = F_loc(dof+2) + f_M(2);
                                F_loc(dof+6)= F_loc(dof+6) + m_M(2);
                            end                         
                        end
                        
                    elseif this.loads(l).type_load == 3 %distrload
                        for dof = 1:length(f_loc)
                            %forza equivalente dovuta a carico q distribuito
                            f_q = f_loc(dof)*[L/2;L/2]; 
                            %momento equivalente dovuto a carico q distribuito
                            m_q = f_loc(dof)*[L^2/12;-L^2/12];         
                            if dof == 1          %qx -> fx
                               F_loc(dof) = F_loc(dof) + f_q(1);     %nodo1 
                               F_loc(dof+6) = F_loc(dof+6) + f_q(2); %nodo2   
                            elseif dof == 2      %qy -> fy, Mz
                               %nodo 1
                               F_loc(dof) = F_loc(dof) + f_q(1);
                               F_loc(dof+4)= F_loc(dof+4) + m_q(1);
                               %nodo 2
                               F_loc(dof+6) = F_loc(dof+6) + f_q(2);
                               F_loc(dof+10)= F_loc(dof+10) + m_q(2); 
                            elseif dof == 3       %qz -> fz,my
                               %nodo 1
                               F_loc(dof) = F_loc(dof) + f_q(1);
                               F_loc(dof+2)= F_loc(dof+2) - m_q(1);
                               %nodo 2
                               F_loc(dof+6) = F_loc(dof+6) + f_q(2);
                               F_loc(dof+8)= F_loc(dof+8) - m_q(2);
                            end
                        end
                    end

                %portare F_loc sul sistema di riferimento globale
                T_1 = [lambda zeros(3,9)
                       zeros(3) lambda zeros(3,6)
                       zeros(3,6) lambda zeros(3)
                       zeros(3,9) lambda]; 
                F_gl = T_1' * F_loc;

                %inserire valori F_gl in F_ext
                for dof = 1:(length(F_gl)/2)
                    F_ext((node_1-1)*this.gdlmax+dof) = F_ext((node_1-1)*this.gdlmax+dof) + F_gl(dof);    %nodo1
                    F_ext((node_2-1)*this.gdlmax+dof) = F_ext((node_2-1)*this.gdlmax+dof) + F_gl(dof+6);  %nodo2
                end

                %..........................................................
                elseif this.loads(l).type_load == 4  %carico superficiale sull'elemento plate
                    %ricavo le coordinate globali
                    el_id = this.loads(l).getelement_id();           
                    nodes_id = this.elements(el_id).el.nodes_id;
                    X=zeros(length(nodes_id),3);
                    for i=1:length(nodes_id)
                        X(i,:)=this.nodes(nodes_id(i)).x;
                    end
                    
                    %ricavo le coordinati locali
                    [x,y,R]=this.elements(el_id).el.rotation_plate(X);

                    %calcolo dei jacobiani
                    cd 'Q8_mindlin'
                    M = matfile('N_ptGauss_Q8MINDLIN.mat');
                    N_ptGauss = M.N_ptGauss;
                    L = matfile('dev_N_ptGauss_Q8MINDLIN.mat');
                    dev_N_ptGauss = L.dev_N_ptGauss;
                    cd ..\
                    det_J=zeros(4,1);
                    for p=1:4
                        a=dev_N_ptGauss(1,:,p)*x';
                        b=dev_N_ptGauss(1,:,p)*y';
                        c=dev_N_ptGauss(2,:,p)*x';
                        d=dev_N_ptGauss(2,:,p)*y';
                        J=[a b; c d];
                        det_J(p)=det(J);
                    end
                    
                    q=this.loads(l).load';
                    %porto il carico dal sdr globale a quello locale
                    q=R'*q;
                    
                    F_nodes=zeros(3,8);
                    for j=1:8
                        
                        %integrazione di gauss
                        for p=1:4
                            for i=1:3
                                F_nodes(i,j)=F_nodes(i,j)+ N_ptGauss(1,j,p)*q(i)*det_J(p);
                            end
                        end
                        
                        %riporto i carichi equivalente dal sdr locale a quello globale
                        F_nodes(:,j)=R*F_nodes(:,j);
                    end
                    
                    %riporto i carichi nodali sul vettore complessivo dei carichi
                    for j=1:length(nodes_id)
                        ind1=(nodes_id(j)-1)*this.gdlmax+1;
                        ind2=ind1+2;
                        F_ext(ind1:ind2)=F_ext(ind1:ind2)+F_nodes(:,j);
                    end
                    
                end
                %..........................................................
            end
        end
        %------------------------------------------------------------------
        
        %--------------------VINCOLI SUGLI SPOSTAMENTI---------------------
        function [ind_u_inc, ind_u_vinc, u_vinc]=assemblyU(this)
           %OUTPUT
           % ind_u_inc:  vettore contenente gli indici di posizione, nel sistema
           %             lineare Ku=f, di tutti gli spostamenti incogniti
           % ind_u_vinc: vettore contenente gli indici di posizione, nel
           %             sistema lineare Ku=f, di tutti gli spostamenti
           %             vincolati
           % u_vinc:     vettore di dimensione dim contente le componenti di spostamento 
           %             bloccate o imposte
           
           %pre allocazione di memoria per ind_u_vinc e u_vinc
           long=0;
           for i=1:length(this.constraint)
               long=long+length(this.constraint(i).u_vinc);
           end
           ind_u_vinc=zeros(long,1);
           u_vinc=zeros(long,1);
           
           %assemblaggio di ind_u_vinc e di u_vinc
           cont_start=0; %variabile temporanea per l'assemblaggio 
           cont_end=0;   %variabile temporanea per l'assemblaggio 
           for i=1:length(this.constraint)
               cont_end=cont_start+length(this.constraint(i).u_vinc);
               ind_u_vinc(cont_start+1:cont_end)=this.constraint(i).ind_u_vinc;
               u_vinc(cont_start+1:cont_end)=this.constraint(i).u_vinc;
               cont_start=cont_end;
           end
           
           ind_u_inc=zeros(this.dim-length(ind_u_vinc),1);   %inizializzazione ind_u_inc
           temp=zeros(this.dim,1);                           %vettore temporaneo per memorizzare le posizioni vincolate
           temp(ind_u_vinc)=1;                               %temp è uguale a 1 nelle posizioni di spostamento vincolato
           cont=0;                                           %variabile contatore
           for i=1:this.dim
               if temp(i)==0
                   cont=cont+1;
                   ind_u_inc(cont)=i;
               end
           end
        end
        %------------------------------------------------------------------
        
        %--------------------SOLUTORE SENZA PENALTY------------------------
        function[u,f]=solutore(this)
            
            %chiamata funzioni di assemblaggio
            K=assemblyK(this);
            F=assemblyF(this);
            [ind_u_inc, ind_u_vinc, u_vinc]=assemblyU(this);
            
            %creazione variabili temporanee per la risoluzione parziale del sistema
            %lineare per trovare gli spostamenti incogniti 
            u_temp=zeros(this.dim,1);
            u_temp(ind_u_vinc)=u_vinc;
            F_temp=F-K*u_temp;
            
            %soluzione parziale del sistema totale
            u_inc=K(ind_u_inc,ind_u_inc)\F_temp(ind_u_inc);
            
            %soluzione completa del sistema lineare
            u=u_temp;
            u(ind_u_inc)=u_inc;
            f=K*u;
            
        end
        %------------------------------------------------------------------
        
        %----------------------SOLUTORE CON PENALTY------------------------
        function [u,F]=solutore_penalty(this,R)
            %chiamata funzioni di assemblaggio
            K=assemblyK(this);
            F=assemblyF(this);
            [~, ind_u_vinc, u_vinc]=assemblyU(this);
            
            %applicazione del coefficiente penalty
            k=K; %k è la matrice K ma che verrà modificata con il penalty
            f=F; %f è il vettore F ma che verrà modificato con il penalty
            for i=1:length(ind_u_vinc)
                k(ind_u_vinc(i),ind_u_vinc(i))=R;
                f(ind_u_vinc(i))=R*u_vinc(i);
            end
            
            %soluzione del sistema lineare
            u=k\f;
            F=K*u;
        end
        %------------------------------------------------------------------
    end
    %......................................................................
end

