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

  Future<void> _fakeDelay() async {
    await Future.delayed(const Duration(milliseconds: 800));
  }

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
    return null;
  }

  /// Atualiza os dados do usuário logado (Alteração 6 — editar perfil)
  void updateProfile({
    String? name,
    String? email,
    String? phone,
    String? birthDate,
  }) {
    if (_loggedUser == null) return;
    final idx = _users.indexWhere((u) => u['email'] == _loggedUser!['email']);
    if (idx == -1) return;

    if (name != null)      _users[idx]['name']      = name;
    if (email != null)     _users[idx]['email']     = email;
    if (phone != null)     _users[idx]['phone']     = phone;
    if (birthDate != null) _users[idx]['birthDate'] = birthDate;

    _loggedUser = _users[idx];
  }

  /// Altera a senha do usuário logado (Alteração 6)
  /// Retorna null em sucesso, ou mensagem de erro
  Future<String?> changePassword(String currentPassword, String newPassword) async {
    await _fakeDelay();
    if (_loggedUser == null) return 'Usuário não autenticado.';

    final idx = _users.indexWhere((u) => u['email'] == _loggedUser!['email']);
    if (idx == -1) return 'Usuário não encontrado.';

    if (_users[idx]['password'] != currentPassword) {
      return 'Senha atual incorreta.';
    }

    _users[idx]['password'] = newPassword;
    _loggedUser = _users[idx];
    return null;
  }

  void logout() => _loggedUser = null;
}
