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


