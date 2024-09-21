<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\MainAdminController;
use App\Http\Controllers\MainPlayerController;
use App\Http\Controllers\AccountManagementController;
use App\Http\Controllers\AdminPlayerController;
use App\Http\Controllers\AdminEventController;
use App\Http\Controllers\AdminGameEventController;
use App\Http\Controllers\LoginController;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/

Route::get('/', [LoginController::class, 'showLoginPage'])->name('showLoginPage');
Route::post('/checklogin', [LoginController::class, 'tryLogin'])->name('tryLogin');

Route::get('/a/home', [MainAdminController::class, 'showAdminHomePage'])->name('showAdminHomePage');
Route::get('/a/players', [MainAdminController::class, 'showPlayersPage'])->name('showPlayersPage');
Route::get('/a/events', [MainAdminController::class, 'showEventsPage'])->name('showEventsPage');

Route::get('/p/home', [MainPlayerController::class, 'getPlayerHomePage'])->name('player.home');
Route::get('/p/update/event/{idevent}', [MainPlayerController::class, 'getPlayerUpdatePresenceForm'])->name('player.updatePresenceForm');
Route::put('/p/update/event/{idevent}', [MainPlayerController::class, 'updatePlayerPresence'])->name('player.updatePresence');

Route::get('/a/add/player', [AdminPlayerController::class, 'showAddPlayerFrom'])->name('showAddPlayerFrom');
Route::post('/a/add/player', [AdminPlayerController::class, 'insertPlayer'])->name('insertPlayer');
Route::get('/a/delete/player/{idjoueur}', [AdminPlayerController::class, 'deletePlayer'])->name('deletePlayer');
Route::get('/a/edit/player/{id}', [AdminPlayerController::class, 'showUpdatePlayerForm'])->name('showUpdatePlayerForm');
Route::post('/a/edit/player/{id}', [AdminPlayerController::class, 'updatePlayer'])->name('updatePlayer');

Route::get('/a/add/event', [AdminEventController::class, 'showAddEventForm'])->name('showAddEventForm');
Route::post('/a/add/event', [AdminEventController::class, 'insertNewEvent'])->name('insertNewEvent');
Route::get('/a/event/{idevenement}', [AdminEventController::class, 'showEventDetails'])->name('showEventDetails');
Route::get('/a/delete/event/{idevenement}', [AdminEventController::class, 'deleteEvent'])->name('deleteEvent');
Route::get('/a/update/event/{idevenement}', [AdminEventController::class, 'showEventUpdateForm'])->name('showAddEventUpdateForm');
Route::post('/a/update/event/{idevenement}', [AdminEventController::class, 'updateEvent'])->name('updateEvent');
Route::get('/a/remove/player/{idplayer}/event/{idevenement}', [AdminEventController::class, 'removePlayerFromEvent'])->name('removePlayerFromEvent');

Route::get('/a/game/events', [AdminGameEventController::class, 'showGameEventsPage'])->name('showGameEventsPage');
Route::get('/a/add/game/{idevenement}/event', [AdminGameEventController::class, 'showGameEventAddFrom'])->name('showGameEventAddFrom');
Route::post('/a/add/game/{idevenement}/event', [AdminGameEventController::class, 'addGameEvent'])->name('addGameEvent');

Route::get('/create/account', [AccountManagementController::class, 'createAccount'])->name('createAccount');
Route::post('/create/account', [AccountManagementController::class, 'openAccount'])->name('openAccount');
Route::get('/edit/account/{idUser}', [AccountManagementController::class, 'editAccountForm'])->name('editAccountForm');
Route::post('/edit/account/{idUser}', [AccountManagementController::class, 'updateAccount'])->name('updateAccount');