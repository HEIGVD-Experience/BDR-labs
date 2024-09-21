
DROP TABLE IF EXISTS Réservation;
DROP TABLE IF EXISTS Chambre_equipement;
DROP TABLE IF EXISTS Membre;
DROP TABLE IF EXISTS Lit;
DROP TABLE IF EXISTS Equipement;
DROP TABLE IF EXISTS Chambre;
DROP TABLE IF EXISTS Hôtel;
DROP TABLE IF EXISTS Client;
DROP TABLE IF EXISTS Ville;


CREATE TABLE Ville (
	id SERIAL,
	nom VARCHAR(30) NOT NULL,
	CONSTRAINT PK_Ville PRIMARY KEY (id),
	CONSTRAINT UC_Ville_nom UNIQUE (nom)
);


CREATE TABLE Hôtel (
	id SERIAL,
	idVille INTEGER NOT NULL,
	nom VARCHAR(30) NOT NULL,
	nbEtoiles SMALLINT NOT NULL,
	rabaisMembre SMALLINT,
	CONSTRAINT PK_Hôtel PRIMARY KEY (id),
	CONSTRAINT UC_Hôtel_nom UNIQUE (nom),
	CONSTRAINT FK_Hôtel_idVille
		FOREIGN KEY (idVille)
		REFERENCES Ville (id)
		ON DELETE RESTRICT
		ON UPDATE CASCADE,
	CONSTRAINT CK_Hôtel_nbEtoiles CHECK (nbEtoiles >= 0),
	CONSTRAINT CK_Hôtel_rabaisMembre CHECK (rabaisMembre IS NULL OR (rabaisMembre > 0 AND rabaisMembre <= 100))
);


CREATE TABLE Chambre (
	idHôtel INTEGER,
	numéro SMALLINT,
	étage SMALLINT NOT NULL,
	prixParNuit SMALLINT NOT NULL,
	CONSTRAINT PK_Chambre PRIMARY KEY (idHôtel, numéro),
	CONSTRAINT FK_Chambre_idHôtel
		FOREIGN KEY (idHôtel)
		REFERENCES Hôtel (id)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	CONSTRAINT CK_Chambre_étage CHECK (étage >= 0),
	CONSTRAINT CK_Chambre_prixParNuit CHECK (prixParNuit >= 0)
);


CREATE TABLE Client (
	id SERIAL,
	idVille INTEGER NOT NULL,
	nom VARCHAR(50) NOT NULL,
	prénom VARCHAR(50) NOT NULL,
	CONSTRAINT PK_Client PRIMARY KEY (id),
	CONSTRAINT FK_Client_idVille
		FOREIGN KEY (idVille)
		REFERENCES Ville (id)
		ON DELETE RESTRICT
		ON UPDATE CASCADE
);


CREATE TABLE Réservation (
	idClient INTEGER,
	idChambre INTEGER,
	numéroChambre INTEGER,
	dateArrivée DATE,
	dateRéservation DATE NOT NULL,
	nbNuits SMALLINT NOT NULL,
	nbPersonnes SMALLINT NOT NULL,
	CONSTRAINT PK_Réservation PRIMARY KEY (idClient, idChambre, numéroChambre, dateArrivée),
	CONSTRAINT FK_Réservation_idClient
		FOREIGN KEY (idClient)
		REFERENCES Client (id)
		ON DELETE RESTRICT
		ON UPDATE CASCADE,
	CONSTRAINT FK_Réservation_idChambre_numéroChambre
		FOREIGN KEY (idChambre, numéroChambre)
		REFERENCES Chambre (idHôtel, numéro)
		ON DELETE RESTRICT
		ON UPDATE CASCADE,
	CONSTRAINT CK_Réservation_nbNuits CHECK (nbNuits > 0),
	CONSTRAINT CK_Réservation_nbPersonnes CHECK (nbPersonnes >= 0),
	CONSTRAINT CK_Réservation_dateArrivée_dateRéservation CHECK (dateArrivée >= dateRéservation)
);


CREATE TABLE Membre (
	idClient INTEGER,
	idHôtel INTEGER,
	depuis DATE NOT NULL,
	CONSTRAINT PK_Membre PRIMARY KEY (idClient, idHôtel),
	CONSTRAINT FK_Membre_idClient
		FOREIGN KEY (idClient)
		REFERENCES Client (id)
		ON DELETE RESTRICT
		ON UPDATE CASCADE,
	CONSTRAINT FK_Membre_idHôtel
		FOREIGN KEY (idHôtel)
		REFERENCES Hôtel (id)
		ON DELETE RESTRICT
		ON UPDATE CASCADE
);


CREATE TABLE Equipement (
	id SERIAL,
	nom VARCHAR(30) NOT NULL,
	CONSTRAINT PK_Equipement PRIMARY KEY (id),
	CONSTRAINT UC_Equipement_nom UNIQUE (nom)
);


CREATE TABLE Lit (
	idEquipement INTEGER,
	nbPlaces SMALLINT NOT NULL,
	CONSTRAINT PK_Lit PRIMARY KEY (idEquipement),
	CONSTRAINT FK_Lit_idEquipement
		FOREIGN KEY (idEquipement)
		REFERENCES Equipement (id)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	CONSTRAINT CK_Lit_nbPlaces CHECK (nbPlaces > 0)
);


CREATE TABLE Chambre_Equipement (
	idChambre INTEGER,
	numéroChambre INTEGER,
	idEquipement INTEGER,
	quantité SMALLINT NOT NULL,
	CONSTRAINT PK_Chambre_Equipement PRIMARY KEY (idEquipement, idChambre, numéroChambre),
	CONSTRAINT FK_Chambre_Equipement_idEquipement
		FOREIGN KEY (idEquipement)
		REFERENCES Equipement (id)
		ON DELETE RESTRICT
		ON UPDATE CASCADE,
	CONSTRAINT FK_Chambre_Equipement_idChambre_numéroChambre
		FOREIGN KEY (idChambre, numéroChambre)
		REFERENCES Chambre (idHôtel, numéro)
		ON DELETE RESTRICT
		ON UPDATE CASCADE,
	CONSTRAINT CK_Chambre_Equipement_quantité CHECK (quantité > 0)
);











INSERT INTO Ville (nom) VALUES ('Lausanne');
INSERT INTO Ville (nom) VALUES ('Bevaix');
INSERT INTO Ville (nom) VALUES ('Interlaken');
INSERT INTO Ville (nom) VALUES ('Montmollin');
INSERT INTO Ville (nom) VALUES ('Montreux');



INSERT INTO Hôtel (idVille, nom, nbEtoiles, rabaisMembre) VALUES (1, 'Hôtel Royal', 3, 5);
INSERT INTO Hôtel (idVille, nom, nbEtoiles, rabaisMembre) VALUES (1, 'Motel du centre urbain', 0, 15);
INSERT INTO Hôtel (idVille, nom, nbEtoiles, rabaisMembre) VALUES (3, 'JungFrau Petrus Palace', 5, 10);
INSERT INTO Hôtel (idVille, nom, nbEtoiles, rabaisMembre) VALUES (3, 'Kurz Alpinhotel', 2, NULL);
INSERT INTO Hôtel (idVille, nom, nbEtoiles, rabaisMembre) VALUES (5, 'Antique Boutique Hôtel', 0, 20);



INSERT INTO Chambre(idHôtel, numéro, étage, prixParNuit) VALUES (1, 1, 1, 100);
INSERT INTO Chambre(idHôtel, numéro, étage, prixParNuit) VALUES (1, 2, 1, 100);
INSERT INTO Chambre(idHôtel, numéro, étage, prixParNuit) VALUES (1, 3, 1, 120);
INSERT INTO Chambre(idHôtel, numéro, étage, prixParNuit) VALUES (1, 21, 2, 100);
INSERT INTO Chambre(idHôtel, numéro, étage, prixParNuit) VALUES (1, 22, 2, 100);
INSERT INTO Chambre(idHôtel, numéro, étage, prixParNuit) VALUES (1, 23, 2, 120);
INSERT INTO Chambre(idHôtel, numéro, étage, prixParNuit) VALUES (1, 31, 3, 100);
INSERT INTO Chambre(idHôtel, numéro, étage, prixParNuit) VALUES (1, 32, 3, 100);
INSERT INTO Chambre(idHôtel, numéro, étage, prixParNuit) VALUES (1, 33, 3, 140);
INSERT INTO Chambre(idHôtel, numéro, étage, prixParNuit) VALUES (1, 100, 4, 400);

INSERT INTO Chambre(idHôtel, numéro, étage, prixParNuit) VALUES (2, 1, 0, 90);
INSERT INTO Chambre(idHôtel, numéro, étage, prixParNuit) VALUES (2, 2, 0, 90);
INSERT INTO Chambre(idHôtel, numéro, étage, prixParNuit) VALUES (2, 3, 0, 90);
INSERT INTO Chambre(idHôtel, numéro, étage, prixParNuit) VALUES (2, 4, 0, 90);
INSERT INTO Chambre(idHôtel, numéro, étage, prixParNuit) VALUES (2, 5, 0, 90);
INSERT INTO Chambre(idHôtel, numéro, étage, prixParNuit) VALUES (2, 6, 0, 90);
INSERT INTO Chambre(idHôtel, numéro, étage, prixParNuit) VALUES (2, 7, 0, 90);
INSERT INTO Chambre(idHôtel, numéro, étage, prixParNuit) VALUES (2, 8, 0, 90);
INSERT INTO Chambre(idHôtel, numéro, étage, prixParNuit) VALUES (2, 9, 0, 90);
INSERT INTO Chambre(idHôtel, numéro, étage, prixParNuit) VALUES (2, 10, 0, 90);

INSERT INTO Chambre(idHôtel, numéro, étage, prixParNuit) VALUES (3, 10, 1, 200);
INSERT INTO Chambre(idHôtel, numéro, étage, prixParNuit) VALUES (3, 11, 1, 200);
INSERT INTO Chambre(idHôtel, numéro, étage, prixParNuit) VALUES (3, 12, 1, 200);
INSERT INTO Chambre(idHôtel, numéro, étage, prixParNuit) VALUES (3, 13, 1, 200);
INSERT INTO Chambre(idHôtel, numéro, étage, prixParNuit) VALUES (3, 14, 1, 200);
INSERT INTO Chambre(idHôtel, numéro, étage, prixParNuit) VALUES (3, 15, 1, 200);
INSERT INTO Chambre(idHôtel, numéro, étage, prixParNuit) VALUES (3, 20, 2, 220);
INSERT INTO Chambre(idHôtel, numéro, étage, prixParNuit) VALUES (3, 21, 2, 220);
INSERT INTO Chambre(idHôtel, numéro, étage, prixParNuit) VALUES (3, 22, 2, 220);
INSERT INTO Chambre(idHôtel, numéro, étage, prixParNuit) VALUES (3, 23, 2, 220);
INSERT INTO Chambre(idHôtel, numéro, étage, prixParNuit) VALUES (3, 24, 2, 220);
INSERT INTO Chambre(idHôtel, numéro, étage, prixParNuit) VALUES (3, 25, 2, 220);
INSERT INTO Chambre(idHôtel, numéro, étage, prixParNuit) VALUES (3, 30, 3, 240);
INSERT INTO Chambre(idHôtel, numéro, étage, prixParNuit) VALUES (3, 31, 3, 240);
INSERT INTO Chambre(idHôtel, numéro, étage, prixParNuit) VALUES (3, 32, 3, 240);
INSERT INTO Chambre(idHôtel, numéro, étage, prixParNuit) VALUES (3, 33, 3, 240);
INSERT INTO Chambre(idHôtel, numéro, étage, prixParNuit) VALUES (3, 34, 3, 240);
INSERT INTO Chambre(idHôtel, numéro, étage, prixParNuit) VALUES (3, 35, 3, 240);
INSERT INTO Chambre(idHôtel, numéro, étage, prixParNuit) VALUES (3, 40, 4, 300);
INSERT INTO Chambre(idHôtel, numéro, étage, prixParNuit) VALUES (3, 41, 4, 300);
INSERT INTO Chambre(idHôtel, numéro, étage, prixParNuit) VALUES (3, 42, 4, 300);
INSERT INTO Chambre(idHôtel, numéro, étage, prixParNuit) VALUES (3, 43, 4, 300);
INSERT INTO Chambre(idHôtel, numéro, étage, prixParNuit) VALUES (3, 44, 4, 300);
INSERT INTO Chambre(idHôtel, numéro, étage, prixParNuit) VALUES (3, 45, 4, 300);
INSERT INTO Chambre(idHôtel, numéro, étage, prixParNuit) VALUES (3, 50, 5, 500);
INSERT INTO Chambre(idHôtel, numéro, étage, prixParNuit) VALUES (3, 51, 5, 3000);
INSERT INTO Chambre(idHôtel, numéro, étage, prixParNuit) VALUES (3, 52, 5, 500);

INSERT INTO Chambre(idHôtel, numéro, étage, prixParNuit) VALUES (4, 1, 1, 400);
INSERT INTO Chambre(idHôtel, numéro, étage, prixParNuit) VALUES (4, 2, 1, 500);
INSERT INTO Chambre(idHôtel, numéro, étage, prixParNuit) VALUES (4, 3, 2, 400);
INSERT INTO Chambre(idHôtel, numéro, étage, prixParNuit) VALUES (4, 4, 2, 500);
INSERT INTO Chambre(idHôtel, numéro, étage, prixParNuit) VALUES (4, 5, 3, 400);
INSERT INTO Chambre(idHôtel, numéro, étage, prixParNuit) VALUES (4, 6, 3, 500);
INSERT INTO Chambre(idHôtel, numéro, étage, prixParNuit) VALUES (4, 7, 4, 400);
INSERT INTO Chambre(idHôtel, numéro, étage, prixParNuit) VALUES (4, 8, 4, 500);
INSERT INTO Chambre(idHôtel, numéro, étage, prixParNuit) VALUES (4, 9, 5, 400);
INSERT INTO Chambre(idHôtel, numéro, étage, prixParNuit) VALUES (4, 10, 5, 500);
INSERT INTO Chambre(idHôtel, numéro, étage, prixParNuit) VALUES (4, 11, 6, 400);
INSERT INTO Chambre(idHôtel, numéro, étage, prixParNuit) VALUES (4, 12, 6, 500);
INSERT INTO Chambre(idHôtel, numéro, étage, prixParNuit) VALUES (4, 13, 7, 400);
INSERT INTO Chambre(idHôtel, numéro, étage, prixParNuit) VALUES (4, 14, 7, 500);
INSERT INTO Chambre(idHôtel, numéro, étage, prixParNuit) VALUES (4, 15, 8, 400);
INSERT INTO Chambre(idHôtel, numéro, étage, prixParNuit) VALUES (4, 16, 8, 500);
INSERT INTO Chambre(idHôtel, numéro, étage, prixParNuit) VALUES (4, 17, 9, 400);
INSERT INTO Chambre(idHôtel, numéro, étage, prixParNuit) VALUES (4, 18, 9, 500);

INSERT INTO Chambre(idHôtel, numéro, étage, prixParNuit) VALUES (5, 1, 1, 300);
INSERT INTO Chambre(idHôtel, numéro, étage, prixParNuit) VALUES (5, 2, 2, 400);
INSERT INTO Chambre(idHôtel, numéro, étage, prixParNuit) VALUES (5, 3, 3, 600);


INSERT INTO Equipement(nom) VALUES ('TV');
INSERT INTO Equipement(nom) VALUES ('Baignoire');
INSERT INTO Equipement(nom) VALUES ('Coffre-fort');
INSERT INTO Equipement(nom) VALUES ('Mini bar');

INSERT INTO Equipement(nom) VALUES ('Lit Queen size');
INSERT INTO Lit(idEquipement, nbPlaces) VALUES (5, 2);
INSERT INTO Equipement(nom) VALUES ('Lit King size');
INSERT INTO Lit(idEquipement, nbPlaces) VALUES (6, 2);
INSERT INTO Equipement(nom) VALUES ('Lit simple');
INSERT INTO Lit(idEquipement, nbPlaces) VALUES (7, 1);




INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (1, 1, 7, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (1, 2, 7, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (1, 3, 7, 2);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (1, 21, 7, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (1, 22, 7, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (1, 23, 7, 2);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (1, 31, 7, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (1, 32, 7, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (1, 33, 7, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (1, 33, 5, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (1, 100, 5, 2);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (1, 100, 7, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (1, 100, 6, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (2, 1, 7, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (2, 2, 7, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (2, 3, 7, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (2, 4, 7, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (2, 5, 7, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (2, 6, 7, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (2, 7, 7, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (2, 8, 7, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 10, 5, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 11, 5, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 12, 5, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 13, 5, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 14, 5, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 15, 5, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 20, 5, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 21, 5, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 22, 5, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 23, 5, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 24, 5, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 25, 5, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 30, 5, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 31, 5, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 32, 5, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 33, 5, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 34, 5, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 35, 5, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 40, 6, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 41, 6, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 42, 6, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 43, 6, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 44, 6, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 45, 6, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 50, 6, 2);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 51, 6, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 52, 6, 2);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 1, 5, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 2, 6, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 3, 5, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 4, 6, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 5, 5, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 6, 6, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 7, 5, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 8, 6, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 9, 5, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 10, 6, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 11, 5, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 12, 6, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 13, 5, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 14, 6, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 15, 5, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 16, 6, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 17, 5, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 18, 6, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (5, 1, 6, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (5, 2, 6, 2);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (5, 3, 6, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (5, 3, 5, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (5, 3, 7, 1);

INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 10, 3, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 11, 3, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 12, 3, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 13, 3, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 14, 3, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 15, 3, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 20, 3, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 21, 3, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 22, 3, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 23, 3, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 24, 3, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 25, 3, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 30, 3, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 31, 3, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 32, 3, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 33, 3, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 34, 3, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 35, 3, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 40, 3, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 41, 3, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 42, 3, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 43, 3, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 44, 3, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 45, 3, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 50, 3, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 51, 3, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 52, 3, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 1, 3, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 2, 3, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 3, 3, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 4, 3, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 5, 3, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 6, 3, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 7, 3, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 8, 3, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 9, 3, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 10, 3, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 11, 3, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 12, 3, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 13, 3, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 14, 3, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 15, 3, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 16, 3, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 17, 3, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 18, 3, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (5, 1, 3, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (5, 2, 3, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (5, 3, 3, 1);

INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 12, 4, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 13, 4, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 14, 4, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 15, 4, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 16, 4, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 17, 4, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 18, 4, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (5, 1, 4, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (5, 2, 4, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (5, 3, 4, 1);

INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (1, 3, 2, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (1, 23, 2, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (1, 33, 2, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (1, 100, 2, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 10, 2, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 11, 2, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 12, 2, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 13, 2, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 14, 2, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 15, 2, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 20, 2, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 21, 2, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 22, 2, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 23, 2, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 24, 2, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 25, 2, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 30, 2, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 31, 2, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 32, 2, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 33, 2, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 34, 2, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 35, 2, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 40, 2, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 41, 2, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 42, 2, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 43, 2, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 44, 2, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 45, 2, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 50, 2, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 51, 2, 2);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 52, 2, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 1, 2, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 2, 2, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 3, 2, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 4, 2, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 5, 2, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 6, 2, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 7, 2, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 8, 2, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 9, 2, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 10, 2, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 11, 2, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 12, 2, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 13, 2, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 14, 2, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 15, 2, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 16, 2, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 17, 2, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 18, 2, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (5, 1, 2, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (5, 2, 2, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (5, 3, 2, 1);

INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (1, 21, 1, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (1, 22, 1, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (1, 23, 1, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (1, 31, 1, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (1, 32, 1, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (1, 33, 1, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (1, 100, 1, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 10, 1, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 11, 1, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 12, 1, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 13, 1, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 14, 1, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 15, 1, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 20, 1, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 21, 1, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 22, 1, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 23, 1, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 24, 1, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 25, 1, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 30, 1, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 31, 1, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 32, 1, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 33, 1, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 34, 1, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 35, 1, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 40, 1, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 41, 1, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 42, 1, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 43, 1, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 44, 1, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 45, 1, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 50, 1, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 51, 1, 4);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (3, 52, 1, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 1, 1, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 2, 1, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 3, 1, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 4, 1, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 5, 1, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 6, 1, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 7, 1, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 8, 1, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 9, 1, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 10, 1, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 11, 1, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 12, 1, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 13, 1, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 14, 1, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 15, 1, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 16, 1, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 17, 1, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (4, 18, 1, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (5, 1, 1, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (5, 2, 1, 1);
INSERT INTO Chambre_Equipement (idChambre, numéroChambre, idEquipement, quantité) VALUES (5, 3, 1, 2);


INSERT INTO Client (idVille, nom, prénom) VALUES (1, 'Hernandez', 'Luis');
INSERT INTO Client (idVille, nom, prénom) VALUES (1, 'Bérubé', 'Vincent');
INSERT INTO Client (idVille, nom, prénom) VALUES (1, 'Traore', 'Aicha');
INSERT INTO Client (idVille, nom, prénom) VALUES (1, 'Hunt', 'Finley');
INSERT INTO Client (idVille, nom, prénom) VALUES (1, 'Plaisance', 'Isabella');
INSERT INTO Client (idVille, nom, prénom) VALUES (1, 'Aguas', 'Shaunta');
INSERT INTO Client (idVille, nom, prénom) VALUES (2, 'Deeann', 'Hibbert');
INSERT INTO Client (idVille, nom, prénom) VALUES (3, 'Schmid', 'Hans');
INSERT INTO Client (idVille, nom, prénom) VALUES (3, 'Burgdorf', 'Providencia');
INSERT INTO Client (idVille, nom, prénom) VALUES (3, 'Weinberger', 'Ozie');



INSERT INTO Membre (idClient, idHôtel, depuis) VALUES (4, 4, '2022-05-18');
INSERT INTO Membre (idClient, idHôtel, depuis) VALUES (5, 1, '2020-01-05');
INSERT INTO Membre (idClient, idHôtel, depuis) VALUES (5, 3, '2021-11-01');
INSERT INTO Membre (idClient, idHôtel, depuis) VALUES (5, 4, '2022-11-30');
INSERT INTO Membre (idClient, idHôtel, depuis) VALUES (7, 3, '2021-08-22');
INSERT INTO Membre (idClient, idHôtel, depuis) VALUES (7, 4, '2022-12-24');
INSERT INTO Membre (idClient, idHôtel, depuis) VALUES (8, 5, '2023-12-24');
INSERT INTO Membre (idClient, idHôtel, depuis) VALUES (8, 3, '2022-08-19');
INSERT INTO Membre (idClient, idHôtel, depuis) VALUES (9, 1, '2023-01-01');



INSERT INTO Réservation (idClient, idChambre, numéroChambre, dateArrivée, dateRéservation, nbNuits, nbPersonnes) VALUES (1, 1, 33, '2022-02-23', '2022-02-22', 2, 1);
INSERT INTO Réservation (idClient, idChambre, numéroChambre, dateArrivée, dateRéservation, nbNuits, nbPersonnes) VALUES (1, 1, 33, '2023-10-12', '2023-10-01', 1, 2);
INSERT INTO Réservation (idClient, idChambre, numéroChambre, dateArrivée, dateRéservation, nbNuits, nbPersonnes) VALUES (1, 1, 3, '2022-03-02', '2022-02-02', 3, 1);
INSERT INTO Réservation (idClient, idChambre, numéroChambre, dateArrivée, dateRéservation, nbNuits, nbPersonnes) VALUES (2, 3, 51, '2022-12-28', '2022-03-02', 5, 2);
INSERT INTO Réservation (idClient, idChambre, numéroChambre, dateArrivée, dateRéservation, nbNuits, nbPersonnes) VALUES (3, 5, 1, '2024-01-02', '2022-12-12', 7, 2);
INSERT INTO Réservation (idClient, idChambre, numéroChambre, dateArrivée, dateRéservation, nbNuits, nbPersonnes) VALUES (4, 1, 23, '2023-10-06', '2023-10-06', 2, 2);
INSERT INTO Réservation (idClient, idChambre, numéroChambre, dateArrivée, dateRéservation, nbNuits, nbPersonnes) VALUES (5, 1, 3, '2012-05-18', '2012-05-16', 1, 1);
INSERT INTO Réservation (idClient, idChambre, numéroChambre, dateArrivée, dateRéservation, nbNuits, nbPersonnes) VALUES (5, 1, 1, '2020-01-07', '2020-01-04', 5, 1);
INSERT INTO Réservation (idClient, idChambre, numéroChambre, dateArrivée, dateRéservation, nbNuits, nbPersonnes) VALUES (5, 1, 33, '2020-01-07', '2020-01-07', 5, 2);
INSERT INTO Réservation (idClient, idChambre, numéroChambre, dateArrivée, dateRéservation, nbNuits, nbPersonnes) VALUES (8, 3, 35, '2021-12-22', '2021-12-12', 13, 2);
INSERT INTO Réservation (idClient, idChambre, numéroChambre, dateArrivée, dateRéservation, nbNuits, nbPersonnes) VALUES (2, 5, 1, '2023-12-24', '2023-04-11', 2, 1);
INSERT INTO Réservation (idClient, idChambre, numéroChambre, dateArrivée, dateRéservation, nbNuits, nbPersonnes) VALUES (5, 5, 2, '2023-12-23', '2023-06-07', 4, 1);
INSERT INTO Réservation (idClient, idChambre, numéroChambre, dateArrivée, dateRéservation, nbNuits, nbPersonnes) VALUES (8, 5, 3, '2023-12-24', '2023-10-22', 2, 2);
INSERT INTO Réservation (idClient, idChambre, numéroChambre, dateArrivée, dateRéservation, nbNuits, nbPersonnes) VALUES (5, 5, 2, '2024-12-23', '2024-10-10', 4, 1);
INSERT INTO Réservation (idClient, idChambre, numéroChambre, dateArrivée, dateRéservation, nbNuits, nbPersonnes) VALUES (8, 5, 3, '2024-12-24', '2024-01-30', 2, 2);
INSERT INTO Réservation (idClient, idChambre, numéroChambre, dateArrivée, dateRéservation, nbNuits, nbPersonnes) VALUES (2, 4, 1, '2023-12-24', '2023-04-11', 1, 1);
INSERT INTO Réservation (idClient, idChambre, numéroChambre, dateArrivée, dateRéservation, nbNuits, nbPersonnes) VALUES (2, 3, 14, '2023-12-24', '2023-02-10', 5, 1);
INSERT INTO Réservation (idClient, idChambre, numéroChambre, dateArrivée, dateRéservation, nbNuits, nbPersonnes) VALUES (5, 4, 2, '2023-12-21', '2022-11-21', 14, 1);
INSERT INTO Réservation (idClient, idChambre, numéroChambre, dateArrivée, dateRéservation, nbNuits, nbPersonnes) VALUES (5, 4, 2, '2021-12-21', '2021-12-21', 5, 1);
INSERT INTO Réservation (idClient, idChambre, numéroChambre, dateArrivée, dateRéservation, nbNuits, nbPersonnes) VALUES (5, 4, 3, '2024-01-11', '2023-11-21', 2, 1);