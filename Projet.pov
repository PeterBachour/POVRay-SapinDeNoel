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

background {White}								    // fond d'ecran blanc

#declare hauteur=6;
#declare rayon=6; 
#declare ecartHauteur=hauteur/2;
#declare nombreDeCone=6; 
#declare i=0;
#declare Pi=3.1415;
#declare rot=2*Pi/20/2;
#declare rBoul=0.35;
#declare nombreDeBoule=25;

#declare sapin=object{								// creation du sapin
	union{
		  cylinder{											// creation du cylindre qui est la base du tronc
		            <0,0,-1>								// position du cylindre
		            <0,0,hauteur>									// mesure du cylindre
		            1										// rayon du cylindre
		            texture {DMFDarkOak scale 0.1}			// texture que le cylindre va prendre
	        	}
	       union {
	       #while(i< nombreDeCone)
		        cone{											//creation du cone
					<0,0,hauteur+ecartHauteur*i> 		// location of base point
					rayon*(1-i/nombreDeCone)			// base point radius
					<0,0,hauteur+ecartHauteur*(i+1)> 	// location of cap point
					1-(1+i)/nombreDeCone				// cap point radius 
					pigment{Jade}							// color of leaves
				}
				#declare j=0;
				#while(j<nombreDeBoule)
	     		 sphere{
	     		 	<	(rayon*(1-i/nombreDeCone))*cos (2*Pi*j/nombreDeBoule+rot),
	     		 		(rayon*(1-i/nombreDeCone))*sin(2*Pi*j/nombreDeBoule+rot),
	     		 		hauteur+i*ecartHauteur > 
	     		 	rBoul/(i+1)
                            pigment {Red}
                        }
                        #declare j=j+1;
                        #end
              #declare nombreDeBoule = nombreDeBoule-3;
	        #declare i=i+1;
	        #end
	       }
	}
}

object{sapin}