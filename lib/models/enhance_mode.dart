/// Modes d’amélioration proposés. Seul le mode rapide est implémenté ;
/// les modes IA restent désactivés tant qu’aucun modèle vérifié n’est embarqué.
enum EnhanceMode {
  fast('Rapide', 'Interpolation bicubique locale', available: true),
  standard('IA standard', 'Bientôt disponible', available: false),
  maximum('Qualité maximale', 'Bientôt disponible', available: false),
  anime('Anime', 'Bientôt disponible', available: false);

  const EnhanceMode(this.label, this.description, {required this.available});

  final String label;
  final String description;
  final bool available;
}
