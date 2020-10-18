clear;
clc;
clf;
fprintf('-------------------------------------------------------------\n');
fprintf('---------------------------------------------------------CODE\n');
fprintf('-----------------------------------------------MECOMP 2019-20\n');
fprintf('-------------------------------------------------------------\n');
fprintf('-------------------------------------------------------------\n');
fprintf('START\n');
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%---------------------------------------------------------------------INPUT
[nodes,elements,properties,boundaries,endRelease,loads,...
                                             stFilePath]=READ_INPUT_FILE();
lenPath = length(stFilePath);
if lenPath>4 
  st        = strsplit(stFilePath,'.inp');
  stFilePath=st{1};
else
  stFilePath = 'resBEAM2D';
end
%-----------------------------------------------------------------END INPUT
%--------------------------------------------------------------------------
%--------------------------------------------------------------------SOLVER
sol=SOLUTORE(elements,nodes,properties, loads, boundaries);
k=sol.assemblyK();
[n,n]=size(k);
k=zeros(n,n)+k;
[u,f]=sol.solutore();
%----------------------------------------------------------------END SOLVER
fprintf('END\n');

gid = GID();
gl  = GLOBAL();
lenPath = length(stFilePath);
if lenPath>4
  stFilePath =  erase(stFilePath,'.dat');
  gid.mshBEAM        (stFilePath, nodes,elements,0.2);
  gid.plotGIDNodesRes(stFilePath,6 ,nodes, u, f);
end


fprintf('-------------------------------------------------------------\n');
fprintf('-------------------------------------------------------------\n');
fprintf('-------------------------------------------------------------\n');


