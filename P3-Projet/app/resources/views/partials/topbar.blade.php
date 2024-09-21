<!-- Topbar -->
<nav class="navbar navbar-expand navbar-light bg-white topbar mb-4 static-top shadow">

    @if(Session::get('role') == 'JOU')
    <!-- Sidebar - Brand -->
    <a class="sidebar-brand d-flex align-items-center justify-content-center" href="/p/home">
        <div class="sidebar-brand-text mx-3">Sport Management</div>
    </a>
    @endif

    @if(Session::has('club_logo'))
    <div class="d-flex justify-content-center align-items-center" style="max-width: 50px; max-height: 50px;">
        <img src="{{ asset(Session::get('club_logo')) }}" alt="Club logo" class="img-fluid">
    </div>
    @endif

    <!-- Topbar Navbar -->
    <ul class="navbar-nav ml-auto">

        <!-- Nav Item - User Information -->
        <li class="nav-item no-arrow">
            <a href="/edit/account/{{Session::get('id_user')}}" class="nav-link">
                <span class="mr-4 d-none d-lg-inline text-gray-600 small">{{ Session::get('first_name') }} {{ Session::get('last_name') }}</span>
                <img class="img-profile rounded-circle"
                    src="{{ asset('img/undraw_profile.svg') }}">
            </a>
        </li>
        <li class="nav-item no-arrow">
            <a  class="nav-link" href="/">
                <span class="mr-2 d-none d-lg-inline text-gray-600 small">Logout</span>
                <i class="fas fa-sign-out-alt fa-sm fa-fw mr-2 text-gray-400"></i>
            </a>
        </li>

    </ul>

</nav>
<!-- End of Topbar -->