@extends('layouts.app')
@section('content')

<div class="container">
    <div class="row justify-content-center mt-3">
        <div class="col-md-8">
            <div class="card">
                <div class="card-header">{{ __('Modifier la présence') }}</div>

                <div class="card-body">
                    @if ($errors->any())
                    <div class="alert alert-danger">
                        <ul>
                            @foreach ($errors->all() as $error)
                                <li>{{ $error }}</li>
                            @endforeach
                            </ul>
                        </div>
                    @endif
                    <form method="POST" action="">
                        @csrf
                    
                        <div class="form-group">
                            <label for="type">Type d'événement*</label>
                            <select id="type" class="form-control" name="type" required>
                                <option selected disabled>Sélectionner ...</option>
                                <option value="MAT">Match</option>
                                <option value="ENT">Entraînement</option>
                                <option value="SOR">Sortie</option>
                            </select>
                        </div>
                    
                        <div class="form-group">
                            <label for="date_debut">Date et heure de début*</label>
                            <input type="datetime-local" id="date_debut" class="form-control" name="date_debut" required>
                        </div>
                    
                        <div class="form-group">
                            <label for="date_fin">Date et heure de fin*</label>
                            <input type="datetime-local" id="date_fin" class="form-control" name="date_fin" required>
                        </div>
                    
                        <div class="form-group">
                            <label for="adresse">Adresse*</label>
                            <input type="text" id="adresse" class="form-control" name="adresse" required>
                        </div>
                    
                        <div id="div_numero_match" class="form-group" style="display: none;">
                            <label for="numero_match">Numéro de match*</label>
                            <input type="text" id="numero_match" class="form-control" name="numero_match">
                        </div>
                    
                        <div id="div_equipe_adverse" class="form-group" style="display: none;">
                            <label for="equipe_adverse">Équipe adverse*</label>
                            <select id="equipe_adverse" class="form-control" name="equipe_adverse">
                                <option value="" selected disabled>Sélectionner ...</option>
                                @foreach($teams as $team)
                                    <option value="{{ $team->id }}">{{ $team->nom }}</option>
                                @endforeach
                            </select>
                        </div>
                    
                        <div class="form-check mb-2">
                            <input class="form-check-input" type="checkbox" value="1" id="invite_equipe" name="invite_equipe">
                            <label class="form-check-label" for="invite_equipe">
                                Inviter toute l'équipe
                            </label>
                        </div>
                    
                        <div class="form-group">
                            <label for="invites_exterieurs">Invités extérieurs (email séparés par des virgules)</label>
                            <input type="text" id="invites_exterieurs" class="form-control" name="invites_exterieurs">
                        </div>
                    
                        <button type="submit" class="btn btn-primary">Ajouter l'événement</button>
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
