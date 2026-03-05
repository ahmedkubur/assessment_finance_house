import '../../models/local/local_account.dart';
import '../../repositories/local_auth_repository.dart';

class MockAuthApi {
  MockAuthApi(this._authRepository);

  final LocalAuthRepository _authRepository;

  Future<LocalAccount> login({
    required String phone,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    final account = await _authRepository.login(phone: phone, password: password);
    if (account == null) {
      throw Exception('Invalid phone or password');
    }

    return account;
  }

  Future<LocalAccount> createAccount({
    required String fullName,
    required String phone,
    required String password,
    String? email,
    String? imageUrl,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));

    final exists = await _authRepository.isPhoneAlreadyRegistered(phone);
    if (exists) {
      throw Exception('Phone number already registered');
    }

    final id = await _authRepository.createAccount(
      LocalAccount(
        fullName: fullName,
        phone: phone,
        password: password,
        email: email,
        imageUrl: imageUrl,
        balance: 0,
        isVerified: false,
      ),
    );

    final account = await _authRepository.getAccountById(id);
    if (account == null) {
      throw Exception('Unable to create account');
    }

    return account;
  }
}
