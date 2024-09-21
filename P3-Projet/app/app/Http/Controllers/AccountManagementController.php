<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Session;

class AccountManagementController extends Controller
{
    /**
     * Affiche le formulaire de création de compte.
     *
     * @return \Illuminate\View\View
     */
    public function createAccount()
    {
        return view('account.create_profile');
    }

    /**
     * Traite la création de compte.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\RedirectResponse
     */
    public function openAccount(Request $request)
    {
        try {
            // Valider les données de la requête entrante
            $validated_data = $request->validate([
                'last_name' => 'required|string|max:255',
                'first_name' => 'required|string|max:255',
                'birthdate' => 'required|date|before_or_equal:today',
                'email' => 'required|email|unique:personne,email',
            ]);

            // Insérer le nouvel utilisateur
            $user_id = UserDatabaseController::insertNewUserAndGetId($validated_data);

            return redirect()->back()->with('success', 'Votre compte a été créé avec succès. Vous pouvez maintenant vous connecter.');

        } catch (\Exception $e) {
            return redirect()->back()->with('error', 'Une erreur s\'est produite lors de la création du compte. Veuillez réessayer.');
        }
    }

    /**
     * Affiche le formulaire de modification du compte.
     *
     * @param  int  $id_user
     * @return \Illuminate\View\View
     */
    public function editAccountForm($id_user)
    {
        // Récupérer les informations du profil
        $profile = UserDatabaseController::getUserById($id_user);

        if (!$profile) {
            // Gérer le cas où le profil n'est pas trouvé
            return redirect()->back()->with('error', 'Profil non trouvé.');
        }

        // Récupère le premier tuple du tableau user
        $profile = $profile[0];

        return view('account.update_profile', compact('profile'));
    }

    /**
     * Traite la mise à jour du compte.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  int  $id_user
     * @return \Illuminate\Http\RedirectResponse
     */
    public function updateAccount(Request $request, $id_user)
    {
        // Valider les données de la requête entrante
        $validated_data = $request->validate([
            'last_name' => 'required|string|max:255',
            'first_name' => 'required|string|max:255',
            'birthdate' => 'required|date|before_or_equal:today',
            'email' => 'required|email|max:255|unique:personne,email,' . $id_user,
        ]);

        // Contrôler que l'utilisateur qui tente d'être modifié est bien l'utilisateur authentifié
        if ($id_user != Session::get('id_user')) {
            return redirect()->back()->with('error', 'Vous ne pouvez modifier que votre propre profil.');
        }

        try {
            // Mettre à jour le profil
            UserDatabaseController::updateUser($validated_data, $id_user);

        } catch (\Exception $e) {
            return redirect()->back()->with('error', 'Une erreur est survenue lors de la mise à jour de votre profile.');
        }

        // Récupérer les données basiques de l'utilisateur
        $user_datas = MainAdminController::getBasicUserData($id_user);

        // Mettre à jour les variables de session
        MainAdminController::setUserSessionData($user_datas);

        if (Session::get('role') == "ENT") {
            return redirect()->route('showAdminHomePage')->with('success', 'Votre profil a été mis à jour avec succès.');
        } elseif (Session::get('role') == "JOU" || Session::has('role') == null) {
            return redirect()->route('player.home')->with('success', 'Votre profil a été mis à jour avec succès.');
        }
    }
}
