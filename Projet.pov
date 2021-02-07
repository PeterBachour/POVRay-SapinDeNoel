#version 3.7;
#include "shapes.inc"
#include "colors.inc"
#include "textures.inc"

#declare sca=50;  									// scalaire pour la taille

global_settings { //max_trace_level 20 
assumed_gamma 1.0
}

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

//Paramètres à modifier
#declare hauteur=6; //hauteur du tronc
#declare rayon=6; //rayon de la brase des cones
#declare ecartHauteur=hauteur/2; // hauteur des cones
#declare nombreDeCone=6;
#declare rayonDeBoule=0.05;
#declare nombreDeBoule=30;

#declare rFicelle = 0.05;
#declare hFicelle = 0.7;
#declare cFicelle = rgb<1,0,0>;

#declare cLathe1 = rgbt<0,0.4,0.4,0.3>;
#declare cLathe2 = rgbt<0.4,1,0.4,0.3>;
#declare cLathe3 = rgbt<0.3,0,0.6,0.3>;

#declare guirlandeRayon = 0.12;
#declare guirlandecouleur = rgb<1,0,0>;

#declare guirlandeERayon = 0.12;
#declare guirlandeEcouleur = rgb<1,1,0>;
#declare guirlandeEcHigh = rgb<0,0,1>;
#declare guirlandeEcLow = rgb<0.5,0,0.5>;

#declare guirlandenbTours = 2;
#declare guirlandeEnbTours = 1;



//Paramètres à ne pas modifier
#declare Pi=3.1415;
#declare endpoint = <0,0,ecartHauteur+hauteur>;
#declare rot=2*Pi/nombreDeBoule/2;
#declare nombreDeCylindre=nombreDeBoule;



#macro Bspline4(step,P0,P1,P2,P3,P4,eq)
	 #local eq=(pow((1-step),4)*P0+4*step*pow((1-step),3)*P1+6*pow(step,2)*pow((1-step),2)*P2+4*pow(step,3)*(1-step)*P3+pow(step,4)*P4);
#end

#macro Bspline2(step,P0,P1,P2, eq)
	 #local eq=(pow((1-step),2)*P0+2*(1-step)*step*P1+step*step*P2);
#end

//Creation des lathes
#macro createLathe( P0, P1, P2, P3, colorr, tX, tY, tZ)
lathe{
  bezier_spline
  4,
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
	
    #local i = 0;
    #while(i<nb+1)
        #local t0=i/nb;
        #local M=<0,0,0>;
        Bspline4(t0,P0,P1,P2,P3,P4,M)
        #local tabP[i]=M;
		#local i = i+1;
    #end
    #local i = 0;
    #while(i<nb)

        cylinder{
            tabP[i] 
            tabP[i+1] 
            dimCyl
            pigment {color1}
			finish { metallic 0.3  }
        }
		#local i = i+1;
    #end
#end


//Creation de la guirlande Electrique
#macro guirlandeElectrique(P0,P1,P2,nb,dimCyl,color1)
    #local M=<0,0,0>;
    #local tabP=array[nb+1];
    #local i = 0;
    #while(i<nb+1)
        #local t0=i/nb;
        #local M=<0,0,0>;
        Bspline2(t0,P0,P1,P2,M)
        #local tabP[i]=M;
		#local i = i+1;
    #end
    #local i = 0;
    #while(i<nb)

        cylinder{
            tabP[i] 
            tabP[i+1] 
            dimCyl
            pigment {color color1}

        }
		#local i = i+1;
    #end
#end

#macro spirale(pente,hauteurspirale,hauteuroffset,coneOffset, nbTours,nbPoints,nbPointsGuirlande,dimCyl,Ccouleur,pointFinal)
    #local tabP=array[nbPoints+1];
	#local i = 0;
    #while(i<nbPoints+1)
		#local paramZ=(hauteuroffset+hauteurspirale) - ((i/nbPoints) * hauteurspirale)  ;
		#local coeff= ((hauteurspirale+hauteuroffset+coneOffset)-paramZ)*(pente)  ;
		#local paramX=coeff*cos(nbTours*paramZ*Pi);
		#local paramY=coeff*sin(nbTours*paramZ*Pi);
        #local tabP[i]=<paramX,paramY,paramZ>;    
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

#macro spiraleElectrique(pente,hauteurspirale,hauteuroffset, coneOffset ,nbTours,nbPoints,nbPointsGuirlande,dimCyl,Ccouleur,CHigh,CLow,pointFinal)
    #local tabP=array[nbPoints+1];
	#local i = 0;
    #while(i<nbPoints+1)
		#local paramZ=(hauteuroffset+hauteurspirale) - ((i/nbPoints) * hauteurspirale)  ;
		#local coeff= ((hauteurspirale+hauteuroffset+coneOffset)-paramZ)*(pente);
		#local paramX=coeff*sin(nbTours*paramZ*Pi);
		#local paramY=coeff*cos(nbTours*paramZ*Pi);
        #local tabP[i]=<paramX,paramY,paramZ>;    
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
			finish { ambient 100 }
			
		}
		#local i = i+2;

    #end
		guirlandeElectrique(tabP[nbPoints-2],tabP[nbPoints-1],pointFinal,nbPointsGuirlande,dimCyl,Ccouleur)
#end


#macro sapin()
object{									// creation du sapin
	union{         
		union {
			
		
				  cylinder{											// creation du cylindre qui est la base du tronc
				            <0,0,0>									// position du cylindre
				            <0,0,hauteur>								// mesure du cylindre
				            1											// rayon du cylindre
				            texture {DMFDarkOak scale 0.1}			// texture que le cylindre va prendre
			        	}

					sphere{										//creation des boules rouges
			     	 <	0, 0, hauteur+nombreDeCone*ecartHauteur >  //position de la boule au sommet
	     		 	 	0.5				
					 pigment {	Yellow }
					 finish { ambient 100 }

					
	                   }

		}
		#local i =0;
		union {
			
		
       #while(i< nombreDeCone)
	   			    #local rayonConeBase = (rayon*(1-i/nombreDeCone));
					#local rayonConePointe = 1-(1+i)/nombreDeCone;
			   	
	   				#local hauteurspirale = ecartHauteur;
					#local hauteurtmp = hauteur+ecartHauteur*(i);
					#local pointDepart = <0,0,hauteur+ecartHauteur*(i)>;
					#local pente = (rayonConeBase)/(ecartHauteur+rayonConePointe);

		union {
			
		
			union {
				
			
				union {

					union {
						union {
							//guirlande classique
							spirale(pente,hauteurspirale,hauteurtmp,rayonConePointe,guirlandenbTours,(100*(nombreDeCone-i))*guirlandenbTours,4,guirlandeRayon,guirlandecouleur,endpoint)
							#local P1 = < (endpoint.x - pointDepart.x)*1/4,(endpoint.y - pointDepart.y)*1/4,hauteur+ecartHauteur*(i)>;
							#local P2 = < (endpoint.x - pointDepart.x)*1/2,(endpoint.y - pointDepart.y)*1/2,hauteur+ecartHauteur*(i)>;
							#local P3 = < (endpoint.x - pointDepart.x)*3/4,(endpoint.y - pointDepart.y)*3/4,hauteur+ecartHauteur*(i)>;
							guirlande(pointDepart,P1,P2,P3,endpoint,4,guirlandeRayon,guirlandecouleur)
						}
						sphere {
							endpoint, guirlandeRayon // point, rayon
							pigment { 
								color guirlandecouleur
							}
						}
					}


					union {
						
					
						union {
							//guirlande Electrique
							spiraleElectrique(pente,hauteurspirale,hauteurtmp,rayonConePointe,guirlandeEnbTours,(14*nombreDeCone)-(i*12),4,guirlandeERayon,guirlandeEcouleur,guirlandeEcHigh,guirlandeEcLow,endpoint)
							#local P2 = < (endpoint.x - pointDepart.x)*1/2,(endpoint.y - pointDepart.y)*1/2,hauteur+ecartHauteur*(i)>;
							guirlandeElectrique(pointDepart,P2,endpoint,4,guirlandeERayon,guirlandeEcouleur)
						}

						sphere {
							endpoint, guirlandeERayon // point, rayon
							pigment { 
								guirlandeEcouleur
							}
						}
					}
				}

			   	
	       	
		       difference {
				   
						cone{											//creation du cone
							<0,0,hauteur+ecartHauteur*i> 		// location of base point
							rayonConeBase			// base point radius
							<0,0,hauteur+ecartHauteur*(i+1)> 	// location of cap point
							rayonConePointe				// cap point radius
					   }
					
					#local j=0;
					union {
						#while(j<nombreDeCylindre)				//nombre de cylindre a enlever
						cylinder{ 
							<	(rayonConeBase)*cos (2*Pi*j/nombreDeCylindre),  //position du cylindre a enlever
								(rayonConeBase)*sin(2*Pi*j/nombreDeCylindre),
								hauteur+i*ecartHauteur	>
						   	<	(rayonConePointe)*cos (2*Pi*j/nombreDeCylindre),      // mesure du cylindre a enlever
						            (rayonConePointe)*sin(2*Pi*j/nombreDeCylindre),
			                         	hauteur+(i+1)*ecartHauteur	>
				                        ((1-(i)/nombreDeCone))/8					//rayon du cylindre a enlever
		                        }
		                        #local j=j+1;
                  		#end  
					}
 					pigment{Jade}						// color of leaves


	       	
			   }
			}
			#local j=0;
			union {
				#while(j<nombreDeBoule)						//ajout de nombreDeBoule Boule
		     		
					#local pointX=rayonConeBase*cos (2*Pi*j/nombreDeBoule+rot);
					#local pointY=rayonConeBase*sin (2*Pi*j/nombreDeBoule+rot);
					#local pointZ=hauteur+i*ecartHauteur ;
					#local latheTranslationX=	(rayonConeBase)*cos (2*Pi*j/nombreDeBoule+rot)	;
					#local latheTranslationY=(rayonConeBase)*sin(2*Pi*j/nombreDeBoule+rot);
					#local latheTranslationZ=hauteur+i*ecartHauteur-hFicelle-0.2; // 0.2 est lier aux points dans la lathe
					union {
					 union {
						 sphere{										//creation des boules rouges
				     		 		<pointX, pointY, pointZ> 
					     		 	rayonDeBoule
				                  	pigment {Red} finish{diffuse 10}
		                  	}	
			                  cylinder {
			     		 		<pointX, pointY, pointZ> 
		 					<pointX, pointY, pointZ-hFicelle> 
							rFicelle
			                  	pigment {Black}
			                 	}
					 }


					 
					 #if( mod(i,3)=0)
					 union {
					 	createLathe( <0, -5 >, <3, -2 >, <3, 0 > , <3, 0.5>, cLathe1, latheTranslationX, latheTranslationY, latheTranslationZ)
						createLathe( <3, 0.5>, <2, 2 >, <2, 1 >, <rFicelle*10, 2 >, cLathe2,  latheTranslationX, latheTranslationY, latheTranslationZ)
						 }
					 
					 #end
					 #if( mod(i,3)=1)
					  union {
					  	createLathe( <1, -5 >, <2, -4 >, <2, -3 > , <1, -2>, cLathe2,  latheTranslationX, latheTranslationY, latheTranslationZ)
						createLathe(<1, -2>, <3, -1 >, <3, 0 >, <rFicelle*10, 2 >, cLathe3,  latheTranslationX, latheTranslationY, latheTranslationZ)
						 }
					 
					 #end
					  #if( mod(i,3)=2)
					  union{
					  	createLathe(  <0, -2 >, <1, -1>, <2, 0 >, <3,0>,cLathe3,  latheTranslationX, latheTranslationY, latheTranslationZ)
						createLathe(  <3, 0 >, <3, 1>, <2, 2 >, <rFicelle*10, 2 >, cLathe1,  latheTranslationX, latheTranslationY, latheTranslationZ)
					  }
					 #end

					}
	                  #declare j=j+1;
	               #end
			}
		}
             #declare nombreDeBoule = ((nombreDeBoule)/(i+1))+5; //div 0
             #declare nombreDeCylindre=nombreDeBoule;
             #declare rot=2*Pi/nombreDeBoule/2;
	       	#local i=i+1;
	       #end
		}


	       
	} 
	
}
#end

#macro superBoite()
object{
	box {
		<-1, -1, -1>, <1, 1, 1> // <x, y, z> near lower left corner, <x, y, z> far upper right corner
		
		pigment { 
				image_map {
							png  //type de fichier graphique, parmi ceux qui sont supportés 
							"linux"
							map_type 0    //Type = type de projection, 0,1,2,...
							interpolate 2 
					}
		}
		scale <2.0, 2.0, 2.0> // <x, y, z>
		rotate <90, 0, 0> // <x°, y°, z°>
	}
}
#end
#declare boite1 = superBoite()
#declare boite2 = superBoite()
#declare sapin1=sapin()
object{sapin1}
object{boite1 scale <1.1,1.0,1.0>}
object{boite2 rotate <0, 0, 90> scale <1.0,1.1,1.0>} // <x°, y°, z°>
