# Configuration Firebase App Distribution

Firebase App Distribution vous permet de distribuer automatiquement vos builds Android/iOS aux testeurs.

## 🔧 Configuration Initiale

### 1. Créer un Projet Firebase

1. Allez sur [Firebase Console](https://console.firebase.google.com/)
2. Créez un nouveau projet ou sélectionnez un existant
3. Ajoutez une application Android :
   - Package name : `ca.charlemagne.croiz` (vérifiez dans `frontend/android/app/build.gradle.kts`)
   - Téléchargez le fichier `google-services.json`

### 2. Ajouter google-services.json

Placez le fichier `google-services.json` téléchargé dans :
```
frontend/android/app/google-services.json
```

**Important** : Ce fichier est déjà dans `.gitignore` - ne le commitez jamais !

### 3. Configurer le Build Gradle Android

Ajoutez le plugin Google Services dans `frontend/android/build.gradle.kts` :

```kotlin
buildscript {
    dependencies {
        classpath("com.google.gms:google-services:4.4.0")
    }
}
```

Et dans `frontend/android/app/build.gradle.kts`, à la fin du fichier :

```kotlin
apply(plugin = "com.google.gms.google-services")
```

### 4. Configurer GitHub Secrets

Allez dans **Settings > Secrets and variables > Actions** de votre repo et ajoutez :

#### FIREBASE_APP_ID
1. Dans Firebase Console, allez dans **Project Settings**
2. Sélectionnez votre app Android
3. Copiez l'**App ID**

#### FIREBASE_SERVICE_ACCOUNT
1. Dans Firebase Console, allez dans **Project Settings > Service accounts**
2. Cliquez sur **Generate new private key**
3. Téléchargez le fichier JSON
4. Ouvrez le fichier et copiez **tout le contenu JSON**
5. Collez-le dans le secret GitHub

## 📱 Utilisation

### Distribution Automatique

Le workflow `.github/workflows/firebase-distribution.yml` se déclenche automatiquement :
- À chaque push sur `main` ou `develop`
- Manuellement via l'onglet **Actions** de GitHub

### Ajouter des Testeurs

1. Dans Firebase Console, allez dans **App Distribution**
2. Cliquez sur **Testers & Groups**
3. Créez un groupe "testers"
4. Ajoutez des emails de testeurs

Les testeurs recevront :
- Un email d'invitation
- Un lien pour télécharger l'app Firebase App Distribution (si pas déjà installée)
- Des notifications à chaque nouveau build

### Télécharger l'APK sur Téléphone

#### Méthode 1 : Via Firebase App Distribution (recommandé)
1. Installez [Firebase App Distribution](https://play.google.com/store/apps/details?id=com.google.firebase.appdistribution) depuis le Play Store
2. Connectez-vous avec l'email utilisé comme testeur
3. Vous verrez tous les builds disponibles
4. Cliquez sur "Download" puis "Install"

#### Méthode 2 : Via Email
1. Ouvrez l'email de notification sur votre téléphone
2. Cliquez sur le lien
3. Téléchargez et installez

#### Méthode 3 : Via GitHub Artifacts (pour développeurs)
1. Allez dans l'onglet **Actions** de votre repo
2. Sélectionnez le workflow **Firebase App Distribution**
3. Cliquez sur le dernier run réussi
4. Téléchargez l'artifact `app-release-xxxxx`
5. Transférez l'APK sur votre téléphone et installez-le

## 🔒 Sécurité

### Activer les Sources Inconnues

Pour installer des APKs hors Play Store, activez sur votre téléphone :
1. **Paramètres > Sécurité**
2. Activez **Sources inconnues** ou **Installer des applications inconnues**
3. Autorisez Chrome/Firefox/Firebase App Distribution

### Signature de l'APK

Pour la production, vous devrez créer une clé de signature :

```bash
cd frontend/android
keytool -genkey -v -keystore croiz-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias croiz
```

Puis configurez dans `frontend/android/key.properties` :
```properties
storePassword=votre_mot_de_passe
keyPassword=votre_mot_de_passe
keyAlias=croiz
storeFile=croiz-release-key.jks
```

Et dans `frontend/android/app/build.gradle.kts` :
```kotlin
android {
    signingConfigs {
        create("release") {
            storeFile = file("../croiz-release-key.jks")
            storePassword = System.getenv("KEYSTORE_PASSWORD")
            keyAlias = "croiz"
            keyPassword = System.getenv("KEY_PASSWORD")
        }
    }
    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}
```

Ajoutez les secrets dans GitHub :
- `KEYSTORE_PASSWORD`
- `KEY_PASSWORD`
- `KEYSTORE_FILE` (encodé en base64)

## 📊 Suivi des Installations

Dans Firebase Console > App Distribution, vous pouvez voir :
- Nombre de testeurs
- Qui a téléchargé quelle version
- Feedback des testeurs
- Crashes (si Firebase Crashlytics est configuré)

## 🐛 Dépannage

### Erreur "App not installed"
- Vérifiez que vous avez autorisé les sources inconnues
- Désinstallez l'ancienne version si elle existe
- Vérifiez que l'architecture CPU est compatible (x86_64 vs ARM)

### Testeur ne reçoit pas d'email
- Vérifiez les spams
- Vérifiez que l'email est bien ajouté dans Firebase Console
- Re-envoyez l'invitation

### Build échoue dans GitHub Actions
- Vérifiez que `FIREBASE_APP_ID` est correct
- Vérifiez que `FIREBASE_SERVICE_ACCOUNT` est un JSON valide
- Vérifiez les logs du workflow

## 🚀 Commandes Manuelles

Pour tester localement avant de push :

```powershell
# Build l'APK
cd frontend
flutter build apk --release

# Upload manuellement avec Firebase CLI
npm install -g firebase-tools
firebase login
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk `
  --app YOUR_FIREBASE_APP_ID `
  --groups testers `
  --release-notes "Test manuel"
```

## 📝 Notes

- Les APKs sont conservés 30 jours dans GitHub Artifacts
- Firebase App Distribution garde l'historique des builds
- Vous pouvez avoir plusieurs groupes de testeurs (alpha, beta, etc.)
- Les release notes incluent automatiquement le commit et l'auteur
