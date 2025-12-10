

**Stratégie :**
- Garder SwiftData pour le cache local
- Ajouter un champ `syncStatus` à Insight
- Synchroniser automatiquement quand connecté

```swift
enum SyncStatus: String, Codable {
    case pending    // Pas encore sync
    case synced     // Sync avec serveur
    case error      // Erreur de sync
}

@Model
final class Insight {
    @Attribute(.unique) private(set) var id: UUID
    var serverId: String?  // ID du serveur
    var userThought: String
    var generatedInsight: String
    var timestamp: Date
    var syncStatus: SyncStatus
}
```

### 1.3 Sécurité renforcée

**Actions immédiates :**
1. Ajouter token refresh si JWT expires
2. Valider le token côté serveur pour toutes les requêtes
3. Chiffrer les insights sensibles en local (optionnel)
4. Rate limiting côté backend

```swift
// Ajouter dans AuthService.swift
func refreshToken(currentToken: String) async throws -> User {
    try await server.request(
        endpoint: "refresh-token", 
        method: "POST", 
        headers: ["Authorization": "Bearer \(currentToken)"]
    )
}
```

### 1.4 Localisation complète

**Fichiers à compléter :**
- `Localizable.xcstrings`

**Strings manquantes :**
```json
{
  "Done": {
    "localizations": {
      "fr": { "stringUnit": { "state": "translated", "value": "Terminé" }}
    }
  },
  "Au moins 8 caractères": {
    "localizations": {
      "fr": { "stringUnit": { "state": "translated", "value": "Au moins 8 caractères" }}
    }
  },
  "Un chiffre": {
    "localizations": {
      "fr": { "stringUnit": { "state": "translated", "value": "Un chiffre" }}
    }
  },
  "Une lettre majuscule": {
    "localizations": {
      "fr": { "stringUnit": { "state": "translated", "value": "Une lettre majuscule" }}
    }
  },
  "Une lettre minuscule": {
    "localizations": {
      "fr": { "stringUnit": { "state": "translated", "value": "Une lettre minuscule" }}
    }
  },
  "Un caractère spécial (!@#$%^&*)": {
    "localizations": {
      "fr": { "stringUnit": { "state": "translated", "value": "Un caractère spécial (!@#$%^&*)" }}
    }
  },
  "Erreur: %@": {
    "localizations": {
      "fr": { "stringUnit": { "state": "translated", "value": "Erreur : %@" }}
    }
  }
}
```

---

## ⚡ PHASE 2 : Amélioration UX (2-3 jours)

### 2.1 Transformer en outil décisionnel

**Concept :** Ne pas afficher l'insight brut, mais proposer des actions concrètes.

**Nouveau flow :**
1. L'utilisateur écrit sa pensée
2. L'app analyse et propose 3 options :
   - ✅ Recadrer positivement
   - 🔄 Perspective alternative
   - 📊 Analyser le pattern

**Fichiers à modifier :**
- `InsightView.swift`
- `InsightController.swift`

**Nouveau modèle :**
```swift
struct ReframeOptions: Decodable {
    let originalThought: String
    let analysis: String
    let options: [ReframeOption]
}

struct ReframeOption: Decodable, Identifiable {
    let id: String
    let type: OptionType
    let title: String
    let suggestion: String
    let actionable: Bool
}

enum OptionType: String, Decodable {
    case reframe
    case alternative
    case pattern
}
```

### 2.2 Historique enrichi avec patterns

**Vue améliorée :**
- Grouper par semaine/mois
- Identifier les patterns récurrents
- Afficher les progrès

```swift
struct PatternInsight {
    let pattern: String          // "Tu te soucies souvent de..."
    let frequency: Int           // Nombre d'occurrences
    let suggestion: String       // Action recommandée
    let relatedInsights: [Insight]
}
```

### 2.3 Notifications intelligentes

**Rappels contextuels :**
- "Tu n'as pas fait de check-in aujourd'hui"
- "Pattern détecté : anxiété le lundi matin"
- "Ça fait 3 jours, comment te sens-tu ?"

---

## 🎨 PHASE 3 : Polish final (1 jour)

### 3.1 Animations et feedback

```swift
// Dans InsightView.swift
.onChange(of: controller.generatedInsight) { _, newValue in
    if newValue != nil {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            // Animation d'apparition
        }
    }
}
```

### 3.2 États de chargement améliorés

```swift
enum LoadingState {
    case idle
    case analyzing      // "Analyse de ta pensée..."
    case generating     // "Génération des options..."
    case complete
    case error(String)
}
```

### 3.3 Onboarding

**Première utilisation :**
1. Écran de bienvenue
2. Explication du concept
3. Exemple interactif
4. Demande de notifications

---

## 📱 Checklist avant soumission App Store

### Technique
- [ ] Tous les strings localisés (EN + FR)
- [ ] Gestion des erreurs réseau
- [ ] Pas de crash en mode Airplane
- [ ] Rotation d'écran gérée
- [ ] Support iPad (si applicable)
- [ ] Dark mode fonctionnel
- [ ] Performance : < 2s pour générer insight

### Légal
- [ ] Politique de confidentialité à jour
- [ ] CGU accessibles
- [ ] Consentement RGPD explicite
- [ ] Bouton "Supprimer mes données" fonctionnel
- [ ] Export des données utilisateur (optionnel mais recommandé)

### App Store Connect
- [ ] Screenshots (iPhone 6.7", 6.5", 5.5")
- [ ] Description EN + FR
- [ ] Mots-clés optimisés
- [ ] Catégorie : Santé & Forme ou Productivité
- [ ] Rating : 4+ (pas de contenu sensible)
- [ ] Privacy Nutrition Label complété

---

## 🚀 Ordre d'implémentation recommandé

### Jour 1-2
1. Backend : endpoints CRUD pour insights
2. Sync SwiftData ↔ Backend
3. Token refresh automatique

### Jour 3-4
4. UX : système d'options au lieu de texte brut
5. Historique avec patterns
6. Localisation complète

### Jour 5
7. Notifications
8. Onboarding
9. Tests finaux

### Jour 6
10. Screenshots
11. Métadonnées App Store
12. Soumission 🎉

---

## 💡 Conseils pour différenciation

**Ce qui rend Reframe unique :**
1. **Pas un journal** : C'est un outil de recadrage actif
2. **Pas un chatbot** : Options structurées, pas de conversation
3. **Patterns intelligents** : L'app apprend de tes pensées récurrentes
4. **Actionable** : Chaque insight mène à une action concrète

**Message marketing :**
> "Reframe ne stocke pas tes pensées, il les transforme en actions. Moins de bruit mental, plus de clarté."

---

## 🔧 Outils nécessaires côté backend

**Stack recommandée :**
- Node.js + Express (déjà en place)
- PostgreSQL ou MongoDB pour les insights
- JWT pour l'auth
- Redis pour le rate limiting (optionnel)

**Endpoints minimaux :**
```
POST   /api/auth/signup
POST   /api/auth/login
POST   /api/auth/apple-login
GET    /api/auth/verify-token
POST   /api/auth/refresh-token
DELETE /api/auth/delete-account

POST   /api/insights              (créer)
GET    /api/insights              (lister)
GET    /api/insights/:id          (détail)
DELETE /api/insights/:id          (supprimer)
GET    /api/insights/patterns     (analyser patterns)

POST   /api/reframe                (générer options de recadrage)
```

---

## ❓ Questions à répondre avant de commencer

1. **Backend prêt ?** Avez-vous déjà une DB pour stocker les insights ?
2. **Budget AI ?** Quel modèle utilisez-vous (GPT, Claude, local) ?
3. **Délai réel ?** Combien de jours avant soumission ?
4. **Équipe ?** Travaillez-vous seul ou avec un backend dev ?
5. **Priorité #1 ?** Sécurité, UX, ou fonctionnalités ?

**Répondez à ces questions et je vous fournirai le code exact à implémenter en priorité !**
