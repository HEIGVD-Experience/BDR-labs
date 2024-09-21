DROP TABLE IF EXISTS FaitMatch, FaitSport, FaitInterSport, Statut, JouePour, Club, Equipe, Personne, Match, Evenement, Sport;

CREATE TABLE Sport (
	nom varchar(20) PRIMARY KEY,
	logo varchar(100)
);

CREATE TABLE Club (
	id SERIAL PRIMARY KEY,
	nom varchar(50) NOT NULL,
	dateDeCreation DATE NOT NULL,
	blason varchar(100),
	nomSport varchar(20) NOT NULL,
	FOREIGN KEY (nomSport) REFERENCES Sport(nom) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE Equipe (
	id SERIAL PRIMARY KEY,
	nom varchar(50) NOT NULL,
	idClub integer NOT NULL,
	FOREIGN KEY (idClub) REFERENCES Club(id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE Personne (
	id SERIAL PRIMARY KEY,
	nom varchar(60) NOT NULL,
	prenom varchar(60) NOT NULL,
	dateDeNaissance DATE NOT NULL,
	email varchar(100) UNIQUE NOT NULL
);

CREATE TABLE JouePour (
	id SERIAL PRIMARY KEY,
	idEquipe integer NOT NULL,
	idPersonne integer,
	role varchar(3) NOT NULL,
	position varchar(3) NOT NULL,
	dateArrivee DATE NOT NULL,
	dateDepart DATE,
	FOREIGN KEY (idEquipe) REFERENCES Equipe(id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (idPersonne) REFERENCES Personne(id) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE Evenement (
	id SERIAL PRIMARY KEY,
	type varchar(3),
	heureDebut TIMESTAMP NOT NULL,
	heureFin TIMESTAMP NOT NULL,
	adresse varchar(150) NOT NULL,
	nomSport varchar(20) NOT NULL,
	FOREIGN KEY (nomSport) REFERENCES Sport(nom) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE Statut (
	id SERIAL PRIMARY KEY,
	idPersonne integer NOT NULL,
	idEvenement integer NOT NULL,
	type char NOT NULL,
	raison TEXT,
	FOREIGN KEY (idPersonne) REFERENCES Personne(id) ON UPDATE CASCADE ON DELETE SET NULL,
	FOREIGN KEY (idEvenement) REFERENCES Evenement(id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE Match (
	idEvenement integer PRIMARY KEY,
	numMatch integer NOT NULL UNIQUE,
	idEquipeDomicile integer,
	idEquipeAdversaire integer,
	nomSport varchar(20) NOT NULL,
	FOREIGN KEY (idEvenement) REFERENCES Evenement(id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (idEquipeDomicile) REFERENCES Equipe(id) ON UPDATE CASCADE ON DELETE SET NULL,
	FOREIGN KEY (idEquipeAdversaire) REFERENCES Equipe(id) ON UPDATE CASCADE ON DELETE SET NULL,
	FOREIGN KEY (nomSport) REFERENCES Sport(nom) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE FaitInterSport (
	id SERIAL PRIMARY KEY,
	nom varchar(50) NOT NULL UNIQUE
);

CREATE TABLE FaitSport (
	id SERIAL PRIMARY KEY,
	nom varchar(50) NOT NULL,
	idFaitInterSport integer,
	nomSport varchar(20) NOT NULL,
	FOREIGN KEY (idFaitInterSport) REFERENCES FaitInterSport(id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (nomSport) REFERENCES Sport(nom) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE FaitMatch (
	id SERIAL PRIMARY KEY,
	heure TIMESTAMP NOT NULL,
	idFaitSport integer NOT NULL,
	idPersonne integer,
	idMatch integer NOT NULL,
	FOREIGN KEY (idFaitSport) REFERENCES FaitSport(id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (idPersonne) REFERENCES Personne(id) ON UPDATE CASCADE ON DELETE SET NULL,
	FOREIGN KEY (idMatch) REFERENCES Match(idEvenement) ON UPDATE CASCADE ON DELETE CASCADE
);