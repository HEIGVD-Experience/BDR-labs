<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Session;
use Illuminate\Support\Facades\Validator;

class AdminGameEventController extends Controller
{
    /**
     * Affiche la page des événements sportifs.
     *
     * @return \Illuminate\View\View
     */
    public function showGameEventsPage()
    {
        // Sélectionne les ID d'événements distincts pour l'équipe actuelle
        $match_id = DB::select('
            SELECT DISTINCT match.idevenement
            FROM statut
                INNER JOIN jouepour ON statut.idpersonne = jouepour.idpersonne
                INNER JOIN evenement ON statut.idevenement = evenement.id
                INNER JOIN match ON statut.idevenement = match.idevenement
            WHERE jouepour.idequipe = ?
        ', [Session::get('id_team')]);

        // Récupère les joueurs présents à l'événement
        $players = UserDatabaseController::getActualTeamPlayer(Session::get('id_team'));

        // Extrayez les ID des joueurs
        $idplayers = array_map(function($player) {
            return $player->id;
        }, $players);

        // Sélectionne les statistiques intéressantes pour le sport actuel
        $selected_sport = AdminGameEventController::selectInterestingStats(Session::get('sport'));

        // Sélectionne le nombre d'événements pour chaque statistique
        $events_number = DB::select('
            SELECT faitsport.id, faitsport.nom, count(faitmatch.idfaitsport)
            FROM faitmatch
                INNER JOIN faitsport ON faitmatch.idfaitsport = faitsport.id
            WHERE faitmatch.idpersonne IN (' . implode(',', $idplayers) . ')
            AND faitsport.nom IN (' . implode(',', $selected_sport) . ')
            GROUP BY (faitsport.id, faitsport.nom)
            ORDER BY faitsport.nom');

        // Extrait les valeurs de la propriété "idevenement"
        $idevenements = array_map(function($event) {
            return $event->idevenement;
        }, $match_id);

        // Vérifie s'il y a des événements, sinon affiche la page sans données d'événements
        if(!$idevenements)
        {
            return view('admin.game_events')->with(['games' => [], 'events_number' => $events_number]);
        }

        // Sélectionne les détails des matchs pour les événements
        $match_details = DB::select('
            SELECT  evenement.id,
                    evenement.heuredebut,
                    evenement.heurefin,
                    evenement.adresse,
                    match.nummatch,
                    idequipedomicile,
                    idequipeadversaire,
                    domicile.nom AS equipe_domicile,
                    exterieur.nom AS equipe_exterieur
            FROM evenement
            LEFT JOIN match ON evenement.id = match.idevenement
            LEFT JOIN equipe AS domicile ON match.idequipedomicile = domicile.id
            LEFT JOIN equipe AS exterieur ON match.idequipeadversaire = exterieur.id
            WHERE evenement.id IN (' . implode(',', $idevenements) . ')');

        // Retourne la vue avec les données d'événements
        return view('admin.game_events')->with(['games' => $match_details, 'events_number' => $events_number]);
    }

    /**
     * Affiche le formulaire d'ajout d'un événement.
     *
     * @param  int  $id_event
     * @return \Illuminate\View\View
     */
    public function showGameEventAddFrom($id_event)
    {
        // Récupère les faits de sport disponibles
        $sport_events = DB::select('
            SELECT id, nom
            FROM faitsport
            WHERE faitsport.nomsport = ?
        ', [Session::get('sport')]);

        // Récupère les personnes présentes à l'événement
        $player_present = DB::select('
            SELECT personne.id, personne.prenom, personne.nom
            FROM statut
            INNER JOIN personne ON statut.idpersonne = personne.id
            WHERE statut.idevenement = ? 
            AND statut.type = ?
        ', [$id_event, 'P']);

        // Récupère la date de l'événement
        $event_date = EventDatabaseController::getEventById($id_event)[0];

        // Retourne la vue avec les données nécessaires
        return view('admin.action.add_game_event')->with(['sport_events' => $sport_events, 
                                                    'player_present' => $player_present,
                                                    'event_date' => $event_date]);
    }

    /**
     * Ajoute un événement pour un match spécifique.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  int  $id_event
     * @return \Illuminate\Http\RedirectResponse
     */
    public function addGameEvent(Request $request, $id_event) {   

        // Valide les données de la requête
        $validator = Validator::make($request->all(), [
            'id_sport_event' => 'required',
            'player' => '',
            'event_time' => 'required|date',
        ]);

        // En cas d'échec de validation, redirige en arrière avec les données d'entrée et un message d'erreur
        if ($validator->fails()) {
            return redirect()->back()->withInput()->with('error', 'Une erreur est survenue lors du contrôle des données.');
        }

        // Insère l'événement du match dans la base de données
        DB::table('faitmatch')->insert([
            'heure' => $request->event_time,
            'idfaitsport' => $request['id_sport_event'],
            'idpersonne' => $request['player'],
            'idmatch' => $id_event,
        ]);

        // Redirige vers la page des événements sportifs avec un message de succès
        return redirect('/a/game/events')->with('success', 'L\'événement du match a été ajouté avec succès!');
    }

    /**
     * Sélectionne les statistiques intéressantes en fonction du nom du sport.
     *
     * @param  string  $sport_name
     * @return array
     */
    public static function selectInterestingStats($sport_name) {
        switch($sport_name) {
            case "Football": return ["'Carton Jaune'", "'Carton Rouge'", "'But'"]; break;
            case "Volley": return ["'Carton Jaune'", "'Carton Rouge'"]; break;
            default: return "";
        }
    }
}
