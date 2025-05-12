# Tableau de Bord CI/CD pour Docker Compose

*Note: Ce projet est une démonstration pour un TP académique et donne simplement une idée de ce que pourrait être un véritable tableau de bord CI/CD. Il a été développé dans le cadre d'un cours sur Flutter.*

## Aperçu du Projet

Ce tableau de bord CI/CD est une application Flutter conçue pour surveiller et gérer les pipelines d'intégration continue et de déploiement continu (CI/CD) pour les projets utilisant Docker Compose. L'application offre une interface utilisateur intuitive pour visualiser l'état des builds, des déploiements et des services en temps réel.

## Contexte du TP

Ce projet a été développé dans le cadre d'un TP (Travaux Pratiques) sur Flutter, où l'objectif était de mettre en pratique les concepts suivants:

- Création d'interfaces utilisateur avec Flutter
- Navigation entre différents écrans
- Gestion d'état avec Provider
- Utilisation de widgets personnalisés
- Implémentation de thèmes (clair/sombre)
- Affichage de données dynamiques
- Organisation du code selon les bonnes pratiques

## Fonctionnalités Détaillées

### Écran d'Accueil (Dashboard)
- Vue d'ensemble des métriques clés (builds réussis, échecs, temps moyen)
- Visualisation de l'état des pipelines avec indicateurs colorés
- Liste des projets récents avec leur statut actuel
- Flux d'activités récentes dans le système

### Gestion des Projets
- Liste complète des repositories connectés
- Détails de chaque projet (branche, dernier commit, statut)
- Actions rapides pour déclencher des builds ou des déploiements
- Filtrage des projets par statut ou environnement

### Surveillance des Builds
- Historique chronologique des builds
- Détails de chaque build (durée, commit associé, auteur)
- Visualisation des étapes de build (clone, build, test, package)
- Logs associés à chaque étape du processus

### Gestion des Déploiements
- Suivi des déploiements par environnement (dev, staging, production)
- Support de différentes stratégies de déploiement
- Historique des déploiements avec possibilité de rollback
- Métriques de performance des déploiements

### Surveillance des Services
- Métriques en temps réel des services déployés
- Graphiques d'utilisation des ressources (CPU, mémoire, réseau)
- État de santé des services avec vérifications automatiques
- Configuration des variables d'environnement et des ports

## Architecture Technique

### Modèles de Données
Le projet utilise plusieurs modèles pour représenter les différentes entités:
- `Repository`: Représente un dépôt de code source
- `Build`: Représente un processus de build avec ses étapes
- `Deployment`: Représente un déploiement vers un environnement
- `Service`: Représente un service déployé et ses métriques
- `Activity`: Représente une action dans le système

### Services
- `RepositoryService`: Gère l'état global des repositories et leurs données associées
- `MockDataService`: Génère des données simulées pour démontrer les fonctionnalités
- `MockServiceData`: Génère des données spécifiques aux services déployés

### Interface Utilisateur
- Utilisation de Material Design avec personnalisation
- Support des thèmes clairs et sombres
- Composants réutilisables pour la cohérence visuelle
- Animations fluides pour améliorer l'expérience utilisateur

## Technologies et Bibliothèques Utilisées

- **Flutter**: Framework UI cross-platform (v3.x)
- **Dart**: Langage de programmation (v3.x)
- **Provider**: Pour la gestion d'état de l'application
- **fl_chart**: Pour les visualisations graphiques des métriques
- **flutter_svg**: Pour l'affichage d'icônes vectorielles
- **percent_indicator**: Pour les indicateurs de progression
- **intl**: Pour l'internationalisation et le formatage
- **shared_preferences**: Pour la persistance des préférences
- **faker**: Pour la génération de données de démonstration

## Structure Détaillée du Projet

```
cicd_dashboard/
├── lib/
│   ├── models/
│   │   ├── repository.dart       # Modèle de dépôt de code
│   │   ├── build.dart            # Modèle de build
│   │   ├── deployment.dart       # Modèle de déploiement
│   │   ├── service.dart          # Modèle de service
│   │   ├── activity.dart         # Modèle d'activité
│   │   └── models.dart           # Export des modèles
│   │
│   ├── screens/
│   │   ├── dashboard_screen.dart # Écran principal
│   │   ├── projects_screen.dart  # Liste des projets
│   │   ├── builds_screen.dart    # Historique des builds
│   │   ├── monitoring_screen.dart # Surveillance des services
│   │   └── screens.dart          # Export des écrans
│   │
│   ├── services/
│   │   ├── repository_service.dart # Service principal
│   │   ├── mock_data_service.dart  # Génération de données
│   │   └── mock_service_data.dart  # Données des services
│   │
│   ├── theme/
│   │   └── app_theme.dart        # Configuration des thèmes
│   │
│   ├── widgets/
│   │   ├── repository_card.dart  # Carte de projet
│   │   ├── pipeline_stage.dart   # Étape de pipeline
│   │   ├── status_badge.dart     # Badge de statut
│   │   ├── activity_feed_item.dart # Item d'activité
│   │   ├── resource_usage_chart.dart # Graphique d'utilisation
│   │   └── widgets.dart          # Export des widgets
│   │
│   └── main.dart                 # Point d'entrée
│
├── assets/
│   ├── images/                   # Images
│   └── icons/                    # Icônes
│
└── pubspec.yaml                  # Configuration des dépendances
```

## Installation et Exécution

1. Assurez-vous d'avoir Flutter installé sur votre machine:
   ```
   flutter --version
   ```

2. Clonez ce repository:
   ```
   git clone git@github.com:mountassirJerrari/S-ance-12---UI-et-Navigation-dans-Flutter.git
   cd S-ance-12---UI-et-Navigation-dans-Flutter
   ```

3. Installez les dépendances:
   ```
   flutter pub get
   ```

4. Lancez l'application sur l'appareil de votre choix:
   ```
   flutter run
   ```

## Captures d'écran

L'application comprend plusieurs écrans principaux:

- **Dashboard**: Vue d'ensemble des métriques et activités
- **Projets**: Liste et gestion des repositories
- **Builds**: Historique et détails des builds
- **Monitoring**: Surveillance des services déployés

## Perspectives d'Amélioration

- Intégration avec de véritables API CI/CD (GitHub Actions, GitLab CI, Jenkins)
- Ajout de notifications en temps réel (push, email)
- Implémentation d'une authentification utilisateur et gestion des rôles
- Support pour d'autres systèmes d'orchestration de conteneurs (Kubernetes)
- Ajout de fonctionnalités d'analyse de logs et de détection d'anomalies
- Internationalisation complète de l'interface
- Tests unitaires et d'intégration

---

*Ce projet a été développé dans le cadre d'un TP académique pour démontrer l'utilisation de Flutter dans le développement d'applications de surveillance d'infrastructure. Il s'agit d'une démonstration et non d'un produit prêt pour la production.*
