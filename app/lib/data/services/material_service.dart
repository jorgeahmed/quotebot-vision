import '../../domain/entities/material_catalog.dart';

class MaterialService {
  /// Normalizes a string for search (lowercase, no accents).
  /// Note: Dart's default string handling is simple; for full normalization
  /// like the backend (removing accents), we'd usually use a package like `diacritic`.
  /// For this MVP, we'll do basic lowercasing and simple replacements if needed,
  /// or assume the input is reasonably clean.
  /// Ideally, we'd import 'package:diacritic/diacritic.dart'.
  String normalizeMaterialName(String name) {
    // Simple normalization for MVP without external deps if possible,
    // or just lowercase since we matched exact strings in TS.
    // The TS version does: lowercase, remove accents, replace non-alphanum with -, etc.
    // We will simulate the critical parts: lowercase.
    // TODO: Add thorough accent removal if 'diacritic' package is added.
    return name
        .toLowerCase()
        .replaceAll(RegExp(r'[áàäâ]'), 'a')
        .replaceAll(RegExp(r'[éèëê]'), 'e')
        .replaceAll(RegExp(r'[íìïî]'), 'i')
        .replaceAll(RegExp(r'[óòöô]'), 'o')
        .replaceAll(RegExp(r'[úùüû]'), 'u')
        .replaceAll(RegExp(r'[ñ]'), 'n')
        .replaceAll(RegExp(r'[^a-z0-9]'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }

  /// Find a material in the catalog by fuzzy matching
  MaterialCatalogEntry? findMaterial(String searchTerm) {
    if (searchTerm.isEmpty) return null;

    final normalizedSearch = normalizeMaterialName(searchTerm);

    // Exact match
    try {
      final exactMatch = materialCatalog.firstWhere(
        (m) => m.normalizedName == normalizedSearch,
      );
      return exactMatch;
    } catch (_) {
      // Continue to partial match
    }

    // Partial match
    try {
      final partialMatch = materialCatalog.firstWhere(
        (m) =>
            normalizedSearch.contains(m.normalizedName) ||
            m.normalizedName.contains(normalizedSearch),
      );
      return partialMatch;
    } catch (_) {
      return null;
    }
  }
}
