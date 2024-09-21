<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class TeamDatabaseController extends Controller
{
    /**
     * Retourne les détails d'une équipe grace à son ID.
     */
    public static function getTeamWithId($id_team) {
        return DB::select('
            SELECT * FROM equipe 
            WHERE id = ?', [$id_team]);
    } 

    /**
     * Retourne les détails d'un club grave à son ID.
     */
    public static function getClubWithId($id_club) {
        return DB::select('
            SELECT * FROM club 
            WHERE id = ?', [$id_club]);
    }

    /**
     * Retourne les détails de toute les équipes exceptés la notre.
     */
    public static function getAllDifferentTeams($id_team) {
        return DB::select('
        SELECT * FROM equipe 
        WHERE id <> ?', [$id_team]);
    }
}
