import '../../home/mock/mock_medication_service.dart';
import '../../exams/mock/mock_exam_service.dart';
import '../../history/mock/mock_history_service.dart';
import '../../notifications/mock/mock_notification_service.dart';

// ════════════════════════════════════════════════════════════
//  MOCK AUTH SERVICE
//  Arquivo: lib/features/auth/mock/mock_auth_service.dart
// ════════════════════════════════════════════════════════════

class MockAuthService {
  MockAuthService._();
  static final MockAuthService instance = MockAuthService._();

  final List<Map<String, String>> _users = [
    {
      'name': 'Maria Silva',
      'email': 'maria@email.com',
      'password': '123456',
      'phone': '(11) 91234-5678',
      'cpf': '123.456.789-00',
      'birthDate': '15/03/1958',
    },
    {
      'name': 'João Santos',
      'email': 'joao@email.com',
      'password': '123456',
      'phone': '(21) 98765-4321',
      'cpf': '987.654.321-00',
      'birthDate': '22/07/1952',
    },
  ];

  Map<String, String>? _loggedUser;

  Map<String, String>? get loggedUser => _loggedUser;
  bool get isLoggedIn => _loggedUser != null;

  Future<void> _fakeDelay() async =>
      Future.delayed(const Duration(milliseconds: 800));

  // ── Inicializa todos os serviços para o usuário ──────────
  void _initServices(String email) {
    MockMedicationService.instance.setUser(email);
    MockExamService.instance.setUser(email);
    MockHistoryService.instance.setUser(email);
    MockNotificationService.instance.setUser(email);
  }

  // ── Login ────────────────────────────────────────────────
  Future<String?> login(String email, String password) async {
    await _fakeDelay();

    final user = _users.firstWhere(
      (u) => u['email'] == email.trim().toLowerCase(),
      orElse: () => {},
    );

    if (user.isEmpty) return 'E-mail não encontrado.';
    if (user['password'] != password) return 'Senha incorreta.';

    _loggedUser = user;
    _initServices(user['email']!);
    return null;
  }

  // ── Registro ─────────────────────────────────────────────
  Future<String?> register(
    String name,
    String email,
    String password, {
    String phone = '',
    String cpf = '',
  }) async {
    await _fakeDelay();

    final emailLower = email.trim().toLowerCase();
    if (_users.any((u) => u['email'] == emailLower)) {
      return 'Este e-mail já está cadastrado.';
    }

    _users.add({
      'name': name.trim(),
      'email': emailLower,
      'password': password,
      'phone': phone.trim(),
      'cpf': cpf.trim(),
      'birthDate': '',
    });

    _loggedUser = _users.last;
    // Novo usuário → serviços iniciam vazios (putIfAbsent com [])
    _initServices(emailLower);
    return null;
  }

  // ── Atualizar perfil ─────────────────────────────────────
  void updateProfile({
    String? name,
    String? email,
    String? phone,
    String? birthDate,
  }) {
    if (_loggedUser == null) return;
    final idx =
        _users.indexWhere((u) => u['email'] == _loggedUser!['email']);
    if (idx == -1) return;

    if (name != null) _users[idx]['name'] = name;
    if (email != null) _users[idx]['email'] = email;
    if (phone != null) _users[idx]['phone'] = phone;
    if (birthDate != null) _users[idx]['birthDate'] = birthDate;

    _loggedUser = _users[idx];
  }

  // ── Alterar senha ────────────────────────────────────────
  Future<String?> changePassword(
      String currentPassword, String newPassword) async {
    await _fakeDelay();
    if (_loggedUser == null) return 'Usuário não autenticado.';

    final idx =
        _users.indexWhere((u) => u['email'] == _loggedUser!['email']);
    if (idx == -1) return 'Usuário não encontrado.';

    if (_users[idx]['password'] != currentPassword) {
      return 'Senha atual incorreta.';
    }

    _users[idx]['password'] = newPassword;
    _loggedUser = _users[idx];
    return null;
  }

  // ── Excluir conta ────────────────────────────────────────
  void deleteAccount() {
    if (_loggedUser == null) return;
    final email = _loggedUser!['email']!;

    // Remove dados de todos os serviços
    MockMedicationService.instance.deleteUser(email);
    MockExamService.instance.deleteUser(email);
    MockHistoryService.instance.deleteUser(email);
    MockNotificationService.instance.deleteUser(email);

    // Remove o usuário da lista
    _users.removeWhere((u) => u['email'] == email);
    _loggedUser = null;
  }

  // ── Logout ───────────────────────────────────────────────
  void logout() {
    if (_loggedUser != null) {
      final email = _loggedUser!['email']!;
      MockMedicationService.instance.clearUser();
      MockExamService.instance.clearUser();
      MockHistoryService.instance.clearUser();
      MockNotificationService.instance.clearUser();
    }
    _loggedUser = null;
  }
}
