@extends('layouts.app')
@section('content')

<div class="container">
    <div class="row justify-content-center mt-3">
        <div class="col-md-8">
            <div class="card">
                <div class="card-header">{{ __('Ajouter un événement de match') }}</div>

                <div class="card-body">
                    <form method="POST" action="">
                        @csrf
                    
                        <div class="form-group">
                            <label for="id_sport_event">Type d'événement*</label>
                            <select id="id_sport_event" class="form-control" name="id_sport_event" required>
                                <option selected disabled>Sélectionner ...</option>
                                @foreach($sport_events as $sport_event)
                                    <option value="{{ $sport_event->id }}" {{ old('id_sport_event') == $sport_event->id ? 'selected' : '' }}>{{ $sport_event->nom }}</option>
                                @endforeach
                            </select>
                        </div>

                        <div class="form-group">
                            <label for="player">Joueur concerné*</label>
                            <select id="player" class="form-control" name="player" required>
                                <option selected disabled>Sélectionner ...</option>
                                @foreach($player_present as $player)
                                    <option value="{{ $player->id }}" {{ old('player') == $player->id ? 'selected' : '' }}>{{ $player->prenom." ".$player->nom }}</option>
                                @endforeach
                            </select>
                        </div>
                    
                        <div class="form-group">
                            <label for="event_time">Date et heure de l'événement*</label>
                            <input type="datetime-local" id="event_time" class="form-control" name="event_time" value="{{ $event_date->heuredebut }}" required>
                        </div>
                    
                        <button type="submit" class="btn btn-primary">Ajouter l'événement</button>
                        <a href="{{ url()->previous() }}" class="btn btn-primary">
                            {{ __('Retour') }}
                        </a>
                    </form>
                    
                    
                </div>
            </div>
        </div>
    </div>
</div>

@endsection
