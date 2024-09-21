<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Session;
use Illuminate\Support\Facades\Validator;

class AdminEventController extends Controller
{
    /**
     * Affiche le formulaire d'ajout d'un nouvel événement.
     *
     * @return \Illuminate\View\View
     */
    public function showAddEventForm()
    {
        $teams = TeamDatabaseController::getAllDifferentTeams(Session::get('id_team'));
        return view('admin.action.add_event')->with('teams', $teams);
    }

    /**
     * Affiche le formulaire de mise à jour d'un événement.
     *
     * @param  int  $id
     * @return \Illuminate\View\View
     */
    public function showEventUpdateForm($id)
    {
        $event = EventDatabaseController::getEventById($id)[0];
        $teams = TeamDatabaseController::getAllDifferentTeams(Session::get('id_team'));

        if (!$event) {
            return redirect()->back()->with('error', 'Événement non trouvé.');
        }

        return view('admin.action.update_event')->with(['event' => $event, 'teams' => $teams]);
    }

    /**
     * Insère un nouvel événement dans la base de données.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\RedirectResponse
     */
    public function insertNewEvent(Request $request)
    {
        // Valider les données de la requête entrante
        $validated_data = Validator::make($request->all(), [
            'type' => 'required|in:MAT,ENT,SOR',
            'date_debut' => 'required|date',
            'date_fin' => 'required|date|after:date_debut',
            'adresse' => 'required|string',
            'numero_match' => 'nullable|required_if:type,MAT|string',
            'equipe_adverse' => 'nullable|required_if:type,MAT',
            'invite_equipe' => 'boolean',
            'invites_exterieurs' => 'nullable|required_if:invite_equipe,0|string',
        ]);

        // Ajoutez une règle personnalisée pour votre condition
        $validated_data->sometimes('invite_equipe', 'required', function ($input) {
            return $input->invite_equipe === null && $input->invites_exterieurs === null;
        });

        // Vérifiez si la validation a échoué
        if ($validated_data->fails()) {
            return back()->withErrors($validated_data)->withInput()->with('error', 'Une erreur est survenue lors de la validation.');
        }

        $validated_data = $validated_data->validated();

        // Insérer un nouvel événement dans la table "evenement"
        $newEventId = DB::table('evenement')->insertGetId([
            'type' => $validated_data['type'],
            'heuredebut' => $validated_data['date_debut'],
            'heurefin' => $validated_data['date_fin'],
            'adresse' => $validated_data['adresse'],
            'nomsport' => Session::get('sport'),
        ]);

        // Si c'est un match insère les données dans la table match
        if ($validated_data['type'] == "MAT") {
            DB::table('match')->insert([
                'idevenement' => $newEventId,
                'nummatch' => $validated_data['numero_match'],
                'idequipedomicile' => Session::get('id_team'),
                'idequipeadversaire' => $validated_data['equipe_adverse'],
                'nomsport' => Session::get('sport'),
            ]);
        }

        $errorMessages = [];
        $team_player = [];

        // Récupérer tous les détails des joueurs de l'équipe
        if ($validated_data['invite_equipe'] == 1) {
            $team_player = UserDatabaseController::getTeamPlayerAtDate(Session::get('id_team'), $validated_data['date_debut']);
        }

        // Récupérer tous les détails des joueurs invités
        if ($validated_data['invites_exterieurs']) {
            $emailsArray = explode(', ', $validated_data['invites_exterieurs']);

            // Boucler sur chaque e-mail
            foreach ($emailsArray as $email) {
                $user = UserDatabaseController::getUserByEmail($email);
                if ($user[0]) {
                    array_push($team_player, $user[0]);
                } else {
                    array_push($errorMessages, "Le compte suivant " . $email . " n'a pas été trouvé.");
                }
            }
        }

        // Contrôler que toutes les personnes invitées sont disponibles pour l'événement
        if (isset($team_player) && count($team_player) > 0) {
            $free_player = [];

            foreach ($team_player as $player) {
                $is_free = DB::select('
                    SELECT * 
                    FROM statut
                    INNER JOIN evenement ON statut.idevenement = evenement.id
                    WHERE ? BETWEEN evenement.heuredebut AND evenement.heurefin
                    OR ? BETWEEN evenement.heuredebut AND evenement.heurefin
                ', [$validated_data['date_debut'], $request['date_fin']]);

                if (!$is_free) {
                    array_push($free_player, $player);
                } else {
                    array_push($errorMessages, "Le joueur suivant " . $player->email . " n'est pas disponible pendant cette horaire.");
                }
            }
        }

        // Insérer les joueurs libres dans la table de statut
        if (isset($free_player) && count($free_player) > 0) {
            foreach ($free_player as $player) {
                DB::table('statut')->insert([
                    'idevenement' => $newEventId,
                    'idpersonne' => $player->id,
                    'type' => "X",
                ]);
            }
        }

        if ($errorMessages) {
            return back()->with('error', implode("\n", $errorMessages));
        } else {
            return back()->with('success', "L'événement a bien été créé et les joueurs ont bien été invités.");
        }
    }

    /**
     * Met à jour un événement dans la base de données.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  int  $id_event
     * @return \Illuminate\Http\RedirectResponse
     */
    public function updateEvent(Request $request, $id_event)
    {
        // Valider les données de la requête entrante
        $validated_data = Validator::make($request->all(), [
            'type' => 'required|in:MAT,ENT,SOR',
            'date_debut' => 'required|date',
            'date_fin' => 'required|date|after:date_debut',
            'adresse' => 'required|string',
            'numero_match' => 'nullable|required_if:type,MAT|string',
            'equipe_adverse' => 'nullable|required_if:type,MAT',
        ]);

        // Vérifiez si la validation a échoué
        if ($validated_data->fails()) {
            return back()->withErrors($validated_data)->withInput()->with('error', 'Une erreur est survenue lors de la validation.');
        }

        $validated_data = $validated_data->validated();

        // Récupérer l'événement à partir de l'ID
        $event = EventDatabaseController::getEventById($id_event)[0];

        if (!$event) {
            return redirect()->back()->with('error', 'Événement non trouvé.');
        }

        // Si l'événement était autre qu'un match et qu'il l'est maintenant, on doit y insérer un tuple
        if ($event->type != 'MAT' && $validated_data['type'] == 'MAT') {
            DB::table('match')->insert([
                'idevenement' => $id_event,
                'nummatch' => $validated_data['numero_match'],
                'idequipedomicile' => Session::get('id_team'),
                'idequipeadversaire' => $validated_data['equipe_adverse'],
                'nomsport' => Session::get('sport'),
            ]);
        }

        // Si le nouvel événement est autre qu'un match mais qu'il l'était avant, on doit supprimer les données le concernant
        if ($event->type == 'MAT' && $validated_data['type'] != 'MAT') {
            DB::statement('DELETE FROM match WHERE idevenement = ?', [$id_event]);
            DB::statement('DELETE FROM faitmatch WHERE idmatch = ?', [$id_event]);
        }

        // Mettre à jour le rôle et la position
        DB::update('UPDATE evenement SET type = ?, heuredebut = ?, heurefin = ?, adresse = ? WHERE id = ?', [
            $validated_data['type'],
            $validated_data['date_debut'],
            $validated_data['date_fin'],
            $validated_data['adresse'],
            $id_event
        ]);

        // Si c'est un match, mettre à jour les données du match
        if ($validated_data['type'] == 'MAT') {
            DB::update('UPDATE match SET nummatch = ?, idequipeadversaire = ? WHERE idevenement = ?', [
                $validated_data['numero_match'],
                $validated_data['equipe_adverse'],
                $id_event
            ]);
        }

        return redirect()->back()->with('success', 'Les informations de l\'événement ont été mises à jour avec succès.');
    }

    /**
     * Supprime un événement de la base de données.
     *
     * @param  int  $id_evenement
     * @return \Illuminate\Http\RedirectResponse
     */
    public function deleteEvent($id_evenement)
    {
        $event = EventDatabaseController::getEventById($id_evenement);

        if (!$event) {
            return redirect()->back()->with('error', 'Événement non trouvé.');
        }

        $event = $event[0];

        // Supprimer les statuts liés à l'événement
        DB::statement('DELETE FROM statut WHERE idevenement = ?', [$id_evenement]);

        // Si c'est un match, supprimer les données du match et de faitmatch
        if ($event->type == 'MAT') {
            DB::statement('DELETE FROM match WHERE idevenement = ?', [$id_evenement]);
            DB::statement('DELETE FROM faitmatch WHERE idmatch = ?', [$id_evenement]);
        }

        // Supprimer l'événement
        DB::statement('DELETE FROM evenement WHERE id = ?', [$id_evenement]);

        return redirect()->back()->with('success', 'L\'événement a été supprimé!');
    }

    /**
     * Retire un joueur d'un événement.
     *
     * @param  int  $id_player
     * @param  int  $id_event
     * @return \Illuminate\Http\RedirectResponse
     */
    public function removePlayerFromEvent($id_player, $id_event)
    {
        DB::statement('DELETE FROM statut WHERE idevenement = ? AND idpersonne = ?', [$id_event, $id_player]);
        return redirect()->back()->with('success', 'Le joueur a été retiré de l\'événement.');
    }

    /**
     * Affiche les détails d'un événement.
     *
     * @param  int  $id_event
     * @return \Illuminate\View\View
     */
    public function showEventDetails($id_event)
    {
        $eventDetails = DB::select('
        SELECT  evenement.id, 
                evenement.type AS type_evenement, 
                evenement.heuredebut,
                evenement.heurefin,
                evenement.adresse,
                equipe_exterieur.nom AS exterieur,
                match.nummatch AS numero_match
        FROM evenement
            LEFT JOIN match ON evenement.id = match.idevenement
            LEFT JOIN equipe AS equipe_exterieur ON match.idequipeadversaire = equipe_exterieur.id
        WHERE evenement.id = ?
        ORDER BY heuredebut DESC', [$id_event])[0];

        $invitedPlayers = DB::select('
        SELECT  personne.id,
                personne.nom,
                personne.prenom,
                statut.type
        FROM evenement
            INNER JOIN statut ON evenement.id = statut.idevenement
            INNER JOIN personne ON statut.idpersonne = personne.id
        WHERE evenement.id = ?
        ORDER BY statut.type, personne.nom', [$id_event]);

        $game_events = [];

        if($eventDetails->type_evenement == 'MAT') {
            $game_events = DB::select('
            SELECT  faitmatch.heure,
                    faitsport.nom AS event,
                    personne.prenom,
                    personne.nom
            FROM faitmatch
                INNER JOIN personne ON faitmatch.idpersonne = personne.id
                INNER JOIN faitsport ON faitmatch.idfaitsport = faitsport.id
            WHERE idmatch = ?
            ORDER BY faitmatch.heure', [$id_event]);
        }

        return view('admin.event_detail')->with(['event' => $eventDetails, 'presentPlayers' => $invitedPlayers, 'game_events' => $game_events]);
    }
}
