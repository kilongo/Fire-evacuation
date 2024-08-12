/**
* Name: Evacuationincendie
* Based on the internal empty template. 
* Author: ibanz
* Tags: 
*/
model Evacuationincendie

/* Insert your model definition here */
global { //chargement des fichiers shapes
	file fichier_couche_feu <- file("../includes/couche/shape_fire.shp");
	file fichier_mur <- file("../includes/couche/mur.shp");
	file fichier_porte <- file("../includes/couche/porte.shp");
	file fichier_zone <- file("../includes/couche/zone.shp");
	file fichier_escalier <- file("../includes/couche/escalier.shp");
	file fichier_forme <- file("../includes/couche/forme.shp");
	file fichier_zone_ascenseur <- file("../includes/couche/zone_ascenseur.shp");
	file fichier_zone_neutre <- file("../includes/couche/zone_neutre.shp");
	float opacity_sonnerie;
	int nb_personne parameter: 'Number of persons' init: 100 min: 20 category: "LES VERSIONS DE SIMULATION";
	int capacite_ascenseur parameter: 'Elevator capacity ' init: 5 min: 1 category: "LES VERSIONS DE SIMULATION";
	float Probabilite_Nier parameter: 'Probability deny ' init: 0.1 min: 0.1 category: "LES VERSIONS DE SIMULATION";
	float Probabilite_patienter parameter: 'Probabilite paniquer ' init: 0.1 min: 0.1 category: "LES VERSIONS DE SIMULATION";
	int tour_maximal <- 90; //en degree
	int facteur_de_cohesion <- 10;
	float taille_personne <- 10.0;
	//int nb_personne <- 50;
	geometry shape <- envelope(fichier_mur);
	geometry espace_libre;
	point point_sortie <- {650, 615};
	point point_1_transit_etage_3 <- {360, 310};
	point point_2_transit_etage_3 <- {200, 310};
	point point_1_transit_etage_2 <- {540, 530};
	point point_1_transit_etage_1 <- {230, 610};
	point point_2_transit_etage_1 <- {445, 610};
	point point_3_transit_etage_1 <- {580, 610};
	point point_1_ascenseur_etage_2 <- {140, 520};
	point point_panneau_etage_3 <- {430, 320};
	point point_panneau_etage_2 <- {430, 535};
	point point_panneau_etage_1 <- {490, 630};
	point point_sortie_2 <- {660, 600};
	point mapapa2 <- {510, 307};
	string situation_actuelle <- "situation_narmale";
	string situation <- "mapapa";
	int nb_cols <- 90;
	int nb_rows <- 90;
	bool sortie_1 <- true;
	bool sortie_2 <- true;
	bool propagation_feu <- true;
	bool usage_ascenseur <- true;
	string modelisation <- "";
	int nb_patienter <- 0;
	int nb_paniquer <- 0;
	int nb_se_conformer <- 0;
	int nb_evaluer <- 0;
	int nb_nier <- 0;
	int nb_former <- 0;
	int nb_connaitre <- 0;
	int temps_evacuation;
	int nb_blesse;
	int nb_mort;
	bool afficher;

	init {
		espace_libre <- copy(shape);
		create mur from: fichier_mur {
			espace_libre <- espace_libre - (shape + taille_personne);
			ask cellule overlapping self {
				est_mur <- true;
			}

		}

		espace_libre <- espace_libre simplification (1.0);
		create porte from: fichier_porte {
		}

		create zone from: fichier_zone {
		}

		create couche_feu from: fichier_couche_feu {
		}

		create zone_ascenseur from: fichier_zone_ascenseur {
		}

		create zone_neutre from: fichier_zone_neutre {
		}

		list les_zones <- list(zone);
		les_zones[0].nom <- "zone_6";
		les_zones[1].nom <- "zone_7";
		les_zones[2].nom <- "zone_8";
		les_zones[3].nom <- "zone_4";
		les_zones[4].nom <- "zone_5";
		les_zones[5].nom <- "zone_1";
		les_zones[6].nom <- "zone_2";
		les_zones[7].nom <- "zone_3";
		create feu number: 200 {
			location <- any_location_in(one_of(les_zones[0], les_zones[1], les_zones[2], les_zones[3], les_zones[4], les_zones[7]));
			if (location.y > 180 and location.y < 330) {
				nom <- "etage_3";
			}

			if (location.y > 400 and location.y < 550) {
				nom <- "etage_2";
			}

			if (location.y > 630 and location.y < 780) {
				nom <- "etage_1";
			}

		}

		create escalier from: fichier_escalier {
		}

		create personne number: nb_personne {
			location <- any_location_in(one_of(zone));
			loop i from: 0 to: 7 {
				if (self distance_to les_zones[i] <= 2) {
					if (i = 0) {
						zone_affectation <- "zone_6";
						ecartement <- true;
					}

					if (i = 1) {
						zone_affectation <- "zone_7";
						ecartement <- true;
					}

					if (i = 2) {
						zone_affectation <- "zone_8";
						ecartement <- true;
					}

					if (i = 3) {
						zone_affectation <- "zone_4";
						ecartement <- true;
					}

					if (i = 4) {
						zone_affectation <- "zone_5";
						ecartement <- true;
					}

					if (i = 5) {
						zone_affectation <- "zone_1";
						ecartement <- true;
					}

					if (i = 6) {
						zone_affectation <- "zone_2";
						ecartement <- true;
					}

					if (i = 7) {
						zone_affectation <- "zone_3";
						ecartement <- true;
					}

				}

			}

			categorie_prevacuation <- rnd_choice(["nier"::0.1, "se_conformer"::0.1, "connaitre"::0.1, "patienter"::0.3, "paniquer"::0.2, "evaluer"::0.1, "formee"::0.1]);
			if (categorie_prevacuation = "nier") {
				temps_preevacuation <- 64;
			}

			if (categorie_prevacuation = "se_conformer") {
				temps_preevacuation <- 40;
			}

			if (categorie_prevacuation = "connaitre") {
				temps_preevacuation <- 40;
			}

			if (categorie_prevacuation = "patienter") {
				temps_preevacuation <- 50;
			}

			if (categorie_prevacuation = "evaluer") {
				temps_preevacuation <- 80;
			}

			if (categorie_prevacuation = "formee") {
				temps_preevacuation <- 60;
			}

			if (categorie_prevacuation != "paniquer" and categorie_prevacuation != "evaluer" and categorie_prevacuation != "se_conformer") {
				categorie_connaissance_chemin_sortie <- rnd_choice(["il_connait"::0.7, "il_ne_connait_pas"::0.3]);
				//categorie_formation <- rnd_choice(["forme"::0.3, "non_formee"::0.7]);
			}

			if (zone_affectation = "zone_4" or zone_affectation = "zone_5" or zone_affectation = "zone_6" or zone_affectation = "zone_7" or zone_affectation = "zone_8") {
				if (categorie_prevacuation != "paniquer" or categorie_prevacuation != "evaluer" or categorie_prevacuation != "se_conformer") {
					peut_prendre_ascenseur <- rnd_choice([true::0.7, false::0.3]);
				}

			}

			if (zone_affectation = "zone_1" and categorie_prevacuation = "evaluer") {
				categorie_prevacuation <- "nier";
				categorie_connaissance_chemin_sortie <- "il_connait";
			}

			if (zone_affectation = "zone_1" and categorie_prevacuation = "se_conformer") {
				categorie_prevacuation <- "nier";
				categorie_connaissance_chemin_sortie <- "il_connait";
			}

			if (zone_affectation = "zone_6" and categorie_connaissance_chemin_sortie = "il_ne_connait_pas") {
				categorie_connaissance_chemin_sortie <- "il_connait";
			}

			if (categorie_prevacuation = "formee") {
				categorie_connaissance_chemin_sortie <- "il_connait";
			}

			if (zone_affectation = "zone_5" and categorie_prevacuation = "evaluer") {
				categorie_prevacuation <- "nier";
				categorie_connaissance_chemin_sortie <- "il_connait";
			}

			if (categorie_prevacuation = "paniquer") {
				couleur <- #orange;
			}

			if (categorie_prevacuation = "nier") {
				couleur <- #deepskyblue;
			}

			if (categorie_prevacuation = "se_conformer") {
				couleur <- #lime;
			}

			if (categorie_prevacuation = "connaitre") {
				couleur <- #gamablue;
			}

			if (categorie_prevacuation = "patienter") {
				couleur <- #purple;
			}

			if (categorie_prevacuation = "evaluer") {
				couleur <- #blue;
			}

			if (categorie_prevacuation = "formee") {
				couleur <- #red;
			}

			if (modelisation = "Evacuation") {
				if (categorie_prevacuation = "evaluer" or categorie_prevacuation = "se_conformer") {
					categorie_prevacuation <- "paniquer";
				}

				if (categorie_prevacuation = "formee" or categorie_prevacuation = "nier" or categorie_prevacuation = "connaitre") {
					categorie_prevacuation <- "patienter";
					etat <- "evacuation";
					preevacuation <- true;
				}

				etat <- "evacuation";
			}

		}

		list les_zone_neutre <- list(zone_neutre);
		les_zone_neutre[0].nom <- "place_sonnerie_1";
		les_zone_neutre[1].nom <- "place_panneau_1";
		les_zone_neutre[2].nom <- "place_sonnerie_2";
		les_zone_neutre[3].nom <- "place_panneau_2";
		les_zone_neutre[4].nom <- "place_sonnerie_3";
		les_zone_neutre[5].nom <- "place_panneau_3";
		list les_zone_ascenceur <- list(zone_ascenseur);
		les_zone_ascenceur[0].nom <- "ascenseur_etage_3";
		les_zone_ascenceur[1].nom <- "porte_ascenseur_etage_3";
		les_zone_ascenceur[2].nom <- "ascenseur_etage_2";
		les_zone_ascenceur[3].nom <- "porte_ascenseur_etage_2";
		les_zone_ascenceur[4].nom <- "ascenseur_etage_1";
		list les_portes <- list(porte);
		les_portes[0].nom <- "zone_1";
		les_portes[1].nom <- "zone_2";
		les_portes[2].nom <- "zone_3";
		les_portes[3].nom <- "zone_4";
		les_portes[4].nom <- "zone_5";
		les_portes[5].nom <- "zone_6";
		les_portes[6].nom <- "zone_7";
		les_portes[7].nom <- "zone_8";
		les_portes[8].nom <- "sortie_1";
		les_portes[9].nom <- "sortie_2";
		list les_escaliers <- list(escalier);
		les_escaliers[0].nom <- "sortie_escalier_1";
		les_escaliers[1].nom <- "entree_escalier_1";
		les_escaliers[2].nom <- "sortie_escalier_2";
		les_escaliers[3].nom <- "entree_escalier_2";
		loop i from: 0 to: 5 {
			if (i = 0) {
				create sonnerie number: 1 {
					location <- les_zone_neutre[i].location;
					nom <- "sonnerie_etage_3";
				}

			}

			if (i = 2) {
				create sonnerie number: 1 {
					location <- les_zone_neutre[i].location;
					nom <- "sonnerie_etage_2";
				}

			}

			if (i = 4) {
				create sonnerie number: 1 {
					location <- les_zone_neutre[i].location;
					nom <- "sonnerie_etage_1";
				}

			}

			if (i = 1) {
				create panneau number: 1 {
					location <- les_zone_neutre[i].location;
					nom <- "panneau_etage_3";
				}

			}

			if (i = 3) {
				create panneau number: 1 {
					location <- les_zone_neutre[i].location;
					nom <- "panneau_etage_2";
				}

			}

			if (i = 5) {
				create panneau number: 1 {
					location <- les_zone_neutre[i].location;
					nom <- "panneau_etage_1";
				}

			}

		}

		create ascenseur number: 1 {
			list<zone_ascenseur> Zones <- list(zone_ascenseur) where ((each.nom = "ascenseur_etage_1"));
			location <- Zones[0].location;
		}

		if (modelisation != "Evacuation") {
			list<personne> people_1 <- list(personne) where ((each.categorie_prevacuation = "paniquer"));
			nb_paniquer <- length(people_1);
			list<personne> people_2 <- list(personne) where ((each.categorie_prevacuation = "nier"));
			nb_nier <- length(people_2);
			list<personne> people_3 <- list(personne) where ((each.categorie_prevacuation = "se_conformer"));
			nb_se_conformer <- length(people_3);
			list<personne> people_4 <- list(personne) where ((each.categorie_prevacuation = "patienter"));
			nb_patienter <- length(people_4);
			list<personne> people_5 <- list(personne) where ((each.categorie_prevacuation = "evaluer"));
			nb_evaluer <- length(people_5);
			list<personne> people_6 <- list(personne) where ((each.categorie_prevacuation = "formee"));
			nb_former <- length(people_6);
			list<personne> people_7 <- list(personne) where ((each.categorie_prevacuation = "connaitre"));
			nb_connaitre <- length(people_6);
			afficher <- true;
		}

	}

	reflex debut_feu when: cycle = 40 {
		list fire <- list(feu);
		situation_actuelle <- "preevacuation";
		int nb_feu <- length(fire);
		if (fire != []) {
			feu element <- fire[rnd(nb_feu)];
			element.etat <- "actif";
		}

	}

	reflex calcul_temps_evacuation {
		list<personne> people <- list(personne);
		if (people != []) {
			if (situation_actuelle = "preevacuation") {
				temps_evacuation <- temps_evacuation + 1;
				write "Total evacuation time :" + temps_evacuation * 0.5 + " Seconds";
				write "Number of people dead : " + nb_mort + " Pople";
				write "Number of people injured: " + nb_blesse + " People";
			}

		}

	}

}

grid cellule width: nb_cols height: nb_rows neighbors: 8 {
	bool est_mur <- false;
	rgb color <- #white;
}

species mur {

	aspect default_mur {
		draw shape color: rgb(255, 128, 128, 255);
	}

}

species porte {
	string nom;
	rgb couleur <- #green;
	string etat <- "ouverte";

	aspect default_porte {
		if (nom = "sortie_1" and !sortie_1) {
			draw shape color: couleur;
		}

		if (nom = "sortie_2" and !sortie_2) {
			draw shape color: couleur;
		}

	}

}

species escalier {
	rgb couleur <- rgb(0, 128, 128, 255);
	string nom;

	aspect default_escalier {
		draw shape color: couleur;
	}

	reflex ff {
		if (nom = "sortie_escalier_2") {
			couleur <- #red;
		}

	}

}

species zone {
	string nom;
	rgb couleur;

	aspect default_zone {
		draw shape color: rgb(147, 0, 0, 255);
	}

}

species zone_ascenseur {
	string nom;
	rgb couleur <- rgb(0, 128, 255, 255);

	aspect default_ascenseur {
		draw shape color: couleur;
	}

	reflex ff {
		if nom = "porte_ascenseur_etage_3" {
			couleur <- #red;
		}

	}

}

species zone_neutre {
	string nom;
	rgb couleur <- #green;

	reflex ff {
		if nom = "place_panneau_2" {
			couleur <- #blue;
		}

	}

	aspect default_neutre {
		draw shape color: couleur;
	}

}

species couche_feu {
	string nom;
	rgb couleur;

	aspect default_feu {
		draw shape color: #blue;
	}

}

species ascenseur skills: [moving] {
	string nom;
	rgb couleur;
	bool est_occuper;
	point sa_destination;
	bool est_arriver;
	float vitesse <- 5.0;
	string position <- "monter";
	bool deja_recuperer;
	int nb_recuperer;
	int capacite <- 5;
	list Personnes;
	file texture_as <- image_file('../includes/ascenseur.png');

	aspect default {
	//draw square(40) color: #blue;
		draw texture_as size: 60;
	}

	reflex aller_au_but {
		if (est_occuper) {
			if (self distance_to sa_destination.location <= 3) {
				est_arriver <- true;
				if (position = "monter") {
					Personnes <- list(personne) where ((each.peut_embarquer = true) and (each distance_to self <= 150) and !deja_recuperer);
					if (Personnes != []) {
						nb_recuperer <- length(Personnes);
						if (nb_recuperer > capacite) {
							nb_recuperer <- capacite;
						}

						deja_recuperer <- true;
						if (nb_recuperer <= capacite) {
							loop i from: 0 to: nb_recuperer - 1 {
								personne element <- Personnes[i];
								element.sa_destination <- self.location;
								element.vitesse <- self.vitesse;
							}

						} else {
							loop i from: 0 to: capacite - 1 {
								personne element <- Personnes[i];
								element.sa_destination <- self.location;
								element.vitesse <- self.vitesse;
							}

						}

					}

				}

			} else {
				est_arriver <- false;
			}

		}

		if (deja_recuperer) {
			list<personne> Personnes_ <- list(personne) where ((each.peut_embarquer = true) and (each distance_to self <= 20));
			int nb_perso <- length(Personnes_);
			if (nb_perso <= capacite) {
			}
			// if(nb_perso=nb_recuperer){
			if (nb_perso = nb_recuperer) {
				list<zone_ascenseur> Zones <- list(zone_ascenseur) where ((each.nom = "ascenseur_etage_1"));
				if (Personnes_ != []) {
					loop i from: 0 to: nb_recuperer - 1 {
						personne element <- Personnes_[i];
						element.vitesse <- vitesse;
						element.sa_destination <- Zones[0].location;
						element.etat <- "est_dans_ascenseur";
						element.peut_marcher <- false;
					}

				}

				sa_destination <- Zones[0].location;
				position <- "descendre";
			}

		}

		if (position = "descendre") {
			if (self distance_to sa_destination.location <= 3 and sa_destination != nil) {
				list<personne> Personnes_ <- list(personne) where ((each.peut_embarquer = true) and (each distance_to self <= 50));
				int nb_perso <- length(Personnes_);
				list<porte> portes_ <- list(porte) where ((each.nom = "sortie_1"));
				if (Personnes_ != []) {
					loop i from: 0 to: nb_recuperer - 1 {
						personne element <- Personnes_[i];
						element.vitesse <- rnd(1.0, 3.0, 1.0);
						element.sa_destination <- portes_[0].location;
						//element.etat<-"fuir";
						element.peut_marcher <- false;
						element.peut_embarquer <- false;
						element.ecartement <- false;
						element.tmp <- "sors_ascenseur";
					}

				}

				position <- "monter";
				est_occuper <- false;
				est_arriver <- false;
				deja_recuperer <- false;
			}

		}

		do goto target: sa_destination speed: vitesse;
	}

}

species sonnerie {
	string nom;
	string etat <- "inactif";
	rgb couleur <- #red;
	int calc <- 0;
	int rayon_observation <- 50;
	file texture_2 <- image_file('../includes/sonnerie2.png');

	aspect default_texture_1 {
		if (etat = "actif") {
			draw texture_2 size: 30;
		}

	}

	reflex observer_feu {
		if (nom = "sonnerie_etage_1") {
			list<feu> fire <- list(feu) where ((each.etat = "actif") and (each.nom = "etage_1"));
			if (fire != []) {
				etat <- "actif";
			}

		}

		if (nom = "sonnerie_etage_2") {
			list<feu> fire <- list(feu) where ((each.etat = "actif") and (each.nom = "etage_2"));
			if (fire != []) {
				etat <- "actif";
			}

		}

		if (nom = "sonnerie_etage_3") {
			list<feu> fire <- list(feu) where ((each.etat = "actif") and (each.nom = "etage_3"));
			if (fire != []) {
				etat <- "actif";
			}

		}

	}

	reflex sonner when: etat = "actif" {
		calc <- calc + 1;
		if (calc = 2) {
			opacity_sonnerie <- 1.0;
			calc <- 0;
		} else {
			opacity_sonnerie <- 0.1;
		}

	}

}

species panneau {
	string nom;
	string etat <- "inactif";
	rgb couleur <- #red;
	int rayon_observation <- 50;
	file texture_ <- image_file('../includes/Panneau2.png');

	aspect default {
	//if (nom = "place_panneau_2") {
		draw texture_ size: 25;
		//draw circle(10) color: #green;

		//}

	}

}

species feu {
	string nom;
	string etat <- "inactif";
	rgb couleur <- #red;
	int rayon_observation <- 50;
	string position;
	file texture <- file('../includes/fire2.gif');

	aspect feu {
		if (etat = "actif") {
			draw texture size: 20;
			//draw circle(20) color:couleur;
		}

	}

	reflex propagation_feu when: etat = "actif" and propagation_feu {
		list<zone> zones <- list(zone) where ((each distance_to self <= rayon_observation));
		if (zones != []) {
			position <- zones[0].nom;
		}

		list<feu> fire <- list(feu) where ((each.etat = "inactif") and (each distance_to self <= rayon_observation));
		if (fire != []) {
			if (flip(0.009)) {
				feu cible <- first(fire sort_by (self distance_to each));
				cible.etat <- "actif";
			}

		}

	}

}

species personne skills: [moving] {
	point sa_destination;
	string tmp;
	int energie <- rnd(100, 200, 10);
	string categorie_formation;
	string categorie_prevacuation;
	string categorie_connaissance_chemin_sortie;
	bool peut_marcher;
	string etat <- "travailler";
	string zone_affectation;
	bool peut_prendre_ascenseur;
	int id_image <- rnd(1, 5);
	float vitesse <- 2 + rnd(1000) / 1000;
	point velocite <- {0, 0};
	float taille <- taille_personne;
	rgb couleur;
	int temps_preevacuation;
	bool preevacuation;
	bool ecartement;
	int calcul_temps <- 0;
	string mission <- "nulle";
	bool peut_embarquer;
	int rayon_observation <- 80;
	bool deja_feu;

	//Direction de l'agent en tenant compte de la rotation maximale qu'un agent est capable d'effectuer
	//float heading max: heading + tour_maximal min: heading - tour_maximal;
	aspect man {
	//draw circle(6) color: couleur;
	//list les_zones <- list(zone);
		draw obj_file("../includes/image/images/people" + id_image + "/people.obj", -150::{0, 0.7, 0}) at: location + {0, 0, 45} size: 39.4 rotate: 80 color: #red;
		if (categorie_prevacuation = "paniquer") {
		//draw self.name + self.categorie_prevacuation + categorie_connaissance_chemin_sortie + "  " + sa_destination + zone_affectation color: #black;
		}

		if (modelisation != "Evacuation") {
			draw circle(10) color: couleur depth: 0.1;
		}

		//draw obj_file("../includes/lego_obj.obj", 90::{-1,0,0}) at: location +{0,0,0.3} size: rnd(0.2,0.4) rotate: heading + 90 color:color;
	}

	reflex travailler when: etat = "travailler" {
		if not (self overlaps espace_libre) {
			location <- ((location closest_points_with espace_libre)[1]);
		}

		do action: wander amplitude: 180.0;
	}

	reflex preevacuation when: situation_actuelle = "preevacuation" {
		if (categorie_prevacuation = "nier" and !self.preevacuation) {
			do nier;
			calcul_temps <- calcul_temps + 1;
			if (calcul_temps * 0.5 = temps_preevacuation) {
				etat <- "evacuation";
				preevacuation <- true;
				calcul_temps <- 0;
			}

		}

		if (categorie_prevacuation = "connaitre" and !self.preevacuation) {
			do nier;
			calcul_temps <- calcul_temps + 1;
			if (calcul_temps * 0.5 = temps_preevacuation) {
				etat <- "evacuation";
				preevacuation <- true;
				calcul_temps <- 0;
			}

		}

		if (categorie_prevacuation = "paniquer" and !self.preevacuation) {
			do paniquer;
		}

		if (categorie_prevacuation = "formee" and !self.preevacuation) {
			do formee;
			calcul_temps <- calcul_temps + 1;
			if (calcul_temps * 0.5 = temps_preevacuation) {
				etat <- "evacuation";
				preevacuation <- true;
				calcul_temps <- 0;
			}

		}

		if (categorie_prevacuation = "patienter" and !self.preevacuation) {
			do patienter;
			calcul_temps <- calcul_temps + 1;
			if (calcul_temps * 0.5 = temps_preevacuation) {
				etat <- "evacuation";
				preevacuation <- true;
				calcul_temps <- 0;
			}

		}

		if (categorie_prevacuation = "evaluer" and !self.preevacuation) {
			do evaluer;
			if (self distance_to sa_destination <= 7) {
				etat <- "evaluer";
				calcul_temps <- calcul_temps + 1;
				if (calcul_temps * 0.5 = temps_preevacuation) {
					etat <- "evacuation";
					preevacuation <- true;
					calcul_temps <- 0;
				}

			}

		}

		if (categorie_prevacuation = "se_conformer" and !self.preevacuation) {
			do suivre_les_autres;
		}

	}

	reflex evacuation when: etat = "evacuation" {
		do calcul_du_chemin(self, "evacuation");
	}

	action nier {
		if not (self overlaps espace_libre and !self.preevacuation) {
			location <- ((location closest_points_with espace_libre)[1]);
		}

		do action: wander amplitude: 180.0;
		etat <- "nier";
	}

	action paniquer {
		list<porte> Porte <- list(porte) where ((each.nom = "sortie_1"));
		sa_destination <- Porte[0].location;
		do goto target: sa_destination speed: 3.0 on: (cellule where not each.est_mur) recompute_path: false;
		etat <- "paniquer";
	}

	action evaluer {
		list<feu> fire <- list(feu) where ((each.etat = "actif"));
		if (fire != [] and etat = "travailler") {
			string nom_ <- fire[0].position;
			list<zone> zones_ <- list(zone) where ((each.nom = nom_));
			if (zones_ != []) {
				sa_destination <- any_location_in(zones_[0]);
				do goto target: sa_destination speed: 3.0 on: (cellule where not each.est_mur) recompute_path: false;
			}
			//ecartement <- false;

		}

	}

	action formee {
		list<porte> Porte <- list(porte) where ((each.nom = zone_affectation));
		sa_destination <- Porte[0].location;
		peut_marcher <- true;
		etat <- "former";
	}

	action patienter {
		etat <- "stopper_de_bouger";
	}

	action suivre_les_autres {
		list<personne> Personne <- list(personne) where ((each.etat = "evacuation") and each distance_to self <= rayon_observation and !self.preevacuation);
		calcul_temps <- calcul_temps + 1;
		if (Personne != []) {
			sa_destination <- point_sortie_2.location;
			do goto target: sa_destination speed: vitesse on: (cellule where not each.est_mur) recompute_path: false;
			//preevacuation<-true;
			etat <- "evacuation";
		}

		if (calcul_temps > 320) {
			sa_destination <- point_sortie_2.location;
			do goto target: sa_destination speed: vitesse on: (cellule where not each.est_mur) recompute_path: false;
			//preevacuation<-true;
		}

	}

	action calcul_du_chemin (personne Personne, string position) {
		if (categorie_connaissance_chemin_sortie = "il_connait" and categorie_prevacuation != "paniquer" and categorie_prevacuation != "evaluer" and categorie_prevacuation !=
		"se_conformer") {
			if (mission = "nulle") {
				list<porte> Porte <- list(porte) where ((each.nom = Personne.zone_affectation));
				//if (zone_affectation = "zone_1" or zone_affectation = "zone_1" zone_affectation = "zone_1" zone_affectation = "zone_1") {
				if (Porte != [] and Personne.mission = "nulle") {
					Personne.sa_destination <- Porte[0].location;
					Personne.peut_marcher <- true;
					Personne.mission <- "mission_1";
				}

				//} 
			}
			//Deuxieme
			if (mission = "mission_1") {
				if (self distance_to Personne.sa_destination <= 7) {
					mission <- "mission_2";
					if (zone_affectation = "zone_1") {
						sa_destination <- point_1_transit_etage_1.location;
					}

					if (zone_affectation = "zone_2") {
						sa_destination <- point_2_transit_etage_1.location;
					}

					if (zone_affectation = "zone_3") {
						sa_destination <- point_3_transit_etage_1.location;
					}

					if (zone_affectation = "zone_4") {
						if (peut_prendre_ascenseur and usage_ascenseur) {
							list<zone_ascenseur> porte_as <- list(zone_ascenseur) where ((each.nom = "porte_ascenseur_etage_2"));
							sa_destination <- porte_as[0].location;
							ecartement <- false;
						} else {
							sa_destination <- point_1_transit_etage_2.location;
						}

					}

					if (zone_affectation = "zone_5") {
						list<escalier> Escalier <- list(escalier) where ((each.nom = "sortie_escalier_1"));
						if (peut_prendre_ascenseur) {
							list<zone_ascenseur> porte_as <- list(zone_ascenseur) where ((each.nom = "porte_ascenseur_etage_2"));
							sa_destination <- porte_as[0].location;
							ecartement <- false;
						} else {
							if (Escalier != []) {
								sa_destination <- Escalier[0].location;
							}

						}

					}

					if (zone_affectation = "zone_6") {
						if (peut_prendre_ascenseur) {
							list<zone_ascenseur> porte_as <- list(zone_ascenseur) where ((each.nom = "porte_ascenseur_etage_3"));
							sa_destination <- porte_as[0].location;

							//Personne.ecartement <- false;
						} else {
							sa_destination <- point_2_transit_etage_3.location;
						}

					}

					if (zone_affectation = "zone_7") {
						list<zone_neutre> Escalier <- list(zone_neutre) where ((each.nom = "place_panneau_1"));
						if (peut_prendre_ascenseur) {
							list<zone_ascenseur> porte_as <- list(zone_ascenseur) where ((each.nom = "porte_ascenseur_etage_3"));
							sa_destination <- porte_as[0].location;
							ecartement <- false;
						} else {
							if (Escalier != []) {
								sa_destination <- point_1_transit_etage_3.location;
								ecartement <- true;
							}

						}

					}

					if (zone_affectation = "zone_8") {
						list<escalier> Escalier <- list(escalier) where ((each.nom = "sortie_escalier_2"));
						if (peut_prendre_ascenseur) {
							list<zone_ascenseur> porte_as <- list(zone_ascenseur) where ((each.nom = "porte_ascenseur_etage_3"));
							sa_destination <- porte_as[0].location;
							ecartement <- false;
						} else {
							if (Escalier != []) {
								sa_destination <- Escalier[0].location;
							}

						}

					}

				}

			}
			//Troisieme
			if (mission = "mission_2") {
				if (self distance_to Personne.sa_destination <= 3) {
					mission <- "mission_3";
					if (zone_affectation = "zone_1") {
						list<porte> Portes <- list(porte) where ((each.nom = "sortie_1"));
						if (Portes != []) {
							Personne.sa_destination <- Portes[0].location;
						}

					}

					if (zone_affectation = "zone_2") {
						list<porte> Portes <- list(porte) where ((each.nom = "sortie_1"));
						if (Portes != []) {
							Personne.sa_destination <- Portes[0].location;
						}

					}

					if (zone_affectation = "zone_3") {
						list<porte> Portes <- list(porte) where ((each.nom = "sortie_2"));
						if (Portes != []) {
							sa_destination <- Portes[0].location;
						}

					}

					if (zone_affectation = "zone_4" and !peut_prendre_ascenseur) {
						list<escalier> Escalier <- list(escalier) where ((each.nom = "entree_escalier_1"));
						if (Escalier != []) {
							Personne.sa_destination <- Escalier[0].location;
						}

					}

					if (zone_affectation = "zone_5" and !peut_prendre_ascenseur) {
						list<escalier> Escalier <- list(escalier) where ((each.nom = "entree_escalier_1"));
						if (Escalier != []) {
							sa_destination <- Escalier[0].location;
						}

					}

					if (zone_affectation = "zone_8" and !peut_prendre_ascenseur) {
						list<escalier> Escalier <- list(escalier) where ((each.nom = "entree_escalier_2"));
						if (Escalier != []) {
							sa_destination <- Escalier[0].location;
						}

					}

					if (zone_affectation = "zone_6" and !peut_prendre_ascenseur) {
						list<escalier> Escalier <- list(escalier) where ((each.nom = "sortie_escalier_2"));
						if (Escalier != []) {
							sa_destination <- Escalier[0].location;
						}

					}

					if (zone_affectation = "zone_7" and !peut_prendre_ascenseur) {
						list<escalier> Escalier <- list(escalier) where ((each.nom = "sortie_escalier_2"));
						if (Escalier != []) {
							sa_destination <- Escalier[0].location;
						}

					}

				}

			}

			//Quatriem
			if (mission = "mission_3") {
				if (self distance_to Personne.sa_destination <= 3) {
					mission <- "mission_4";
					if (zone_affectation = "zone_7" and !peut_prendre_ascenseur) {
						list<escalier> Escalier <- list(escalier) where ((each.nom = "entree_escalier_2"));
						if (Escalier != []) {
							sa_destination <- Escalier[0].location;
						}

					}

					if (zone_affectation = "zone_8" and !peut_prendre_ascenseur) {
						list<escalier> Escalier <- list(escalier) where ((each.nom = "sortie_escalier_1"));
						if (Escalier != []) {
							sa_destination <- point_1_transit_etage_2.location;
						}

					}

					if (zone_affectation = "zone_6" and !peut_prendre_ascenseur) {
						list<escalier> Escalier <- list(escalier) where ((each.nom = "entree_escalier_2"));
						if (Escalier != []) {
							sa_destination <- Escalier[0].location;
						}

					}

					if (zone_affectation = "zone_4" and !peut_prendre_ascenseur) {
						list<porte> Portes_1 <- list(porte) where ((each.nom = "sortie_1"));
						list<porte> Portes_2 <- list(porte) where ((each.nom = "sortie_2"));
						sa_destination <- point_1_transit_etage_1.location;
						sa_destination <- rnd_choice([Portes_1[0].location::0.2, point_sortie_2.location::0.8]);
					}

					if (zone_affectation = "zone_5" and !peut_prendre_ascenseur) {
						list<porte> Portes_1 <- list(porte) where ((each.nom = "sortie_1"));
						list<porte> Portes_2 <- list(porte) where ((each.nom = "sortie_2"));
						sa_destination <- point_1_transit_etage_1.location;
						sa_destination <- rnd_choice([Portes_1[0].location::0.2, point_sortie_2.location::0.8]);
					}

				}

			}

			//Cinquieme
			if (mission = "mission_4") {
				if (self distance_to Personne.sa_destination <= 3) {
					mission <- "mission_5";
					if (zone_affectation = "zone_7" and !peut_prendre_ascenseur) {
						sa_destination <- point_1_transit_etage_2.location;
					}

					if (zone_affectation = "zone_6" and !Personne.peut_prendre_ascenseur) {
						sa_destination <- point_1_transit_etage_2.location;
					}

					if (zone_affectation = "zone_8" and !peut_prendre_ascenseur) {
						list<escalier> Escalier <- list(escalier) where ((each.nom = "sortie_escalier_1"));
						if (Escalier != []) {
							sa_destination <- point_sortie_2.location;
						}

					}

				}

			}
			//Sixieme
			if (mission = "mission_5") {
				if (self distance_to Personne.sa_destination <= 3) {
					mission <- "mission_5";
					if (zone_affectation = "zone_7" and !peut_prendre_ascenseur) {
						Personne.sa_destination <- point_sortie_2.location;
					}

					if (zone_affectation = "zone_6" and !peut_prendre_ascenseur) {
						sa_destination <- point_sortie_2.location;
					}

					if (zone_affectation = "zone_8" and !peut_prendre_ascenseur) {
						list<porte> Portes_1 <- list(porte) where ((each.nom = "sortie_1"));
						list<porte> Portes_2 <- list(porte) where ((each.nom = "sortie_2"));
						//sa_destination <- point_1_transit_etage_1.location;
						sa_destination <- rnd_choice([Portes_1[0].location::0.2, point_sortie_2.location::0.8]);
					}

				}

			}

			//Septieme
			if (mission = "mission_6") {
				if (self distance_to sa_destination <= 3) {
					mission <- "mission_7";
					if (zone_affectation = "zone_6" and !peut_prendre_ascenseur) {
						list<porte> Portes_1 <- list(porte) where ((each.nom = "sortie_1"));
						list<porte> Portes_2 <- list(porte) where ((each.nom = "sortie_2"));
						sa_destination <- point_1_transit_etage_1.location;
						sa_destination <- rnd_choice([Portes_1[0].location::0.2, point_sortie_2.location::0.8]);
					}

					if (Personne.zone_affectation = "zone_7" and !Personne.peut_prendre_ascenseur) {
						list<porte> Portes_1 <- list(porte) where ((each.nom = "sortie_1"));
						list<porte> Portes_2 <- list(porte) where ((each.nom = "sortie_2"));
						sa_destination <- rnd_choice([Portes_1[0].location::0.2, point_sortie_2.location::0.8]);
					}

				}

			}

		}

		if (categorie_connaissance_chemin_sortie = "il_ne_connait_pas" and categorie_prevacuation != "paniquer" and categorie_prevacuation != "evaluer" and categorie_prevacuation !=
		"se_conformer") {
			if (zone_affectation = "zone_6" or zone_affectation = "zone_7" or zone_affectation = "zone_8") {
			//Personne.ecartement <- false;
				do goto target: point_panneau_etage_3.location speed: 3.0 on: (cellule where not each.est_mur) recompute_path: false;
				//do goto target: point_panneau_etage_3.location speed: 3.0 ;
				if (self distance_to point_panneau_etage_3.location <= 7) {
					calcul_temps <- calcul_temps + 1;
					if (calcul_temps * 0.5 = temps_preevacuation) {
						categorie_connaissance_chemin_sortie <- "il_connait";
						if (zone_affectation = "zone_6") {
						//ecartement <- false;
						}

					}

				}

			}

			if (zone_affectation = "zone_4" or zone_affectation = "zone_5") {
			//ecartement <- false;
				do goto target: point_panneau_etage_2.location speed: 3.0 on: (cellule where not each.est_mur) recompute_path: false;
				//do goto target: point_panneau_etage_2.location speed: 3.0 ;
				//Personne.etat<-"panneau";
				if (self distance_to point_panneau_etage_2.location <= 4) {
					calcul_temps <- calcul_temps + 1;
					//Personne.ecartement <- false;
					if (calcul_temps * 0.5 = temps_preevacuation) {
						categorie_connaissance_chemin_sortie <- "il_connait";
					}

				}

			}

			if (zone_affectation = "zone_1" or zone_affectation = "zone_2" or zone_affectation = "zone_3") {
				do goto target: point_panneau_etage_1.location speed: 3.0 on: (cellule where not each.est_mur) recompute_path: false;
				if (self distance_to point_panneau_etage_1.location <= 7) {
					calcul_temps <- calcul_temps + 1;

					//Personne.ecartement <- false;
					if (calcul_temps * 0.5 = temps_preevacuation) {
						categorie_connaissance_chemin_sortie <- "il_connait";
					}

				}

			}

		}

		if (tmp = "connait_deja") {
			list<porte> Porte <- list(porte) where ((each.nom = "sortie_1"));
			sa_destination <- Porte[0].location;
			do goto target: sa_destination speed: vitesse on: (cellule where not each.est_mur) recompute_path: false;
		}

		if (categorie_prevacuation = "evaluer" and etat = "evacuation") {
			list<porte> Portes_1 <- list(porte) where ((each.nom = "sortie_1"));
			list<porte> Portes_2 <- list(porte) where ((each.nom = "sortie_2"));
			sa_destination <- rnd_choice([Portes_1[0].location::0.4, Portes_2[0].location::0.6]);
			do goto target: point_sortie_2.location speed: 3.0 on: (cellule where not each.est_mur) recompute_path: false;
		}

	}

	reflex changement_version_evacuation {
		if (!usage_ascenseur) {
			if (peut_prendre_ascenseur) {
				peut_prendre_ascenseur <- false;
			}

		}

	}

	reflex embarquement_ascenseur when: peut_prendre_ascenseur = true and etat = "evacuation" {
		if (zone_affectation = "zone_6" or zone_affectation = "zone_7" or zone_affectation = "zone_8") {
			list<zone_ascenseur> Portes <- list(zone_ascenseur) where ((each.nom = "porte_ascenseur_etage_3"));
			list<zone_ascenseur> Asc <- list(zone_ascenseur) where ((each.nom = "ascenseur_etage_3"));
			if (Portes != []) {
				if (self distance_to Portes[0].location <= 7) {
					peut_embarquer <- true;
					list<ascenseur> Ascenseur <- list(ascenseur) where ((each.est_occuper = false));
					if (Ascenseur != []) {
						Ascenseur[0].est_occuper <- true;
						Ascenseur[0].sa_destination <- Asc[0].location;
					}

				}

			}

			if (etat = "est_dans_ascenseur" and tmp != "sors_ascenseur") {
				list<ascenseur> asc <- list(ascenseur) where ((each distance_to self <= 30));
				if (asc = []) {
					list<ascenseur> Ascenseur <- list(ascenseur) where ((each.est_occuper = false));
					if (Ascenseur != []) {
						Ascenseur[0].est_occuper <- true;
						Ascenseur[0].sa_destination <- Asc[0].location;
					}

				}

			}

		}

		if (zone_affectation = "zone_4" or zone_affectation = "zone_5") {
			list<zone_ascenseur> Portes <- list(zone_ascenseur) where ((each.nom = "porte_ascenseur_etage_2"));
			list<zone_ascenseur> Asc <- list(zone_ascenseur) where ((each.nom = "ascenseur_etage_2"));
			if (Portes != []) {
				if (self distance_to Portes[0].location <= 7) {
					peut_embarquer <- true;
					list<ascenseur> Ascenseur <- list(ascenseur) where ((each.est_occuper = false));
					if (Ascenseur != []) {
						Ascenseur[0].est_occuper <- true;
						Ascenseur[0].sa_destination <- Asc[0].location;
					}

				}

			}

			if (etat = "est_dans_ascenseur" and tmp != "sors_ascenseur") {
				list<ascenseur> asc <- list(ascenseur) where ((each distance_to self <= 30));
				if (asc = []) {
					list<ascenseur> Ascenseur <- list(ascenseur) where ((each.est_occuper = false));
					if (Ascenseur != []) {
						Ascenseur[0].est_occuper <- true;
						Ascenseur[0].sa_destination <- Asc[0].location;
					}

				}

			}

		}

	}

	reflex observer_feu {
		list<feu> Feu <- list(feu) where ((each.etat = "actif") and each distance_to self <= 20);
		if (Feu != []) {
			energie <- energie - 1;
			if (!deja_feu) {
				nb_blesse <- nb_blesse + 1;
				deja_feu <- true;
			}

		}

		if (energie <= 0) {
			nb_mort <- nb_mort + 1;
			nb_blesse <- nb_blesse + 1;
			do die;
		}

	}
	//Réflexe pour calculer la vitesse de l'agent en tenant compte du facteur de cohésion
	reflex follow_goal {
		velocite <- velocite + ((sa_destination - location) / facteur_de_cohesion);
	}
	//Reflex pour appliquer la séparation lorsque les personnes sont trop proches les unes des autres
	reflex separation {
		point acc <- {0, 0};
		ask (personne at_distance taille) {
			acc <- acc - (location - myself.location);
		}

		velocite <- velocite + acc;
	}
	//Reflexion pour éviter les différents obstacles
	reflex avoid {
		point acc <- {0, 0};
		list<mur> nearby_obstacles <- (mur at_distance taille_personne);
		loop obs over: nearby_obstacles {
			acc <- acc - (obs.location - location);
		}

		velocite <- velocite + acc;
	}

	reflex do_die {
		list<porte> Portes <- list(porte) where ((each.nom = "sortie_1"));
		list<porte> Portes_2 <- list(porte) where ((each.nom = "sortie_2"));
		if (self distance_to Portes[0] <= 3 and sortie_1) {
			do die;
		}

		if (self distance_to Portes[0] <= 3 and !sortie_1) {
			sa_destination <- point_sortie_2.location;
			preevacuation <- true;
			etat <- "est_dans_ascenseur";
		}

		if (self distance_to Portes_2[0] <= 3 and sortie_2) {
			do die;
		}

		if (self distance_to Portes_2[0] <= 3 and !sortie_2) {
			sa_destination <- Portes[0].location;
			preevacuation <- true;
			etat <- "est_dans_ascenseur";
		}

	}
	//Reflex de deplacemnet de l'agents
	reflex move {
		if (peut_marcher) {
			point old_location <- copy(location);
			if (ecartement) {
				do goto target: sa_destination speed: vitesse;
			} else {
				do goto target: location + velocite;
				if not (self overlaps espace_libre) {
					location <- ((location closest_points_with espace_libre)[1]);
				}

				velocite <- location - old_location;
			}

		}

		if (etat = "est_dans_ascenseur") {
			do goto target: sa_destination speed: vitesse;
		}

	}

}

experiment Evacuation type: gui {
	category "CARACTERISTIQUES_DES_PERSONNES" expanded: afficher color: #grey;

	//text "Nombre de personnes :"+paniquer_ category: "Explanation" color: #orange font: font("Arial",16); 
	text "Couleur catégorie nier: " + nb_nier + " personnes" category: "CARACTERISTIQUES_DES_PERSONNES" color: #black background: #deepskyblue font: font("Courier New", 12);
	text "Couleur catégorie Se conformer: " + nb_se_conformer + " personnes" category: "CARACTERISTIQUES_DES_PERSONNES" color: #black background: #lime font: font("Courier New", 12);
	text "Couleur catégorie connaitre: " + nb_connaitre + " personnes" category: "CARACTERISTIQUES_DES_PERSONNES" color: #black background: #gamablue font: font("Courier New", 12);
	text "Couleur catégorie patienter: " + nb_patienter + " personnes" category: "CARACTERISTIQUES_DES_PERSONNES" color: #black background: #purple font: font("Courier New", 12);
	text "Couleur catégorie paniquer: " + nb_paniquer + " personnes" category: "CARACTERISTIQUES_DES_PERSONNES" color: #black background: #orange font: font("Courier New", 12);
	text "Couleur Couleur evaluer: " + nb_evaluer + " personnes" category: "CARACTERISTIQUES_DES_PERSONNES" color: #black background: #blue font: font("Courier New", 12);
	text "Couleur Couleur former: " + nb_former + " personnes" category: "CARACTERISTIQUES_DES_PERSONNES" color: #black background: #red font: font("Courier New", 12);
	//text "This bold light green text \rspans over \r3 lines." category: "Explanation" color: #lightgreen background: #black font: font("Helvetica",12,#bold); 
	//	parameter "Sortie 1 ouverte" category: "GESTION PORTE" var: sortie_1;
	//	parameter "Sortie 2 ouverte" category: "GESTION PORTE" var: sortie_2;
	//	parameter "Propagation feu" category: "LES VERSIONS DE SIMULATION" var: propagation_feu;
	//	parameter "Usage aseceur" category: "LES VERSIONS DE SIMULATION" var: usage_ascenseur;
	//	parameter "Mode simulation" category: "LES VERSIONS DE SIMULATION" var: modelisation <- "Prevacuation Evacuation" among: ["Prevacuation Evacuation", "Evacuation"];
	parameter "Exit 1 open" category: "DOOR MANAGEMENT" var: sortie_1;
	parameter "Exit 2 open" category: "DOOR MANAGEMENT" var: sortie_2;
	parameter "Fire propagation" category: "SIMULATION VERSIONS" var: propagation_feu;
	parameter "Use of elevator" category: "SIMULATION VERSIONS" var: usage_ascenseur;
	parameter "Simulation mode" category: "SIMULATION VERSIONS" var: modelisation <- "Prevacuation Evacuation" among: ["Prevacuation Evacuation", "Evacuation"];
	float minimum_cycle_duration <- 0.04;
	output {
		display map type: opengl {
			image "../includes/image/Plan3.png";
			species porte;
			species feu aspect: feu;
			species personne aspect: man;

			//species cell transparency: 0.7;
			//species escalier aspect: default_escalier;
			//species mur aspect: default_mur;
			//species zone aspect: default_zone;
			//species zone_neutre aspect: default_neutre;
			//species zone_ascenseur aspect: default_ascenseur;
			//species zone_neutre;
			species panneau;
			species ascenseur;
			species sonnerie aspect: default_texture_1 transparency: opacity_sonnerie;
			// species couche_feu ;
			graphics "sortie" refresh: false {
			//draw circle(10) at: point_sortie color: #red;

			//draw circle(10) at: point_1_transit_etage_3 color: #red;
			//draw circle(10) at: point_2_transit_etage_3 color: #red;
			/*draw circle(10) at: point_1_transit_etage_2 color: #red;
				draw circle(10) at: point_1_transit_etage_1 color: #red;
				draw circle(10) at: point_2_transit_etage_1 color: #red;
				draw circle(10) at: point_3_transit_etage_1 color: #red;
				/*draw circle(10) at: point_1_ascenseur_etage_2 color: #red;
				draw circle(10) at: point_panneau_etage_1 color: #blue;
				draw circle(10) at: point_panneau_etage_2 color: #blue;
				draw circle(10) at: point_panneau_etage_3 color: #blue;
				draw circle(10) at: point_sortie_2 color: #blue;*/
			}

		}

		display "Table de distribution" {
			chart "Diagramme de distribution" type: pie {
				if (modelisation != "Evacuation") {
					data "Paniquer" value: nb_paniquer color: #orange;
					data "Se conformer" value: nb_se_conformer color: #lime;
					data "Connaitre" value: nb_connaitre color: #gamablue;
					data "Patienter" value: nb_patienter color: #purple;
					data "Evaluer" value: nb_evaluer color: #blue;
					data "Former" value: nb_former color: #red;
					data "nier" value: nb_nier color: #deepskyblue;
				}

			}

		}

	}

}



