<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class UserDatabaseController extends Controller
{
    /**
     * Permet de récupérer un utilisateur avec son ID.
     */
    public static function getUserById($id) {
        return DB::select('
            SELECT * FROM personne 
            WHERE id = ?', [$id]);
    }

    /**
     * Permet de récupérer un utilisateur avec son email.
     */
    public static function getUserByEmail($email) {
        return DB::select('
            SELECT * FROM personne 
            WHERE email = ?', [$email]);
    }

    /**
     * Insère un nouveau utilisateur dans la base de données et retourne son ID si tout s'est bien passé.
     */
    public static function insertNewUserAndGetId($validated_data) {

        return DB::table('personne')->insertGetId([
            'nom' => $validated_data['last_name'],
            'prenom' => $validated_data['first_name'],
            'email' => $validated_data['email'],
            'datedenaissance' => $validated_data['birthdate'],
        ]);
    }

    /**
     * Mets à jour le profile de l'utilisateur choisi.
     */
    public static function updateUser($validated_data, $id_user) {
        DB::update('
            UPDATE personne SET nom = ?, prenom = ?, datedenaissance = ?, email = ? WHERE id = ?', 
            [$validated_data['last_name'], $validated_data['first_name'], 
            $validated_data['birthdate'], $validated_data['email'], $id_user]);
    }

    /**
     * Récupère les détails de la table jouepour en fonction de l'id de la personne.
     */
    public static function getPlayForDetailsForUser($id_user) {
        return DB::select('
            SELECT * FROM jouepour 
            WHERE idpersonne = ? 
            AND datedepart IS NULL', [$id_user]);
    }

    /**
     * Récupère tous les utilisateurs actuellement dans une équipe (joueurs et entraineurs).
     */
    public static function getActualTeamUser($id_team) {
        return DB::select('
        SELECT * FROM jouepour
        INNER JOIN personne ON jouepour.idpersonne = personne.id
        WHERE jouepour.idequipe = ?
        AND datedepart IS NULL
        AND datearrivee < ?
        ORDER BY jouepour.role, jouepour.position, personne.nom', [$id_team, now()]);
    }

    /**
     * Récupère tous les joueurs actuellement dans une équipe.
     */
    public static function getActualTeamPlayer($id_team) {
        return UserDatabaseController::getTeamPlayerAtDate($id_team, now());
    }

    /**
     * Récupère tous les joueurs a une date donnée dans une équipe.
     */
    public static function getTeamPlayerAtDate($id_team, $date) {
        return DB::select('
        SELECT * FROM jouepour
        INNER JOIN personne ON jouepour.idpersonne = personne.id
        WHERE jouepour.idequipe = ?
        AND datedepart IS NULL
        AND datearrivee < ?
        AND jouepour.role = ?
        ORDER BY jouepour.role, jouepour.position, personne.nom', [$id_team, $date, 'JOU']);
    }

    /**
     * Contrôle qu'un joueur est déjé dans une équipe.
     */
    public static function isPlayerInTeam($id_player)
    {
        return DB::select('
        SELECT idpersonne FROM jouepour
        WHERE idpersonne = ? 
        AND datedepart IS NULL', [$id_player]);
    }
}
