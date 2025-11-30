# Configuration iOS pour Firebase App Distribution

## Prérequis

1. **Compte Apple Developer** avec accès à l'équipe
2. **Certificat de distribution** (.p12)
3. **Profil de provisionnement** Ad Hoc (.mobileprovision)
4. **App iOS créée dans Firebase Console**

## Étapes de configuration

### 1. Créer l'app iOS dans Firebase

1. Aller dans la Firebase Console : https://console.firebase.google.com/
2. Sélectionner votre projet Croiz
3. Cliquer sur "Add app" et choisir iOS
4. Renseigner le Bundle ID : `ca.charlemagne.croiz`
5. Télécharger le fichier `GoogleService-Info.plist`
6. Placer ce fichier dans `frontend/ios/Runner/GoogleService-Info.plist`

**✅ Cette étape est déjà complétée pour ce projet.**

**Firebase App ID iOS**
### 2. Installer les dépendances Firebase (sur macOS avec Xcode)

Le projet utilise CocoaPods pour gérer les dépendances Firebase. Le `Podfile` est déjà configuré.

**Sur macOS, exécuter :**
```bash
cd frontend/ios
pod install
```

**Dépendances Firebase incluses :**
- `FirebaseAnalytics` : Analytics
- `FirebaseAppDistribution` : Distribution aux testeurs

**Note :** Sur Windows, cette étape sera automatiquement effectuée par le GitHub Actions runner macOS lors du build.

### 3. Initialiser Firebase dans l'application

Le fichier `AppDelegate.swift` est déjà configuré avec l'initialisation Firebase :

```swift
import FirebaseCore

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()  // Initialize Firebase
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

**✅ Cette étape est déjà complétée pour ce projet.**

### 4. Configurer ExportOptions.plist

Éditer `frontend/ios/ExportOptions.plist` :

```xml
<key>teamID</key>
<string>VOTRE_TEAM_ID</string>  <!-- Trouvé dans Apple Developer Account -->

<key>provisioningProfiles</key>
<dict>
    <key>ca.charlemagne.croiz</key>  <!-- Bundle ID de l'application -->
    <string>NOM_DU_PROFIL_DE_PROVISIONNEMENT</string>
</dict>
```

### 5. Exporter le certificat en base64

Sur macOS :

```bash
# Exporter le certificat depuis Keychain Access en .p12
# Puis convertir en base64
base64 -i certificate.p12 -o certificate_base64.txt
```

### 6. Convertir le profil de provisionnement en base64

```bash
base64 -i profile.mobileprovision -o profile_base64.txt
```

### 7. Ajouter les secrets GitHub

Aller dans : `Settings > Secrets and variables > Actions > New repository secret`

Créer les secrets suivants :

| Nom du secret | Description | Comment l'obtenir |
|---------------|-------------|-------------------|
| `FIREBASE_APP_ID_IOS` | ID de l'app iOS dans Firebase | Firebase Console > Project Settings > Your apps > iOS app |
| `IOS_P12_BASE64` | Certificat de signature encodé | Contenu de `certificate_base64.txt` |
| `IOS_P12_PASSWORD` | Mot de passe du certificat .p12 | Celui défini lors de l'export du certificat |
| `IOS_PROVISIONING_PROFILE_BASE64` | Profil de provisionnement encodé | Contenu de `profile_base64.txt` |

**Secrets existants à vérifier :**
- `FIREBASE_APP_ID` : ID de l'app Android
- `FIREBASE_SERVICE_ACCOUNT` : Credentials du service account Firebase

### 8. Obtenir Team ID et Bundle ID

**Team ID :**
1. Aller sur https://developer.apple.com/account
2. Cliquer sur "Membership"
3. Copier le "Team ID"

**Bundle ID :**
Le Bundle ID est : `ca.charlemagne.croiz` (déjà configuré)

Vous pouvez le vérifier dans Xcode :
1. Ouvrir `frontend/ios/Runner.xcworkspace` dans Xcode
2. Sélectionner le projet Runner
3. Dans "Signing & Capabilities", noter le "Bundle Identifier"

### 9. Créer un certificat et un profil de provisionnement

**Si vous n'avez pas encore de certificat :**

1. Aller sur https://developer.apple.com/account/resources/certificates
2. Créer un "Apple Distribution" certificate
3. Télécharger et double-cliquer pour l'installer dans Keychain
4. Exporter depuis Keychain Access (clic droit > Export) en .p12

**Profil de provisionnement Ad Hoc :**

1. Aller sur https://developer.apple.com/account/resources/profiles
2. Créer un nouveau profil "Ad Hoc"
3. Sélectionner votre App ID
4. Sélectionner le certificat de distribution
5. Sélectionner les devices de test
6. Télécharger le fichier .mobileprovision

## Utilisation

### Lancer le workflow

1. Aller dans `Actions` sur GitHub
2. Sélectionner "Firebase App Distribution"
3. Cliquer "Run workflow"
4. Choisir la plateforme :
   - `android` : Build APK Android uniquement
   - `ios` : Build IPA iOS uniquement
   - `both` : Build les deux plateformes

### Tester localement

**Android :**
```bash
cd frontend
flutter build apk --release
```

**iOS (nécessite macOS) :**
```bash
cd frontend
flutter build ipa --release --export-options-plist=ios/ExportOptions.plist
```

## Dépannage

### Erreur "No valid code signing"
- Vérifier que le certificat est bien importé dans le keychain
- Vérifier que le Team ID et Bundle ID sont corrects dans ExportOptions.plist
- Vérifier que le profil de provisionnement correspond au certificat

### Erreur "Provisioning profile not found"
- Vérifier que le nom du profil dans ExportOptions.plist correspond exactement
- S'assurer que le profil est bien encodé en base64 sans retours à la ligne

### Erreur Firebase "App not found"
- Vérifier que `FIREBASE_APP_ID_IOS` correspond à l'ID iOS dans Firebase Console
- Ne pas confondre avec `FIREBASE_APP_ID` (Android)

## Ressources

- [Firebase App Distribution iOS](https://firebase.google.com/docs/app-distribution/ios/distribute-console)
- [Apple Code Signing](https://developer.apple.com/support/code-signing/)
- [Flutter iOS Deployment](https://docs.flutter.dev/deployment/ios)
