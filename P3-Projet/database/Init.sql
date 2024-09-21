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


-- Supprimer le déclencheur CI_memeSport s'il existe
DROP TRIGGER IF EXISTS CI_memeSport ON Match;

-- Supprimer le déclencheur CI_checkFaitsSport s'il existe
DROP TRIGGER IF EXISTS CI_checkFaitsSport ON FaitMatch;

-- Supprimer le déclencheur CI_checkUneEquipe s'il existe
DROP TRIGGER IF EXISTS CI_checkUneEquipe ON JouePour;

-- Supprimer le déclencheur CI_checkHeureFaitMatch s'il existe
DROP TRIGGER IF EXISTS CI_checkHeureFaitMatch ON FaitMatch;

-- Supprimer le déclencheur CI_checkDateEvenementClub s'il existe
DROP TRIGGER IF EXISTS CI_checkDateEvenementClub ON "match";

-- Supprimer le déclencheur CI_checkPresenceEquipe s'il existe
DROP TRIGGER IF EXISTS CI_checkPresenceEquipe ON Statut;

-- Supprimer le déclencheur CI_checkEquipeFaitMatch s'il existe
DROP TRIGGER IF EXISTS CI_checkEquipeFaitMatch ON FaitMatch;

-- Supprimer le déclencheur CI_checkPersonneEquipeEvenement s'il existe
DROP TRIGGER IF EXISTS CI_checkPersonneEquipeEvenement ON Statut;

-- Supprimer le déclencheur CI_checkDebutEvenement s'il existe
DROP TRIGGER IF EXISTS CI_checkDebutEvenement ON Evenement;

-- Supprimer le déclencheur CI_checkEquipesDistinctes s'il existe
DROP TRIGGER IF EXISTS CI_checkEquipesDistinctes ON "match";

-- Supprimer le déclencheur CI_checkDateJouePour s'il existe
DROP TRIGGER IF EXISTS CI_checkDateJouePour ON JouePour;

-- Supprimer le déclencheur CI_checkPresenceFaitMatch s'il existe
DROP TRIGGER IF EXISTS CI_checkPresenceFaitMatch ON FaitMatch;

-- Supprimer le déclencheur CI_checkEvenementStatut s'il existe
DROP TRIGGER IF EXISTS CI_checkEvenementStatut ON Statut;



-- Une équipe ne peut participer qu'aux matchs du même sport.
CREATE OR REPLACE FUNCTION memeSport() 
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE EXCEPTION 'idEquipeDomicile ne peut pas etre le meme que idEquipeAdversaire.';
END $$;

CREATE TRIGGER CI_memeSport 
BEFORE INSERT OR UPDATE ON Match
FOR EACH ROW WHEN (NEW.idEquipeDomicile = NEW.idEquipeAdversaire)
EXECUTE FUNCTION memeSport();


-- Tous les faits de match doivent être du même sport que le match auquel ils appartiennent.
CREATE OR REPLACE FUNCTION checkFaitsSport()
RETURNS TRIGGER AS $$
BEGIN    
  IF (
    SELECT COUNT(*)
    FROM FaitSport
    JOIN FaitMatch ON FaitSport.id = NEW.idFaitSport
    JOIN "match" ON NEW.idMatch = "match".idEvenement
    WHERE FaitSport.nomSport <> "match".nomSport
  ) >= 1 THEN
    RAISE EXCEPTION 'Les faits de match doivent appartenir au même sport que le match.';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER CI_checkFaitsSport
BEFORE INSERT OR UPDATE ON FaitMatch
FOR EACH row EXECUTE FUNCTION checkFaitsSport();


-- Un joueur ne peut être que dans une seule équipe de sport en même temps.
CREATE OR REPLACE FUNCTION checkUneEquipe()
RETURNS TRIGGER AS $$
BEGIN    
  IF EXISTS (
    SELECT *
    FROM JouePour
    WHERE JouePour.idpersonne = NEW.idpersonne 
      AND JouePour.idequipe IS NOT NULL 
      AND (JouePour.datedepart IS NULL AND NEW.datedepart IS NULL
      OR ((JouePour.datearrivee <= NEW.datedepart AND (JouePour.datedepart IS NULL OR JouePour.datedepart >= NEW.datearrivee)) OR
      (NEW.datearrivee <= JouePour.datedepart AND (NEW.datedepart IS NULL OR NEW.datedepart >= JouePour.datearrivee))))
  ) THEN
    RAISE EXCEPTION 'Un joueur peut jouer pour maximum 1 équipe en même temps.';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER CI_checkUneEquipe
BEFORE INSERT ON JouePour
FOR EACH row EXECUTE FUNCTION checkUneEquipe();


-- L'heure d'un `FaitMatch` doit être entre le début et la fin du matche.

CREATE OR REPLACE FUNCTION checkHeureFaitMatch()
RETURNS TRIGGER AS $$
BEGIN
  IF (
    NEW.heure NOT BETWEEN
    (SELECT Evenement.heureDebut FROM Evenement WHERE Evenement.id = NEW.idMatch)
    AND
    (SELECT Evenement.heureFin FROM Evenement WHERE Evenement.id = NEW.idMatch)
  ) THEN
    RAISE EXCEPTION 'Un fait de match doit arriver durant le match.';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER CI_checkHeureFaitMatch
BEFORE INSERT OR UPDATE ON FaitMatch
FOR EACH row EXECUTE FUNCTION checkHeureFaitMatch();


-- La date de l'événement (dans les attributs heureDebut et heureFin) dois être égal ou antérieur à la date de création des deux clubs des deux équipes s'affrontant.

CREATE OR REPLACE FUNCTION checkDateEvenementClub()
RETURNS TRIGGER AS $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM Evenement
    JOIN Equipe E1 ON NEW.idEquipeAdversaire = E1.id
    JOIN Equipe E2 ON NEW.idEquipeDomicile = E2.id
    JOIN Club C1 ON E1.idClub = C1.id
    JOIN Club C2 ON E2.idClub = C2.id
    WHERE Evenement.id = NEW.idEvenement
      AND (Evenement.heuredebut < C1.dateDeCreation OR Evenement.heuredebut < C2.dateDeCreation)
  ) THEN
    RAISE EXCEPTION 'Les equipes doivent exister pour participer au match';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER CI_checkDateEvenementClub
BEFORE INSERT OR UPDATE ON "match"
FOR EACH row EXECUTE FUNCTION checkDateEvenementClub();


-- Chaque personne ne peut être présente au même moment que pour une équipe.

CREATE OR REPLACE FUNCTION checkPresenceEquipe()
RETURNS TRIGGER AS $$
BEGIN
  IF EXISTS (
    SELECT * FROM Statut
    JOIN Evenement E1 ON Statut.idEvenement = E1.id
    JOIN Evenement E2 ON NEW.idEvenement = E2.id
    WHERE (NEW.idPersonne = Statut.idPersonne) AND (NEW.type = 'P') AND (Statut.type = 'P') AND 
     ((E1.heureDebut BETWEEN E2.heureDebut AND E2.heureFin) OR (E2.heureDebut BETWEEN E1.heureDebut AND E1.heureFin))
  ) THEN
    RAISE EXCEPTION 'Une personne ne peut pas jouer pour deux équipes en même temps.';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER CI_checkPresenceEquipe
BEFORE INSERT OR UPDATE ON Statut
FOR EACH row EXECUTE FUNCTION checkPresenceEquipe();


-- Une équipe peut avoir des faits de matchs uniquement pour les matchs auxquels elle participe.

CREATE OR REPLACE FUNCTION checkEquipeFaitMatch()
RETURNS TRIGGER AS $$
BEGIN
  IF EXISTS (
  
    SELECT 1
    FROM "match"
    JOIN Evenement ON "match".idEvenement = Evenement.id
    JOIN Personne ON NEW.idPersonne = Personne.id
    JOIN JouePour ON Personne.id = JouePour.idPersonne
    WHERE "match".idEvenement = NEW.idMatch AND Personne.id IS NOT NULL AND 
      (JouePour.idEquipe <> "match".idEquipeDomicile AND JouePour.idEquipe <> "match".idEquipeAdversaire)
  ) THEN
    RAISE EXCEPTION 'Un fait de match ne peut pas être pour une équipe qui ne joue pas.';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER CI_checkEquipeFaitMatch
BEFORE INSERT OR UPDATE ON FaitMatch
FOR EACH row EXECUTE FUNCTION checkEquipeFaitMatch();


-- L'heure de fin d'un événement ne peut être que supérieur à l'heure de début de celui-ci.

CREATE OR REPLACE FUNCTION checkDebutEvenement()
RETURNS TRIGGER AS $$
BEGIN
  IF (
  
    NEW.heureFin < NEW.heureDebut
  
  ) THEN
    RAISE EXCEPTION 'Un évènement ne peut pas commencer après la fin.';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER CI_checkDebutEvenement
BEFORE INSERT OR UPDATE ON Evenement
FOR EACH row EXECUTE FUNCTION checkDebutEvenement();


-- Un match doit avoir deux équipes distinctes.

CREATE OR REPLACE FUNCTION checkEquipesDistinctes()
RETURNS TRIGGER AS $$
BEGIN
  IF (
  
    NEW.idEquipeDomicile = NEW.idEquipeAdversaire
  
  ) THEN
    RAISE EXCEPTION 'La même équipe ne peut pas jouer deux fois.';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER CI_checkEquipesDistinctes
BEFORE INSERT OR UPDATE ON "match"
FOR EACH row EXECUTE FUNCTION checkEquipesDistinctes();


-- La date d'arrivée dans `JouePour` ne doit pas être après la date de départ ni avant la date de création du club ni avant la date de naissance du joueur en question.

CREATE OR REPLACE FUNCTION checkDateJouePour()
RETURNS TRIGGER AS $$
BEGIN
  IF (
    
    NEW.dateArrivee > NEW.dateDepart OR
    NEW.dateArrivee < (
      SELECT Club.dateDeCreation
      FROM Club
      JOIN Equipe ON Club.id = Equipe.idClub
      WHERE NEW.idEquipe = Equipe.id
    ) OR
    NEW.dateArrivee < (
      SELECT Personne.dateDeNaissance
      FROM Personne
      WHERE NEW.idPersonne = Personne.id
    )
  
  ) THEN
    RAISE EXCEPTION 'Un joueur doit être arrivé avant de partir, le club doit déjà exister et il doit être né.';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER CI_checkDateJouePour
BEFORE INSERT OR UPDATE ON JouePour
FOR EACH row EXECUTE FUNCTION checkDateJouePour();


-- Un FaitMatch peut être fait uniquement par une personne présente au match en question

CREATE OR REPLACE FUNCTION checkPresenceFaitMatch()
RETURNS TRIGGER AS $$
BEGIN
  IF (
    
    (
    SELECT Statut."type" FROM Statut
    JOIN "match" ON Statut.idEvenement = "match".idEvenement AND NEW.idMatch = "match".idEvenement
    WHERE
    NEW.idPersonne = Statut.idPersonne
    ) <> 'P'
  
  ) THEN
    RAISE EXCEPTION 'Un joueur doit être présent pour efffectuer un fait de match.';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER CI_checkPresenceFaitMatch
BEFORE INSERT OR UPDATE ON FaitMatch
FOR EACH row EXECUTE FUNCTION checkPresenceFaitMatch();


-- Le statut de présence à un événement qui est déjà passé n'est plus modifiable

CREATE OR REPLACE FUNCTION checkEvenementStatut()
RETURNS TRIGGER AS $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM Evenement 
    WHERE NEW.idEvenement = Evenement.id
  ) THEN
    RAISE EXCEPTION 'Le statut d''un évènement en cours ou déjà passé n''est pas modifiable.';
  END IF;
  
  IF (
    (
      SELECT Evenement.heureDebut FROM Evenement 
      WHERE NEW.idEvenement = Evenement.id
    ) < now()
  ) THEN
    RAISE EXCEPTION 'Le statut d''un évènement en cours ou déjà passé n''est pas modifiable.';
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER CI_checkEvenementStatut
BEFORE UPDATE ON Statut
FOR EACH row EXECUTE FUNCTION checkEvenementStatut();


INSERT INTO Sport (nom,logo) VALUES ('Volley','img/sport/volley.jpg');
INSERT INTO Sport (nom,logo) VALUES ('Football','img/sport/football.jpg');

INSERT INTO Club (nom,dateDeCreation,blason,nomSport) VALUES ('FC Villars-Thiercelin','2002-02-23', 'img/club/fcvt.jpg', 'Football');
INSERT INTO Club (nom,dateDeCreation,blason,nomSport) VALUES ('FC le Talent','2000-04-14', 'img/club/talent.jpg', 'Football');
INSERT INTO Club (nom,dateDeCreation,blason,nomSport) VALUES ('FC Yverdon','1987-08-24', 'img/club/yverdon.jpg', 'Football');
INSERT INTO Club (nom,dateDeCreation,blason,nomSport) VALUES ('FC Poliez', '2020-01-01', 'img/club/default_team.png', 'Football');
INSERT INTO Club (nom,dateDeCreation,blason,nomSport) VALUES ('FC HEIG', '2019-05-15', 'img/club/default_team.png', 'Football');
INSERT INTO Club (nom,dateDeCreation,blason,nomSport) VALUES ('FC UNIL', '2021-02-10', 'img/club/default_team.png', 'Football');
INSERT INTO Club (nom,dateDeCreation,blason,nomSport) VALUES ('FC EPFL', '2018-06-25', 'img/club/default_team.png', 'Football');
INSERT INTO Club (nom,dateDeCreation,blason,nomSport) VALUES ('FC HES-SO', '2019-11-05', 'img/club/default_team.png', 'Football');
INSERT INTO Club (nom,dateDeCreation,blason,nomSport) VALUES ('VBC Bottens', '2020-04-15', 'img/club/default_team.png', 'Volley');
INSERT INTO Club (nom,dateDeCreation,blason,nomSport) VALUES ('VBC Echallens', '2017-08-20', 'img/club/default_team.png', 'Volley');
INSERT INTO Club (nom,dateDeCreation,blason,nomSport) VALUES ('VBC Lausanne', '2022-03-01', 'img/club/default_team.png', 'Volley');
INSERT INTO Club (nom,dateDeCreation,blason,nomSport) VALUES ('VBC Geneve', '2016-09-10', 'img/club/default_team.png', 'Volley');
INSERT INTO Club (nom,dateDeCreation,blason,nomSport) VALUES ('VBC Cheseaux', '2022-01-05', 'img/club/default_team.png', 'Volley');
INSERT INTO Club (nom,dateDeCreation,blason,nomSport) VALUES ('FC Bayern München','1900-02-27', 'img/club/bayern.png', 'Football');

INSERT INTO Equipe (nom,idClub) VALUES ('VT1',1);
INSERT INTO Equipe (nom,idClub) VALUES ('VT2',1);
INSERT INTO Equipe (nom,idClub) VALUES ('VT3',1);
INSERT INTO Equipe (nom,idClub) VALUES ('Talent1',2);
INSERT INTO Equipe (nom,idClub) VALUES ('Talent2',2);
INSERT INTO Equipe (nom,idClub) VALUES ('Yverdon1',3);
INSERT INTO Equipe (nom,idClub) VALUES ('Yverdon2',3);
INSERT INTO Equipe (nom,idClub) VALUES ('Yverdon3',3);
INSERT INTO Equipe (nom,idClub) VALUES ('Poliez1', 4);
INSERT INTO Equipe (nom,idClub) VALUES ('Poliez2', 4);
INSERT INTO Equipe (nom,idClub) VALUES ('HEIG1', 5);
INSERT INTO Equipe (nom,idClub) VALUES ('HEIG2', 5);
INSERT INTO Equipe (nom,idClub) VALUES ('UNIL1', 6);
INSERT INTO Equipe (nom,idClub) VALUES ('UNIL2', 6);
INSERT INTO Equipe (nom,idClub) VALUES ('EPFL1', 7);
INSERT INTO Equipe (nom,idClub) VALUES ('EPFL2', 7);
INSERT INTO Equipe (nom,idClub) VALUES ('HES-SO1', 8);
INSERT INTO Equipe (nom,idClub) VALUES ('HES-SO2', 8);
INSERT INTO Equipe (nom,idClub) VALUES ('Bottens1', 9);
INSERT INTO Equipe (nom,idClub) VALUES ('Bottens2', 9);
INSERT INTO Equipe (nom,idClub) VALUES ('Echallens1', 10);
INSERT INTO Equipe (nom,idClub) VALUES ('Echallens2', 10);
INSERT INTO Equipe (nom,idClub) VALUES ('Lausanne1', 11);
INSERT INTO Equipe (nom,idClub) VALUES ('Lausanne2', 11);
INSERT INTO Equipe (nom,idClub) VALUES ('Geneve1', 12);
INSERT INTO Equipe (nom,idClub) VALUES ('Geneve2', 12);
INSERT INTO Equipe (nom,idClub) VALUES ('Cheseaux1', 13);
INSERT INTO Equipe (nom,idClub) VALUES ('Cheseaux2', 13);
INSERT INTO Equipe (nom,idClub) VALUES ('FCB', 14);
INSERT INTO Equipe (nom,idClub) VALUES ('FCB Amateure', 14);

INSERT INTO Personne (nom,prenom,dateDeNaissance,email) VALUES 
('Trueb','Guillaume','1999-02-17','guillaume.trueb@example.com'),
('Philibert','Alexandre','2000-03-08','alexandre.philibert@example.com'),
('Ricard','Valentin','2002-08-27','valentin.ricard@example.com'),
('Piemontesi','Gwendal','2002-07-16','gwendal.piemonte@example.com'),
('Quinn','Calum','2000-03-26','calum.quinn@example.com'),
('Graf','Marcel','1966-04-22','marcel.graf@example.com'),
('Jaquet','Loic','1987-05-17','loic.jaquet@example.com'),
('Acacio','Rafael','1976-02-02','rafael.acacio@example.com'),
('Sanchez','Diego','1999-12-10','diego.sanchez@example.com'),
('Portelli','Jeremy','1996-01-18','jeremy.portelli@example.com'),
('Haas','Benjamin','1962-11-26','benjamin.haas@example.com'),
('Vuilleumier','Thomas','2002-09-06','thomas.vuilleumier@example.com'),
('Ramos','Dylan','2001-03-07','dylan.ramos@example.com'),
('Curchod','Michael','1996-02-22','michael.curchod@example.com'),
('Stadler','Jonathan','2000-02-11','jonathan.stadler@example.com'),
('Langel','Arnaud','2001-03-16','arnaud.langel@example.com'),
('Doe', 'John', '1990-03-15', 'john.doe@example.com'),
('Smith', 'Jane', '1985-07-22', 'jane.smith@example.com'),
('Johnson', 'David', '1992-05-10', 'david.johnson@example.com'),
('Williams', 'Emily', '1988-12-05', 'emily.williams@example.com'),
('Harris', 'Michael', '1995-09-20', 'michael.harris@example.com'),
('Brown', 'Amanda', '1991-04-08', 'amanda.brown@example.com'),
('Miller', 'Robert', '1987-10-15', 'robert.miller@example.com'),
('Garcia', 'Olivia', '1993-02-01', 'olivia.garcia@example.com'),
('Martinez', 'Daniel', '1989-06-18', 'daniel.martinez@example.com'),
('Robinson', 'Sophia', '1994-11-30', 'sophia.robinson@example.com'),
('Taylor', 'Mark', '1996-08-25', 'mark.taylor@example.com'),
('Anderson', 'Linda', '1986-03-12', 'linda.anderson@example.com'),
('White', 'Christopher', '1997-07-05', 'christopher.white@example.com'),
('Martinez', 'Karen', '1990-01-28', 'karen.martinez@example.com'),
('Harris', 'Brian', '1988-09-15', 'brian.harris@example.com'),
('Thomas', 'Jessica', '1983-12-22', 'jessica.thomas@example.com'),
('Jackson', 'Andrew', '1992-04-10', 'andrew.jackson@example.com'),
('Walker', 'Maria', '1986-11-01', 'maria.walker@example.com'),
('Hall', 'Kevin', '1989-06-08', 'kevin.hall@example.com'),
('Lewis', 'Melissa', '1995-01-15', 'melissa.lewis@example.com'),
('Smith', 'Daniel', '1994-08-18', 'daniel.smith@example.com'),
('Johnson', 'Emma', '1989-02-27', 'emma.johnson@example.com'),
('Williams', 'Ryan', '1996-06-10', 'ryan.williams@example.com'),
('Brown', 'Sophie', '1990-11-15', 'sophie.brown@example.com'),
('Davis', 'Nicholas', '1993-04-08', 'nicholas.davis@example.com'),
('Miller', 'Hannah', '1987-09-25', 'hannah.miller@example.com'),
('Garcia', 'Brandon', '1995-01-30', 'brandon.garcia@example.com'),
('Martinez', 'Isabella', '1991-06-18', 'isabella.martinez@example.com'),
('Jones', 'Caleb', '1988-12-01', 'caleb.jones@example.com'),
('Taylor', 'Chloe', '1992-05-20', 'chloe.taylor@example.com'),
('Anderson', 'Ethan', '1986-10-12', 'ethan.anderson@example.com'),
('White', 'Zoe', '1997-03-05', 'zoe.white@example.com'),
('Moore', 'Liam', '1990-07-15', 'liam.moore@example.com'),
('Jackson', 'Mia', '1985-12-22', 'mia.jackson@example.com'),
('Martin', 'Logan', '1993-02-01', 'logan.martin@example.com'),
('Hall', 'Ella', '1989-07-08', 'ella.hall@example.com'),
('Thompson', 'Jackson', '1994-12-01', 'jackson.thompson@example.com'),
('Lee', 'Ava', '1986-06-15', 'ava.lee@example.com'),
('Lewis', 'Connor', '1995-11-30', 'connor.lewis@example.com'),
('Young', 'Sophia', '1993-09-18', 'sophia.young@example.com'),
('Hall', 'Elijah', '1987-02-27', 'elijah.hall@example.com'),
('Carter', 'Grace', '1996-06-10', 'grace.carter@example.com'),
('Fisher', 'Jackson', '1991-11-15', 'jackson.fisher@example.com'),
('King', 'Avery', '1994-04-08', 'avery.king@example.com'),
('Morgan', 'Ella', '1988-09-25', 'ella.morgan@example.com'),
('Foster', 'Liam', '1995-01-30', 'liam.foster@example.com'),
('Bennett', 'Aria', '1990-06-18', 'aria.bennett@example.com'),
('Graham', 'Isaac', '1988-12-01', 'isaac.graham@example.com'),
('Murray', 'Lily', '1992-05-20', 'lily.murray@example.com'),
('Harrison', 'Gabriel', '1986-10-12', 'gabriel.harrison@example.com'),
('Ward', 'Zoe', '1997-03-05', 'zoe.ward@example.com'),
('Perry', 'Levi', '1990-07-15', 'levi.perry@example.com'),
('Barnes', 'Luna', '1985-12-22', 'luna.barnes@example.com'),
('Stewart', 'Evan', '1993-02-01', 'evan.stewart@example.com'),
('Watson', 'Aurora', '1989-07-08', 'aurora.watson@example.com'),
('Burke', 'Colton', '1994-12-01', 'colton.burke@example.com'),
('George', 'Hazel', '1986-06-15', 'hazel.george@example.com'),
('Arnold', 'Parker', '1995-11-30', 'parker.arnold@example.com'),
('Hudson', 'Bella', '1987-05-25', 'bella.hudson@example.com'),
('West', 'Lucas', '1991-10-05', 'lucas.west@example.com'),
('Porter', 'Nova', '1998-03-18', 'nova.porter@example.com'),
('Webb', 'Micah', '1996-08-10', 'micah.webb@example.com'),
('Sullivan', 'Mila', '1989-01-12', 'mila.sullivan@example.com'),
('Wagner', 'Kai', '1994-06-28', 'kai.wagner@example.com'),
('Norris', 'Ivy', '1985-11-20', 'ivy.norris@example.com'),
('Hoffman', 'Max', '1993-04-02', 'max.hoffman@example.com'),
('Coleman', 'Nora', '1990-09-15', 'nora.coleman@example.com'),
('Simmons', 'Grayson', '1997-02-28', 'grayson.simmons@example.com'),
('Perez', 'Mila', '1988-06-22', 'mila.perez@example.com'),
('Floyd', 'Wyatt', '1995-11-10', 'wyatt.floyd@example.com'),
('Holmes', 'Alice', '1992-04-25', 'alice.holmes@example.com'),
('Morrison', 'Xander', '1986-09-08', 'xander.morrison@example.com'),
('Gibson', 'Aria', '1993-12-15', 'aria.gibson@example.com'),
('Bishop', 'Liam', '1987-05-01', 'liam.bishop@example.com'),
('Bryant', 'Sadie', '1994-10-18', 'sadie.bryant@example.com'),
('Hawkins', 'Finn', '1989-03-02', 'finn.hawkins@example.com'),
('Bradley', 'Eva', '1996-08-17', 'eva.bradley@example.com'),
('Barnett', 'Ryder', '1990-01-30', 'ryder.barnett@example.com'),
('Barrett', 'Stella', '1997-06-12', 'stella.barrett@example.com'),
('Greene', 'Owen', '1985-11-25', 'owen.greene@example.com'),
('Harper', 'Nina', '1992-04-10', 'nina.harper@example.com'),
('Henderson', 'Leo', '1987-09-23', 'leo.henderson@example.com'),
('Adams', 'Isla', '1995-02-08', 'isla.adams@example.com'),
('Sims', 'Jaxon', '1990-07-22', 'jaxon.sims@example.com'),
('Brewer', 'Ivy', '1988-01-15', 'ivy.brewer@example.com'),
('Mathews', 'Eli', '1993-06-30', 'eli.mathews@example.com'),
('Hubbard', 'Sophie', '1987-11-12', 'sophie.hubbard@example.com'),
('Briggs', 'Asher', '1996-04-25', 'asher.briggs@example.com'),
('Pratt', 'Bella', '1989-09-08', 'bella.pratt@example.com'),
('Dixon', 'Caleb', '1994-02-20', 'caleb.dixon@example.com'),
('Pierce', 'Lucy', '1991-07-05', 'lucy.pierce@example.com'),
('Schneider', 'Aiden', '1986-12-20', 'aiden.schneider@example.com'),
('Wells', 'Lila', '1993-05-03', 'lila.wells@example.com'),
('Logan', 'Finn', '1988-10-18', 'finn.logan@example.com'),
('Wade', 'Clara', '1995-03-02', 'clara.wade@example.com'),
('Peters', 'Ezra', '1990-08-17', 'ezra.peters@example.com'),
('Black', 'Hazel', '1984-12-30', 'hazel.black@example.com'),
('Dean', 'Milo', '1992-06-12', 'milo.dean@example.com'),
('Clarke', 'Mia', '1987-11-25', 'mia.clarke@example.com'),
('Steele', 'Jasper', '1996-04-10', 'jasper.steele@example.com'),
('Summers', 'Isabella', '1989-09-23', 'isabella.summers@example.com'),
('Kane', 'Harry', '1993-07-28', 'harry.kane@example.com'),
('Neuer', 'Manuel', '1986-03-27', 'manuel.neuer@example.com'),
('Müller', 'Thomas', '1989-09-13', 'thomas.muller@example.com'),
('Kimmich', 'Joshua', '1995-02-08', 'joshua.kimmich@example.com'),
('Sané', 'Leroy', '1996-01-11', 'leroy.sane@example.com'),
('Gnabry', 'Serge', '1995-07-14', 'serge.gnabry@example.com'),
('Alaba', 'David', '1992-06-24', 'david.alaba@example.com'),
('Coman', 'Kingsley', '1996-06-13', 'kingsley.coman@example.com'),
('Hernández', 'Lucas', '1996-02-14', 'lucas.hernandez@example.com'),
('Pavard', 'Benjamin', '1996-03-28', 'benjamin.pavard@example.com'),
('Davies', 'Alphonso', '2000-11-02', 'alphonso.davies@example.com'),
('Goretzka', 'Leon', '1995-02-06', 'leon.goretzka@example.com'),
('Boateng', 'Jérôme', '1988-09-03', 'jerome.boateng@example.com'),
('Süle', 'Niklas', '1995-09-03', 'niklas.sule@example.com'),
('Martínez', 'Javi', '1988-09-02', 'javi.martinez@example.com'),
('Tolisso', 'Corentin', '1994-08-03', 'corentin.tolisso@example.com'),
('Musiala', 'Jamal', '2003-02-26', 'jamal.musiala@example.com'),
('Upamecano', 'Dayot', '1998-10-27', 'dayot.upamecano@example.com'),
('Nübel', 'Alexander', '1996-09-30', 'alexander.nubel@example.com'),
('Tuchel', 'Thomas', '1973-08-29', 'tuto@bayern.de');

INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (1, 1, 'ENT', 'CDB', '2019-02-13', null); 
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (1, 2, 'JOU', 'DGA', '2019-02-13', null); 
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (1, 3, 'JOU', 'ADR', '2019-02-13', null); 
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (1, 4, 'JOU', 'GUA', '2019-02-13', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (2, 5, 'ENT', 'DGA', '2019-02-13', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (2, 6, 'JOU', 'ENT', '2019-02-13', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (2, 7, 'JOU', 'ADR', '2019-02-13', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (2, 8, 'JOU', 'GUA', '2019-02-13', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (3, 9, 'ENT', 'CDR', '2019-02-13', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (3, 10, 'JOU', 'ENT', '2019-02-13', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (3, 11, 'JOU', 'DGA', '2019-02-13', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (3, 12, 'JOU', 'GUA', '2019-02-13', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (4, 13, 'ENT', 'ADR', '2019-02-13', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (4, 14, 'JOU', 'CGA', '2019-02-13', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (4, 15, 'JOU', 'ADR', '2019-02-13', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (4, 16, 'JOU', 'CDB', '2019-02-13', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (5, 17, 'ENT', 'CDB', '2015-04-12', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (5, 18, 'JOU', 'DGA', '2013-10-08', '2017-12-15');
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (5, 19, 'JOU', 'ADR', '2014-06-20', '2020-02-10');
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (5, 20, 'JOU', 'GUA', '2012-12-01', '2019-05-18');
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (6, 21, 'ENT', 'ADR', '2013-09-14', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (6, 22, 'JOU', 'CDB', '2014-08-02', '2021-04-05');
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (6, 23, 'JOU', 'DGA', '2016-05-17', '2019-08-22');
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (6, 24, 'JOU', 'GUA', '2017-02-02', '2023-01-15');
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (7, 25, 'ENT', 'DGA', '2015-11-10', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (7, 26, 'JOU', 'ADR', '2013-08-25', '2022-03-30');
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (7, 27, 'JOU', 'GUA', '2014-11-30', '2023-02-15');
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (7, 28, 'JOU', 'CDB', '2021-01-01', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (8, 29, 'ENT', 'ADR', '2020-05-15', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (8, 30, 'JOU', 'DGA', '2019-08-10', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (8, 31, 'JOU', 'DGA', '2022-02-01', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (8, 32, 'JOU', 'CDB', '2021-03-01', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (9, 33, 'ENT', 'ADR', '2020-06-15', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (9, 34, 'JOU', 'DGA', '2020-09-10', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (9, 35, 'JOU', 'DGA', '2022-03-01', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (9, 36, 'JOU', 'CDB', '2021-04-01', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (10, 37, 'ENT', 'ADR', '2020-07-15', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (10, 38, 'JOU', 'DGA', '2021-10-10', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (10, 39, 'JOU', 'DGA', '2022-04-01', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (10, 40, 'JOU', 'CDB', '2021-05-01', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (11, 41, 'ENT', 'ADR', '2020-08-15', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (11, 42, 'JOU', 'DGA', '2019-11-10', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (11, 43, 'JOU', 'DGA', '2022-05-01', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (11, 44, 'JOU', 'CDB', '2021-06-01', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (12, 45, 'ENT', 'ADR', '2020-09-15', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (12, 46, 'JOU', 'DGA', '2019-12-10', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (12, 47, 'JOU', 'DGA', '2022-06-01', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (12, 48, 'JOU', 'CDB', '2023-04-12', '2023-09-25');
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (13, 49, 'ENT', 'DGA', '2021-10-08', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (13, 50, 'JOU', 'ADR', '2023-06-20', '2024-02-10');
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (13, 51, 'JOU', 'GUA', '2023-12-01', '2024-05-18');
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (13, 52, 'JOU', 'ADR', '2023-09-14', '2023-11-30');
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (14, 53, 'ENT', 'CDB', '2021-08-02', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (14, 54, 'JOU', 'DGA', '2023-05-17', '2023-08-22');
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (14, 55, 'JOU', 'GUA', '2022-02-02', '2023-01-15');
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (14, 56, 'JOU', 'DGA', '2023-11-10', '2024-06-28');
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (15, 57, 'ENT', 'CDB', '2018-07-05', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (15, 58, 'JOU', 'ADR', '2021-08-25', '2022-03-30');
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (15, 59, 'JOU', 'GUA', '2020-11-30', '2023-02-15');
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (15, 60, 'JOU', 'CDB', '2021-01-01', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (16, 61, 'ENT', 'ADR', '2020-05-15', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (16, 62, 'JOU', 'DGA', '2019-08-10', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (16, 63, 'JOU', 'DGA', '2022-02-01', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (16, 64, 'JOU', 'CDB', '2021-03-01', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (17, 65, 'ENT', 'ADR', '2020-06-15', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (17, 66, 'JOU', 'DGA', '2020-09-10', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (17, 67, 'JOU', 'DGA', '2022-03-01', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (17, 68, 'JOU', 'CDB', '2021-04-01', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (18, 69, 'ENT', 'ADR', '2020-07-15', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (18, 70, 'JOU', 'DGA', '2021-10-10', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (18, 71, 'JOU', 'DGA', '2022-04-01', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (18, 72, 'JOU', 'CDB', '2021-05-01', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (19, 73, 'ENT', 'ADR', '2020-08-15', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (19, 74, 'JOU', 'DGA', '2020-11-10', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (19, 75, 'JOU', 'DGA', '2022-05-01', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (19, 76, 'JOU', 'CDB', '2021-06-01', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (20, 77, 'ENT', 'ADR', '2020-09-15', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (20, 78, 'JOU', 'DGA', '2021-12-10', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (20, 79, 'JOU', 'DGA', '2022-06-01', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (20, 80, 'JOU', 'CDB', '2021-02-13', null); 
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (21, 81, 'ENT', 'DGA', '2019-02-13', null); 
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (21, 82, 'JOU', 'ADR', '2019-02-13', null); 
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (21, 83, 'JOU', 'GUA', '2019-02-13', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (21, 84, 'JOU', 'DGA', '2019-02-13', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (22, 85, 'ENT', 'ENT', '2019-02-13', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (22, 86, 'JOU', 'ADR', '2019-02-13', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (22, 87, 'JOU', 'GUA', '2019-02-13', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (22, 88, 'JOU', 'CDR', '2019-02-13', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (23, 89, 'ENT', 'ENT', '2023-02-13', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (23, 90, 'JOU', 'DGA', '2023-02-13', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (23, 91, 'JOU', 'GUA', '2023-02-13', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (23, 92, 'JOU', 'ADR', '2023-02-13', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (24, 93, 'ENT', 'CGA', '2023-02-13', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (24, 94, 'JOU', 'ADR', '2023-02-13', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (24, 95, 'JOU', 'CDB', '2023-02-13', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (24, 96, 'JOU', 'CDB', '2023-04-12', '2023-09-25');
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (25, 97, 'ENT', 'DGA', '2020-10-08', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (25, 98, 'JOU', 'ADR', '2019-06-20', '2020-02-10');
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (25, 99, 'JOU', 'GUA', '2023-12-01', '2024-05-18');
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (25, 100, 'JOU', 'ADR', '2023-09-14', '2023-11-30');
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (26, 101, 'ENT', 'CDB', '2020-08-02', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (26, 102, 'JOU', 'DGA', '2023-05-17', '2023-08-22');
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (26, 103, 'JOU', 'GUA', '2017-02-02', '2023-01-15');
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (26, 104, 'JOU', 'DGA', '2023-11-10', '2024-06-28');
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (27, 105, 'ENT', 'CDB', '2023-07-05', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (27, 106, 'JOU', 'ADR', '2023-08-25', '2024-03-30');
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (27, 107, 'JOU', 'GUA', '2023-11-30', '2024-02-15');
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (27, 108, 'JOU', 'CDB', '2023-01-01', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (28, 109, 'ENT', 'ADR', '2022-05-15', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (28, 110, 'JOU', 'DGA', '2022-08-10', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (28, 111, 'JOU', 'DGA', '2022-02-01', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (28, 112, 'JOU', 'CDB', '2023-03-01', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (1, 113, 'JOU', 'DGA', '2022-05-01', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (14, 114, 'JOU', 'CDB', '2021-06-01', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (20, 115, 'JOU', 'ADR', '2020-09-15', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (22, 116, 'JOU', 'DGA', '2019-12-10', null);
INSERT INTO JouePour (idEquipe,idPersonne,role,position,dateArrivee,dateDepart) VALUES (27, 117, 'JOU', 'DGA', '2022-06-01', null);
INSERT INTO JouePour (idEquipe, idPersonne, role, position, dateArrivee, dateDepart)
VALUES
  (29, 118, 'JOU', 'AT', '2020-01-01', null),
  (29, 119, 'JOU', 'GB', '2020-01-01', null),
  (29, 120, 'JOU', 'MC', '2020-01-01', null),
  (29, 121, 'JOU', 'MC', '2020-01-01', null),
  (29, 122, 'JOU', 'AT', '2020-01-01', null),
  (29, 123, 'JOU', 'MC', '2020-01-01', null),
  (29, 124, 'JOU', 'DC', '2020-01-01', null),
  (29, 125, 'JOU', 'AT', '2020-01-01', null),
  (29, 126, 'JOU', 'DC', '2020-01-01', null),
  (29, 127, 'JOU', 'DC', '2020-01-01', null),
  (29, 128, 'JOU', 'AT', '2020-01-01', null),
  (29, 129, 'JOU', 'MC', '2020-01-01', null),
  (29, 130, 'JOU', 'DC', '2020-01-01', null),
  (29, 131, 'JOU', 'DC', '2020-01-01', null),
  (29, 132, 'JOU', 'MC', '2020-01-01', null),
  (29, 133, 'JOU', 'MC', '2020-01-01', null),
  (29, 134, 'JOU', 'AT', '2020-01-01', null),
  (29, 135, 'JOU', 'DC', '2020-01-01', null),
  (29, 136, 'JOU', 'MC', '2020-01-01', null),
  (29, 137, 'ENT', 'ENT', '2020-01-01', null);


INSERT INTO Evenement (type,heureDebut,heureFin,adresse,nomSport) VALUES ('MAT','2023-02-22 06:00:00','2023-02-22 08:00:00','Terrain de villars','Football');
INSERT INTO Evenement (type,heureDebut,heureFin,adresse,nomSport) VALUES ('ENT','2023-02-13 17:00:00','2023-02-13 20:00:00','Terrain de Lausanne','Football');
INSERT INTO Evenement (type,heureDebut,heureFin,adresse,nomSport) VALUES ('ENT','2023-03-24 17:00:00','2023-03-24 20:00:00','Terrain de villars','Volley');
INSERT INTO Evenement (type,heureDebut,heureFin,adresse,nomSport) VALUES ('MAT','2023-03-15 06:00:00','2023-03-15 08:00:00','Terrain de Yverdon','Football');
INSERT INTO Evenement (type,heureDebut,heureFin,adresse,nomSport) VALUES ('ENT','2023-03-09 17:00:00','2023-03-09 20:00:00','Terrain de villars','Football');
INSERT INTO Evenement (type,heureDebut,heureFin,adresse,nomSport) VALUES ('SOR','2023-04-12 07:00:00','2023-04-12 18:00:00','Aquapark','Football');
INSERT INTO Evenement (type,heureDebut,heureFin,adresse,nomSport) VALUES ('ENT','2023-05-26 17:00:00','2023-05-26 20:00:00','Terrain de villars','Volley');
INSERT INTO Evenement (type,heureDebut,heureFin,adresse,nomSport) VALUES ('MAT','2023-06-09 06:00:00','2023-06-09 08:00:00','Terrain de Geneve','Volley');
INSERT INTO Evenement (type,heureDebut,heureFin,adresse,nomSport) VALUES ('MAT','2023-06-22 06:00:00','2023-06-22 08:00:00','Terrain de villars','Football');
INSERT INTO Evenement (type,heureDebut,heureFin,adresse,nomSport) VALUES ('MAT','2023-07-20 06:00:00','2023-07-20 08:00:00','Terrain de Ependes','Football');
INSERT INTO Evenement (type,heureDebut,heureFin,adresse,nomSport) VALUES ('ENT','2023-06-18 17:00:00','2023-06-18 20:00:00','Terrain de Poliez','Football');
INSERT INTO Evenement (type,heureDebut,heureFin,adresse,nomSport) VALUES ('SOR','2023-07-01 07:00:00','2023-07-01 18:00:00','Bowling','Volley');
INSERT INTO Evenement (type,heureDebut,heureFin,adresse,nomSport) VALUES ('ENT','2023-08-12 17:00:00','2023-08-12 20:00:00','Terrain de Bottens','Football');
INSERT INTO Evenement (type,heureDebut,heureFin,adresse,nomSport) VALUES ('MAT','2023-09-20 06:00:00','2023-09-20 08:00:00','Terrain de Planaise','Volley');
INSERT INTO Evenement (type,heureDebut,heureFin,adresse,nomSport) VALUES ('MAT','2023-10-08 06:00:00','2023-10-08 08:00:00','Terrain de Yverdon','Football');
INSERT INTO Evenement (type,heureDebut,heureFin,adresse,nomSport) VALUES ('MAT','2023-11-15 06:00:00','2023-11-15 08:00:00','Terrain synthétique','Volley');
INSERT INTO Evenement (type,heureDebut,heureFin,adresse,nomSport) VALUES ('SOR','2023-12-22 07:00:00','2023-12-22 18:00:00','Cinema','Volley');
INSERT INTO Evenement (type,heureDebut,heureFin,adresse,nomSport) VALUES ('ENT','2024-01-28 17:00:00','2024-01-28 20:00:00','Terrain de villars','Football');
INSERT INTO Evenement (type,heureDebut,heureFin,adresse,nomSport) VALUES ('MAT','2024-02-15 06:00:00','2024-02-15 08:00:00','Terrain de Morges','Volley');
INSERT INTO Evenement (type,heureDebut,heureFin,adresse,nomSport) VALUES ('MAT','2024-03-10 06:00:00','2024-03-10 08:00:00','Terrain de Geneve','Football');
INSERT INTO Evenement (type,heureDebut,heureFin,adresse,nomSport) VALUES ('ENT','2024-04-18 17:00:00','2024-04-18 20:00:00','Terrain Lausanne','Football');
INSERT INTO Evenement (type,heureDebut,heureFin,adresse,nomSport) VALUES ('SOR','2024-05-01 07:00:00','2024-05-01 18:00:00','Europapark','Volley');
INSERT INTO Evenement (type,heureDebut,heureFin,adresse,nomSport) VALUES ('ENT','2024-06-12 17:00:00','2024-06-12 20:00:00','Terrain de Bettens','Football');
INSERT INTO Evenement (type,heureDebut,heureFin,adresse,nomSport) VALUES ('MAT','2024-07-20 06:00:00','2024-07-20 08:00:00','Terrain de Echallens','Volley');
INSERT INTO Evenement (type,heureDebut,heureFin,adresse,nomSport) VALUES ('MAT','2024-08-08 06:00:00','2024-08-08 08:00:00','Terrain de Essertines','Football');
INSERT INTO Evenement (type,heureDebut,heureFin,adresse,nomSport) VALUES ('MAT','2024-09-15 06:00:00','2024-09-15 08:00:00','Terrain de Peney','Volley');
INSERT INTO Evenement (type,heureDebut,heureFin,adresse,nomSport) VALUES ('SOR','2024-10-22 07:00:00','2024-10-22 18:00:00','EscapeGame','Volley');
INSERT INTO Evenement (type,heureDebut,heureFin,adresse,nomSport) VALUES ('ENT','2024-11-28 17:00:00','2024-11-28 20:00:00','Terrain de Vuiteboeuf','Football');
INSERT INTO Evenement (type,heureDebut,heureFin,adresse,nomSport) VALUES ('MAT','2024-12-15 06:00:00','2024-12-15 08:00:00','Terrain de Ependes','Volley');
INSERT INTO Evenement (type,heureDebut,heureFin,adresse,nomSport) VALUES ('MAT','2025-01-10 06:00:00','2025-01-10 08:00:00','Terrain de Froideville','Football');
INSERT INTO Evenement (type,heureDebut,heureFin,adresse,nomSport) VALUES ('ENT','2025-02-18 17:00:00','2025-02-18 20:00:00','Terrain de Bière','Football');
INSERT INTO Evenement (type,heureDebut,heureFin,adresse,nomSport) VALUES ('SOR','2025-03-01 07:00:00','2025-03-01 18:00:00','Cinema','Volley');
INSERT INTO Evenement (type,heureDebut,heureFin,adresse,nomSport) VALUES ('ENT','2025-04-12 17:00:00','2025-04-12 20:00:00','Terrain de Poliez','Football');
INSERT INTO Evenement (type,heureDebut,heureFin,adresse,nomSport) VALUES ('MAT','2025-05-20 06:00:00','2025-05-20 08:00:00','Terrain de Bottens','Volley');
INSERT INTO Evenement (type,heureDebut,heureFin,adresse,nomSport) VALUES ('MAT','2025-06-15 06:00:00','2025-06-15 08:00:00','Terrain de Yverdon','Football');
INSERT INTO Evenement (type, heureDebut, heureFin, adresse, nomSport)
VALUES
  ('MAT', '2024-02-03 18:00:00', '2024-02-03 20:00:00', 'Allianz Arena', 'Football'),
  ('ENT', '2024-02-01 16:00:00', '2024-02-01 18:00:00', 'Sabener Strasse', 'Football'),
  ('ENT', '2024-02-02 16:00:00', '2024-02-02 18:00:00', 'Sabener Strasse', 'Football'),
  ('ENT', '2024-02-04 16:00:00', '2024-02-04 18:00:00', 'Sabener Strasse', 'Football'),
  ('MAT', '2024-02-10 18:00:00', '2024-02-10 20:00:00', 'Allianz Arena', 'Football'),
  ('ENT', '2024-02-08 16:00:00', '2024-02-08 18:00:00', 'Sabener Strasse', 'Football'),
  ('ENT', '2024-02-09 16:00:00', '2024-02-09 18:00:00', 'Sabener Strasse', 'Football'),
  ('ENT', '2024-02-11 16:00:00', '2024-02-11 18:00:00', 'Sabener Strasse', 'Football'),
  ('MAT', '2024-03-02 19:00:00', '2024-03-02 21:00:00', 'Allianz Arena', 'Football'),
  ('ENT', '2024-03-01 16:00:00', '2024-03-01 18:00:00', 'Sabener Strasse', 'Football'),
  ('ENT', '2024-03-03 16:00:00', '2024-03-03 18:00:00', 'Sabener Strasse', 'Football'),
  ('ENT', '2024-03-05 16:00:00', '2024-03-05 18:00:00', 'Sabener Strasse', 'Football'),
  ('MAT', '2024-04-06 18:00:00', '2024-04-06 20:00:00', 'Allianz Arena', 'Football'),
  ('ENT', '2024-04-05 16:00:00', '2024-04-05 18:00:00', 'Sabener Strasse', 'Football'),
  ('ENT', '2024-04-07 16:00:00', '2024-04-07 18:00:00', 'Sabener Strasse', 'Football'),
  ('ENT', '2024-04-09 16:00:00', '2024-04-09 18:00:00', 'Sabener Strasse', 'Football'),
  ('MAT', '2024-05-04 19:00:00', '2024-05-04 21:00:00', 'Allianz Arena', 'Football'),
  ('ENT', '2024-05-03 16:00:00', '2024-05-03 18:00:00', 'Sabener Strasse', 'Football'),
  ('ENT', '2024-05-05 16:00:00', '2024-05-05 18:00:00', 'Sabener Strasse', 'Football'),
  ('ENT', '2024-05-07 16:00:00', '2024-05-07 18:00:00', 'Sabener Strasse', 'Football');


INSERT INTO Match (idEvenement,numMatch,idEquipeDomicile,idEquipeAdversaire,nomSport) VALUES (1,1,1,18,'Football');
INSERT INTO Match (idEvenement,numMatch,idEquipeDomicile,idEquipeAdversaire,nomSport) VALUES (4,2,2,17,'Football');
INSERT INTO Match (idEvenement,numMatch,idEquipeDomicile,idEquipeAdversaire,nomSport) VALUES (8,3,19,28,'Volley');
INSERT INTO Match (idEvenement,numMatch,idEquipeDomicile,idEquipeAdversaire,nomSport) VALUES (9,4,3,16,'Football');
INSERT INTO Match (idEvenement,numMatch,idEquipeDomicile,idEquipeAdversaire,nomSport) VALUES (10,5,4,15,'Football');
INSERT INTO Match (idEvenement,numMatch,idEquipeDomicile,idEquipeAdversaire,nomSport) VALUES (14,6,20,27,'Volley');
INSERT INTO Match (idEvenement,numMatch,idEquipeDomicile,idEquipeAdversaire,nomSport) VALUES (15,7,5,14,'Football');
INSERT INTO Match (idEvenement,numMatch,idEquipeDomicile,idEquipeAdversaire,nomSport) VALUES (16,8,21,26,'Volley');
INSERT INTO Match (idEvenement,numMatch,idEquipeDomicile,idEquipeAdversaire,nomSport) VALUES (19,9,22,25,'Volley');
INSERT INTO Match (idEvenement,numMatch,idEquipeDomicile,idEquipeAdversaire,nomSport) VALUES (20,10,6,13,'Football');
INSERT INTO Match (idEvenement,numMatch,idEquipeDomicile,idEquipeAdversaire,nomSport) VALUES (24,11,23,24,'Volley');
INSERT INTO Match (idEvenement,numMatch,idEquipeDomicile,idEquipeAdversaire,nomSport) VALUES (25,12,7,12,'Football');
INSERT INTO Match (idEvenement,numMatch,idEquipeDomicile,idEquipeAdversaire,nomSport) VALUES (26,13,19,20,'Volley');
INSERT INTO Match (idEvenement,numMatch,idEquipeDomicile,idEquipeAdversaire,nomSport) VALUES (29,14,21,22,'Volley');
INSERT INTO Match (idEvenement,numMatch,idEquipeDomicile,idEquipeAdversaire,nomSport) VALUES (30,15,8,11,'Football');
INSERT INTO Match (idEvenement,numMatch,idEquipeDomicile,idEquipeAdversaire,nomSport) VALUES (34,16,25,26,'Volley');
INSERT INTO Match (idEvenement,numMatch,idEquipeDomicile,idEquipeAdversaire,nomSport) VALUES (35,17,9,10,'Football');
INSERT INTO Match (idEvenement, numMatch, idEquipeDomicile, idEquipeAdversaire, nomSport)
VALUES
  (36, 12345, 29, 1, 'Football'),
  (40, 54321, 29, 2, 'Football'),
  (44, 98765, 29, 3, 'Football'),
  (48, 67890, 29, 4, 'Football'),
  (52, 13579, 29, 5, 'Football');


-- Equipe 1
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (1,1,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (1,2,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (1,27,'A','Maladie');
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (2,1,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (2,2,'A','Souper de boite');
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (2,27,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (3,1,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (3,2,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (3,27,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (4,1,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (4,2,'A','Blessure');
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (4,27,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (113,1,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (113,2,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (113,27,'A','Maladie');

-- Equipe 2
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (5,2,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (5,4,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (5,27,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (6,2,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (6,4,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (6,27,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (7,2,'A','Etudes');
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (7,4,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (7,27,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (8,2,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (8,4,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (8,27,'P',null);

-- Equipe 3
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (9,2,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (9,9,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (9,27,'A','Maladie');
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (10,2,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (10,9,'A','Souper de boite');
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (10,27,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (11,2,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (11,9,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (11,27,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (12,2,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (12,9,'A','Blessure');
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (12,27,'P',null);

-- Equipe 4
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (13,3,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (13,10,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (13,28,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (14,3,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (14,10,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (14,28,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (15,3,'A','Etudes');
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (15,10,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (15,28,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (16,3,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (16,10,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (16,28,'P',null);

-- Equipe 5
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (17,3,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (17,15,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (17,28,'A','Maladie');
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (18,3,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (18,15,'A','Souper de boite');
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (18,28,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (19,3,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (19,15,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (19,28,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (20,3,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (20,15,'A','Blessure');
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (20,28,'P',null);

-- Equipe 6
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (21,5,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (21,20,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (21,31,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (22,5,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (22,20,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (22,31,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (23,5,'A','Etudes');
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (23,20,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (23,31,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (24,5,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (24,20,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (24,31,'P',null);

-- Equipe 7
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (25,5,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (25,25,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (25,31,'A','Maladie');
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (26,5,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (26,25,'A','Souper de boite');
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (26,31,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (27,5,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (27,25,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (27,31,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (28,5,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (28,25,'A','Blessure');
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (28,31,'P',null);

-- Equipe 8
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (29,5,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (29,30,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (29,31,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (30,5,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (30,30,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (30,31,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (31,5,'A','Etudes');
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (31,30,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (31,31,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (32,5,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (32,30,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (32,31,'P',null);

-- Equipe 9
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (33,6,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (33,32,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (33,35,'A','Maladie');
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (34,6,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (34,32,'A','Souper de boite');
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (34,35,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (35,6,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (35,32,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (35,35,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (36,6,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (36,32,'A','Blessure');
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (36,35,'P',null);

-- Equipe 10
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (37,6,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (37,32,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (37,35,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (38,6,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (38,32,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (38,35,'A','Etudes');
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (39,6,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (39,32,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (39,35,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (40,6,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (40,32,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (40,35,'P',null);

-- Equipe 11
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (41,7,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (41,30,'A','Maladie');
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (41,33,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (42,7,'A','Souper de boite');
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (42,30,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (42,33,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (43,7,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (43,30,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (43,33,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (44,7,'A','Blessure');
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (44,30,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (44,33,'P',null);

-- Equipe 12
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (45,7,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (45,25,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (45,33,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (46,7,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (46,25,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (46,33,'A','Etudes');
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (47,7,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (47,25,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (47,33,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (48,7,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (48,25,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (48,33,'P',null);

-- Equipe 13
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (49,11,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (49,20,'A','Maladie');
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (50,11,'A','Souper de boite');
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (50,20,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (51,11,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (51,20,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (52,11,'A','Blessure');
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (52,20,'P',null);

-- Equipe 14
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (53,11,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (53,15,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (54,11,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (54,15,'A','Etudes');
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (55,11,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (55,15,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (56,11,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (56,15,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (114,11,'A','Souper de boite');
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (114,15,'P',null);

-- Equipe 15
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (57,10,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (57,12,'A','Maladie');
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (58,10,'A','Souper de boite');
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (58,12,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (59,10,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (59,12,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (60,10,'A','Blessure');
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (60,12,'P',null);

-- Equipe 16
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (61,9,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (61,12,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (62,9,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (62,12,'A','Etudes');
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (63,9,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (63,12,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (64,9,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (64,12,'P',null);

-- Equipe 17
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (65,4,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (65,13,'A','Maladie');
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (66,4,'A','Souper de boite');
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (66,13,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (67,4,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (67,13,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (68,4,'A','Blessure');
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (68,13,'P',null);

-- Equipe 18
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (69,1,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (69,13,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (70,1,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (70,13,'A','Etudes');
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (71,1,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (71,13,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (72,1,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (72,13,'P',null);

-- Equipe 19
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (73,8,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (73,17,'A','Maladie');
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (73,26,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (74,8,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (74,17,'A','Souper de boite');
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (74,26,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (75,8,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (75,17,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (75,26,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (76,8,'A','Blessure');
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (76,17,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (76,26,'P',null);

-- Equipe 20
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (77,14,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (77,17,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (77,26,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (78,14,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (78,17,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (78,26,'A','Etudes');
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (79,14,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (79,17,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (79,26,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (80,14,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (80,17,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (80,26,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (115,14,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (115,17,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (115,26,'P',null);

-- Equipe 21
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (81,16,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (81,18,'A','Maladie');
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (81,29,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (82,16,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (82,18,'A','Souper de boite');
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (82,29,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (83,16,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (83,18,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (83,29,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (84,16,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (84,18,'A','Blessure');
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (84,29,'P',null);

-- Equipe 22
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (85,18,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (85,19,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (85,29,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (86,18,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (86,19,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (86,29,'A','Etudes');
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (87,18,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (87,19,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (87,29,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (88,18,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (88,19,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (88,29,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (116,18,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (116,19,'A','Blessure');
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (116,29,'P',null);

-- Equipe 23
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (89,21,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (89,24,'A','Maladie');
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (90,21,'A','Souper de boite');
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (90,24,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (91,21,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (91,24,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (92,21,'A','Blessure');
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (92,24,'P',null);

-- Equipe 24
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (93,21,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (93,24,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (94,21,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (94,24,'A','Etudes');
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (95,21,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (95,24,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (96,21,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (96,24,'P',null);

-- Equipe 25
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (97,19,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (97,22,'A','Maladie');
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (97,34,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (98,19,'A','Souper de boite');
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (98,22,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (98,34,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (99,19,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (99,22,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (99,34,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (100,19,'A','Blessure');
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (100,22,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (100,34,'P',null);

-- Equipe 26
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (101,16,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (101,22,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (101,34,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (102,16,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (102,22,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (102,34,'A','Etudes');
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (103,16,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (103,22,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (103,34,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (104,16,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (104,22,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (104,34,'P',null);

-- Equipe 27
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (105,14,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (105,23,'A','Maladie');
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (106,14,'A','Souper de boite');
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (106,23,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (107,14,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (107,23,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (108,14,'A','Blessure');
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (108,23,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (117,14,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (117,23,'P',null);

-- Equipe 28
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (109,8,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (109,23,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (110,8,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (110,23,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (111,8,'A','Etudes');
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (111,23,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (112,8,'P',null);
INSERT INTO Statut (idPersonne,idEvenement,type,raison) VALUES (112,23,'P',null);

INSERT INTO Statut (idPersonne, idEvenement, type, raison)
VALUES
  (118, 36, 'P', null),
  (119, 36, 'P', null),
  (120, 36, 'P', null),
  (121, 36, 'P', null),
  (122, 36, 'P', null),
  (123, 36, 'P', null),
  (124, 36, 'P', null),
  (125, 36, 'P', null),
  (126, 36, 'P', null),
  (127, 36, 'P', null),
  (128, 36, 'P', null),
  (129, 36, 'P', null),
  (130, 36, 'P', null),
  (131, 36, 'P', null),
  (132, 36, 'P', null),
  (133, 36, 'P', null),
  (134, 36, 'P', null),
  (135, 36, 'P', null),
  (136, 36, 'P', null),
  (118, 37, 'P', null),
  (119, 37, 'P', null),
  (120, 37, 'P', null),
  (121, 37, 'P', null),
  (122, 37, 'P', null),
  (123, 37, 'P', null),
  (124, 37, 'P', null),
  (125, 37, 'P', null),
  (126, 37, 'P', null),
  (127, 37, 'P', null),
  (128, 37, 'P', null),
  (129, 37, 'P', null),
  (130, 37, 'P', null),
  (131, 37, 'P', null),
  (132, 37, 'P', null),
  (133, 37, 'P', null),
  (134, 37, 'P', null),
  (135, 37, 'P', null),
  (136, 37, 'P', null),
  (118, 38, 'P', null),
  (119, 38, 'P', null),
  (120, 38, 'P', null),
  (121, 38, 'P', null),
  (122, 38, 'P', null),
  (123, 38, 'A', null),
  (124, 38, 'P', null),
  (125, 38, 'P', null),
  (126, 38, 'P', null),
  (127, 38, 'A', null),
  (128, 38, 'P', null),
  (129, 38, 'P', null),
  (130, 38, 'P', null),
  (131, 38, 'A', 'Blessé'),
  (132, 38, 'P', null),
  (133, 38, 'P', null),
  (134, 38, 'P', null),
  (135, 38, 'A', 'Malade'),
  (136, 38, 'P', null),
  (118, 39, 'P', null),
  (119, 39, 'P', null),
  (120, 39, 'P', null),
  (121, 39, 'P', null),
  (122, 39, 'A', 'Malade'),
  (123, 39, 'P', null),
  (124, 39, 'P', null),
  (125, 39, 'P', null),
  (126, 39, 'A', 'Blessé'),
  (127, 39, 'P', null),
  (128, 39, 'P', null),
  (129, 39, 'P', null),
  (130, 39, 'A', 'Malade'),
  (131, 39, 'P', null),
  (132, 39, 'P', null),
  (133, 39, 'P', null),
  (134, 39, 'A', 'Blessé'),
  (135, 39, 'P', null),
  (136, 39, 'P', null),
  (118, 40, 'P', null),
  (119, 40, 'P', null),
  (120, 40, 'P', null),
  (121, 40, 'P', null),
  (122, 40, 'P', null),
  (123, 40, 'P', null),
  (124, 40, 'P', null),
  (125, 40, 'P', null),
  (126, 40, 'P', null),
  (127, 40, 'P', null),
  (128, 40, 'P', null),
  (129, 40, 'P', null),
  (130, 40, 'P', null),
  (131, 40, 'P', null),
  (132, 40, 'P', null),
  (133, 40, 'P', null),
  (134, 40, 'P', null),
  (135, 40, 'P', null),
  (136, 40, 'P', null),
  (118, 41, 'P', null),
  (119, 41, 'P', null),
  (120, 41, 'P', null),
  (121, 41, 'A', 'Blessé'),
  (122, 41, 'P', null),
  (123, 41, 'P', null),
  (124, 41, 'P', null),
  (125, 41, 'A', 'Malade'),
  (126, 41, 'P', null),
  (127, 41, 'P', null),
  (128, 41, 'P', null),
  (129, 41, 'A', 'Blessé'),
  (130, 41, 'P', null),
  (131, 41, 'P', null),
  (132, 41, 'P', null),
  (133, 41, 'A', 'Malade'),
  (134, 41, 'P', null),
  (135, 41, 'P', null),
  (136, 41, 'P', null),
  (118, 42, 'P', null),
  (119, 42, 'A', 'Blessé'),
  (120, 42, 'P', null),
  (121, 42, 'P', null),
  (122, 42, 'A', 'Malade'),
  (123, 42, 'P', null),
  (124, 42, 'P', null),
  (125, 42, 'P', null),
  (126, 42, 'A', 'Blessé'),
  (127, 42, 'P', null),
  (128, 42, 'P', null),
  (129, 42, 'P', null),
  (130, 42, 'A', 'Malade'),
  (131, 42, 'P', null),
  (132, 42, 'P', null),
  (133, 42, 'P', null),
  (134, 42, 'A', 'Blessé'),
  (135, 42, 'P', null),
  (136, 42, 'P', null),
  (118, 43, 'P', null),
  (119, 43, 'P', null),
  (120, 43, 'A', 'Malade'),
  (121, 43, 'P', null),
  (122, 43, 'P', null),
  (123, 43, 'A', 'Blessé'),
  (124, 43, 'P', null),
  (125, 43, 'P', null),
  (126, 43, 'P', null),
  (127, 43, 'A', 'Malade'),
  (128, 43, 'P', null),
  (129, 43, 'P', null),
  (130, 43, 'P', null),
  (131, 43, 'A', 'Blessé'),
  (132, 43, 'P', null),
  (133, 43, 'P', null),
  (134, 43, 'P', null),
  (135, 43, 'A', 'Malade'),
  (136, 43, 'P', null),
  (118, 44, 'P', 'Blessé'),
  (119, 44, 'P', null),
  (120, 44, 'P', null),
  (121, 44, 'P', null),
  (122, 44, 'P', 'Malade'),
  (123, 44, 'P', null),
  (124, 44, 'P', null),
  (125, 44, 'P', null),
  (126, 44, 'P', 'Blessé'),
  (127, 44, 'P', null),
  (128, 44, 'P', null),
  (129, 44, 'P', null),
  (130, 44, 'P', 'Malade'),
  (131, 44, 'P', null),
  (132, 44, 'P', null),
  (133, 44, 'P', null),
  (134, 44, 'P', 'Blessé'),
  (135, 44, 'P', null),
  (136, 44, 'P', null),
  (118, 45, 'P', null),
  (119, 45, 'A', 'Malade'),
  (120, 45, 'P', null),
  (121, 45, 'P', null),
  (122, 45, 'A', 'Blessé'),
  (123, 45, 'P', null),
  (124, 45, 'P', null),
  (125, 45, 'A', 'Blessé'),
  (126, 45, 'P', null),
  (127, 45, 'P', null),
  (128, 45, 'A', 'Malade'),
  (129, 45, 'P', null),
  (130, 45, 'P', null),
  (131, 45, 'P', null),
  (132, 45, 'A', 'Blessé'),
  (133, 45, 'P', null),
  (134, 45, 'P', null),
  (135, 45, 'P', null),
  (136, 45, 'A', 'Malade');

INSERT INTO FaitInterSport (nom) VALUES ('Carton Jaune');
INSERT INTO FaitInterSport (nom) VALUES ('Carton Rouge');
INSERT INTO FaitInterSport (nom) VALUES ('Debut');
INSERT INTO FaitInterSport (nom) VALUES ('Fin');
INSERT INTO FaitInterSport (nom) VALUES ('Pause');
INSERT INTO FaitInterSport (nom) VALUES ('Changement');

INSERT INTO FaitSport (nom,idFaitInterSport,nomSport) VALUES ('Carton Jaune',1,'Football');
INSERT INTO FaitSport (nom,idFaitInterSport,nomSport) VALUES ('Carton Rouge',2,'Football');
INSERT INTO FaitSport (nom,idFaitInterSport,nomSport) VALUES ('Debut',3,'Football');
INSERT INTO FaitSport (nom,idFaitInterSport,nomSport) VALUES ('Fin',4,'Football');
INSERT INTO FaitSport (nom,idFaitInterSport,nomSport) VALUES ('Pause',5,'Football');
INSERT INTO FaitSport (nom,idFaitInterSport,nomSport) VALUES ('Changement',6,'Football');
INSERT INTO FaitSport (nom,idFaitInterSport,nomSport) VALUES ('But',null,'Football');
INSERT INTO FaitSport (nom,idFaitInterSport,nomSport) VALUES ('Penalty',null,'Football');
INSERT INTO FaitSport (nom,idFaitInterSport,nomSport) VALUES ('Carton Jaune',1,'Volley');
INSERT INTO FaitSport (nom,idFaitInterSport,nomSport) VALUES ('Carton Rouge',2,'Volley');
INSERT INTO FaitSport (nom,idFaitInterSport,nomSport) VALUES ('Debut',3,'Volley');
INSERT INTO FaitSport (nom,idFaitInterSport,nomSport) VALUES ('Fin',4,'Volley');
INSERT INTO FaitSport (nom,idFaitInterSport,nomSport) VALUES ('Pause',5,'Volley');
INSERT INTO FaitSport (nom,idFaitInterSport,nomSport) VALUES ('Changement',6,'Volley');
INSERT INTO FaitSport (nom,idFaitInterSport,nomSport) VALUES ('Porté',null,'Volley');
INSERT INTO FaitSport (nom,idFaitInterSport,nomSport) VALUES ('Temps mort',null,'Volley');
INSERT INTO FaitSport (nom,idFaitInterSport,nomSport) VALUES ('Out',null,'Volley');

-- Match 1 Foot
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2023-02-22 06:00:00',3,null,1);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2023-02-22 06:14:00',2,3,1);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2023-02-22 06:32:00',6,113,1);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2023-02-22 06:45:00',5,null,1);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2023-02-22 07:21:00',2,70,1);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2023-02-22 08:00:00',4,null,1);

-- Match 4 Foot
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2023-03-15 06:00:00',3,null,4);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2023-03-15 07:27:00',2,7,4);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2023-03-15 06:45:00',5,null,4);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2023-03-15 06:04:00',2,5,4);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2023-03-15 06:32:00',6,67,4);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2023-03-15 08:00:00',4,null,4);

-- Match 8 Volley
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2023-06-09 06:00:00',11,null,8);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2023-06-09 07:37:00',10,74,8);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2023-06-09 06:45:00',13,null,8);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2023-06-09 06:21:00',17,109,8);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2023-06-09 06:43:00',16,null,8);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2023-06-09 08:00:00',12,null,8);

-- Match 9 Foot
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2023-06-22 06:00:00',3,null,9);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2023-06-22 07:28:00',2,11,9);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2023-06-22 06:45:00',5,null,9);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2023-06-22 06:10:00',2,61,9);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2023-06-22 06:36:00',6,63,9);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2023-06-22 08:00:00',4,null,9);

-- Match 10 Foot
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2023-07-20 06:00:00',3,null,10);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2023-07-20 06:48:00',2,13,10);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2023-07-20 06:26:00',6,57,10);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2023-07-20 06:45:00',5,null,10);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2023-07-20 07:19:00',2,16,10);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2023-07-20 08:00:00',4,null,10);

-- Match 14 Volley
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2023-09-20 06:00:00',11,null,14);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2023-09-20 06:49:00',17,115,14);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2023-09-20 06:20:00',16,null,14);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2023-09-20 06:45:00',13,null,14);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2023-09-20 07:40:00',10,117,14);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2023-09-20 08:00:00',12,null,14);

-- Match 15 Foot
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2023-10-08 06:00:00',3,null,15);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2023-10-08 07:18:00',2,19,15);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2023-10-08 06:45:00',5,null,15);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2023-10-08 06:30:00',2,55,15);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2023-10-08 06:13:00',6,114,15);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2023-10-08 08:00:00',4,null,15);

-- Match 16 Volley
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2023-11-15 06:00:00',11,null,16);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2023-11-15 06:49:00',17,81,16);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2023-11-15 06:20:00',16,null,16);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2023-11-15 06:45:00',13,null,16);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2023-11-15 07:16:00',10,102,16);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2023-11-15 08:00:00',12,null,16);

-- Match 19 Volley
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-02-15 06:00:00',11,null,19);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-02-15 07:49:00',10,86,19);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-02-15 06:45:00',13,null,19);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-02-15 06:20:00',17,99,19);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-02-15 06:48:00',16,null,19);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-02-15 08:00:00',12,null,19);

-- Match 20 Foot
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-03-10 06:00:00',3,null,20);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-03-10 07:19:00',2,21,20);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-03-10 06:45:00',5,null,20);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-03-10 06:30:00',2,22,20);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-03-10 06:15:00',6,50,20);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-03-10 08:00:00',4,null,20);

-- Match 24 Volley
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-07-20 06:00:00',11,null,24);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-07-20 06:38:00',17,90,24);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-07-20 06:44:00',16,null,24);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-07-20 06:45:00',13,null,24);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-07-20 07:29:00',10,92,24);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-07-20 08:00:00',12,null,24);

-- Match 25 Foot
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-08-08 06:00:00',3,null,25);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-08-08 06:19:00',2,27,25);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-08-08 06:15:00',6,45,25);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-08-08 06:45:00',5,null,25);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-08-08 07:57:00',2,47,25);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-08-08 08:00:00',4,null,25);

-- Match 26 Volley
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-09-15 06:00:00',11,null,26);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-09-15 06:17:00',17,74,26);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-09-15 06:56:00',16,null,26);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-09-15 06:45:00',13,null,26);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-09-15 07:29:00',10,115,26);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-09-15 08:00:00',12,null,26);

-- Match 29 Volley
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-12-15 06:00:00',11,null,29);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-12-15 07:57:00',10,83,29);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-12-15 06:45:00',13,null,29);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-12-15 06:15:00',17,88,29);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-12-15 06:19:00',16,null,29);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-12-15 08:00:00',12,null,29);

-- Match 30 Foot
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2025-01-10 06:00:00',3,null,30);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2025-01-10 06:49:00',2,29,30);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2025-01-10 06:36:00',6,31,30);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2025-01-10 06:45:00',5,null,30);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2025-01-10 07:20:00',2,44,30);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2025-01-10 08:00:00',4,null,30);

-- Match 34 Volley
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2025-05-20 06:00:00',11,null,34);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2025-05-20 06:51:00',17,97,34);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2025-05-20 06:58:00',16,null,34);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2025-05-20 06:45:00',13,null,34);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2025-05-20 07:36:00',10,100,34);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2025-05-20 08:00:00',12,null,34);

-- Match 35 Foot
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2025-06-15 06:00:00',3,null,35);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2025-06-15 06:49:00',2,34,35);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2025-06-15 06:20:00',6,36,35);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2025-06-15 06:45:00',5,null,35);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2025-06-15 07:12:00',2,39,35);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2025-06-15 08:00:00',4,null,35);

-- Match 36 Foot
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-02-03 18:03:00',3,null,36);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-02-03 18:05:00',8,null,36);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-02-03 18:07:00',7,118,36);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-02-03 18:13:00',7,118,36);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-02-03 18:17:00',7,122,36);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-02-03 18:23:00',7,122,36);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-02-03 18:35:00',1,118,36);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-02-03 18:40:00',7,125,36);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-02-03 18:45:00',5,null,36);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-02-03 19:00:00',7,118,36);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-02-03 19:05:00',7,134,36);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-02-03 19:10:00',6,122,36);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-02-03 19:10:00',6,123,36);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-02-03 19:50:00',4,null,36);

-- Match 40 Foot
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-02-10 18:03:00',3,null,40);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-02-10 18:17:00',7,120,40);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-02-10 18:23:00',7,118,40);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-02-10 18:35:00',1,129,40);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-02-10 18:40:00',7,120,40);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-02-10 18:45:00',5,null,40);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-02-10 19:00:00',7,118,40);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-02-10 19:05:00',7,134,40);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-02-10 19:10:00',6,128,40);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-02-10 19:10:00',6,123,40);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-02-10 18:23:00',7,123,40);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-02-10 19:50:00',4,null,40);

-- Match 44 Foot
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-03-02 19:03:00',3,null,44);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-03-02 19:05:00',8,null,44);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-03-02 19:07:00',7,118,44);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-03-02 19:13:00',7,118,44);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-03-02 19:17:00',7,122,44);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-03-02 19:23:00',7,122,44);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-03-02 19:35:00',1,118,44);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-03-02 19:40:00',7,125,44);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-03-02 19:45:00',5,null,44);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-03-02 20:00:00',7,118,44);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-03-02 20:05:00',7,134,44);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-03-02 20:10:00',6,122,44);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-03-02 20:10:00',6,123,44);
INSERT INTO FaitMatch (heure,idFaitSport,idPersonne,idMatch) VALUES ('2024-03-02 20:50:00',4,null,44);