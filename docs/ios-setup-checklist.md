# Checklist: Configuration iOS Firebase Distribution

## ✅ Déjà fait

- [x] Bundle ID iOS configuré : `ca.charlemagne.croiz`
- [x] Package Android configuré : `ca.charlemagne.croiz`
- [x] Workflow GitHub Actions prêt
- [x] Documentation créée
- [x] **App iOS créée dans Firebase Console**
- [x] **GoogleService-Info.plist placé dans `frontend/ios/Runner/`**
- [x] **Firebase App ID iOS** : `1:439585026140:ios:4c726108f5f68a36997699`
- [x] **Podfile configuré avec dépendances Firebase**

## 📋 À faire AVANT de commiter et pousser

### 1. ~~Créer l'application iOS dans Firebase Console~~ ✅ FAIT

**✅ Cette étape est déjà complétée.**

**Firebase App ID iOS** : `1:439585026140:ios:4c726108f5f68a36997699`

### 2. Créer un compte Apple Developer

**Si vous n'avez pas encore de compte :**

1. Aller sur : https://developer.apple.com/programs/
2. S'inscrire au Apple Developer Program (99 USD/an)
3. Attendre l'approbation (peut prendre 24-48h)

**Une fois approuvé :**

1. Aller sur : https://developer.apple.com/account
2. Noter votre **Team ID** (visible dans Membership)

### 3. Créer l'App ID sur Apple Developer

1. Aller sur : https://developer.apple.com/account/resources/identifiers/list
2. Cliquer sur le "+" pour créer un nouveau identifier
3. Sélectionner "App IDs" > Continue
4. Type: App
5. Description: "Croiz Crossword Game"
6. Bundle ID: **Explicit** - `ca.charlemagne.croiz`
7. Capabilities: Sélectionner celles nécessaires (Push Notifications, etc.)
8. Register

### 4. Créer un Certificat de Distribution

**Sur macOS uniquement :**

1. Ouvrir "Keychain Access"
2. Menu > Certificate Assistant > Request a Certificate from a Certificate Authority
3. Entrer votre email, nom
4. Sélectionner "Saved to disk"
5. Sauvegarder le .certSigningRequest

**Sur Apple Developer Portal :**

1. Aller sur : https://developer.apple.com/account/resources/certificates/list
2. Cliquer sur "+"
3. Sélectionner "Apple Distribution"
4. Uploader le .certSigningRequest
5. Télécharger le certificat (.cer)
6. Double-cliquer pour l'installer dans Keychain

**Exporter le certificat en .p12 :**

1. Ouvrir Keychain Access
2. Chercher le certificat "Apple Distribution"
3. Clic droit > Export
4. Format: Personal Information Exchange (.p12)
5. **Créer un mot de passe** (noter ce mot de passe!)
6. Sauvegarder comme `certificate.p12`

**Convertir en base64 :**
```bash
base64 -i certificate.p12 -o certificate_base64.txt
```

### 5. Créer un Profil de Provisionnement Ad Hoc

1. Aller sur : https://developer.apple.com/account/resources/profiles/list
2. Cliquer sur "+"
3. Sélectionner "Ad Hoc"
4. App ID: `ca.charlemagne.croiz`
5. Sélectionner le certificat "Apple Distribution" créé à l'étape 4
6. Sélectionner les devices de test (il faut d'abord enregistrer des devices)
7. Profile Name: "Croiz AdHoc Distribution"
8. Generate
9. Télécharger le profil `.mobileprovision`

**Convertir en base64 :**
```bash
base64 -i profile.mobileprovision -o profile_base64.txt
```

### 6. Mettre à jour ExportOptions.plist

Éditer `frontend/ios/ExportOptions.plist` :

```xml
<key>teamID</key>
<string>VOTRE_TEAM_ID_ICI</string>  <!-- De l'étape 2 -->

<key>provisioningProfiles</key>
<dict>
    <key>ca.charlemagne.croiz</key>
    <string>Croiz AdHoc Distribution</string>  <!-- Nom exact du profil de l'étape 5 -->
</dict>
```

### 7. Ajouter les Secrets GitHub

Aller dans : **GitHub Repository > Settings > Secrets and variables > Actions**

Créer ces 4 nouveaux secrets :

| Secret Name | Value | Source |
|------------|-------|--------|
| `FIREBASE_APP_ID_IOS` | `1:xxxxx:ios:xxxxx` | Firebase Console (étape 1) |
| `IOS_P12_BASE64` | Contenu de `certificate_base64.txt` | Étape 4 |
| `IOS_P12_PASSWORD` | Le mot de passe du .p12 | Étape 4 |
| `IOS_PROVISIONING_PROFILE_BASE64` | Contenu de `profile_base64.txt` | Étape 5 |

**Vérifier les secrets existants :**
- `FIREBASE_APP_ID` (Android)
- `FIREBASE_SERVICE_ACCOUNT`

## ⚠️ Notes importantes

### Enregistrement des Devices de Test

Pour le profil Ad Hoc, vous devez enregistrer les UDIDs des iPhones de test :

1. Connecter l'iPhone à un Mac
2. Ouvrir Finder > iPhone > onglet Général
3. Cliquer sur le numéro de série pour afficher l'UDID
4. Sur Apple Developer : https://developer.apple.com/account/resources/devices/list
5. Cliquer sur "+" et ajouter le device avec son UDID

### Alternative : Provisioning Profile "Development"

Si vous voulez juste tester localement sans Firebase Distribution :
- Créer un profil "iOS App Development" au lieu de "Ad Hoc"
- Pas besoin de base64, juste télécharger et double-cliquer

## 🚀 Une fois tout configuré

1. Commiter et pousser les changements
2. Aller dans GitHub Actions
3. Lancer "Firebase App Distribution"
4. Choisir "ios" ou "both"
5. Le build se lancera et distribuera l'app sur Firebase

## 📚 Ressources

- [Documentation iOS Firebase Setup](docs/ios-firebase-setup.md)
- [Apple Developer Portal](https://developer.apple.com/account)
- [Firebase Console](https://console.firebase.google.com/)
- [Flutter iOS Deployment](https://docs.flutter.dev/deployment/ios)

## ❓ Questions fréquentes

**Q: J'ai pas de Mac, je peux quand même faire tout ça ?**
R: Non, vous avez besoin d'un Mac pour :
- Créer le Certificate Signing Request
- Exporter le certificat en .p12
- Tester localement l'app iOS

**Q: Le build échoue sur GitHub Actions ?**
R: Vérifier que :
- Les 4 secrets iOS sont bien ajoutés
- Le Team ID est correct dans ExportOptions.plist
- Le nom du profil de provisionnement est exact (sensible à la casse)

**Q: Je dois refaire ces étapes à chaque fois ?**
R: Non, une fois configuré, c'est bon pour toute la vie du projet. Sauf :
- Renouvellement du certificat (1 an)
- Ajout de nouveaux devices de test
- Changement de Bundle ID
