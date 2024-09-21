@extends('layouts.app')

@section('content')

<body id="page-top">
    <div class="container">
        <!-- Outer Row -->
        <div class="row justify-content-center">
            <div class="col-xl-10 col-lg-12 col-md-9">
                <div class="card o-hidden border-0 shadow-lg my-5">
                    <div class="card-body p-0">
                        <!-- Nested Row within Card Body -->
                        <div class="row" style="height: 45rem !important;">
                            <div class="col-lg-6 d-none d-lg-block bg-login-image" style="background-image: url({{ asset('img/login.jpg') }});"></div>
                            <div class="col-lg-6">
                                <div class="p-5" style="margin-top: 45%;">
                                    <div class="text-center">
                                        <h1 class="h4 text-gray-900 mb-4">Bienvenue sur <br><b>sport management</b>!</h1>
                                    </div>
                                    <form class="user" action="checklogin" method="post">
                                        @csrf
                                        <div class="form-group">
                                            <input type="email" class="form-control form-control-user"
                                                id="email" name="email" aria-describedby="emailHelp"
                                                placeholder="Entrez votre adresse email.">
                                        </div>
                                        <button class="btn btn-primary btn-user btn-block w-50 mx-auto" id="submitButton" type="submit">Connexion</button>
                                        <a href="/create/account" class="btn btn-primary btn-user btn-block w-50 mx-auto" id="createAccountButton">Créer un compte</a>
                                    </form>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>

@endsection
