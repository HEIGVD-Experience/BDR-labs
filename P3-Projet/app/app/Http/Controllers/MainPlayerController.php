<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Mail\NewProject;
use App\Mail\Questions;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Session;

class MainPlayerController extends Controller
{
    /**
     * Affiche la page d'accueil du joueur principal.
     *
     * @return \Illuminate\View\View|\Illuminate\Http\RedirectResponse
     */
    public function getPlayerHomePage()
    {
        if (!$this->checkTrainerRole()) {
            // Récupère les événements et statistiques du joueur pour afficher sur la page d'accueil
            $events = $this->getAllPlayerEvents(Session::get('id_user'));
            $stats = $this->getPlayerStats(Session::get('id_user'));
            return view('player.home')->with(['events' => $events, 'stats' => $stats]);
        }
        return redirect()->back()->with('error', 'Vous n\'avez pas accès à cette ressource. Merci de réessayer!');
    }

    /**
     * Affiche le formulaire de mise à jour de la présence du joueur à un événement.
     *
     * @param  int  $id_event
     * @return \Illuminate\View\View
     */
    public function getPlayerUpdatePresenceForm($id_event)
    {
        // Récupère le statut de présence du joueur pour l'événement
        $presence = $this->getPresenceEvent(Session::get('id_user'), $id_event)[0];
        return view('player.update_event_presence')->with('presence', $presence);
    }

    /**
     * Met à jour la présence du joueur à un événement.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  int  $eventPresenceId
     * @return \Illuminate\Http\RedirectResponse
     */
    public function updatePlayerPresence(Request $request, $eventPresenceId)
    {
        try {
            // Valider les données de la requête
            $validatedData = $request->validate([
                'presence' => 'required|in:P,A',
                'motif' => 'nullable|required_if:presence,A|string|max:255',
            ]);

            // Mettre à jour le statut en fonction de la présence
            $statusData = [
                'type' => $validatedData['presence'],
                'raison' => $validatedData['presence'] == 'A' ? $validatedData['motif'] : null,
            ];

            //dd($request);

            // Utiliser DB::update pour mettre à jour les champs type et raison de la table statut
            DB::update('UPDATE statut SET type = ?, raison = ? WHERE id = ?', [
                $statusData['type'],
                $statusData['raison'],
                $eventPresenceId
            ]);

            return redirect()->route('player.home')->with('success', 'Statut mis à jour avec succès.');
        } catch(\Exception $e) {
            return redirect()->route('player.home')->with('error', 'Un problème est survenu lors de la modification.');
        }
    }

    /**
     * Récupère les statistiques du joueur.
     *
     * @param  int  $id_user
     * @return array
     */
    public function getPlayerStats($id_user) {
        return DB::select('
        SELECT faitsport.nom AS name, count(faitmatch.idfaitsport) AS value
        FROM faitmatch
        INNER JOIN faitsport ON faitmatch.idfaitsport = faitsport.id
        WHERE faitmatch.idpersonne = ?
        GROUP BY (faitsport.nom)
        ORDER BY faitsport.nom', [$id_user]);
    }

    /**
     * Vérifie si le rôle de l'utilisateur est entraîneur.
     *
     * @return bool
     */
    private function checkTrainerRole() {
        return $this->checkRole('ENT');
    }

    /**
     * Vérifie si le rôle de l'utilisateur est joueur.
     *
     * @return bool
     */
    private function checkPlayerRole() {
        return $this->checkRole('JOU');
    }

    /**
     * Vérifie le rôle de l'utilisateur.
     *
     * @param  string  $role
     * @return bool
     */
    private function checkRole($role)
    {
        return Session::has('role') && Session::get('role') == $role;
    }

    /**
     * Récupère le statut de présence du joueur à un événement.
     *
     * @param  int  $id_user
     * @param  int  $id_event
     * @return array
     */
    public function getPresenceEvent($id_user, $id_event) {
        return DB::select('
        SELECT *
        FROM statut
        WHERE idpersonne = ? AND idevenement = ?
        ', [$id_user, $id_event]);
    }

    /**
     * Récupère tous les événements du joueur.
     *
     * @param  int  $id
     * @return array
     */
    private function getAllPlayerEvents(int $id) {
        return DB::select('
        SELECT  evenement.id, 
                evenement.type AS type_evenement, 
                evenement.heuredebut,
                evenement.heurefin,
                evenement.adresse,
                statut.type AS statut,
                equipe_domicile.nom AS domicile, 
                equipe_exterieur.nom AS exterieur
        FROM statut
        INNER JOIN evenement ON statut.idevenement = evenement.id
        LEFT JOIN match ON statut.idevenement = match.idevenement
        LEFT JOIN equipe AS equipe_domicile ON match.idequipedomicile = equipe_domicile.id
        LEFT JOIN equipe AS equipe_exterieur ON match.idequipeadversaire = equipe_exterieur.id
        WHERE statut.idpersonne = ?
        ORDER BY heuredebut DESC', [$id]);
    }
}
