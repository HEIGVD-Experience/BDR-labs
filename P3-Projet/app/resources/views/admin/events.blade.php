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
                <h1 class="h3 mb-0 text-gray-800">Gestion des évenements</h1>
                <a href="/a/add/event" class="d-none d-sm-inline-block btn btn-sm btn-primary shadow-sm"><i
                        class="fas fa-add fa-sm text-white-50"></i> Ajouter un évenement</a>
            </div>
                

                <!-- DataTales Example -->
                <div class="card shadow mb-4">
                    <div class="card-header py-3">
                        <h6 class="m-0 font-weight-bold text-primary">Evenements pour : {{ Session::get('team_name')}}</h6>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-bordered" id="dataTable" width="100%" cellspacing="0">
                                <thead>
                                    <tr>
                                        <th>N°event</th>
                                        <th>Type</th>
                                        <th>Adresse</th>
                                        <th>Date</th>
                                        <th>Heure</th>
                                        <th class="text-center">Détails</th>
                                        <th class="text-center">Modifier</th>
                                        <th class="text-center">Supprimer</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    @foreach ($data as $event)
                                        <tr>
                                            <td>{{$event->id}}</td>
                                            <td>{{$event->type}}</td>
                                            <td>{{$event->adresse}}</td>
                                            @if(\Carbon\Carbon::parse($event->heuredebut)->format('d/m/Y') == \Carbon\Carbon::parse($event->heurefin)->format('d/m/Y'))
                                                <td>{{\Carbon\Carbon::parse($event->heuredebut)->format('d/m/Y')}}</td>
                                            @else
                                                <td>{{\Carbon\Carbon::parse($event->heuredebut)->format('d/m/Y')}} au {{\Carbon\Carbon::parse($event->heurefin)->format('d/m/Y')}}</td>
                                            @endif
                                            <td>{{\Carbon\Carbon::parse($event->heuredebut)->format('H:m')}} à {{\Carbon\Carbon::parse($event->heurefin)->format('H:m')}}</td>
                                            <td class="text-center"><a href="/a/event/{{$event->id}}"><i class="fa-solid fa-search"></i></a></td>
                                            <td class="text-center"><a href="/a/update/event/{{$event->id}}"><i class="fa-solid fa-pen-to-square"></i></i></a></td>
                                            <td class="text-center"><a href="/a/delete/event/{{$event->id}}"><i class="fa-solid fa-trash"></i></a></td>
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
