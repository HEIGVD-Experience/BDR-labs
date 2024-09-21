# Cahier des charges

## Description
Nous allons faire une interface web qui va permettre de gérer une équipe de sport.   

Liste des fonctionnalitées de base:   
- Créer une équipe et la personnaliser (choisir son nom, son blason, ses infos)
- Ajouter ou supprimer des membres
- Créer des événements, des entrainements ou des matches
- Pouvoir créer et avoir un bilan des présences des événements
- Gérer de manière approfondie les équipes de football et de volley
- En fonction des sports adapter les possibilitées pour des matchs et autres statistiques liés aux matchs

Pour ce faire nous allons utiliser Laravel et Bootstrap pour la partie application et Postgresql pour la base de données.

## Gestion du projet
Pour nous permettre de gérer le projet correctement dans le temps nous allons stocker tout notre code / diagrammes / documentations dans GitHub. Cela nous permettera de tous être à jour sur les dernières nouveautés du code. De plus, pour savoir qui va faire quoi nous allons utiliser les Github Issues et créer des tâches.

## Implémentation base de donnée

Les principaux éléments que nous allons mettre en place sont:
- Personnes composants l'équipe
- Rôles que peuvent prendre ces personnes (e.g. joueur, entraineur, ...)
- Types d'évènements pour l'équipe (e.g. match, entrainement, ...)
- Le statut des personnes durant les évènements (e.g. présent, malade, blessé, ...)
- Le type de sport pour l'équipe
- Les détails d'évenements pendant les matchs des différents sports

## Implémentation client web

Nous allons faire une interface de management d'une équipe sportive qui permettra à un manager / entraineur de gérer les données de son équipe.
Comme cité dans la [description](#description), le manager pourra:
- Voir les présences de ses joueurs
- Décider des compositions pour les matchs
- Gérer certaines statistiques globales
  - Taux de présence (évènement / semaine / mois / saison)
- Gérer les statistiques de matchs
  - Goals
  - Pénalités (carton jaune / rouge)
  - Changements
  - Temps de jeu

L'interface web sera implémentée avec le framework Laravel qui met à disposition des connecteurs pour accéder à notre base Postgresql. Celle-ci devra ressembler à une interface d'administration.
