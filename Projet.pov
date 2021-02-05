#include "shapes.inc"
#include "colors.inc"
#include "textures.inc"


#declare sca=50;  									// scalaire pour la taille

//global_settings { max_trace_level 20 }

camera {
    location <0.2*sca,1*sca,14.5> 					// location of camera
    look_at <0,0,10>								// ou la camera va se fixer 
    sky <0,0,1> 									// pour avoir le Z en haut
    right <-image_width/image_height,0,0>	 	    // pour un repere direct
    rotate<0,0, -360*(clock+0.10)>
}

light_source { <0.4*sca,1*sca,14.5> White }		    // light source
light_source { <-0.4*sca,1*sca,14.5> White }       	// light source          

background {White}								  	  // fond d'ecran blanc

#declare hauteur=6;
#declare rayon=6; 
#declare ecartHauteur=hauteur/2;
#declare nombreDeCone=6; 
#declare i=0;
#declare Pi=3.1415;
#declare rayonDeBoule=0.05;
#declare nombreDeBoule=30;
#declare nombreDeCylindre=nombreDeBoule;
#declare rot=2*Pi/nombreDeBoule/2;
#declare rFicelle = 0.06; 

//ne pas multiplier 
#macro Bspline4(step,P0,P1,P2,P3,P4,eq)
	 #local eq=(pow((1-step),4)*P0+4*step*pow((1-step),3)*P1+6*pow(step,2)*pow((1-step),2)*P2+4*pow(step,3)*(1-step)*P3+pow(step,4)*P4);
#end

#macro Bspline2(step,P0,P1,P2, eq)
	 #local eq=(pow((1-step),2)*P0+2*(1-step)*step*P1+step*step*P2);
#end

//Creation des lathes
#macro createLathe(nbPoints, P0, P1, P2, P3, colorr, tX, tY, tZ)
lathe{
  bezier_spline
  nbPoints,
  P0, P1, P2, P3
  pigment {color colorr}
  rotate <90, 0, 0> // <x°, y°, z°>
  scale <0.1, 0.1, 0.1> // <x, y, z>
  translate <tX, tY, tZ> // <x, y, z>
}
#end

//Creation de la guirlande
#macro guirlande(P0,P1,P2,P3,P4,nb,dimCyl,color1)
    #local M=<0,0,0>;
    #local tabP=array[nb+1];
    #for(i,0,nb)
        #local t0=i/nb;
        #local M=<0,0,0>;
        Bspline4(t0,P0,P1,P2,P3,P4,M)
        #local tabP[i]=M;
    #end
    #for(i,0,nb-1)

        cylinder{
            tabP[i] 
            tabP[i+1] 
            dimCyl
            pigment {color1}
        }
    #end
#end


//Creation de la guirlande Electrique
#macro guirlandeElectrique(P0,P1,P2,nb,dimCyl,color1)
    #local M=<0,0,0>;
    #local tabP=array[nb+1];
    #for(i,0,nb)
        #local t0=i/nb;
        #local M=<0,0,0>;
        Bspline2(t0,P0,P1,P2,M)
        #local tabP[i]=M;
    #end
    #for(i,0,nb-1)

        cylinder{
            tabP[i] 
            tabP[i+1] 
            dimCyl
            pigment {color color1}
        }
    #end
#end

#macro spirale(pente,hauteurspirale,hauteuroffset,nbTours,nbPoints,nbPointsGuirlande,dimCyl,Ccouleur,pointFinal)
    #local tabP=array[nbPoints+1];
	#local i = 0;
    #while(i<nbPoints+1)
		#declare paramZ=(hauteuroffset+hauteurspirale) - ((i/nbPoints) * hauteurspirale)  ;
		#declare coeff= ((hauteurspirale+hauteuroffset)-paramZ)*pente  ;
		#declare paramX=coeff*cos(nbTours*paramZ);
		#declare paramY=coeff*sin(nbTours*paramZ);
        #declare tabP[i]=<paramX,paramY,paramZ>;    
		#local i = i+1;
    #end
	#local pointFinal = tabP[nbPoints];	
	#local i = 1;
    #while(i<nbPoints-4)
		guirlande(tabP[i-1],tabP[i],tabP[i+1],tabP[i+2],tabP[i+3],nbPointsGuirlande,dimCyl,Ccouleur)
		#local i = i+4;
    #end
		guirlande(tabP[nbPoints-4],tabP[nbPoints-3],tabP[nbPoints-2],tabP[nbPoints-1],pointFinal,nbPointsGuirlande,dimCyl,Ccouleur)
#end

#macro spiraleElectrique(pente,hauteurspirale,hauteuroffset,nbTours,nbPoints,nbPointsGuirlande,dimCyl,Ccouleur,CHigh,CLow,pointFinal)
    #local tabP=array[nbPoints+1];
	#local i = 0;
    #while(i<nbPoints+1)
		#declare paramZ=(hauteuroffset+hauteurspirale) - ((i/nbPoints) * hauteurspirale)  ;
		#declare coeff= ((hauteurspirale+hauteuroffset)-paramZ)*pente  ;
		#declare paramX=coeff*sin(nbTours*paramZ);
		#declare paramY=coeff*cos(nbTours*paramZ);
        #declare tabP[i]=<paramX,paramY,paramZ>;    
		#local i = i+1;
    #end
	#local pointFinal = tabP[nbPoints];	
	#local i = 1;
    #while(i<nbPoints-2)
		guirlandeElectrique(tabP[i-1],tabP[i],tabP[i+1],nbPointsGuirlande,dimCyl,Ccouleur)
		#if ( mod(clock*360, 2) < 0.5 )
      #local color1 = CHigh;
    	#else
       #local color1 = CLow;
		#end
		sphere {
			tabP[i], 0.15 // <x, y, z>, radius
			pigment { 
				color1
			}
			
		}
		#local i = i+2;

    #end
		guirlandeElectrique(tabP[nbPoints-2],tabP[nbPoints-1],pointFinal,nbPointsGuirlande,dimCyl,Ccouleur)
#end

#declare endpoint = <0,0,ecartHauteur+hauteur>; 

#declare sapin=object{									// creation du sapin
	union{         
				  cylinder{											// creation du cylindre qui est la base du tronc
				            <0,0,0>									// position du cylindre
				            <0,0,hauteur>								// mesure du cylindre
				            1											// rayon du cylindre
				            texture {DMFDarkOak scale 0.1}			// texture que le cylindre va prendre
			        	}
       #while(i< nombreDeCone)

			   	union {
					#local hauteurspirale = ecartHauteur;
					#local hauteurtmp = hauteur+ecartHauteur*(i);
					#local pointDepart = <0,0,hauteur+ecartHauteur*(i)>;
					#local dimcyl = 0.12;
					#local pente = ((rayon*(1-i/nombreDeCone))/ecartHauteur)  ;

					spirale(pente,hauteurspirale,hauteurtmp,6,100*(nombreDeCone-i),4,dimcyl,Red,endpoint)
					#local P1 = < (endpoint.x - pointDepart.x)*1/4,(endpoint.y - pointDepart.y)*1/4,hauteur+ecartHauteur*(i)>;
					#local P2 = < (endpoint.x - pointDepart.x)*1/2,(endpoint.y - pointDepart.y)*1/2,hauteur+ecartHauteur*(i)>;
					#local P3 = < (endpoint.x - pointDepart.x)*3/4,(endpoint.y - pointDepart.y)*3/4,hauteur+ecartHauteur*(i)>;
					guirlande(pointDepart,P1,P2,P3,endpoint,4,dimcyl,Red)

			   	}
				   	union {
					#local hauteurspirale = ecartHauteur;
					#local hauteurtmp = hauteur+ecartHauteur*(i);
					#local pointDepart = <0,0,hauteur+ecartHauteur*(i)>;
					#local dimcyl = 0.12;
					#local pente = ((rayon*(1-i/nombreDeCone))/ecartHauteur)  ;

					spiraleElectrique(pente,hauteurspirale,hauteurtmp,3,100-(i*12),4,dimcyl,Yellow,Green,Magenta,endpoint)
					#local P2 = < (endpoint.x - pointDepart.x)*1/2,(endpoint.y - pointDepart.y)*1/2,hauteur+ecartHauteur*(i)>;
					guirlandeElectrique(pointDepart,P2,endpoint,4,dimcyl,Yellow)

			   	}
	       	
		       difference {
				   
						cone{											//creation du cone
							<0,0,hauteur+ecartHauteur*i> 		// location of base point
							rayon*(1-i/nombreDeCone)			// base point radius
							<0,0,hauteur+ecartHauteur*(i+1)> 	// location of cap point
							0				// cap point radius 
					   }
					
					#declare j=0;
					union {
						#while(j<nombreDeCylindre)				//nombre de cylindre a enlever
						cylinder{ 
							<	(rayon*(1-i/nombreDeCone))*cos (2*Pi*j/nombreDeCylindre),  //position du cylindre a enlever
								(rayon*(1-i/nombreDeCone))*sin(2*Pi*j/nombreDeCylindre),
								hauteur+i*ecartHauteur	>
						   	<	((1-(i+1)/nombreDeCone))*cos (2*Pi*j/nombreDeCylindre),      // mesure du cylindre a enlever
						            ((1-(i+1)/nombreDeCone))*sin(2*Pi*j/nombreDeCylindre),
			                         	hauteur+(i+1)*ecartHauteur	>
				                        ((1-(i)/nombreDeCone))/8					//rayon du cylindre a enlever
		                        }
		                        #declare j=j+1;
                  		#end  
					}
 					pigment{Jade}						// color of leaves


	       	}
			#declare j=0;
			union {
				#while(j<nombreDeBoule)						//ajout de nombreDeBoule Boule
		     		union {
					#declare rayonJ = rayon*(1-i/nombreDeCone);	 
					#declare pointX=rayonJ*cos (2*Pi*j/nombreDeBoule+rot);
					#declare pointY=rayonJ*sin (2*Pi*j/nombreDeBoule+rot);
					#declare pointZ=hauteur+i*ecartHauteur ;
					
					 union {
						 sphere{										//creation des boules rouges
				     		 		<pointX, pointY, pointZ> 
					     		 	rayonDeBoule
				                  	pigment {Red} finish{diffuse 10}
		                  	}	
			                  cylinder {
			     		 		<pointX, pointY, pointZ> 
		 					<pointX, pointY, pointZ-0.7> 
							rFicelle
			                  	pigment {Black}
			                 	}
					 }
					 #declare latheX=	(rayon*(1-i/nombreDeCone))*cos (2*Pi*j/nombreDeBoule+rot);
					 #declare latheY=(rayon*(1-i/nombreDeCone))*sin(2*Pi*j/nombreDeBoule+rot);
					 #declare latheZ=hauteur+i*ecartHauteur-0.7-0.2;

					 
					 #if( mod(i,3)=0)
					 union {
					 	createLathe(4, <0, -5 >, <3, -2 >, <3, 0 > , <3, 0.5>, rgbt<0,0.4,0.4,0.3>, latheX, latheY, latheZ)
						createLathe(4, <3, 0.5>, <2, 2 >, <2, 1 >, <rFicelle*10, 2 >, rgbt<0.4,0.4,0,0.3>,  latheX, latheY, latheZ)
						 }
					 
					 #end
					 #if( mod(i,3)=1)
					  union {
					  	createLathe(4, <1, -5 >, <2, -4 >, <2, -3 > , <1, -2>, rgbt<0.4,1,0.4,0.3>,  latheX, latheY, latheZ)
						createLathe(4, <1, -2>, <3, -1 >, <3, 0 >, <rFicelle*10, 2 >, rgbt<0,0.4,1,0.3>,  latheX, latheY, latheZ)
						 }
					 
					 #end
					  #if( mod(i,3)=2)
					  union{
					  	createLathe(4,  <0, -2 >, <1, -1>, <2, 0 >, <3,0>, rgbt<0.3,0,0.6,0.3>,  latheX, latheY, latheZ)
						createLathe(4,  <3, 0 >, <3, 1>, <2, 2 >, <rFicelle*10, 2 >, rgb<0.3,1,0.6,0.3>,  latheX, latheY, latheZ)
					  }
					 #end

					}
	                  #declare j=j+1;
	               #end
			}
             #declare nombreDeBoule = nombreDeBoule-5;
             #declare nombreDeCylindre=nombreDeBoule;
             #declare rot=2*Pi/nombreDeBoule/2;
	       #declare i=i+1;
	       #end
	       union {
	       sphere{										//creation des boules rouges
			     	<	0, 0, hauteur+nombreDeCone*ecartHauteur >  //position de la boule au sommet
	     		 		0.5				
					pigment {Black}
	                  }

	       }
	} 
	
}
object{sapin}