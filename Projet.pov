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
#declare rayonDeBoule=0.3;
#declare nombreDeBoule=30;
#declare nombreDeCylindre=nombreDeBoule;
#declare rot=2*Pi/nombreDeBoule/2;
#declare rFicelle = 0.06

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
				                        ((1-(i)/nombreDeCone))/8					//rayon du cylindre a enlever
		                        }
		                        #declare j=j+1;
                  		#end  
					}
 							pigment{Jade}							// color of leaves

	       	}
		
			#declare j=0;
			union {
				#while(j<nombreDeBoule)						//ajout de nombreDeBoule Boule
		     		union {
						 
					 
					 union {
					 sphere{										//creation des boules rouges
			     		 	<	(rayon*(1-i/nombreDeCone))*cos (2*Pi*j/nombreDeBoule+rot),
			     		 		(rayon*(1-i/nombreDeCone))*sin(2*Pi*j/nombreDeBoule+rot),
			     		 		hauteur+i*ecartHauteur > 
				     		 	rayonDeBoule				
		                            pigment {Red} finish{diffuse 10}
	                  }
	                  cylinder {
	                 			 <	(rayon*(1-i/nombreDeCone))*cos (2*Pi*j/nombreDeBoule+rot),
			     		 		(rayon*(1-i/nombreDeCone))*sin(2*Pi*j/nombreDeBoule+rot),
			     		 		hauteur+i*ecartHauteur > 
 						<	(rayon*(1-i/nombreDeCone))*cos (2*Pi*j/nombreDeBoule+rot),
			     		 		(rayon*(1-i/nombreDeCone))*sin(2*Pi*j/nombreDeBoule+rot),
			     		 		hauteur+i*ecartHauteur-1 >
								rFicelle
	                  		pigment {Black}
	                  }

					  lathe{

						  bezier_spline
						  4,
						  <0, -5 >, <3, -2 >, <3, 0 >, <rFicelle, 2 >
						  pigment {Blue}
						  rotate <90, 0, 0> // <x°, y°, z°>
						  scale <0.1, 0.1, 0.1> // <x, y, z>
						  translate <(rayon*(1-i/nombreDeCone))*cos (2*Pi*j/nombreDeBoule+rot),
			     		 		(rayon*(1-i/nombreDeCone))*sin(2*Pi*j/nombreDeBoule+rot),
			     		 		hauteur+i*ecartHauteur-1 > // <x, y, z>
					  }
					 }
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