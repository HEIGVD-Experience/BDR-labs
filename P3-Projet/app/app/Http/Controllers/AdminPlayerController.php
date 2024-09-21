<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Session;

class AdminPlayerController extends Controller
{
    /**
     * Affiche le formulaire d'ajout d'un joueur.
     *
     * @return \Illuminate\View\View
     */
    public function showAddPlayerFrom()
    {
        return view('admin.action.add_player');
    }

    /**
     * Affiche le formulaire de mise à jour d'un joueur.
     *
     * @param  int  $id
     * @return \Illuminate\View\View
     */
    public function showUpdatePlayerForm($id)
    {
        // Vérifie si le joueur existe
        $player = $this->doesPlayerExist($id);

        // Si le joueur n'est pas trouvé, redirige en arrière avec un message d'erreur
        if (!$player) {
            return redirect()->back()->with('error', 'Joueur non trouvé.');
        }

        // Retourne la vue avec les données du joueur
        return view('admin.action.update_player', compact('player'));
    }

    /**
     * Insère un joueur dans l'équipe actuelle.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\RedirectResponse
     */
    public function insertPlayer(Request $request)
    {
        // Valide les données de la requête entrante
        $validatedData = $request->validate([
            'email' => 'required|email',
            'role' => 'required|in:JOU,ENT',
            'position' => 'required|string|max:255',
            'date' => 'required|date',
        ]);

        try {
            // Récupère l'ID de l'équipe depuis la session
            $id_team = Session::get('id_team');

            // Récupère l'ID du joueur par son adresse e-mail
            $player = UserDatabaseController::getUserByEmail($validatedData['email']);

            // Si un joueur est trouvé, récupère son ID
            if(count($player) == 1) {
                $id_player = $player[0]->id;
            }

            // Vérifie si le joueur est déjà dans une équipe
            $isInTeam = count(UserDatabaseController::isPlayerInTeam($id_player));

            // Si le joueur n'est pas dans une équipe, l'ajoute
            if ($isInTeam == 0) {
                DB::insert('
                    INSERT INTO jouepour(idequipe, idpersonne, role, position, datearrivee)
                    VALUES(?, ?, ?, ?, ?)', [$id_team, $id_player, $validatedData['role'], $validatedData['position'], $validatedData['date']]);        

                return redirect()->back()->with('success', 'Le joueur a été ajouté avec succès.');
            } else {
                return redirect()->back()->with('error', 'Ce joueur est déjà dans une équipe.');
            }
        } catch (\Exception $e) {
            // Gère les exceptions ou les erreurs qui peuvent survenir pendant l'insertion
            return redirect()->back()->with('error', 'Une erreur s\'est produite lors de l\'ajout du joueur. Veuillez réessayer.');
        }
    }

    /**
     * Supprime un joueur de l'équipe en mettant à jour la date de départ.
     *
     * @param  int  $id_player
     * @return \Illuminate\Http\RedirectResponse
     */
    public function deletePlayer($id_player)
    {
        try {
            // Met à jour la date de départ du joueur
            DB::insert('
                UPDATE jouepour SET datedepart = ?
                WHERE idpersonne = ?', [now(), $id_player]);   

            return redirect()->back()->with('success', 'La date de départ du joueur a été mise à jour avec succès.');
        } catch (\Exception $e) {
            // En cas d'erreur, affiche la page avec le message d'erreur
            return redirect()->back()->with('error', $e);
        }
    }

    /**
     * Met à jour le rôle et la position d'un joueur.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  int  $id
     * @return \Illuminate\Http\RedirectResponse
     */
    public function updatePlayer(Request $request, $id)
    {
        // Vérifie si le joueur existe
        $player = $this->doesPlayerExist($id);

        // Si le joueur n'est pas trouvé, redirige en arrière avec un message d'erreur
        if (!$player) {
            return redirect()->back()->with('error', 'Joueur non trouvé.');
        }

        // Met à jour le rôle et la position du joueur
        DB::update('UPDATE jouepour SET role = ?, position = ? WHERE id = ?', [$request->role, $request->position, $id]);

        // Redirige vers la page précédente avec un message de succès
        return redirect()->back()->with('success', 'Les informations du joueur ont été mises à jour avec succès.');
    }   

    /**
     * Obtient l'ID du joueur par son adresse e-mail.
     *
     * @param  string  $email
     * @return array
     */
    private function getJoueurIdByEmail($email)
    {
        return DB::select('
            SELECT id
            FROM personne
            WHERE email = ?', [$email]);
    }

    /**
     * Vérifie si le joueur existe en récupérant ses informations.
     *
     * @param  int  $id
     * @return array
     */
    public function doesPlayerExist($id) {
        return DB::select('
            SELECT *
            FROM personne
            INNER JOIN jouepour ON jouepour.idpersonne = personne.id
            WHERE personne.id = ?', [$id])[0];
    }
}