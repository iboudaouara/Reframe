# Reframe — Connexion / Authentification

## Objectif
Permettre à l’utilisateur d’accéder à son espace personnel et à son historique via un compte hébergé sur le serveur ou via “Sign in with Apple”.

## Acteurs
- Utilisateur
- Serveur d’authentification
- Service “Sign in with Apple”

## Méthodes disponibles
- Sign in with Apple uniquement.

## Scénario principal
1. L’utilisateur ouvre l’application.
2. L’utilisateur voit deux options : “Se connecter avec un compte” et “Se connecter avec Apple”.
3. L’utilisateur choisit un service.
4. L’application vérifie l’identité :
   - Pour le compte serveur : vérifier email + mot de passe
   - Pour Apple : OAuth via Apple
5. Si l’authentification réussit, l’utilisateur est redirigé vers l’écran principal.

## Scénarios alternatifs
- **1A.** L’utilisateur refuse la permission Apple → afficher un message d’erreur.
- **1B.** L’utilisateur saisit des identifiants invalides → afficher un message d’erreur.
- **1C.** L’utilisateur n’a pas Internet → afficher “Connexion impossible”.

## Tests TDD possibles
- Vérifier que les boutons de connexion sont visibles.
- Vérifier que l’application affiche un message d’erreur si l’authentification échoue.
- Vérifier qu’après connexion, l’écran principal s’affiche avec le nom de l’utilisateur.
