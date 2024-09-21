<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Session;

class LoginController extends Controller
{
    /**
     * Affiche la page de connexion et supprime des variables de session spécifiques.
     *
     * @return \Illuminate\View\View
     */
    public function showLoginPage()
    {
        // Efface des variables de session spécifiques
        Session::forget(['first_name', 'last_name', 'id_user', 'role', 'id_team', 'team_name', 'club_names']);
        return view('login');
    }

    /**
     * Tente de connecter l'utilisateur et redirige en fonction du rôle.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\RedirectResponse
     */
    public function tryLogin(Request $request)
    {
        try {
            // Vérifie la connexion à la base de données
            DB::connection()->getPdo();

            try {
                // Récupère les données de l'utilisateur par e-mail
                $user_data = UserDatabaseController::getUserByEmail($request->email);

                // Si un utilisateur est trouvé, configure les données de session et redirige
                if(count($user_data) == 1) {
                    $user_data = $user_data[0];
                    $basic_user_data = MainAdminController::getBasicUserData($user_data->id);
                    LoginController::setUserSessionData($basic_user_data);
                    return $this->redirectToCorrectHome($basic_user_data['role']);
                } else {
                    // Redirige avec un message d'erreur si le compte n'existe pas
                    return redirect()->route('showLoginPage')->with('error', 'Ce compte n\'existe pas, merci de réessayer.');
                }
            } catch (\Exception $e) {
                // Redirige avec un message d'erreur en cas d'erreur lors de la connexion au compte
                return redirect()->route('showLoginPage')->with('error', 'Une erreur est survenue lors de la tentative de connexion au compte.');
            }
        } catch (\Exception $e) {
            // En cas d'erreur d'accès à la base de données, redirige avec un message d'erreur
            return redirect()->route('showLoginPage')->with('error', 'La base de donnée n\'est pas accessible, merci de réessayer.');
        }
    }

    /**
     * Configure les données de session utilisateur.
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
            'club_logo' => $user_data["club_logo"],
            'sport' => $user_data["sport"],
        ]);
    }

    /**
     * Redirige vers la page d'accueil appropriée en fonction du rôle utilisateur.
     *
     * @param  string  $user_role
     * @return \Illuminate\Http\RedirectResponse
     */
    private function redirectToCorrectHome($user_role)
    {
        if ($user_role == "ENT")
            return redirect()->route('showAdminHomePage');
        if ($user_role == "JOU" || $user_role == null)
            return redirect()->route('player.home');
    }

    /**
     * Vérifie le rôle d'entraîneur.
     *
     * @return bool
     */
    public static function checkTrainerRole()
    {
        return LoginController::checkRole('ENT');
    }

    /**
     * Vérifie le rôle du joueur.
     *
     * @return bool
     */
    public static function checkPlayerRole()
    {
        return LoginController::checkRole('JOU');
    }

    /**
     * Vérifie le rôle spécifié.
     *
     * @param  string  $role
     * @return bool
     */
    public static function checkRole($role)
    {
        return Session::has('role') && Session::get('role') == $role;
    }
}
