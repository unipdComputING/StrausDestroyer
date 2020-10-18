classdef GID < GLOBAL
  properties
  end
  methods
    %-----------------------------------------------------------constructor
    function this=GID()
    end
    %----------------------------------------------------------------------
    function mshBEAM(this,stFilePath, nodes,elements,depth)
      path = strcat(stFilePath,'.msh');
      unit = fopen(path, 'w');
      if (unit == -1)
        error('cannot open file for writing');
        return;
      end
      totNodes = size(nodes,2);
      totElem  = size(elements,2);
      fprintf(unit,'#RESULTS 1D models \n');
      fprintf(unit,'MESH "mod" dimension 3 Elemtype Line Nnode 2\n');
      fprintf(unit,'#Nodal coordinates \n');
      fprintf(unit,'coordinates \n');
      for n=1:totNodes
          fprintf(unit, '%i %f %f %f \n', nodes(n).id, nodes(n).x(1), ...
                                                       nodes(n).x(2), ...
                                                       nodes(n).x(3));
      end
      for n=1:totNodes
          fprintf(unit, '%i %f %f \n', n+totNodes, nodes(n).x(1), depth);
      end
      fprintf(unit,'end coordinates \n');
      fprintf(unit,'elements \n');
      for e=1:totElem
          id = elements(e).id;
          totNodes = elements(e).getTotNodes();
          fprintf(unit,'%i ', id);
          for i = 1:totNodes
            fprintf(unit, '%i ', elements(e).nodeID(i));
          end
          fprintf(unit, '%i ', elements(e).propID());
          fprintf(unit,'\n');
      end
      fprintf(unit,'end elements \n');
      fclose(unit);
    end
    %----------------------------------------------------------------------
    function plotGIDNodesRes(this,stFilePath,NDOF,nodes,dbU,dbF)
      path = strcat(stFilePath,'.res');
      unit = fopen(path, 'w');
      if (unit == -1)
        error('cannot open file for writing');
        return
      end
      dimRes  = size(dbU  ,2);
      dimNode = size(nodes,2);

      flag = 1;

      totStep = dimRes;
      fprintf(unit,'GiD Post Results File 1.0 \n');
      for i=1:totStep
          if (flag==0)
              t = time(i);
          else
              t = i;
          end
          %----------------------------------------------------------------
          %displacements
          st = strcat({'Result '},{'"Disp U" '}, ...
                                  {'"nlAnalysis" '   }, ...
                                    string(t),{' Vector OnNodes \n'});
          fprintf(unit,string(st));
          st = strcat({'ComponentNames '},{'"Ux"'},{', '} ...
                                         ,{'"Uy"'},{', '} ...
                                         ,{'"Uz"'},{'\n'});
          fprintf(unit,string(st));
          fprintf(unit,'Values \n');
          for n=1:dimNode
            fprintf(unit,'%i %f %f %f\n',n,dbU(NDOF*(n-1)+1,i),...
                                           dbU(NDOF*(n-1)+2,i),...
                                           dbU(NDOF*(n-1)+3,i));
          end
          fprintf(unit,'End Values \n\n');
          %end displacements
          %rotations
          st = strcat({'Result '},{'"Disp R" '}, ...
                                  {'"nlAnalysis" '   }, ...
                                    string(t),{' Vector OnNodes \n'});
          fprintf(unit,string(st));
          st = strcat({'ComponentNames '},{'"Rx"'},{', '} ...
                                         ,{'"Ry"'},{', '} ...
                                         ,{'"Rz"'},{'\n'});
          fprintf(unit,string(st));
          fprintf(unit,'Values \n');
          for n=1:dimNode
            fprintf(unit,'%i %f %f %f \n',n,dbU(NDOF*(n-1)+4,i),...
                                            dbU(NDOF*(n-1)+5,i),...
                                            dbU(NDOF*(n-1)+6,i));
          end
          fprintf(unit,'End Values \n\n');
          %end rotation
          %----------------------------------------------------------------
          %----------------------------------------------------------------
          %internal loads
          st = strcat({'Result '},{'"Reactions F" '     } ...
                                 ,{'"nlAnalysis" '} ...
                                 ,   string(t),{' Vector OnNodes \n'});
          fprintf(unit,string(st));
          st = strcat({'ComponentNames '},{'"Fx"'},{', '} ...
                                         ,{'"Fy"'},{', '} ...
                                         ,{'"Fz"'},{'\n'});
          fprintf(unit,string(st));
          fprintf(unit,'Values \n');
          for n=1:dimNode
              fprintf(unit,'%i %f %f %f \n',n,dbF(NDOF*(n-1)+1,i),...
                                              dbF(NDOF*(n-1)+2,i),...
                                              dbF(NDOF*(n-1)+3,i));
          end
          fprintf(unit,'End Values \n\n');
          %end internal loads
          %internal bendings
          st = strcat({'Result '},{'"Reactions M" '     } ...
                                 ,{'"nlAnalysis" '} ...
                                 ,   string(t),{' Vector OnNodes \n'});
          fprintf(unit,string(st));
          st = strcat({'ComponentNames '},{'"Mx"'},{', '} ...
                                         ,{'"My"'},{', '} ...
                                         ,{'"Mz"'},{'\n'});
          fprintf(unit,string(st));
          fprintf(unit,'Values \n');
          for n=1:dimNode
              fprintf(unit,'%i %f %f %f \n',n,dbF(NDOF*(n-1)+4,i),...
                                              dbF(NDOF*(n-1)+5,i),...
                                              dbF(NDOF*(n-1)+6,i));
          end
          fprintf(unit,'End Values \n\n');
          %end internal bendings
          %----------------------------------------------------------------
          %----------------------------------------------------------------
      end
      fclose(unit);
    end
    %----------------------------------------------------------------------
    %----------------------------------------------------------------------
    %----------------------------------------------------------------------
    %----------------------------------------------------------------------
    %----------------------------------------------------------------------
    %----------------------------------------------------------------------
    %----------------------------------------------------------------------
    %----------------------------------------------------------------------
    %----------------------------------------------------------------------
    %----------------------------------------------------------------------
    %----------------------------------------------------------------------
  end
end