/**
 * Pricing Engine with Machine Learning Capabilities
 * 
 * This service implements intelligent pricing for construction quotations:
 * 1. Auto-generation: Creates quotations from analysis data
 * 2. Evaluation: Compares prices against historical market data
 * 3. Adjustment: Automatically adjusts prices based on ML algorithms
 */

import { Firestore } from '@google-cloud/firestore';
import { MATERIAL_CATALOG, findMaterialInCatalog, normalizeMaterialName } from '../data/material-catalog';

const firestore = new Firestore();

// ==================== INTERFACES ====================

export interface Material {
    name: string;
    quantity: string;
    unit: string;
}

export interface QuotedMaterial extends Material {
    unitPrice: number;
    totalPrice: number;
    marketAverage?: number;
    wasAdjusted: boolean;
    adjustmentReason?: string;
}

export interface Quotation {
    id: string;
    jobId: string;
    projectId: string;
    materials: QuotedMaterial[];
    laborCost: number;
    totalCost: number;
    status: 'draft' | 'approved' | 'rejected';
    createdAt: string;
    updatedAt: string;
    marketAdjustment: number;
    confidenceScore: number;
    wasAdjusted: boolean;
}

export interface MaterialPriceData {
    materialName: string;
    normalizedName: string;
    basePrice: number;
    unit: string;
    priceHistory: PriceHistoryEntry[];
    averagePrice: number;
    minPrice: number;
    maxPrice: number;
    standardDeviation: number;
    sampleCount: number;
    lastUpdated: string;
}

export interface PriceHistoryEntry {
    price: number;
    date: string;
    source: 'initial' | 'quotation' | 'manual_adjustment';
    quotationId?: string;
}

export interface PriceAdjustment {
    adjustedPrice: number;
    adjustment: number;
    confidence: number;
    reason: string;
}

// ==================== PRICING ENGINE ====================

export class PricingEngine {

    /**
     * Generate a complete quotation from a job analysis
     */
    async generateQuotation(jobId: string): Promise<Quotation> {
        // 1. Get the job and its analysis
        const jobDoc = await firestore.collection('jobs').doc(jobId).get();

        if (!jobDoc.exists) {
            throw new Error(`Job ${jobId} not found`);
        }

        const jobData = jobDoc.data()!;

        if (jobData.status !== 'completed') {
            throw new Error(`Job ${jobId} is not completed yet (status: ${jobData.status})`);
        }

        const analysis = jobData.analysis;
        if (!analysis || !analysis.materials) {
            throw new Error(`Job ${jobId} has no material analysis`);
        }

        // 2. Process each material and get prices
        const quotedMaterials: QuotedMaterial[] = [];

        for (const material of analysis.materials) {
            const quotedMaterial = await this.priceMaterial(material);
            quotedMaterials.push(quotedMaterial);
        }

        // 3. Calculate labor cost based on difficulty and materials
        const laborCost = this.calculateLaborCost(analysis.difficulty || 5, quotedMaterials);

        // 4. Calculate totals
        const materialsCost = quotedMaterials.reduce((sum, m) => sum + m.totalPrice, 0);
        const totalCost = materialsCost + laborCost;

        // 5. Calculate overall confidence and adjustment factor
        const avgConfidence = quotedMaterials.reduce((sum, m) => sum + (m.wasAdjusted ? 0.7 : 0.3), 0) / quotedMaterials.length;
        const wasAdjusted = quotedMaterials.some(m => m.wasAdjusted);

        // 6. Create quotation
        const quotationId = `quote_${Date.now()}`;
        const quotation: Quotation = {
            id: quotationId,
            jobId,
            projectId: jobData.projectId,
            materials: quotedMaterials,
            laborCost,
            totalCost,
            status: 'draft',
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString(),
            marketAdjustment: 1.0,
            confidenceScore: avgConfidence,
            wasAdjusted
        };

        // 7. Save to Firestore
        await firestore.collection('quotations').doc(quotationId).set(quotation);

        // 8. Update price history for all materials
        for (const material of quotedMaterials) {
            await this.updatePriceHistory(material.name, material.unitPrice, quotationId);
        }

        return quotation;
    }

    /**
     * Price a single material with ML adjustment
     */
    private async priceMaterial(material: Material): Promise<QuotedMaterial> {
        // 1. Find material in catalog
        const catalogEntry = findMaterialInCatalog(material.name);
        const basePrice = catalogEntry?.basePrice || 100; // Default fallback

        // 2. Parse quantity
        const quantity = this.parseQuantity(material.quantity);

        // 3. Apply ML price adjustment
        const adjustment = await this.adjustPrice(
            material.name,
            basePrice,
            quantity
        );

        const unitPrice = adjustment.adjustedPrice;
        const totalPrice = unitPrice * quantity;

        return {
            name: material.name,
            quantity: material.quantity,
            unit: material.unit || (catalogEntry?.unit || 'unidad'),
            unitPrice: Math.round(unitPrice * 100) / 100, // Round to 2 decimals
            totalPrice: Math.round(totalPrice * 100) / 100,
            marketAverage: adjustment.adjustment !== 1.0 ? basePrice : undefined,
            wasAdjusted: adjustment.adjustment !== 1.0,
            adjustmentReason: adjustment.adjustment !== 1.0 ? adjustment.reason : undefined
        };
    }

    /**
     * Adjust price based on historical market data (ML algorithm)
     */
    async adjustPrice(
        materialName: string,
        initialPrice: number,
        quantity: number
    ): Promise<PriceAdjustment> {

        // 1. Get historical price data
        const priceData = await this.getMaterialPriceData(materialName);

        if (!priceData || priceData.sampleCount < 3) {
            // Insufficient data - use initial price
            return {
                adjustedPrice: initialPrice,
                adjustment: 1.0,
                confidence: 0.3,
                reason: 'Datos insuficientes, usando precio base del catálogo'
            };
        }

        // 2. Compare with market average
        const marketAverage = priceData.averagePrice;
        const deviation = priceData.standardDeviation;

        // 3. Detect outliers (z-score > 2)
        const zScore = deviation > 0 ? Math.abs((initialPrice - marketAverage) / deviation) : 0;

        if (zScore > 2) {
            // Price is an outlier - adjust toward market average
            const adjustedPrice = marketAverage * 1.05; // Add 5% buffer
            const confidence = Math.min(priceData.sampleCount / 10, 0.95);

            return {
                adjustedPrice,
                adjustment: adjustedPrice / initialPrice,
                confidence,
                reason: `Ajustado al promedio de mercado ($${Math.round(marketAverage)} ±$${Math.round(deviation)})`
            };
        }

        // 4. Price is within normal range - apply weighted adjustment
        const weightedPrice = (
            initialPrice * 0.4 +    // 40% catalog price
            marketAverage * 0.6     // 60% market average
        );

        const confidence = Math.min(priceData.sampleCount / 10, 0.9);

        return {
            adjustedPrice: weightedPrice,
            adjustment: weightedPrice / initialPrice,
            confidence,
            reason: `Ajuste ponderado con ${priceData.sampleCount} cotizaciones previas`
        };
    }

    /**
     * Get material price data from Firestore
     */
    private async getMaterialPriceData(materialName: string): Promise<MaterialPriceData | null> {
        const normalizedName = normalizeMaterialName(materialName);
        const docRef = firestore.collection('material_prices').doc(normalizedName);
        const doc = await docRef.get();

        if (!doc.exists) {
            return null;
        }

        return doc.data() as MaterialPriceData;
    }

    /**
     * Update price history with new quotation data
     */
    async updatePriceHistory(
        materialName: string,
        price: number,
        quotationId: string
    ): Promise<void> {
        const normalizedName = normalizeMaterialName(materialName);
        const docRef = firestore.collection('material_prices').doc(normalizedName);

        const doc = await docRef.get();

        if (!doc.exists) {
            // Create new entry
            const catalogEntry = findMaterialInCatalog(materialName);

            await docRef.set({
                materialName,
                normalizedName,
                basePrice: catalogEntry?.basePrice || price,
                unit: catalogEntry?.unit || 'unidad',
                priceHistory: [{
                    price,
                    date: new Date().toISOString(),
                    source: 'quotation',
                    quotationId
                }],
                averagePrice: price,
                minPrice: price,
                maxPrice: price,
                standardDeviation: 0,
                sampleCount: 1,
                lastUpdated: new Date().toISOString()
            });

            // Log adjustment
            await this.logPriceAdjustment(quotationId, materialName, price, price, 'initial');
        } else {
            // Update existing entry
            const data = doc.data() as MaterialPriceData;
            const newHistory = [...data.priceHistory, {
                price,
                date: new Date().toISOString(),
                source: 'quotation' as const,
                quotationId
            }];

            // Recalculate statistics
            const prices = newHistory.map(h => h.price);
            const stats = this.calculateStats(prices);

            await docRef.update({
                priceHistory: newHistory,
                ...stats,
                sampleCount: prices.length,
                lastUpdated: new Date().toISOString()
            });

            // Log if price was adjusted
            if (Math.abs(price - data.averagePrice) > data.standardDeviation) {
                await this.logPriceAdjustment(
                    quotationId,
                    materialName,
                    data.averagePrice,
                    price,
                    'market_comparison'
                );
            }
        }
    }

    /**
     * Log price adjustments for auditing
     */
    private async logPriceAdjustment(
        quotationId: string,
        materialName: string,
        originalPrice: number,
        adjustedPrice: number,
        reason: string
    ): Promise<void> {
        const adjustmentId = `adj_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;

        await firestore.collection('price_adjustments').doc(adjustmentId).set({
            id: adjustmentId,
            quotationId,
            materialName,
            originalPrice,
            adjustedPrice,
            adjustmentFactor: adjustedPrice / originalPrice,
            reason,
            metadata: {
                timestamp: new Date().toISOString()
            },
            createdAt: new Date().toISOString()
        });
    }

    /**
     * Calculate statistics for price history
     */
    private calculateStats(prices: number[]) {
        const avg = prices.reduce((a, b) => a + b, 0) / prices.length;
        const variance = prices.reduce((sum, p) => sum + Math.pow(p - avg, 2), 0) / prices.length;
        const stdDev = Math.sqrt(variance);

        return {
            averagePrice: Math.round(avg * 100) / 100,
            minPrice: Math.min(...prices),
            maxPrice: Math.max(...prices),
            standardDeviation: Math.round(stdDev * 100) / 100
        };
    }

    /**
     * Calculate labor cost based on difficulty and materials
     */
    private calculateLaborCost(difficulty: number, materials: QuotedMaterial[]): number {
        // Base labor rate per hour (MXN)
        const baseHourlyRate = 250;

        // Estimate hours based on difficulty (1-10 scale)
        const estimatedHours = difficulty * 8; // 8-80 hours

        // Additional hours based on material complexity
        const materialComplexity = materials.length * 2; // 2 hours per material type

        const totalHours = estimatedHours + materialComplexity;
        const laborCost = totalHours * baseHourlyRate;

        return Math.round(laborCost);
    }

    /**
     * Parse quantity string to number
     */
    private parseQuantity(quantityStr: string): number {
        // Extract first number from string
        const match = quantityStr.match(/(\d+(?:\.\d+)?)/);
        return match ? parseFloat(match[1]) : 1;
    }

    /**
     * Seed initial material prices from catalog
     */
    async seedMaterialPrices(): Promise<number> {
        let count = 0;

        for (const material of MATERIAL_CATALOG) {
            const docRef = firestore.collection('material_prices').doc(material.normalizedName);
            const doc = await docRef.get();

            if (!doc.exists) {
                await docRef.set({
                    materialName: material.materialName,
                    normalizedName: material.normalizedName,
                    basePrice: material.basePrice,
                    unit: material.unit,
                    priceHistory: [{
                        price: material.basePrice,
                        date: new Date().toISOString(),
                        source: 'initial'
                    }],
                    averagePrice: material.basePrice,
                    minPrice: material.basePrice,
                    maxPrice: material.basePrice,
                    standardDeviation: 0,
                    sampleCount: 1,
                    lastUpdated: new Date().toISOString()
                });
                count++;
            }
        }

        return count;
    }
}
