import 'package:flutter_test/flutter_test.dart';
import 'package:app_perufest/models/usuario.dart';

// 🔥 MOCK SIMULADO DEL SERVICE
class MockFirestoreService {
  static bool retornarUsuarioCorrecto = true;

  static Future<Usuario?> loginUsuario(String correo, String contrasena) async {
    if (!retornarUsuarioCorrecto) return null;

    if (correo == "admin@test.com" && contrasena == "123456") {
      return Usuario(
        id: "1",
        nombre: "Administrador",
        username: "admin",
        correo: correo,
        telefono: "999999999",
        rol: "administrador",
        contrasena: "hashX",
      );
    }

    return null;
  }

  static Future<bool> correoExiste(String correo) async => false;
  static Future<void> registrarUsuario(Usuario usuario) async {}
  static Future<Usuario?> obtenerUsuarioPorId(String id) async => null;
}

// 🔥 VIEWMODEL DE PRUEBA (sin depender de Firebase ni métodos privados)
enum AuthState { idle, loading, success, error }

class AuthViewModelMock {
  AuthState state = AuthState.idle;
  Usuario? currentUser;
  String errorMessage = '';

  Future<void> login(String correo, String contrasena) async {
    if (correo.isEmpty || contrasena.isEmpty) {
      state = AuthState.error;
      errorMessage = 'Los campos no pueden estar vacíos';
      return;
    }

    state = AuthState.loading;

    final usuario = await MockFirestoreService.loginUsuario(correo, contrasena);

    if (usuario != null) {
      currentUser = usuario;
      state = AuthState.success;
    } else {
      state = AuthState.error;
      errorMessage = 'Credenciales incorrectas';
    }
  }
}

void main() {
  group('Pruebas unitarias del AuthViewModel', () {
    late AuthViewModelMock viewModel;

    setUp(() {
      viewModel = AuthViewModelMock();
    });

    // ------------------------------------------------------------
    // 1️⃣ LOGIN EXITOSO (credenciales correctas)
    // ------------------------------------------------------------
    test('Login con credenciales correctas', () async {
      await viewModel.login("admin@test.com", "123456");

      expect(viewModel.state, AuthState.success);
      expect(viewModel.currentUser?.nombre, "Administrador");
    });

    // ------------------------------------------------------------
    // 2️⃣ LOGIN FALLIDO (credenciales incorrectas)
    // ------------------------------------------------------------
    test('Login con credenciales incorrectas', () async {
      await viewModel.login("admin@test.com", "clave_incorrecta");

      expect(viewModel.state, AuthState.error);
      expect(viewModel.errorMessage, "Credenciales incorrectas");
    });

    // ------------------------------------------------------------
    // 3️⃣ CAMPOS VACÍOS (validación)
    // ------------------------------------------------------------
    test('Validar que no se puede iniciar sesión con campos vacíos', () async {
      await viewModel.login("", "");

      expect(viewModel.state, AuthState.error);
      expect(viewModel.errorMessage.isNotEmpty, true);
    });
  });
}
