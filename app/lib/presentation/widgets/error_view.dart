import 'package:flutter/material.dart';

class ErrorView extends StatelessWidget {
  final FlutterErrorDetails errorDetails;

  const ErrorView({super.key, required this.errorDetails});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.red[50], // Light red background
                  shape: BoxShape.circle,
                ),
                child:
                    Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
              ),
              const SizedBox(height: 24),
              const Text(
                '¡Algo salió mal!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'La aplicación ha encontrado un error inesperado. Por favor intenta reiniciar o contacta a soporte si persiste.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Detalles Técnicos:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      errorDetails.exceptionAsString(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        color: Colors.red,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () {
                  // Basic retry: pop completely or just rebuild?
                  // In error widget context, often simpler to encourage app restart or navigation
                  // Here we try to navigate to root
                  // Note: Navigator might be broken if the error is high up.
                  // A simple reload approach using something like Phoenix or just exiting might be safer in prod,
                  // but for development, popping helps.
                  try {
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil('/', (route) => false);
                  } catch (_) {
                    // Fallback if context is messed up
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red[500],
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.refresh),
                label: const Text('Reiniciar Aplicación'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
