@extends('layouts.app')
@section('content')

<div class="container">
    <div class="row justify-content-center mt-3">
        <div class="col-md-8">
            <div class="card">
                <div class="card-header">{{ __('Détails de l\'événement') }}</div>

                <div class="card-body">
                    <h4 class="mb-3">
                        @if($event->type_evenement == 'ENT')
                            Entraînement
                        @elseif($event->type_evenement == 'MAT')
                            Match
                        @elseif($event->type_evenement == 'SOR')
                            Sortie
                        @else
                            Autre
                        @endif
                    </h4>
                    @if($event->type_evenement == 'MAT')
                        <p>Numéro de match : {{ $event->numero_match }}</p>
                        <p>Adversaire : {{ $event->exterieur }}</p>
                        <br>
                    @endif
                    @if(\Carbon\Carbon::parse($event->heuredebut)->format('d/m/Y') == \Carbon\Carbon::parse($event->heurefin)->format('d/m/Y'))
                        <p>Date : {{\Carbon\Carbon::parse($event->heuredebut)->format('d/m/Y')}}</p>
                    @else
                        <p>Date : {{\Carbon\Carbon::parse($event->heuredebut)->format('d/m/Y')}} au {{\Carbon\Carbon::parse($event->heurefin)->format('d/m/Y')}}</p>
                    @endif
                    <p>Heure : {{\Carbon\Carbon::parse($event->heuredebut)->format('H:m')}} à {{\Carbon\Carbon::parse($event->heurefin)->format('H:m')}}</p>

                    <p>Adresse : {{ $event->adresse }}</p>

                    <h4>Liste des joueurs invités</h4>
                    <table class="table table-bordered">
                        <thead>
                            <tr>
                                <th>Nom</th>
                                <th>Prénom</th>
                                <th class="text-center">Statut</th>
                                <th class="text-center">Retirer</th>
                            </tr>
                        </thead>
                        <tbody>
                            @foreach($presentPlayers as $player)
                                <tr>
                                    <td>{{ $player->nom }}</td>
                                    <td>{{ $player->prenom }}</td>
                                    <td class="text-center">
                                        @if($player->type == 'A')
                                            Absent
                                        @elseif($player->type == 'P')
                                            Présent
                                        @elseif($player->type == 'X')
                                            Pas répondu
                                        @else
                                            Autre
                                        @endif
                                    </td>                                    
                                    <td class="text-center"><a href="/a/remove/player/{{$player->id}}/event/{{$event->id}}"><i class="fa-solid fa-trash"></i></a></td>
                                </tr>
                            @endforeach
                        </tbody>
                    </table>
                    @if(isset($game_events) && !empty($game_events))
                    <h4>Evenements du matchs</h4>
                    <table class="table table-bordered">
                        <thead>
                            <tr>
                                <th>Joueur</th>
                                <th>Evenement</th>
                                <th>Heure</th>
                            </tr>
                        </thead>
                        <tbody>
                            @foreach($game_events as $event)
                                <tr>
                                    <td>{{ $event->prenom }} {{ $event->nom }}</td>
                                    <td>{{ $event->event }}</td>
                                    <td>{{ $event->heure }}</td>
                                </tr>
                            @endforeach
                        </tbody>
                    </table>
                    @endif
                </div>
                <div class="form-group row mb-3">
                    <div class="col-md-12 text-center">
                        <a href="/a/events" class="btn btn-primary">
                            {{ __('Retour') }}
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

@endsection
