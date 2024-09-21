<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Mail\NewProject;
use App\Mail\Questions;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Session;

class MainAdminController extends Controller
{
    /**
     * Affiche la page d'accueil de l'administrateur principal.
     *
     * @return \Illuminate\View\View|\Illuminate\Http\RedirectResponse
     */
    public function showAdminHomePage()
    {
        if (LoginController::checkTrainerRole()) {
            // Récupère les données pour afficher sur la page d'accueil de l'administrateur
            $data = [
                'nb_players' => count(UserDatabaseController::getActualTeamPlayer(Session::get('id_team'))),
                'nb_events' => count(EventDatabaseController::getEventsForTeam(Session::get('id_team'))),
                'presence_percentage' => $this->getEventsPresencePercentage(Session::get('id_team')),
                'events_without_response' => count(EventDatabaseController::getEventsWithoutAnswer(Session::get('id_team'))),
                'last_four_events' => EventDatabaseController::getNextFourEvents(Session::get('id_team')),
            ];
            
            return view('admin.home')->with('data', $data);
        } else {
            return redirect()->back()->with('error', 'Vous n\'avez pas accès à cette ressource. Merci de réessayer!');
        }
    }

    /**
     * Affiche la page des joueurs pour l'administrateur principal.
     *
     * @return \Illuminate\View\View|\Illuminate\Http\RedirectResponse
     */
    public function showPlayersPage()
    {
        if(LoginController::checkTrainerRole()) {
            // Récupère les données des joueurs pour afficher sur la page des joueurs
            $data = UserDatabaseController::getActualTeamUser(Session::get('id_team'));
            return view('admin.players')->with('data', $data);
        }

        return redirect()->back()->with('error', 'Vous n\'avez pas accès à cette ressource. Merci de réessayer!');
    }

    /**
     * Affiche la page des événements pour l'administrateur principal.
     *
     * @return \Illuminate\View\View|\Illuminate\Http\RedirectResponse
     */
    public function showEventsPage()
    {
        if(LoginController::checkTrainerRole()) {
            // Récupère les données des événements pour afficher sur la page des événements
            $data = EventDatabaseController::getEventsForTeam(Session::get('id_team'));
            return view('admin.events')->with('data', $data);
        }
        return redirect()->back()->with('error', 'Vous n\'avez pas accès à cette ressource. Merci de réessayer!');
    }

    /**
     * Récupère les données utilisateur de base par ID d'utilisateur.
     *
     * @param  int  $id_user
     * @return array
     */
    public static function getBasicUserData($id_user) {

        // Récupérer les informations de l'utilisateur
        $userData = UserDatabaseController::getUserById($id_user);
        $userData = count($userData) > 0 ? $userData[0] : null;

        // Récupérer les informations de l'équipe de l'utilisateur
        $userTeam = null;
        $teamData = null;
        $clubData = null;

        if ($userData) {
            $userTeam = UserDatabaseController::getPlayForDetailsForUser($userData->id);
            $userTeam = count($userTeam) > 0 ? $userTeam[0] : null;

            if ($userTeam) {
                $teamData = TeamDatabaseController::getTeamWithId($userTeam->idequipe)[0];
                $clubData = TeamDatabaseController::getClubWithId($teamData->idclub)[0];
            }   
        }

        // Aplatir toutes les valeurs au même niveau
        $userData = [
            'id' => $userData->id ?? null,
            'last_name' => $userData->nom ?? null,
            'first_name' => $userData->prenom ?? null,
            'role' => $userTeam->role ?? null,
            'id_team' => $teamData->id ?? null,
            'team_name' => $teamData->nom ?? null,
            'club_name' => $clubData->nom ?? null,
            'club_logo' => $clubData->blason ?? 'img/club/default_team.png',
            'sport' => $clubData->nomsport ?? null,
        ];

        return $userData;
    }

    /**
     * Définit les données de session utilisateur.
     *
     * @param  array  $user_data
     * @return void
     */
    public static function setUserSessionData($user_data)
    {
        Session::put([
            'id_user' => $user_data["id"],
            'first_name' => $user_data["first_name"],
            'last_name' => $user_data["last_name"],
            'role' => $user_data["role"],
            'id_team' => $user_data["id_team"],
            'team_name' => $user_data["team_name"],
            'club_name' => $user_data["club_name"],
            'sport' => $user_data["sport"],
        ]);
    }

    /**
     * Récupère le pourcentage de présence aux événements de l'équipe.
     *
     * @param  int  $id_team
     * @return int
     */
    private function getEventsPresencePercentage($id_team) {
        $nb_status_team_events = count(EventDatabaseController::getAllStatusForTeamEvents($id_team));
        $nb_prensent_status_team_event = count(EventDatabaseController::getAllPresentStatusForTeamEvents($id_team));

        if($nb_status_team_events > 0)
            return round(($nb_prensent_status_team_event / $nb_status_team_events) * 100);
        else
            return 0;
    }
}
