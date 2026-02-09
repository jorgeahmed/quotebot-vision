/**
 * Material Catalog for Construction Quotations
 * 
 * Initial database of common construction materials with base prices.
 * Prices are in MXN (Mexican Pesos) and represent market averages for 2025.
 */

export interface MaterialCatalogEntry {
    materialName: string;
    normalizedName: string;
    basePrice: number;
    unit: string;
    category: 'painting' | 'masonry' | 'flooring' | 'electrical' | 'plumbing' | 'drywall' | 'carpentry' | 'other';
    description?: string;
}

export const MATERIAL_CATALOG: MaterialCatalogEntry[] = [
    // === PAINTING ===
    {
        materialName: 'Pintura látex blanca',
        normalizedName: 'pintura-latex-blanca',
        basePrice: 180,
        unit: 'litro',
        category: 'painting',
        description: 'Pintura vinílica de calidad media para interiores'
    },
    {
        materialName: 'Pintura látex color',
        normalizedName: 'pintura-latex-color',
        basePrice: 200,
        unit: 'litro',
        category: 'painting',
        description: 'Pintura vinílica de colores para interiores'
    },
    {
        materialName: 'Pintura esmalte',
        normalizedName: 'pintura-esmalte',
        basePrice: 250,
        unit: 'litro',
        category: 'painting',
        description: 'Pintura de esmalte para acabados brillantes'
    },
    {
        materialName: 'Primer sellador',
        normalizedName: 'primer-sellador',
        basePrice: 150,
        unit: 'litro',
        category: 'painting',
        description: 'Sellador base para muros nuevos'
    },

    // === MASONRY ===
    {
        materialName: 'Cemento',
        normalizedName: 'cemento',
        basePrice: 220,
        unit: 'bulto',
        category: 'masonry',
        description: 'Bulto de cemento gris de 50kg'
    },
    {
        materialName: 'Arena',
        normalizedName: 'arena',
        basePrice: 450,
        unit: 'm3',
        category: 'masonry',
        description: 'Arena de río para construcción'
    },
    {
        materialName: 'Grava',
        normalizedName: 'grava',
        basePrice: 500,
        unit: 'm3',
        category: 'masonry',
        description: 'Grava triturada para concreto'
    },
    {
        materialName: 'Ladrillos rojos',
        normalizedName: 'ladrillos-rojos',
        basePrice: 8,
        unit: 'pieza',
        category: 'masonry',
        description: 'Ladrillo rojo recocido'
    },
    {
        materialName: 'Block de concreto',
        normalizedName: 'block-concreto',
        basePrice: 18,
        unit: 'pieza',
        category: 'masonry',
        description: 'Block hueco de 15cm'
    },

    // === FLOORING ===
    {
        materialName: 'Cerámica piso',
        normalizedName: 'ceramica-piso',
        basePrice: 180,
        unit: 'm2',
        category: 'flooring',
        description: 'Cerámica para piso de calidad media'
    },
    {
        materialName: 'Cerámica pared',
        normalizedName: 'ceramica-pared',
        basePrice: 220,
        unit: 'm2',
        category: 'flooring',
        description: 'Azulejo para muros'
    },
    {
        materialName: 'Porcelanato',
        normalizedName: 'porcelanato',
        basePrice: 350,
        unit: 'm2',
        category: 'flooring',
        description: 'Piso de porcelanato de alta calidad'
    },
    {
        materialName: 'Loseta vinílica',
        normalizedName: 'loseta-vinilica',
        basePrice: 120,
        unit: 'm2',
        category: 'flooring',
        description: 'Piso vinílico tipo madera'
    },

    // === DRYWALL ===
    {
        materialName: 'Placa de yeso (tablaroca)',
        normalizedName: 'placa-yeso',
        basePrice: 180,
        unit: 'm2',
        category: 'drywall',
        description: 'Placa de yeso de 1/2 pulgada'
    },
    {
        materialName: 'Perfil metálico',
        normalizedName: 'perfil-metalico',
        basePrice: 85,
        unit: 'pieza',
        category: 'drywall',
        description: 'Perfil de acero galvanizado de 3m'
    },
    {
        materialName: 'Pasta para juntas',
        normalizedName: 'pasta-juntas',
        basePrice: 320,
        unit: 'cubeta',
        category: 'drywall',
        description: 'Pasta para resanar juntas de tablaroca'
    },

    // === ELECTRICAL ===
    {
        materialName: 'Cable calibre 12',
        normalizedName: 'cable-calibre-12',
        basePrice: 15,
        unit: 'metro',
        category: 'electrical',
        description: 'Cable eléctrico THHN calibre 12'
    },
    {
        materialName: 'Cable calibre 14',
        normalizedName: 'cable-calibre-14',
        basePrice: 12,
        unit: 'metro',
        category: 'electrical',
        description: 'Cable eléctrico THHN calibre 14'
    },
    {
        materialName: 'Apagador sencillo',
        normalizedName: 'apagador-sencillo',
        basePrice: 35,
        unit: 'pieza',
        category: 'electrical',
        description: 'Apagador sencillo tipo Decora'
    },
    {
        materialName: 'Contacto doble',
        normalizedName: 'contacto-doble',
        basePrice: 45,
        unit: 'pieza',
        category: 'electrical',
        description: 'Contacto polarizado doble'
    },

    // === PLUMBING ===
    {
        materialName: 'Tubo PVC hidráulico 1/2"',
        normalizedName: 'tubo-pvc-hidraulico-media',
        basePrice: 35,
        unit: 'metro',
        category: 'plumbing',
        description: 'Tubo de PVC para agua de 1/2 pulgada'
    },
    {
        materialName: 'Tubo PVC sanitario 4"',
        normalizedName: 'tubo-pvc-sanitario-4',
        basePrice: 85,
        unit: 'metro',
        category: 'plumbing',
        description: 'Tubo de PVC para drenaje de 4 pulgadas'
    },
    {
        materialName: 'Codo PVC',
        normalizedName: 'codo-pvc',
        basePrice: 15,
        unit: 'pieza',
        category: 'plumbing',
        description: 'Codo de PVC de 90 grados'
    },

    // === CARPENTRY ===
    {
        materialName: 'Madera de pino',
        normalizedName: 'madera-pino',
        basePrice: 280,
        unit: 'm2',
        category: 'carpentry',
        description: 'Tabla de pino cepillada'
    },
    {
        materialName: 'MDF',
        normalizedName: 'mdf',
        basePrice: 350,
        unit: 'm2',
        category: 'carpentry',
        description: 'Placa de MDF de 15mm'
    }
];

/**
 * Helper function to normalize material names for search
 */
export function normalizeMaterialName(name: string): string {
    return name
        .toLowerCase()
        .normalize('NFD')
        .replace(/[\u0300-\u036f]/g, '') // Remove accents
        .replace(/[^a-z0-9]/g, '-')
        .replace(/-+/g, '-')
        .replace(/^-|-$/g, '');
}

/**
 * Find a material in the catalog by fuzzy matching
 */
export function findMaterialInCatalog(searchTerm: string): MaterialCatalogEntry | null {
    const normalizedSearch = normalizeMaterialName(searchTerm);

    // Exact match
    const exactMatch = MATERIAL_CATALOG.find(m => m.normalizedName === normalizedSearch);
    if (exactMatch) return exactMatch;

    // Partial match (search term contains catalog name or vice versa)
    const partialMatch = MATERIAL_CATALOG.find(m =>
        normalizedSearch.includes(m.normalizedName) ||
        m.normalizedName.includes(normalizedSearch)
    );

    return partialMatch || null;
}
