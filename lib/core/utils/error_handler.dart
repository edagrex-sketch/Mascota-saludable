import 'package:flutter/material.dart';

/// Centralized error handling utility.
///
/// Maps Supabase and network errors to user-friendly Spanish messages.
class ErrorHandler {
  ErrorHandler._();

  /// Maps an exception/error to a user-friendly message in Spanish.
  static String mapError(dynamic error) {
    final message = error.toString().toLowerCase();

    if (message.contains('network') ||
        message.contains('socketexception') ||
        message.contains('connection refused') ||
        message.contains('host lookup')) {
      return 'Sin conexión a internet. Verifica tu red e intenta de nuevo.';
    }

    if (message.contains('timeout') || message.contains('timed out')) {
      return 'La conexión tardó demasiado. Por favor, intenta de nuevo.';
    }

    if (message.contains('already registered') ||
        message.contains('user already exists')) {
      return 'Este correo ya está registrado. Intenta iniciar sesión.';
    }

    if (message.contains('invalid login') ||
        message.contains('invalid credentials') ||
        message.contains('wrong password')) {
      return 'Correo o contraseña incorrectos.';
    }

    if (message.contains('rate limit') || message.contains('too many')) {
      return 'Demasiados intentos. Espera unos minutos y vuelve a intentar.';
    }

    if (message.contains('email not confirmed')) {
      return 'Por favor confirma tu correo electrónico antes de iniciar sesión.';
    }

    if (message.contains('user not found')) {
      return 'No encontramos una cuenta con este correo.';
    }

    if (message.contains('weak password')) {
      return 'La contraseña es muy débil. Usa al menos 6 caracteres.';
    }

    if (message.contains('permission denied') ||
        message.contains('unauthorized')) {
      return 'No tienes permiso para realizar esta acción.';
    }

    if (message.contains('duplicate') || message.contains('unique')) {
      return 'Este registro ya existe.';
    }

    if (message.contains('invalid') && message.contains('email')) {
      return 'Ingresa un correo electrónico válido.';
    }

    // Fallback for unknown errors
    return 'Ocurrió un error inesperado. Intenta de nuevo más tarde.';
  }

  /// Shows a [SnackBar] with the mapped error message.
  static void showSnackBar(BuildContext context, dynamic error) {
    final message = mapError(error);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: const Color(0xFFBA1A1A),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
  }

  /// Shows a retry [SnackBar].
  static void showRetrySnackBar(
    BuildContext context,
    VoidCallback onRetry,
  ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('Error al cargar datos'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: const Color(0xFFBA1A1A),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Reintentar',
            textColor: Colors.white,
            onPressed: onRetry,
          ),
        ),
      );
  }
}
