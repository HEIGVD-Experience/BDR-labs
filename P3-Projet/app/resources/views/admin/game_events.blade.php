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
                        <h1 class="h3 mb-0 text-gray-800">Gestion des faits de matchs</h1>
                    </div>

                    <!-- Statistiques -->
                    <div class="row">
                        @foreach($events_number as $number)
                            <div class="col-lg-4">
                                <div class="card mb-4">
                                    <div class="card-header">
                                        <h5>{{ $number->nom }}</h5>
                                    </div>
                                    <div class="card-body text-center">
                                        <h1 class="display-4">{{ $number->count }}</h1>
                                    </div>
                                </div>
                            </div>
                        @endforeach
                    </div>


                    <!-- DataTales Example -->
                    <div class="card shadow mb-4">
                        <div class="card-header py-3">
                            <h6 class="m-0 font-weight-bold text-primary">Match de : {{ Session::get('team_name')}}</h6>
                        </div>
                        <div class="card-body">
                            <div class="table-responsive">
                                <table class="table table-bordered" id="dataTable" width="100%" cellspacing="0">
                                    <thead>
                                        <tr>
                                            <th>N°event</th>
                                            <th>N°match</th>
                                            <th>Equipe domicile</th>
                                            <th>Equipe adverse</th>
                                            <th>Adresse</th>
                                            <th>Date</th>
                                            <th>Heure</th>
                                            <th class="text-center">Details</th>
                                            <th class="text-center">Ajouter un fait de match</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        @foreach ($games as $event)
                                            <tr>
                                                <td>{{$event->id}}</td>
                                                <td>{{$event->nummatch}}</td>
                                                <td>{{$event->equipe_domicile}}</td>
                                                <td>{{$event->equipe_exterieur}}</td>
                                                <td>{{$event->adresse}}</td>
                                                @if(\Carbon\Carbon::parse($event->heuredebut)->format('d/m/Y') == \Carbon\Carbon::parse($event->heurefin)->format('d/m/Y'))
                                                    <td>{{\Carbon\Carbon::parse($event->heuredebut)->format('d/m/Y')}}</td>
                                                @else
                                                    <td>{{\Carbon\Carbon::parse($event->heuredebut)->format('d/m/Y')}} au {{\Carbon\Carbon::parse($event->heurefin)->format('d/m/Y')}}</td>
                                                @endif
                                                <td>{{\Carbon\Carbon::parse($event->heuredebut)->format('H:m')}} à {{\Carbon\Carbon::parse($event->heurefin)->format('H:m')}}</td>
                                                <td class="text-center"><a href="/a/event/{{$event->id}}"><i class="fa-solid fa-search"></i></a></td>
                                                <td class="text-center"><a href="/a/add/game/{{$event->id}}/event"><i class="fa-solid fa-plus"></i></i></a></td>
                                            </tr>
                                    @endforeach
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>

                </div>
                <!-- /.container-fluid -->

            </div>
            <!-- End of Main Content -->

        </div>
        <!-- End of Content Wrapper -->

    </div>
    <!-- End of Page Wrapper -->
    
</body>

@endsection
