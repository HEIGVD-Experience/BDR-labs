@extends('layouts.app')
@section('content')

<body id="page-top">

    <!-- Page Wrapper -->
    <div id="wrapper">

        @include('partials.navbar')

        <!-- Content Wrapper -->
        <div id="content-wrapper" class="d-flex flex-column">

            <!-- Main Content -->
            <div id="content">

                @include('partials.topbar')

                <!-- Begin Page Content -->
                <div class="container-fluid">

                    <!-- Page Heading -->
                    <div class="d-sm-flex align-items-center justify-content-between mb-4">
                        <h1 class="h3 mb-0 text-gray-800">Dashboard</h1>
                        <h5 class="h5 mb-0 text-gray-800">{{ Session::get('team_name') }} - {{ Session::get('club_name') }}</h5>
                    </div>

                    <!-- Content Row -->
                    <div class="row">

                        <!-- Earnings (Monthly) Card Example -->
                        <div class="col-xl-3 col-md-6 mb-4">
                            <div class="card border-left-primary shadow h-100 py-2">
                                <div class="card-body">
                                    <div class="row no-gutters align-items-center">
                                        <div class="col mr-2">
                                            <div class="text-xs font-weight-bold text-primary text-uppercase mb-1">
                                                Nombre de joueurs</div>
                                            <div class="h5 mb-0 font-weight-bold text-gray-800">{{ $data['nb_players'] }}</div>
                                        </div>
                                        <div class="col-auto">
                                            <i class="fas fa-users fa-2x text-gray-300"></i>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Earnings (Monthly) Card Example -->
                        <div class="col-xl-3 col-md-6 mb-4">
                            <div class="card border-left-success shadow h-100 py-2">
                                <div class="card-body">
                                    <div class="row no-gutters align-items-center">
                                        <div class="col mr-2">
                                            <div class="text-xs font-weight-bold text-success text-uppercase mb-1">
                                                Nombre d'évenements</div>
                                            <div class="h5 mb-0 font-weight-bold text-gray-800">{{ $data['nb_events'] }}</div>
                                        </div>
                                        <div class="col-auto">
                                            <i class="fas fa-calendar fa-2x text-gray-300"></i>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Earnings (Monthly) Card Example -->
                        <div class="col-xl-3 col-md-6 mb-4">
                            <div class="card border-left-info shadow h-100 py-2">
                                <div class="card-body">
                                    <div class="row no-gutters align-items-center">
                                        <div class="col mr-2">
                                            <div class="text-xs font-weight-bold text-info text-uppercase mb-1">Présence moyenne
                                            </div>
                                            <div class="row no-gutters align-items-center">
                                                <div class="col-auto">
                                                    <div class="h5 mb-0 mr-3 font-weight-bold text-gray-800">{{ $data['presence_percentage'] }}%</div>
                                                </div>
                                                <div class="col">
                                                    <div class="progress progress-sm mr-2">
                                                        <div class="progress-bar bg-info" role="progressbar"
                                                            style="width: {{ $data['presence_percentage'] }}%" aria-valuenow="{{ $data['presence_percentage'] }}" aria-valuemin="0"
                                                            aria-valuemax="100"></div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="col-auto">
                                            <i class="fas fa-clipboard-list fa-2x text-gray-300"></i>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Pending Requests Card Example -->
                        <div class="col-xl-3 col-md-6 mb-4">
                            <div class="card border-left-warning shadow h-100 py-2">
                                <div class="card-body">
                                    <div class="row no-gutters align-items-center">
                                        <div class="col mr-2">
                                            <div class="text-xs font-weight-bold text-warning text-uppercase mb-1">
                                                Evenements attendant réponses</div>
                                            <div class="h5 mb-0 font-weight-bold text-gray-800">{{ $data['events_without_response'] }}</div>
                                        </div>
                                        <div class="col-auto">
                                            <i class="fas fa-comments fa-2x text-gray-300"></i>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Content Row -->

                    <div class="row">

                        <!-- Page Heading -->
                        <div class="d-sm-flex col-12 align-items-center justify-content-between mb-4">
                            @if(count($data['last_four_events']) == 1)
                                <h1 class="h4 mb-0 text-gray-800"> Le prochain événement</h1>
                            @elseif(count($data['last_four_events']) > 0)
                                <h1 class="h4 mb-0 text-gray-800"> {{count($data['last_four_events'])}} prochains événements</h1>
                            @else
                                <h1 class="h4 mb-0 text-gray-800"> Aucun événement n'est prévu prochainement.</h1>
                            @endif
                        </div>

                        @foreach ($data['last_four_events'] as $key => $event)

                            <div class="col-lg-6 mb-4">
                                <div class="card bg-light text-black shadow">
                                    <a href="/a/event/{{$event->id}}">
                                        <div class="card-body">
                                            @if($event->type == 'SOR')
                                            <h4 class="mb-3"><i class="fa-solid fa-people-group"></i> Sortie d'équipe</h4>
                                            @elseif($event->type == 'MAT')
                                            <h4 class="mb-3"><i class="fas fa-volleyball"></i> Match</h4>
                                            @elseif($event->type == 'ENT')
                                            <h4 class="mb-3"><i class="fas fa-dumbbell"></i> Entrainement</h4>
                                            @endif

                                            <p><strong>Date :</strong> {{ \Carbon\Carbon::parse($event->heuredebut)->format('d/m/Y') }}</p>
                                            <p><strong>Heure :</strong> {{ \Carbon\Carbon::parse($event->heuredebut)->format('H:i') }} à {{ \Carbon\Carbon::parse($event->heurefin)->format('H:i') }}</p>
                                            <p><strong>Adresse :</strong> {{ $event->adresse }}</p>
                                        </div>
                                    </a>
                                </div>
                            </div>

                        @endforeach
                    
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
