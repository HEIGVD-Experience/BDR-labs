<!DOCTYPE html>
<html lang="fr">
    <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no" />
        <meta name="description" content="" />
        <meta name="author" content="" />
        <title>Sport Management</title>
        <!-- Description -->
        <meta name="description" content="Ceci est le site pour un nouveau projet!"/>

        <!-- Favicon-->
        <link rel="icon" type="image/x-icon" href="{{ asset('img/favicon.ico') }}" />

        <!-- Font Awesome icons (free version)-->
        <script src="https://use.fontawesome.com/releases/v6.1.0/js/all.js" crossorigin="anonymous"></script>

        <!-- UI theme JS-->
        <script src="{{ asset('js/ui.js') }}"></script>
        <!-- Custom theme JS-->
        <script src="{{ asset('js/custom.js') }}"></script>

        <!-- UI theme CSS (includes Bootstrap)-->
        <link href="{{ asset('css/ui.css') }}" rel="stylesheet" />
        <!-- Custom CSS -->
        <link href="{{ asset('css/custom.css') }}" rel="stylesheet" />

        <!-- SMS Properties -->
        <meta property="og:image" content="{{ asset('img/favicon.ico') }}" />
        <meta property="og:title" content="Nouveau projet!" />
        <meta property="og:description" content="Ceci est le site pour un nouveau projet!" />

    </head>

    <body id="page-top">

      @if(session('success'))
          <div class="alert alert-success mb-0">
              {{ session('success') }}
          </div>
      @endif

      @if(session('error'))
          <div class="alert alert-danger mb-0">
              {{ session('error') }}
          </div>
      @endif

      @yield('content')

      <!-- Page level plugins -->
      <script src="{{ asset('js/chart.js') }}"></script>

      <!-- Page level custom scripts -->
      <script src="{{ asset('js/demo/chart-area-demo.js') }}"></script>
      <script src="{{ asset('js/demo/chart-pie-demo.js') }}"></script>

    </body>

</html>
