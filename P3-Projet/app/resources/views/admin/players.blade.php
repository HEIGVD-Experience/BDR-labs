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
                <h1 class="h3 mb-0 text-gray-800">Gestion des joueurs</h1>
                <a href="/a/add/player" class="d-none d-sm-inline-block btn btn-sm btn-primary shadow-sm"><i
                        class="fas fa-add fa-sm text-white-50"></i> Ajouter un joueur</a>
            </div>
                

                <!-- DataTales Example -->
                <div class="card shadow mb-4">
                    <div class="card-header py-3">
                        <h6 class="m-0 font-weight-bold text-primary">Joueurs de : {{ Session::get('team_name')}}</h6>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-bordered" id="dataTable" width="100%" cellspacing="0">
                                <thead>
                                    <tr>
                                        <th>N°joueur</th>
                                        <th>Nom</th>
                                        <th>Prenom</th>
                                        <th>Date de naissance</th>
                                        <th>Email</th>
                                        <th>Role</th>
                                        <th>Position</th>
                                        <th>Date d'arrivée</th>
                                        <th class="text-center">Modifier</th>
                                        <th class="text-center">Supprimer</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    @foreach ($data as $user)
                                    <tr>
                                        <td>{{$user->id}}</td>
                                        <td>{{$user->nom}}</td>
                                        <td>{{$user->prenom}}</td>
                                        <td class="text-center">{{$user->datedenaissance}}</td>
                                        <td>{{$user->email}}</td>
                                        <td>{{$user->role}}</td>
                                        <td>{{$user->position}}</td>
                                        <td class="text-center">{{$user->datearrivee}}</td>
                                        <td class="text-center"><a method="GET" href="/a/edit/player/{{$user->id}}"><i class="fa-solid fa-pen-to-square"></i></a></td>
                                        <td class="text-center"><a method="POST" href="/a/delete/player/{{$user->id}}"><i class="fa-solid fa-trash"></i></a></td>
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

<!-- Scroll to Top Button-->
<a class="scroll-to-top rounded" href="#page-top">
    <i class="fas fa-angle-up"></i>
</a>
</body>

@endsection
