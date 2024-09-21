<body>
  <h1>Vous avez reçu un nouveau mail de : {{ $data['name'] }}</h1>
  <ul>
    <li>
      Nom complet : {{ $data['name'] }}
    </li>
    <li>
      Email : {{ $data['email'] }}
    </li>
    <li>
      Numéro de téléphone : {{ $data['phone'] }}
    </li>
    <li>
      Objet de la demande : {{ $data['object'] }}
    </li>
    <li>
      Message : {{ $data['message'] }}
    </li>
  </ul>
</body>
</html>
