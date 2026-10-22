# Changelog

Format inspiré de [Keep a Changelog](https://keepachangelog.com/fr/1.1.0/).

## [0.2.0] - 2026-10-22

### Ajouté
- Enregistrement dans la galerie (album « PixelRebuild ») et partage système.
- Plafond mémoire : le facteur est réduit automatiquement au-delà de 16 Mpx en sortie.
- Annulation d’un traitement en cours.
- Comparaison « Résultat / Original ».
- Tests unitaires, de contrôleur, d’isolate et de widget ; CI avec formatage, analyse et tests.

### Modifié
- Traitement d’image dans un Isolate (l’interface ne se fige plus).
- Code réorganisé en couches : `models`, `services`, `controllers`, `ui`.
- Prise en compte de l’orientation EXIF.
- Les modes IA restent désactivés : seul l’agrandissement bicubique est implémenté.

### Supprimé
- Test factice qui ne testait pas le code de l’application.
