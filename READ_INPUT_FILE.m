  %--------------------------------------------------------------------------
function [nodes,...
          elements,...
          properties,...
          boundaries,...
          endRelease,...
          loads,...
          filePath]=READ_INPUT_FILE()
  %-----
  nodes      = NODE.empty;
  elements   = ELEMENT.empty;
  properties = PROPERTY.empty;
  loads      = LOAD.empty;
  boundaries = CONSTRAINT.empty;
  endRelease = zeros(1,1);
  %tables    = zeros(1,1);
  %-----
  [stPath,pathName] = uigetfile('*.dat');
  stPath = strcat(pathName,stPath);
  try
    unitIN = fopen(stPath,'r');
  catch
    fprintf('ERROR in READ_INPUT_FILE: cannot open input file\n');
    return
  end
  %-----
  p =0;
  b =0;
  l =0;
  n =0;
  e =0;
  er=0;
  % mod da filePath(originale) a stfilePath non è questo l'errore
  filePath = stPath;
  %-----
  %-----
  while  ~feof(unitIN)
    stCommand = fgetl(unitIN);
    switch stCommand
      case 'properties'
        stLine = fgetl(unitIN);
        while (~feof(unitIN))&&(strcmp(stLine,'end')==0)
          p  = p+1;
          st = strsplit(stLine);
          st(strcmp('',st)) = [];
          id = str2double(st(1));
          mat = MATERIAL("E",  str2double(st(2)), ...
                         "nu", str2double(st(3)));
          sec = SECTION(str2double(st(4)), ...
                        str2double(st(5)), ...
                        str2double(st(6)), ...
                        str2double(st(7)));
          properties(p)=PROPERTY(id, mat, sec);
          stLine = fgetl(unitIN);
        end
      case 'boundaries'
        stLine = fgetl(unitIN);
        while (~feof(unitIN))&&(strcmp(stLine,'end')==0)
          b  = b+1;
          st = strsplit(stLine);
          st(strcmp('',st)) = [];
          id = str2double(st(1));
          fix = str2double(st(2:7));
          disp = str2double(st(8:13));
          boundaries(b) = CONSTRAINT(id, fix, disp);
          %table
          %if (size(st,1)>=8)
          %  boundaries(m,8)=str2double(st(8));
          %end
          stLine = fgetl(unitIN);
        end
      case 'endrelease'
        stLine = fgetl(unitIN);
        while (~feof(unitIN))&&(strcmp(stLine,'end')==0)
          er  = er+1;
          st = strsplit(stLine);
          st(strcmp('',st)) = [];
          endRelease(er,1)=str2double(st(1)); %insex elem
          endRelease(er,2)=str2double(st(2)); %index node
          endRelease(er,3)=str2double(st(3)); %rel_dir_x
          endRelease(er,4)=str2double(st(4)); %rel_dir_y
          endRelease(er,5)=str2double(st(5)); %rel_dir_r
          stLine = fgetl(unitIN);
        end
      case 'loads'
        stLine = fgetl(unitIN);
        while (~feof(unitIN))&&(strcmp(stLine,'end')==0)  
          l  = l+1;
          st = strsplit(stLine); 
          st(strcmp('',st)) = []; 
          dim = size(st,2);
          loadType = str2double(st(1)); 
          if (loadType == 1)
            node_id = str2double(st(dim));
            loadVec = str2double(st(2:dim-1));
            loads(l) = LOAD(loadType, loadVec, node_id);
          elseif (loadType == 2)
            el_id = str2double(st(dim-1));
            loadVec = str2double(st(2:dim-2));
            a = str2double(st(dim));
            loads(l) = LOAD(loadType, loadVec, el_id,a);
          elseif (loadType == 3 || loadType == 4)
            el_id = str2double(st(dim));
            loadVec = str2double(st(2:dim-1));
            loads(l) = LOAD(loadType, loadVec, el_id);
          end
          %table
          %if (size(st,1)>=5)
          %  loads(l,5)=str2double(st(5));
          %end
          stLine = fgetl(unitIN);
        end
      case 'nodes'
        stLine = fgetl(unitIN);
        while (~feof(unitIN))&&(strcmp(stLine,'end')==0)
          n = n + 1;
          st = strsplit(stLine);
          st(strcmp('',st)) = [];
          id = str2double(st(1));
          dim = size(st,2);
          x = str2double(st(2:dim));
          nodes(n) = NODE(id, x);
          stLine = fgetl(unitIN);
        end
      case 'elements'
        stLine = fgetl(unitIN);
        while (~feof(unitIN))&&(strcmp(stLine,'end')==0)
          e  = e +1;
          st = strsplit(stLine);
          st(strcmp('',st)) = [];
          dim = size(st,2);
          id = str2double(st(1));
          elemType = str2double(st(2));
          idmat = str2double(st(dim));
          idnodes = str2double(st(3:dim-1));
          elements(e)=ELEMENT(id, elemType, idnodes, idmat);
          stLine = fgetl(unitIN);
        end
      case 'solver'
        i=0;
        stLine = fgetl(unitIN);
        while (~feof(unitIN))&&(strcmp(stLine,'end')==0)
          i  = i+1;
          st = strsplit(stLine);
          st(strcmp('',st)) = [];
          solverPar(1)=str2double(st(1));
          solverPar(2)=str2double(st(2));
          solverPar(3)=str2double(st(3));
          solverPar(4)=str2double(st(4));
          stLine = fgetl(unitIN);
        end
    end
  end
  fclose(unitIN);
  %-----
  %-----
end
%--------------------------------------------------------------------------