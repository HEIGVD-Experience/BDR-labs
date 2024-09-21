@extends('layouts.app')
@section('content')

<body id="page-top">

    <!-- Page Wrapper -->
    <div id="wrapper">

        <!-- Content Wrapper -->
        <div id="content-wrapper" class="d-flex flex-column">

            <!-- Main Content -->
            <div id="content">

                @include('partials.topbar')

                <!-- Begin Page Content -->
                <div class="container-fluid">

                    <div class="d-sm-flex align-items-center justify-content-between mb-4">
                        <h1 class="h3 mb-0 text-gray-800">Vos statistiques</h1>
                        @if (Session::get('team_name') && Session::get('club_name'))
                        <h5 class="h5 mb-0 text-gray-800">{{ Session::get('team_name') }} - {{ Session::get('club_name') }}</h5>
                        @else
                        <h5 class="h5 mb-0 text-gray-800">Vous n'avez actuellement aucun club.</h5>
                        @endif
                    </div>

                    <div class="row">
                    <!-- Statistiques spécifiques au football -->
                    @if (!empty($stats))
                        @foreach($stats as $stat)
                            <div class="col-lg-4">
                                <div class="card mb-4">
                                    <div class="card-header">
                                        <h5>{{ $stat->name }}</h5>
                                    </div>
                                    <div class="card-body text-center">
                                        <h1 class="display-4">{{ $stat->value }}</h1>
                                    </div>
                                </div>
                            </div>
                        @endforeach
                    @endif
                    </div>


                    <!-- Page Heading -->
                    <div class="d-sm-flex align-items-center justify-content-between mb-4">
                        <h1 class="h3 mb-0 text-gray-800">Vos événements</h1>
                    </div>

                    <!-- Content Row -->
                    <div class="row justify-content-center">

                        @if(count($events) > 0)
                            <div class="col-md-6"> <!-- Ajustez la taille selon vos besoins -->
                                <div class="list-group">
                                    @foreach($events as $event)
                                        <div class="list-group-item mb-3 rounded">

                                            <!-- Bouton avec popup pour changer le statut -->
                                            <div class="d-flex justify-content-between align-items-center">
                                                <!-- Contenu à gauche -->
                                                <div>
                                                    <h4 class="mb-3">{{ $event->type_evenement }}</h4>
                                                    @if($event->type_evenement == 'MAT')
                                                        <p><strong>{{ $event->domicile }}</strong> vs <strong>{{ $event->exterieur }}</strong></p>
                                                    @endif
                                                    <p><strong>Date :</strong> {{ \Carbon\Carbon::parse($event->heuredebut)->format('d/m/Y') }}</p>
                                                    <p><strong>Heure :</strong> {{ \Carbon\Carbon::parse($event->heuredebut)->format('H:i') }} à {{ \Carbon\Carbon::parse($event->heurefin)->format('H:i') }}</p>
                                                    <p><strong>Adresse :</strong> {{ $event->adresse }}</p>
                                                </div>
                                                <!-- Bouton à droite -->
                                                <!-- Bouton avec popup pour changer le statut -->
                                                <a @if(now() > $event->heuredebut || !Session::has('role')) href="#" style="pointer-events: none;" @else href="/p/update/event/{{ $event->id }}" @endif
                                                    class="btn btn-{{ $event->statut === 'P' ? 'success' : ($event->statut === 'A' ? 'warning' : 'secondary') }}">
                                                    {{ $event->statut === 'P' ? 'Présent' : ($event->statut === 'A' ? 'Absent' : 'À définir') }}
                                                </a>
                                            </div>
                                        </div>
                                    @endforeach
                                </div>
                            </div>
                        @else
                            <p class="text-center">Aucun événement disponible.</p>
                        @endif
                        
                    </div>


                </div>
                <!-- /.container-fluid -->

            </div>
            <!-- End of Main Content -->

            <!-- Footer -->
            <footer class="sticky-footer bg-white">
                <div class="container my-auto">
                    <div class="copyright text-center my-auto">
                        <span>Copyright &copy; BDR Project 2023-2024</span>
                    </div>
                </div>
            </footer>
            <!-- End of Footer -->

        </div>
        <!-- End of Content Wrapper -->

    </div>
    <!-- End of Page Wrapper -->

</body>
@endsection
