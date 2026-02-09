import 'package:equatable/equatable.dart';

enum MaterialCategory {
  painting,
  masonry,
  flooring,
  electrical,
  plumbing,
  drywall,
  carpentry,
  other
}

class MaterialCatalogEntry extends Equatable {
  final String materialName;
  final String normalizedName;
  final double basePrice;
  final String unit;
  final MaterialCategory category;
  final String? description;

  const MaterialCatalogEntry({
    required this.materialName,
    required this.normalizedName,
    required this.basePrice,
    required this.unit,
    required this.category,
    this.description,
  });

  @override
  List<Object?> get props => [
        materialName,
        normalizedName,
        basePrice,
        unit,
        category,
        description,
      ];
}

const List<MaterialCatalogEntry> materialCatalog = [
  // === PAINTING ===
  MaterialCatalogEntry(
    materialName: 'Pintura látex blanca',
    normalizedName: 'pintura-latex-blanca',
    basePrice: 180,
    unit: 'litro',
    category: MaterialCategory.painting,
    description: 'Pintura vinílica de calidad media para interiores',
  ),
  MaterialCatalogEntry(
    materialName: 'Pintura látex color',
    normalizedName: 'pintura-latex-color',
    basePrice: 200,
    unit: 'litro',
    category: MaterialCategory.painting,
    description: 'Pintura vinílica de colores para interiores',
  ),
  MaterialCatalogEntry(
    materialName: 'Pintura esmalte',
    normalizedName: 'pintura-esmalte',
    basePrice: 250,
    unit: 'litro',
    category: MaterialCategory.painting,
    description: 'Pintura de esmalte para acabados brillantes',
  ),
  MaterialCatalogEntry(
    materialName: 'Primer sellador',
    normalizedName: 'primer-sellador',
    basePrice: 150,
    unit: 'litro',
    category: MaterialCategory.painting,
    description: 'Sellador base para muros nuevos',
  ),

  // === MASONRY ===
  MaterialCatalogEntry(
    materialName: 'Cemento',
    normalizedName: 'cemento',
    basePrice: 220,
    unit: 'bulto',
    category: MaterialCategory.masonry,
    description: 'Bulto de cemento gris de 50kg',
  ),
  MaterialCatalogEntry(
    materialName: 'Arena',
    normalizedName: 'arena',
    basePrice: 450,
    unit: 'm3',
    category: MaterialCategory.masonry,
    description: 'Arena de río para construcción',
  ),
  MaterialCatalogEntry(
    materialName: 'Grava',
    normalizedName: 'grava',
    basePrice: 500,
    unit: 'm3',
    category: MaterialCategory.masonry,
    description: 'Grava triturada para concreto',
  ),
  MaterialCatalogEntry(
    materialName: 'Ladrillos rojos',
    normalizedName: 'ladrillos-rojos',
    basePrice: 8,
    unit: 'pieza',
    category: MaterialCategory.masonry,
    description: 'Ladrillo rojo recocido',
  ),
  MaterialCatalogEntry(
    materialName: 'Block de concreto',
    normalizedName: 'block-concreto',
    basePrice: 18,
    unit: 'pieza',
    category: MaterialCategory.masonry,
    description: 'Block hueco de 15cm',
  ),

  // === FLOORING ===
  MaterialCatalogEntry(
    materialName: 'Cerámica piso',
    normalizedName: 'ceramica-piso',
    basePrice: 180,
    unit: 'm2',
    category: MaterialCategory.flooring,
    description: 'Cerámica para piso de calidad media',
  ),
  MaterialCatalogEntry(
    materialName: 'Cerámica pared',
    normalizedName: 'ceramica-pared',
    basePrice: 220,
    unit: 'm2',
    category: MaterialCategory.flooring,
    description: 'Azulejo para muros',
  ),
  MaterialCatalogEntry(
    materialName: 'Porcelanato',
    normalizedName: 'porcelanato',
    basePrice: 350,
    unit: 'm2',
    category: MaterialCategory.flooring,
    description: 'Piso de porcelanato de alta calidad',
  ),
  MaterialCatalogEntry(
    materialName: 'Loseta vinílica',
    normalizedName: 'loseta-vinilica',
    basePrice: 120,
    unit: 'm2',
    category: MaterialCategory.flooring,
    description: 'Piso vinílico tipo madera',
  ),

  // === DRYWALL ===
  MaterialCatalogEntry(
    materialName: 'Placa de yeso (tablaroca)',
    normalizedName: 'placa-yeso',
    basePrice: 180,
    unit: 'm2',
    category: MaterialCategory.drywall,
    description: 'Placa de yeso de 1/2 pulgada',
  ),
  MaterialCatalogEntry(
    materialName: 'Perfil metálico',
    normalizedName: 'perfil-metalico',
    basePrice: 85,
    unit: 'pieza',
    category: MaterialCategory.drywall,
    description: 'Perfil de acero galvanizado de 3m',
  ),
  MaterialCatalogEntry(
    materialName: 'Pasta para juntas',
    normalizedName: 'pasta-juntas',
    basePrice: 320,
    unit: 'cubeta',
    category: MaterialCategory.drywall,
    description: 'Pasta para resanar juntas de tablaroca',
  ),

  // === ELECTRICAL ===
  MaterialCatalogEntry(
    materialName: 'Cable calibre 12',
    normalizedName: 'cable-calibre-12',
    basePrice: 15,
    unit: 'metro',
    category: MaterialCategory.electrical,
    description: 'Cable eléctrico THHN calibre 12',
  ),
  MaterialCatalogEntry(
    materialName: 'Cable calibre 14',
    normalizedName: 'cable-calibre-14',
    basePrice: 12,
    unit: 'metro',
    category: MaterialCategory.electrical,
    description: 'Cable eléctrico THHN calibre 14',
  ),
  MaterialCatalogEntry(
    materialName: 'Apagador sencillo',
    normalizedName: 'apagador-sencillo',
    basePrice: 35,
    unit: 'pieza',
    category: MaterialCategory.electrical,
    description: 'Apagador sencillo tipo Decora',
  ),
  MaterialCatalogEntry(
    materialName: 'Contacto doble',
    normalizedName: 'contacto-doble',
    basePrice: 45,
    unit: 'pieza',
    category: MaterialCategory.electrical,
    description: 'Contacto polarizado doble',
  ),

  // === PLUMBING ===
  MaterialCatalogEntry(
    materialName: 'Tubo PVC hidráulico 1/2"',
    normalizedName: 'tubo-pvc-hidraulico-media',
    basePrice: 35,
    unit: 'metro',
    category: MaterialCategory.plumbing,
    description: 'Tubo de PVC para agua de 1/2 pulgada',
  ),
  MaterialCatalogEntry(
    materialName: 'Tubo PVC sanitario 4"',
    normalizedName: 'tubo-pvc-sanitario-4',
    basePrice: 85,
    unit: 'metro',
    category: MaterialCategory.plumbing,
    description: 'Tubo de PVC para drenaje de 4 pulgadas',
  ),
  MaterialCatalogEntry(
    materialName: 'Codo PVC',
    normalizedName: 'codo-pvc',
    basePrice: 15,
    unit: 'pieza',
    category: MaterialCategory.plumbing,
    description: 'Codo de PVC de 90 grados',
  ),

  // === CARPENTRY ===
  MaterialCatalogEntry(
    materialName: 'Madera de pino',
    normalizedName: 'madera-pino',
    basePrice: 280,
    unit: 'm2',
    category: MaterialCategory.carpentry,
    description: 'Tabla de pino cepillada',
  ),
  MaterialCatalogEntry(
    materialName: 'MDF',
    normalizedName: 'mdf',
    basePrice: 350,
    unit: 'm2',
    category: MaterialCategory.carpentry,
    description: 'Placa de MDF de 15mm',
  ),
];
