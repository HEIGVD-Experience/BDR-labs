@extends('layouts.app')
@section('content')

<div class="container">
    <div class="row justify-content-center mt-3">
        <div class="col-md-8">
            <div class="card">
                <div class="card-header">{{ __('Modifier la présence') }}</div>

                <div class="card-body">
                    <form method="POST" action="/p/update/event/{{ $presence->id }}">
                        @csrf
                        @method('PUT') <!-- Utilisez la méthode PUT pour la modification -->

                        <div class="form-group row">
                            <label for="presence" class="col-md-4 col-form-label text-md-right">{{ __('Présence') }}</label>

                            <div class="col-md-6">
                                <select id="presence" class="form-control @error('presence') is-invalid @enderror" name="presence" required>
                                    <option value="P" {{ $presence->type == 'P' ? 'selected' : '' }}>Présent-e</option>
                                    <option value="A" {{ $presence->type == 'A' ? 'selected' : '' }}>Absent-e</option>
                                    <option value="X" {{ $presence->type == 'X' ? 'selected' : '' }}>À définir</option>
                                </select>

                                @error('presence')
                                    <span class="invalid-feedback" role="alert">
                                        <strong>{{ $message }}</strong>
                                    </span>
                                @enderror
                            </div>
                        </div>

                        <div class="form-group row" id="motifGroup" style="display: none;">
                            <label for="motif" class="col-md-4 col-form-label text-md-right">{{ __('Motif d\'absence*') }}</label>

                            <div class="col-md-6">
                                <input id="motif" type="text" class="form-control @error('motif') is-invalid @enderror" name="motif" value="{{ $presence->raison }}">

                                @error('motif')
                                    <span class="invalid-feedback" role="alert">
                                        <strong>{{ $message }}</strong>
                                    </span>
                                @enderror
                            </div>
                        </div>

                        <div class="form-group row mb-0">
                            <div class="col-md-6 offset-md-4">
                                <button type="submit" class="btn btn-primary">
                                    {{ __('Modifier la présence') }}
                                </button>
                                <a href="/p/home" class="btn btn-primary">
                                    {{ __('Retour') }}
                                </a>
                            </div>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- JavaScript pour afficher/cacher le champ motif en fonction de la sélection -->
<script>
    document.addEventListener('DOMContentLoaded', function() {
        var presenceSelect = document.getElementById('presence');
        var motifGroup = document.getElementById('motifGroup');

        presenceSelect.addEventListener('change', function() {
            motifGroup.style.display = this.value === 'A' ? '' : 'none';
        });

        // Déclencher le changement initial
        presenceSelect.dispatchEvent(new Event('change'));
    });
</script>

@endsection
