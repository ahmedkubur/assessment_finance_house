import '../../models/local/local_account.dart';

enum ProfileStatus { initial, loading, loaded, failure }

class ProfileState {
  const ProfileState({
    this.status = ProfileStatus.initial,
    this.account,
    this.errorMessage,
  });

  final ProfileStatus status;
  final LocalAccount? account;
  final String? errorMessage;

  ProfileState copyWith({
    ProfileStatus? status,
    LocalAccount? account,
    bool clearAccount = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ProfileState(
      status: status ?? this.status,
      account: clearAccount ? null : (account ?? this.account),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
