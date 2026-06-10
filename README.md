# HotelGo — Application Mobile de Réservation d’Hôtels
Réalisé par : Manar Ouahabi et Sara Laaroussi

## 1. Présentation du projet

**HotelGo** est une application mobile de réservation d’hôtels développée avec **Flutter** et **Dart** dans le cadre du mini-projet de Programmation Mobile.

L’application permet à l’utilisateur de créer un compte, se connecter, rechercher des hôtels, consulter les détails, ajouter des favoris, réserver une chambre, gérer ses réservations, laisser des avis, personnaliser son profil et explorer des hôtels à partir d’une API REST externe.

Le projet respecte l’architecture **MVC** et intègre plusieurs fonctionnalités modernes : stockage local, SQLite, dark mode, animations, notifications locales, géolocalisation, upload d’image, dashboard statistique et consommation d’API REST.

---

## 2. Sujet choisi

Le sujet choisi est :

**Application de Réservation d’Hôtels**

Applications similaires :

- Booking.com
- Airbnb

Fonctionnalités liées au sujet :

- Recherche d’hôtels
- Réservation de chambres
- Galerie d’images
- Historique des réservations
- Système d’avis et de notation
- Favoris
- Profil utilisateur
- Dashboard statistique

---

## 3. Objectifs du projet

Ce projet permet de mettre en pratique les notions suivantes :

- Développement mobile avec Flutter
- Utilisation du langage Dart
- Navigation entre plusieurs écrans
- Gestion des formulaires
- Validation des champs
- Stockage local des données
- Architecture logicielle MVC
- CRUD complet
- Consommation d’une API REST externe
- Design UI/UX moderne et responsive
- Intégration de fonctionnalités avancées

---

## 4. Fonctionnalités réalisées

### 4.1 Authentification

L’application contient un système d’authentification locale.

Fonctionnalités réalisées :

- Création de compte
- Connexion
- Déconnexion
- Choix d’un compte déjà enregistré
- Validation des champs
- Vérification des comptes existants
- Sauvegarde locale des utilisateurs

Les champs validés sont :

- Nom complet obligatoire
- Email obligatoire avec format valide
- Mot de passe obligatoire
- Confirmation du mot de passe obligatoire
- Vérification de la correspondance des mots de passe

---

### 4.2 Gestion multi-utilisateur

L’application permet de gérer plusieurs utilisateurs sur le même appareil.

Chaque utilisateur possède ses propres données :

- Ses réservations
- Ses favoris
- Ses avis
- Sa photo de profil
- Ses statistiques

Cela permet de séparer les données entre les comptes enregistrés.

---

### 4.3 Page d’accueil

La page d’accueil affiche :

- Message personnalisé avec le nom de l’utilisateur
- Barre de recherche
- Liste des hôtels disponibles
- Destinations populaires
- Filtres rapides
- Bouton de géolocalisation
- Bouton d’accès à l’API REST
- Navigation vers les détails d’un hôtel

---

### 4.4 Recherche et filtres

L’utilisateur peut rechercher un hôtel par :

- Nom d’hôtel
- Ville
- Texte partiel

La recherche est améliorée pour gérer les différences d’écriture :

- `fes` peut correspondre à `Fès`
- Les majuscules et minuscules ne bloquent pas la recherche
- Les espaces sont traités correctement

Filtres disponibles :

- 3 étoiles
- 4 étoiles
- 5 étoiles
- Prix inférieur ou égal à 600 DH
- Prix inférieur ou égal à 1000 DH
- Prix inférieur ou égal à 1500 DH
- Filtre par ville

---

### 4.5 Liste des hôtels

Chaque hôtel est affiché sous forme de carte contenant :

- Image principale
- Nom de l’hôtel
- Ville et pays
- Note
- Nombre d’étoiles
- Prix par nuit
- Bouton détails
- Bouton favori

---

### 4.6 Détails d’un hôtel

La page détails affiche :

- Image principale
- Nom de l’hôtel
- Ville
- Prix
- Note
- Description
- Galerie d’images horizontale
- Équipements disponibles
- Avis clients
- Bouton de réservation

La galerie permet de consulter plusieurs images de l’hôtel avec une navigation horizontale.

---

### 4.7 Avis clients

L’utilisateur peut ajouter un avis sur un hôtel.

Un avis contient :

- Nom de l’utilisateur
- Note par étoiles
- Commentaire
- Date de publication

Après l’ajout, l’avis apparaît directement dans la page détails de l’hôtel.

---

### 4.8 Réservation

L’utilisateur peut réserver une chambre en remplissant un formulaire.

Le formulaire contient :

- Nom du client
- Nombre de personnes
- Type de chambre
- Date d’arrivée
- Date de départ
- Nombre de nuits
- Prix total

Types de chambres disponibles :

- Standard
- Deluxe
- Suite

Formule utilisée pour le calcul automatique :

**Prix total = prix par nuit × nombre de nuits × coefficient du type de chambre**

---

### 4.9 CRUD des réservations

L’application respecte la contrainte CRUD demandée.

- **Create** : création d’une nouvelle réservation
- **Read** : affichage de l’historique des réservations
- **Update** : modification d’une réservation existante
- **Delete** : suppression d’une réservation

Les réservations sont stockées localement avec **SQLite**.

---

### 4.10 Historique des réservations

La page “Mes réservations” affiche :

- Résumé du nombre de réservations
- Montant total dépensé
- Nom de l’hôtel
- Ville
- Date d’arrivée
- Date de départ
- Nombre de personnes
- Type de chambre
- Nombre de nuits
- Prix total

L’utilisateur peut modifier ou supprimer une réservation.

---

### 4.11 Favoris

L’utilisateur peut :

- Ajouter un hôtel aux favoris
- Retirer un hôtel des favoris
- Consulter la liste de ses hôtels favoris

Les favoris sont sauvegardés localement et séparés par utilisateur.

---

### 4.12 Profil utilisateur

La page profil affiche :

- Nom de l’utilisateur
- Email
- Photo de profil
- Nombre de réservations
- Nombre de favoris
- Total dépensé
- Nombre de nuits réservées
- Dernière réservation
- Accès aux réservations
- Accès aux favoris
- Déconnexion

---

### 4.13 Dashboard statistique

Le profil contient un tableau de bord statistique avec :

- Réservations par ville
- Dépenses par type de chambre
- Comparaison entre réservations et favoris
- Total dépensé
- Nombre de nuits réservées

Les graphiques sont générés à partir des données de l’utilisateur connecté.

---

### 4.14 Dark Mode

L’application propose un mode sombre.

L’utilisateur peut activer ou désactiver le mode sombre depuis la page profil.

Le choix du thème est sauvegardé localement afin d’être conservé après fermeture de l’application.

---

### 4.15 Animations

Plusieurs animations ont été ajoutées pour améliorer l’expérience utilisateur :

- Animation d’apparition des hôtels
- Animation lors du changement de filtre
- Transition animée vers la page détails
- Effets de fade, slide et zoom léger
- Animation de changement de contenu dans la page API REST

---

### 4.16 Notifications locales

Après la confirmation d’une réservation, l’application affiche une notification locale.

Exemple :

**Réservation confirmée**  
Votre réservation à l’hôtel sélectionné a bien été enregistrée.

Cette fonctionnalité utilise le package `flutter_local_notifications`.

---

### 4.17 Géolocalisation

L’application permet de trier les hôtels selon la position actuelle de l’utilisateur.

Fonctionnement :

- Demande d’autorisation de localisation
- Récupération de la position GPS
- Calcul de la distance entre l’utilisateur et chaque hôtel
- Tri des hôtels du plus proche au plus loin
- Affichage de la distance sur chaque carte

Exemple :

**À 3.0 km de vous**

---

### 4.18 Caméra et upload d’image

L’utilisateur peut personnaliser sa photo de profil :

- Choisir une image depuis la galerie
- Prendre une photo avec la caméra
- Supprimer la photo de profil
- Sauvegarder la photo localement

Chaque utilisateur possède sa propre photo de profil.

---

### 4.19 API REST externe

L’application contient une page dédiée :

**Explorer API REST**

Cette page récupère des hôtels depuis une API REST externe et les affiche dans l’application.

Fonctionnement :

- Requête HTTP vers une API REST externe
- Récupération des données JSON
- Conversion des données vers un modèle Dart
- Affichage des résultats dans des cartes Flutter
- Gestion du chargement
- Gestion des erreurs
- Changement de ville

Villes disponibles :

- Tanger
- Casablanca
- Marrakech
- Rabat
- Agadir
- Fès

Remarque : les données des hôtels proviennent de l’API REST. Les images utilisées dans cette page sont des images illustratives par ville afin de garder une interface claire et professionnelle.

---

## 5. Technologies utilisées

- **Flutter** : développement mobile multiplateforme
- **Dart** : langage de programmation
- **SQLite / sqflite** : stockage local des réservations
- **SharedPreferences** : stockage local des utilisateurs, favoris, thème et avis
- **HTTP** : consommation de l’API REST
- **Geolocator** : géolocalisation et calcul de distance
- **Image Picker** : galerie et caméra
- **Path Provider** : sauvegarde locale des images
- **Flutter Local Notifications** : notifications locales
- **FL Chart** : graphiques statistiques
- **Material Design** : interface moderne et responsive

---

## 6. Architecture MVC adoptée

Le projet respecte l’architecture **MVC : Model - View - Controller**.

Cette architecture permet de séparer les responsabilités du code :

- Les **Models** représentent les données.
- Les **Views** affichent l’interface utilisateur.
- Les **Controllers** contiennent la logique métier.
- Les **Services** gèrent les opérations techniques comme la base de données, le stockage local, l’API, la géolocalisation et les notifications.

---

### 6.1 Models

Dossier :

`lib/models/`

Fichiers principaux :

- `user_model.dart`
- `hotel_model.dart`
- `reservation_model.dart`
- `review_model.dart`
- `api_place_model.dart`

Rôle :

- Définir la structure d’un utilisateur
- Définir la structure d’un hôtel
- Définir la structure d’une réservation
- Définir la structure d’un avis
- Définir la structure d’un résultat API

---

### 6.2 Views

Dossier :

`lib/views/`

Fichiers principaux :

- `splash_view.dart`
- `welcome_view.dart`
- `account_picker_view.dart`
- `login_view.dart`
- `register_view.dart`
- `home_view.dart`
- `hotel_details_view.dart`
- `booking_view.dart`
- `reservations_view.dart`
- `favorites_view.dart`
- `profile_view.dart`
- `api_explore_view.dart`

Rôle :

- Afficher les écrans
- Gérer les interactions utilisateur
- Appeler les contrôleurs
- Afficher les résultats
- Afficher les messages de succès ou d’erreur

---

### 6.3 Controllers

Dossier :

`lib/controllers/`

Fichiers principaux :

- `auth_controller.dart`
- `hotel_controller.dart`
- `reservation_controller.dart`
- `favorite_controller.dart`
- `review_controller.dart`
- `theme_controller.dart`
- `profile_image_controller.dart`

Rôle :

- Gérer l’authentification
- Gérer les hôtels
- Gérer les réservations
- Gérer les favoris
- Gérer les avis
- Gérer le mode sombre
- Gérer la photo de profil

---

### 6.4 Services

Dossier :

`lib/services/`

Fichiers principaux :

- `storage_service.dart`
- `database_service.dart`
- `location_service.dart`
- `notification_service.dart`
- `api_place_service.dart`

Rôle :

- Sauvegarder les données simples avec SharedPreferences
- Gérer la base de données SQLite
- Récupérer la position GPS
- Afficher les notifications locales
- Consommer l’API REST externe

---

### 6.5 Utils et Widgets

Dossiers :

`lib/utils/`  
`lib/widgets/`

Fichiers utilitaires :

- `app_routes.dart`
- `app_colors.dart`
- `app_theme.dart`
- `validators.dart`

Widgets réutilisables :

- `app_bottom_nav_bar.dart`
- `custom_button.dart`
- `custom_text_field.dart`
- `hotel_card.dart`
- `stat_chart_card.dart`

Rôle :

- Centraliser les couleurs
- Centraliser les routes
- Centraliser les thèmes
- Réutiliser les composants graphiques
- Garder une interface cohérente

---

## 7. Structure du projet

hotelgo_app/
│
├── android/
├── ios/
├── lib/
│   ├── controllers/
│   │   ├── auth_controller.dart
│   │   ├── favorite_controller.dart
│   │   ├── hotel_controller.dart
│   │   ├── profile_image_controller.dart
│   │   ├── reservation_controller.dart
│   │   ├── review_controller.dart
│   │   └── theme_controller.dart
│   │
│   ├── models/
│   │   ├── api_place_model.dart
│   │   ├── hotel_model.dart
│   │   ├── reservation_model.dart
│   │   ├── review_model.dart
│   │   └── user_model.dart
│   │
│   ├── services/
│   │   ├── api_place_service.dart
│   │   ├── database_service.dart
│   │   ├── location_service.dart
│   │   ├── notification_service.dart
│   │   └── storage_service.dart
│   │
│   ├── utils/
│   │   ├── app_colors.dart
│   │   ├── app_routes.dart
│   │   ├── app_theme.dart
│   │   └── validators.dart
│   │
│   ├── views/
│   │   ├── account_picker_view.dart
│   │   ├── api_explore_view.dart
│   │   ├── booking_view.dart
│   │   ├── favorites_view.dart
│   │   ├── home_view.dart
│   │   ├── hotel_details_view.dart
│   │   ├── login_view.dart
│   │   ├── profile_view.dart
│   │   ├── register_view.dart
│   │   ├── reservations_view.dart
│   │   ├── splash_view.dart
│   │   └── welcome_view.dart
│   │
│   ├── widgets/
│   │   ├── app_bottom_nav_bar.dart
│   │   ├── custom_button.dart
│   │   ├── custom_text_field.dart
│   │   ├── hotel_card.dart
│   │   └── stat_chart_card.dart
│   │
│   └── main.dart
│
├── screenshots/
├── pubspec.yaml
└── README.md

---

## 8. Stockage local

L’application utilise deux types de stockage local.

### 8.1 SharedPreferences

`SharedPreferences` est utilisé pour stocker les données simples :

- Utilisateurs enregistrés
- État de connexion
- Email de l’utilisateur connecté
- Favoris
- Avis clients
- Mode sombre
- Chemin de la photo de profil

### 8.2 SQLite

SQLite est utilisé pour stocker les réservations.

Table principale :

`reservations`

Champs principaux :

- `id`
- `userEmail`
- `hotelId`
- `hotelName`
- `city`
- `pricePerNight`
- `customerName`
- `checkInDate`
- `checkOutDate`
- `guests`
- `roomType`
- `nights`
- `totalPrice`
- `createdAt`

L’utilisation de `userEmail` permet de séparer les réservations de chaque utilisateur.

---

## 9. Installation et exécution du projet

### 9.1 Prérequis

Avant de lancer le projet, il faut installer :

- Flutter SDK
- Dart SDK
- Android Studio ou Visual Studio Code
- Un émulateur Android ou un téléphone Android
- Git

Vérifier l’installation de Flutter :

```bash
flutter doctor
```

---

### 9.2 Cloner le projet

```bash
git clone https://github.com/VOTRE_USERNAME/hotelgo_app.git
cd hotelgo_app
```

Remplacer `VOTRE_USERNAME` par le nom du compte GitHub contenant le projet.

---

### 9.3 Installer les dépendances

```bash
flutter pub get
```

---

### 9.4 Lancer l’application

```bash
flutter run
```

---

### 9.5 Analyser le code

```bash
flutter analyze
```

Remarque : certaines lignes de type `info` peuvent apparaître selon la version de Flutter. Elles ne bloquent pas l’exécution de l’application.

---

### 9.6 Nettoyer le projet si nécessaire

En cas de problème de build :

```bash
flutter clean
flutter pub get
flutter run
```

---

## 10. Permissions utilisées

L’application utilise certaines permissions selon les fonctionnalités :

- Internet pour l’API REST et les images réseau
- Localisation pour le tri des hôtels par distance
- Notifications pour la confirmation de réservation
- Caméra et galerie pour la photo de profil

Ces permissions sont configurées dans le projet Android.

---

## 11. Captures d’écran principales

Les captures suivantes présentent les principaux écrans et fonctionnalités de l’application : authentification, recherche, détails hôtel, avis, réservation, favoris, profil, statistiques, géolocalisation, API REST et multi-utilisateur.

La galerie complète est disponible dans le dossier :

`screenshots/`

---

### 11.1 Lancement et authentification

#### Splash screen

![Splash screen](screenshots/01_splash_screen.png)

#### Welcome sans compte

![Welcome sans compte](screenshots/02_welcome_no_account.png)

#### Fonctionnalités sur la page Welcome

![Fonctionnalités Welcome](screenshots/03_welcome_features_buttons.png)

#### Validation du formulaire d’inscription

![Validation inscription](screenshots/04_register_empty_validation.png)

#### Formulaire d’inscription rempli

![Formulaire inscription rempli](screenshots/05_register_filled_form.png)

#### Connexion après création du compte

![Login après inscription](screenshots/06_login_after_register_success.png)

#### Choix d’un compte enregistré

![Compte enregistré](screenshots/07_account_picker_saved_account.png)

#### Gestion d’une erreur de connexion

![Erreur login](screenshots/08_login_wrong_password.png)

---

### 11.2 Accueil, recherche et filtres

#### Page d’accueil

![Accueil](screenshots/09_home_overview.png)

#### Liste des hôtels

![Liste hôtels](screenshots/10_home_hotels_list.png)

#### Recherche par ville

![Recherche Casablanca](screenshots/11_home_search_casablanca.png)

#### Résultats de recherche

![Résultats Casablanca](screenshots/12_home_search_results_casa.png)

#### Filtre par ville

![Filtre Tanger](screenshots/13_home_filter_tanger.png)

#### Tri par distance activé

![Tri distance](screenshots/14_home_distance_sorting.png)

#### Distances affichées sur les hôtels

![Badges distance](screenshots/15_home_distance_badges.png)

---

### 11.3 Détails hôtel et avis

#### Page détails hôtel

![Détails hôtel](screenshots/16_hotel_details_overview.png)

#### Galerie et équipements

![Galerie équipements](screenshots/17_hotel_gallery_facilities.png)

#### Ajout d’un avis

![Ajout avis](screenshots/18_add_review_sheet.png)

#### Avis ajouté avec succès

![Avis ajouté](screenshots/19_review_added_success.png)

---

### 11.4 Réservations

#### Formulaire de réservation rempli

![Formulaire réservation](screenshots/20_booking_form_filled.png)

#### Calcul du total et confirmation

![Total réservation](screenshots/21_booking_total_confirm.png)

#### Réservation ajoutée et notification

![Réservation ajoutée](screenshots/22_reservation_success_and_list.png)

#### Modification d’une réservation

![Modifier réservation](screenshots/23_edit_reservation_form.png)

#### Réservation modifiée avec succès

![Réservation modifiée](screenshots/24_edit_reservation_success.png)

#### Réservation supprimée avec succès

![Réservation supprimée](screenshots/25_delete_reservation_success.png)

---

### 11.5 Favoris

#### Ajout d’un hôtel aux favoris

![Ajout favori](screenshots/26_favorite_added_success.png)

#### Page des favoris

![Page favoris](screenshots/27_favorites_page.png)

---

### 11.6 Profil, statistiques et dark mode

#### Profil utilisateur

![Profil](screenshots/28_profile_dashboard.png)

#### Graphiques statistiques

![Statistiques](screenshots/29_profile_charts_city_room.png)

#### Dernière réservation et actions profil

![Actions profil](screenshots/30_profile_last_reservation_buttons.png)

#### Mode sombre

![Mode sombre](screenshots/31_profile_dark_mode.png)

---

### 11.7 API REST externe

#### API REST avec Tanger

![API REST Tanger](screenshots/32_api_rest_tanger.png)

#### API REST avec Agadir

![API REST Agadir](screenshots/33_api_rest_city_switch_agadir.png)

---

### 11.8 Multi-utilisateur

#### Choix entre plusieurs comptes

![Multi-utilisateur](screenshots/34_account_picker_multiple_users.png)

#### Profil du deuxième utilisateur

![Profil deuxième utilisateur](screenshots/35_profile_second_user_empty.png)

---

## 12. Liste complète des captures dans le dossier screenshots

- `01_splash_screen.png`
- `02_welcome_no_account.png`
- `03_welcome_features_buttons.png`
- `04_register_empty_validation.png`
- `05_register_filled_form.png`
- `06_login_after_register_success.png`
- `07_account_picker_saved_account.png`
- `08_login_wrong_password.png`
- `09_home_overview.png`
- `10_home_hotels_list.png`
- `11_home_search_casablanca.png`
- `12_home_search_results_casa.png`
- `13_home_filter_tanger.png`
- `14_home_distance_sorting.png`
- `15_home_distance_badges.png`
- `16_hotel_details_overview.png`
- `17_hotel_gallery_facilities.png`
- `18_add_review_sheet.png`
- `19_review_added_success.png`
- `20_booking_form_filled.png`
- `21_booking_total_confirm.png`
- `22_reservation_success_and_list.png`
- `23_edit_reservation_form.png`
- `24_edit_reservation_success.png`
- `25_delete_reservation_success.png`
- `26_favorite_added_success.png`
- `27_favorites_page.png`
- `28_profile_dashboard.png`
- `29_profile_charts_city_room.png`
- `30_profile_last_reservation_buttons.png`
- `31_profile_dark_mode.png`
- `32_api_rest_tanger.png`
- `33_api_rest_city_switch_agadir.png`
- `34_account_picker_multiple_users.png`
- `35_profile_second_user_empty.png`

---

## 13. Tests effectués

Tests réalisés manuellement :

- Création de compte : réussi
- Validation des champs vides : réussi
- Connexion avec compte existant : réussi
- Connexion avec mot de passe incorrect : réussi
- Déconnexion : réussi
- Choix d’un compte enregistré : réussi
- Recherche par ville : réussi
- Recherche par texte partiel : réussi
- Filtrage par ville : réussi
- Filtrage par étoiles : réussi
- Filtrage par prix : réussi
- Affichage des détails hôtel : réussi
- Galerie d’images : réussi
- Ajout d’un avis : réussi
- Création d’une réservation : réussi
- Calcul automatique du total : réussi
- Notification après réservation : réussi
- Modification d’une réservation : réussi
- Suppression d’une réservation : réussi
- Ajout aux favoris : réussi
- Suppression des favoris : réussi
- Photo de profil depuis galerie : réussi
- Dark mode : réussi
- Géolocalisation : réussi
- API REST externe : réussi
- Séparation des données entre utilisateurs : réussi

---

## 14. Fonctionnalités minimales obligatoires

Fonctionnalités demandées et réalisées :

- Authentification Login/Register : réalisée
- Navigation entre plusieurs écrans : réalisée
- CRUD : réalisé
- Formulaires : réalisés
- Validation des champs : réalisée
- Stockage local : réalisé
- Interface moderne et responsive : réalisée
- Architecture MVC : respectée
- Icônes, thème et design personnalisés : réalisés

---

## 15. Fonctionnalités avancées intégrées

Fonctionnalités avancées ajoutées :

- API REST externe
- SQLite
- Dark Mode
- Animations
- Notifications locales
- Géolocalisation
- Caméra
- Upload d’images
- Dashboard statistique
- Gestion multi-utilisateur
- Avis clients
- Favoris personnalisés

---

## 16. Organisation du dépôt GitHub

Le dépôt GitHub contient :

- Le code source complet de l’application Flutter
- Le fichier `README.md`
- Le dossier `screenshots/`
- Les fichiers de configuration Flutter
- Le fichier `pubspec.yaml`
- Le code organisé selon l’architecture MVC

---

## 17. Conclusion

HotelGo est une application mobile complète de réservation d’hôtels développée avec Flutter.

Elle répond aux exigences principales du mini-projet :

- Application fonctionnelle
- Interface moderne et responsive
- Architecture MVC respectée
- Authentification
- CRUD complet
- Stockage local
- Formulaires avec validation
- Documentation claire
- Captures d’écran principales
- Fonctionnalités avancées intégrées

Ce projet montre une mise en pratique complète des notions étudiées en programmation mobile, avec une organisation claire du code et une expérience utilisateur cohérente.
