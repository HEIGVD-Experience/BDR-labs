<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class EventDatabaseController extends Controller
{
    /**
     * Récupère les détails d'un événement en se basant sur l'id de celui-ci.
     */
    public static function getEventById($id_event) {
        return DB::select('
            SELECT * FROM evenement
                LEFT JOIN match ON evenement.id = match.idevenement
            WHERE id = ?', [$id_event]);
    }

    /**
     * Récupère tous les événements pour une équipe donnée.
     */
    public static function getEventsForTeam($id_team) {
        return DB::select('
        SELECT DISTINCT (evenement.*) FROM statut
	        INNER JOIN jouepour ON statut.idpersonne = jouepour.idpersonne
	        INNER JOIN evenement ON statut.idevenement = evenement.id
        WHERE jouepour.idequipe = ?
        AND jouepour.datedepart IS NULL
        ORDER BY evenement.heuredebut', [$id_team]);
    }

    /**
     * Récupère tous les status de tous les événements pour une équipe.
     */
    public static function getAllStatusForTeamEvents($id_team) {
        return DB::select('
        SELECT statut.idpersonne, statut.idevenement, statut.type FROM statut
	        INNER JOIN jouepour ON statut.idpersonne = jouepour.idpersonne
        WHERE jouepour.idequipe = ?
        GROUP BY (statut.idpersonne, statut.idevenement, statut.type);', [$id_team]);
    }

    /**
     * Récupère tous les status présent de tous les événements pour une équipe.
     */
    public static function getAllPresentStatusForTeamEvents($id_team) {
        return DB::select('
        SELECT statut.idpersonne, statut.idevenement, statut.type FROM statut
	        INNER JOIN jouepour ON statut.idpersonne = jouepour.idpersonne
        WHERE jouepour.idequipe = ?
        AND statut.type = ?
        GROUP BY (statut.idpersonne, statut.idevenement, statut.type);', [$id_team, 'P']);
    }

    /**
     * Récupère tous les événements ou il y a une personne qui n'aurait pas encore répondu.
     */
    public static function getEventsWithoutAnswer($id_team) {
        return DB::select('
        SELECT DISTINCT evenement.* FROM statut
            INNER JOIN jouepour ON statut.idpersonne = jouepour.idpersonne
            INNER JOIN evenement ON statut.idevenement = evenement.id
        AND jouepour.idequipe = ?
        AND statut.type = ?', [$id_team, 'X']);
    }

    /**
     * Récupère les 4 prochains événements.
     */
    public static function getNextFourEvents($id_team) {
        return DB::select('
        SELECT DISTINCT evenement.* FROM jouepour
            INNER JOIN statut ON jouepour.idpersonne = statut.idpersonne
            INNER JOIN evenement ON statut.idevenement = evenement.id
        WHERE idequipe = ? 
        AND datedepart IS NULL 
        AND heuredebut > ?
        ORDER BY heuredebut
        LIMIT 4', [$id_team, now()]);
    }
}
