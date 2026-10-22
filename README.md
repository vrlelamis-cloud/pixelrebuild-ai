# PixelRebuild

[![CI](https://github.com/vrlelamis-cloud/pixelrebuild-ai/actions/workflows/ci.yml/badge.svg)](https://github.com/vrlelamis-cloud/pixelrebuild-ai/actions/workflows/ci.yml)
[![Licence : MIT](https://img.shields.io/badge/licence-MIT-blue.svg)](LICENSE)

Application Android (Flutter) qui **agrandit vos images directement sur le téléphone**.
Aucune photo n’est envoyée sur internet : l’application ne demande aucune permission réseau.

## Fonctionnalités

- Choix d’une image depuis la galerie (JPEG, PNG, WebP, etc.).
- Agrandissement ×2, ×4 ou ×8 par interpolation bicubique.
- Traitement en arrière-plan (Isolate), avec annulation possible.
- Plafond mémoire : le facteur est réduit automatiquement si le résultat dépasserait 16 Mpx.
- Comparaison avec l’original, enregistrement dans la galerie et partage.

## Ce que l’application fait (et ne fait pas)

L’agrandissement bicubique **lisse** l’image : il n’invente pas de détails. Les modes
« IA standard », « Qualité maximale » et « Anime » sont affichés mais **désactivés** :
ils seront activés lorsqu’un modèle de super-résolution vérifié sera intégré
(voir la feuille de route).

## Architecture

```
lib/
├── main.dart, app.dart        point d’entrée, MaterialApp
├── core/                      thème, formatage
├── models/                    EnhanceMode, PickedImage
├── services/                  planification mémoire, upscaler (Isolate), sélecteur, export
├── controllers/               EnhanceController (état + actions, services injectés)
└── ui/                        HomePage et widgets
test/                          tests unitaires, contrôleur (avec faux services), widget
tool/                          génération du projet Android
```

Les services sont des interfaces (`ImageUpscaler`, `ImageSourceService`, `ResultExporter`) :
un futur moteur IA s’ajoute en implémentant `ImageUpscaler`, sans toucher à l’interface.

## Développement

Prérequis : Flutter 3.47 (stable) et JDK 17.

```bash
flutter pub get
dart format .
flutter analyze
flutter test
bash tool/android_setup.sh      # génère le projet Android (non versionné)
flutter build apk --release
```

La CI (`.github/workflows/ci.yml`) exécute ces mêmes étapes et publie l’APK en artefact.
Le dossier `android/` est généré : `tool/android_setup.sh` fixe l’identifiant
(`com.pixelrebuild.app`), le nom affiché, `minSdk 24` et un script Gradle `compileSdk 36`.

## Feuille de route

- [ ] Modèle de super-résolution embarqué (TFLite/ONNX) derrière `ImageUpscaler`
- [ ] Signature de release avec un keystore (secrets GitHub)
- [ ] Icône d’application et captures d’écran
- [ ] Traitement par tuiles pour les très grandes images

## Licence

[MIT](LICENSE)
