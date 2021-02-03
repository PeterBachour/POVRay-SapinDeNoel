#include "shapes.inc"
#include "colors.inc"
#include "textures.inc"


#declare sca=50;  									// scalaire pour la taille
 
camera {
    location <0.2*sca,1*sca,14.5> 					// location of camera
    look_at <0,0,10>								// ou la camera va se fixer 
    sky <0,0,1> 									// pour avoir le Z en haut
    right <-image_width/image_height,0,0>	 	    // pour un repere direct
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
#macro Bspline5(step,P0,P1,P2,P3,P4,eq)
	 #local eq=(pow(1-step,4)*P0+4*step*pow(1-step,3)*P1+4*pow(step,2)*pow(1-step,2)*P2+4*pow(step,3)*(1-step)*P3+pow(step,4)*P4);
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
#macro guirlande(P0,P1,P2,P3,P4,nb,dimPt,dimCyl,color1)
    #local M=<0,0,0>;
    #declare tabP=array[nb+1];
    #for(i,0,nb)
        #declare t0=i/nb;
        #declare M=<0,0,0>;
        Bspline5(t0,P0,P1,P2,P3,P4,M)
        #declare tabP[i]=M;
    #end
    #for(i,0,nb-1)
        cylinder{
            tabP[i] tabP[i+1] dimCyl
            pigment {color color1}
        }
    #end
#end



#declare sapin=object{									// creation du sapin
	union{         
				  cylinder{											// creation du cylindre qui est la base du tronc
				            <0,0,-1>									// position du cylindre
				            <0,0,hauteur>								// mesure du cylindre
				            1											// rayon du cylindre
				            texture {DMFDarkOak scale 0.1}			// texture que le cylindre va prendre
			        	}
       #while(i< nombreDeCone)
		       difference {
				   	union {
							cone{											//creation du cone
							<0,0,hauteur+ecartHauteur*i> 		// location of base point
							rayon*(1-i/nombreDeCone)			// base point radius
							<0,0,hauteur+ecartHauteur*(i+1)> 	// location of cap point
							1-(1+i)/nombreDeCone				// cap point radius 
					   }
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
//			                         	(rayon*(1-i/nombreDeCone))*0.075	
				                        ((1-(i)/nombreDeCone))/8					//rayon du cylindre a enlever
		                        }
		                        #declare j=j+1;
                  		#end  
					}
 					pigment{Jade}							// color of leaves

	       	}
	       	union {
	       		#declare P0=<0,(rayon*1)*((1-(i-1)/nombreDeCone)),hauteur+(1+i)* ecartHauteur>; //Point du dessus
        			#declare P1 = <(rayon*3)*((1-(i)/nombreDeCone)), 0,hauteur+i*ecartHauteur+(ecartHauteur/4)>;
        			#declare P2 = <0,	-(rayon*3)*((1-(i)/nombreDeCone)),	hauteur+i* ecartHauteur +(2* ecartHauteur/4)>;
        			#declare P3 = <-(rayon*3)*((1-(i)/nombreDeCone)),0,hauteur+i* ecartHauteur +(3* ecartHauteur/4)>;
        			#declare P4 = <0,	(rayon*1)*((1-(i-1)/nombreDeCone)), hauteur+i* ecartHauteur>; 
	       		#declare nb=100;
	       		#declare dimPt=0.05;
	       		#declare dimCyl=0.05;
	       		guirlande(P0,P1,P2,P3,P4,nb,dimPt,dimCyl,Red)
	       	}
	       	
		
			#declare j=0;
			union {
				#while(j<nombreDeBoule)						//ajout de nombreDeBoule Boule
		     		union {
					#declare rayonJ = 	 rayon*(1-i/nombreDeCone);	 
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
					  	createLathe(4,  <0, -2 >, <1, -1>, <2, 0 >, <3,0>, rgbt<0.3,0,0.6,0.3>,  latheX, latheY, latheZ)						createLathe(4,  <3, 0 >, <3, 1>, <2, 2 >, <rFicelle*10, 2 >, rgb<0.3,1,0.6,0.3>,  latheX, latheY, latheZ)
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
	       sphere{										//creation des boules rouges
			     	<	0, 0, hauteur+nombreDeCone*ecartHauteur >  //position de la boule au sommet
	     		 		0.5				
					pigment { Black}
	                  }
	} 
	
}
object{sapin}