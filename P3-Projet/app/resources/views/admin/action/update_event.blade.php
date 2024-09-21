@extends('layouts.app')
@section('content')

<div class="container">
    <div class="row justify-content-center mt-3">
        <div class="col-md-8">
            <div class="card">
                <div class="card-header">{{ __('Modifier l\'événement') }}</div>

                <div class="card-body">
                    <form method="POST" action="/a/update/event/{{ $event->id }}">
                        @csrf

                        <div class="form-group">
                            <label for="type">Type d'événement*</label>
                            <select id="type" class="form-control" name="type" required>
                                <option disabled>Sélectionner ...</option>
                                <option value="MAT" {{ $event->type == 'MAT' ? 'selected' : '' }}>Match</option>
                                <option value="ENT" {{ $event->type == 'ENT' ? 'selected' : '' }}>Entraînement</option>
                                <option value="SOR" {{ $event->type == 'SOR' ? 'selected' : '' }}>Sortie</option>
                            </select>
                        </div>


                        <div class="form-group">
                            <label for="date_debut">Date et heure de début*</label>
                            <input type="datetime-local" id="date_debut" class="form-control" name="date_debut" required value="{{ $event->heuredebut }}">
                        </div>

                        <div class="form-group">
                            <label for="date_fin">Date et heure de fin*</label>
                            <input type="datetime-local" id="date_fin" class="form-control" name="date_fin" required value="{{ $event->heurefin }}">
                        </div>

                        <div class="form-group">
                            <label for="adresse">Adresse*</label>
                            <input type="text" id="adresse" class="form-control" name="adresse" required value="{{ $event->adresse }}">
                        </div>

                        <div id="div_numero_match" class="form-group" style="display: none;">
                            <label for="numero_match">Numéro de match*</label>
                            <input type="text" id="numero_match" class="form-control" name="numero_match" value="{{ $event->nummatch }}">
                        </div>
                    
                        <div id="div_equipe_adverse" class="form-group" style="display: none;">
                            <label for="equipe_adverse">Équipe adverse*</label>
                            <select id="equipe_adverse" class="form-control" name="equipe_adverse">
                                <option value="" selected disabled>Sélectionner ...</option>
                                @foreach($teams as $team)
                                    <option value="{{ $team->id }}" {{ $team->id == $event->idequipeadversaire ? 'selected' : ''}}>{{ $team->nom }}</option>
                                @endforeach
                            </select>
                        </div>

                        <button type="submit" class="btn btn-primary">Modifier l'événement</button>
                        <a href="/a/events" class="btn btn-primary">
                            {{ __('Retour') }}
                        </a>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- JavaScript pour afficher/cacher le champ motif en fonction de la sélection -->
<script>
    document.addEventListener('DOMContentLoaded', function() {
        var typeEvent = document.getElementById('type');
        var numMatch = document.getElementById('div_numero_match');
        var equipeAdverse = document.getElementById('div_equipe_adverse');

        typeEvent.addEventListener('change', function() {
            numMatch.style.display = this.value === 'MAT' ? '' : 'none';
            equipeAdverse.style.display = this.value === 'MAT' ? '' : 'none';
        });

        // Déclencher le changement initial
        typeEvent.dispatchEvent(new Event('change'));
    });
</script>

@endsection
