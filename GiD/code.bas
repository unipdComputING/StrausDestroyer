*set var indexTab = 0
*#nodes------------------------------------------01
nodes
*loop nodes
*set var posX = NodesCoord(1,real)
*set var posY = NodesCoord(2,real)
*set var posZ = NodesCoord(3,real)
*format "%5i %16.7e %16.7e %16.7e"
*nodesnum *posX *posY *posZ
*end nodes
end
*#elements---------------------------------------02
! ID_elem elemType [connectivity] ID_mat
elements
*loop elems
*format "%5i%5i%5i%5i%5i"
*set var elemType = 0
*if(strcasecmp(elemsmatprop(1),"Truss")==0)
*set var elemType = 1
*elseif(strcasecmp(elemsmatprop(1),"Beam")==0)
*set var elemType = 2
*end if
*elemsnum *elemType *ElemsConec *ElemsMat
*end elems
end
*#properties-------------------------------------03
! ID mat        E                nu               A                I11              I22              J
properties
*loop materials
*format "%5i %13.5e %13.5e %13.5e %13.5e %13.5e %13.5e"
*#       E                nu               A                I11              I22              J
*MatNum *MatProp(2,real) *MatProp(3,real) *MatProp(4,real) *MatProp(5,real) *MatProp(6,real) *MatProp(7,real)
*end materials
end
*#boundaries-------------------------------------04
*set cond Node-BC *nodes
boundaries
*loop nodes *OnlyInCond
*#*if(cond(13,int)!=0)
*#*format "%5i %2i %2i %2i %2i %2i %2i %16.7e %16.7e %16.7e %16.7e %16.7e %16.7e %5i"
*#*set var indexTab =Operation(indexTab+1)
*#*NodesNum *cond(1) *cond(3) *cond(5) *cond(7) *cond(9) *cond(11) *cond(2) *cond(4) *cond(6) *cond(8) *cond(10) *cond(12) *indexTab
*#*else
*format "%5i %2i %2i %2i %2i %2i %2i %16.7e %16.7e %16.7e %16.7e %16.7e %16.7e"
*NodesNum *cond(1) *cond(3) *cond(5) *cond(7) *cond(9) *cond(11) *cond(2) *cond(4) *cond(6) *cond(8) *cond(10) *cond(12) 
*#*endif
*end nodes
end
*#loads------------------------------------------05
loads
*set cond Node-Force *nodes
*set var loadType = 1
*loop nodes *OnlyInCond
*format "%5i %16.7e %16.7e %16.7e %16.7e %16.7e %16.7e %5i"
*set var indexTab =Operation(indexTab+1)
*loadType *cond(1) *cond(2) *cond(3) *cond(4) *cond(5) *cond(6) *NodesNum
*end nodes
end
*#solver-----------------------------------------06
*#outputs----------------------------------------07