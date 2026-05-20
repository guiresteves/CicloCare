// Serviço de autenticação mockado (sem backend real)
// Simula login e cadastro com dados em memória

class MockAuthService {
  MockAuthService._();
  static final MockAuthService instance = MockAuthService._();

  // Usuários pré-cadastrados para teste
  final List<Map<String, String>> _users = [
    {
      'name': 'Maria Silva',
      'email': 'maria@email.com',
      'password': '123456',
      'phone': '(11) 91234-5678',
      'cpf': '123.456.789-00',
    },
    {
      'name': 'João Santos',
      'email': 'joao@email.com',
      'password': '123456',
      'phone': '(21) 98765-4321',
      'cpf': '987.654.321-00',
    },
  ];

  Map<String, String>? _loggedUser;

  Map<String, String>? get loggedUser => _loggedUser;
  bool get isLoggedIn => _loggedUser != null;

  Future<void> _fakeDelay() async {
    await Future.delayed(const Duration(milliseconds: 800));
  }

  /// Retorna null em sucesso, ou mensagem de erro.
  Future<String?> login(String email, String password) async {
    await _fakeDelay();

    final user = _users.firstWhere(
      (u) => u['email'] == email.trim().toLowerCase(),
      orElse: () => {},
    );

    if (user.isEmpty) return 'E-mail não encontrado.';
    if (user['password'] != password) return 'Senha incorreta.';

    _loggedUser = user;
    return null;
  }

  /// Retorna null em sucesso, ou mensagem de erro.
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
    });

    _loggedUser = _users.last;
    return null;
  }

  void logout() => _loggedUser = null;
}
