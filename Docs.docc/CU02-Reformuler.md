# Cas d’utilisation : Génération d’un insight

## Nom du cas d’utilisation : Générer un insight

## Acteurs principaux :
- Utilisateur
- Module Insight / moteur de génération d’insights
- Serveur (si nécessaire pour traitement ou stockage)

## Objectif :
Permettre à l’utilisateur de créer un insight basé sur ses données ou activités, et de le visualiser dans son historique.

## Préconditions :
- L’utilisateur est connecté à l’application.
- L’utilisateur dispose de données suffisantes pour générer un insight.
- L’appareil est connecté à Internet (si le traitement nécessite le serveur).
## Scénario principal :
- L’utilisateur ouvre l’écran “Insights”.
- L’utilisateur clique sur “Générer un nouvel insight”.
- L’application récupère les données nécessaires (locales ou serveur).
- Le moteur Insight traite les données et génère l’insight.
- L’application affiche l’insight à l’utilisateur.
- L’insight est sauvegardé dans l’historique de l’utilisateur.

## Scénarios alternatifs :
- 1A. L’utilisateur n’a pas suffisamment de données → afficher un message “Impossible de générer un insight”.
- 1B. Le serveur ne répond pas → afficher “Erreur de génération, réessayez plus tard”.

## Postconditions :
- L’insight est visible dans l’écran principal des insights.
- L’insight est sauvegardé dans l’historique pour consultation future.

## Notes / règles métier :
- Les insights doivent être générés de manière rapide (<2 sec si possible).
- Les insights doivent respecter la confidentialité des données utilisateur.
- Chaque insight doit être unique pour éviter la duplication dans l’historique.
