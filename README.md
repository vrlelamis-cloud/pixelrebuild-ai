# PixelRebuild AI

Application Flutter Android de reconstruction et d'amélioration d'images, avec traitement local prioritaire.

## État actuel

Cette première version publique fournit une base fonctionnelle et honnête :

- sélection d'images depuis l'appareil ;
- analyse et décodage locaux ;
- agrandissement 2×, 4× et 8× ;
- interpolation bicubique CPU via le package `image` ;
- export et partage du résultat ;
- thème sombre Material 3 ;
- tests de calcul des dimensions ;
- workflow GitHub Actions de génération APK.

Les modes IA sont affichés comme indisponibles tant qu'un modèle Android vérifié (licence, opérateurs, poids et performances) n'est pas intégré. Le projet ne prétend donc pas exécuter une super-résolution IA avant cette validation.

## Lancer le projet

Installer Flutter stable, puis :

```bash
flutter pub get
flutter run
```

Pour générer les fichiers Android manquants dans cette base :

```bash
flutter create --platforms=android --project-name pixelrebuild_ai .
```

## Validation

```bash
flutter analyze
flutter test
flutter build apk --release
```

## Prochaine étape technique

Évaluer Real-ESRGAN ou un modèle équivalent pour ONNX Runtime Android/TFLite, vérifier sa licence et ses opérateurs, mesurer la mémoire sur plusieurs appareils, puis implémenter une classe native `AiSuperResolutionEngine` derrière l'interface de traitement. Aucun modèle ni poids non vérifié n'est téléchargé automatiquement.

## Limitation connue

L'environnement initial de génération ne disposait pas du SDK Flutter ; la compilation sera exécutée par GitHub Actions, qui installe Flutter et génère les plateformes Android avant les tests.
