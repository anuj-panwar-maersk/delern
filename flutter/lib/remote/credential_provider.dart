import 'package:delern_flutter/remote/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:quiver/strings.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

abstract class CredentialProvider {
  /// Get AuthCredential from user or provider-specific credential cache.
  ///
  /// When [silent] is set, do not interact with the user and only obtain
  /// previously cached credential, or `null` when there's no valid credential.
  /// When [forceAccountPicker] is set, always provide account selection dialog,
  /// perhaps by clearing credential cache (also known as signing out).
  ///
  /// The caller guarantees that [silent] and [forceAccountPicker] are not set
  /// to `true` at the same time.
  ///
  /// The return Future should resolve to `null` if the user has cancelled login
  /// dialog, or an error if an unexpected condition was met (e.g. application
  /// misconfiguration, network connection issues).
  Future<AuthCredentialWithMetadata> getCredential({
    bool silent = false,
    bool forceAccountPicker = false,
  });

  /// ID for reverse mapping of [User]'s providers into [AuthProvider].
  String get _providerId;
}

// The order in this map defines silent Sign In probe order. First wins.
final credentialProviders = <AuthProvider, CredentialProvider>{
  AuthProvider.google: _GoogleCredentialProvider(),
  AuthProvider.facebook: _FacebookCredentialProvider(),
  AuthProvider.apple: _AppleCredentialProvider(),
  // TODO(dotdoom): handle other providers here (ex.: Twitter) #944.
};

/// [AuthProvider] for the provider with ID, or `null` if unknown.
AuthProvider providerFromID(String providerId) => credentialProviders.entries
    .firstWhere((element) => element.value._providerId == providerId,
        orElse: () => null)
    ?.key;

/// Wrapper around [AuthCredential] and select metadata which some providers
/// (e.g. Apple) only supply once at the first login, so it must be relayed
/// upstream to be preserved there.
@immutable
class AuthCredentialWithMetadata {
  /// Required credential.
  final AuthCredential credential;

  /// Given name + family name, optional.
  final String displayName;

  const AuthCredentialWithMetadata({
    @required this.credential,
    this.displayName,
  }) : assert(credential != null);
}

class _GoogleCredentialProvider implements CredentialProvider {
  static final _googleSignIn = GoogleSignIn();

  @override
  final _providerId = GoogleAuthProvider.PROVIDER_ID;

  @override
  Future<AuthCredentialWithMetadata> getCredential({
    bool silent = false,
    bool forceAccountPicker = false,
  }) async {
    assert(!(silent && forceAccountPicker),
        'Silent Sign In is meaningless if Sign Out is forced first');
    if (forceAccountPicker) {
      await _googleSignIn.signOut();
    }

    final account = await (silent
        ? _googleSignIn.signInSilently()
        : _googleSignIn.signIn());
    if (account == null) {
      // signInSilently() will suppress any errors and return null, and signIn()
      // will also return null if the user has cancelled authentication.
      return null;
    }
    final auth = await account.authentication;
    // NOTE: `auth` may contain an access token that is not valid at this point
    //       anymore, or will expire in a few seconds. There is no guarantee
    //       that the token is up to date. If this happens, further use of the
    //       token (e.g. `signInWithCredential`) will fail. To recover from
    //       this, we can force token re-generation when signIn fails, by using
    //       `await account.clearAuthCache()`. Note that `getCredential()` call
    //       below will never fail as it merely copies tokens into a different
    //       structure without validation.
    //       Another solution is to always call `clearAuthCache()`, but what are
    //       the side effects of it?
    return AuthCredentialWithMetadata(
      credential: GoogleAuthProvider.credential(
        accessToken: auth.accessToken,
        idToken: auth.idToken,
      ),
    );
  }
}

class _FacebookCredentialProvider implements CredentialProvider {
  static final _facebookSignIn = FacebookLogin();

  @override
  final _providerId = FacebookAuthProvider.PROVIDER_ID;

  @override
  Future<AuthCredentialWithMetadata> getCredential({
    bool silent = false,
    bool forceAccountPicker = false,
  }) async {
    if (forceAccountPicker) {
      await _facebookSignIn.logOut();
    }

    FacebookAccessToken accessToken;

    if (silent) {
      accessToken = await _facebookSignIn.currentAccessToken;
    } else {
      final result = await _facebookSignIn.logIn(['public_profile', 'email']);
      if (result.status == FacebookLoginStatus.loggedIn) {
        accessToken = result.accessToken;
      }
    }

    if (accessToken != null && accessToken.isValid()) {
      return AuthCredentialWithMetadata(
        credential: FacebookAuthProvider.credential(accessToken.token),
      );
    }
    return null;
  }
}

class _AppleCredentialProvider implements CredentialProvider {
  static final _appleOAuth = OAuthProvider('apple.com');

  @override
  final _providerId = _appleOAuth.providerId;

  @override
  Future<AuthCredentialWithMetadata> getCredential({
    bool silent = false,
    bool forceAccountPicker = false,
  }) async {
    assert(!(silent && forceAccountPicker),
        'Silent Sign In is meaningless if Sign Out is forced first');

    if (silent) {
      debugPrint('Silent Sign In was requested for Apple, but not supported');
      return null;
    }

    if (!forceAccountPicker) {
      debugPrint('Force Account Picker not requested for Apple, ignoring');
    }

    AuthorizationCredentialAppleID credential;
    try {
      credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled ||
          // This happens when the account is not configured on the iOS device.
          e.message.contains('error 1000')) {
        // By the contract, and to avoid unnecessary UI interaction, we return
        // null if the user cancelled the authentication flow.
        debugPrint('Apple auth flow has been canceled (by user): $e');
        return null;
      }
      rethrow;
    }

    return AuthCredentialWithMetadata(
      credential: _appleOAuth.credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      ),
      // https://developer.apple.com/forums/thread/121496.
      displayName:
          (isBlank(credential.givenName) && isBlank(credential.familyName))
              ? null
              : '${credential.givenName ?? ''} ${credential.familyName ?? ''}'
                  .trim(),
    );
  }
}
