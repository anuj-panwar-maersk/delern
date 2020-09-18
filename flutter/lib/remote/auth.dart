import 'dart:async';

import 'package:delern_flutter/models/base/stream_with_value.dart';
import 'package:delern_flutter/models/user.dart';
import 'package:delern_flutter/remote/credential_provider.dart';
import 'package:delern_flutter/remote/database.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:pedantic/pedantic.dart';
import 'package:quiver/strings.dart';

enum AuthProvider {
  google,
  facebook,
}

/// An abstraction layer on top of FirebaseAuth.
class Auth {
  static final _database = Database();

  Auth() {
    // Even though this will be evaluated lazily, the initial trigger is
    // guaranteed by Firebase (per documentation).
    fb_auth.FirebaseAuth.instance.userChanges().listen((firebaseUser) async {
      UserProfile constructUserProfile() => UserProfile(
            displayName: firebaseUser.displayName,
            email: firebaseUser.email,
            photoUrl: firebaseUser.photoURL,
            providers: firebaseUser.providerData
                .map((e) => providerFromID(e.providerId))
                .where((element) => element != null)
                .toSet(),
          );

      if (firebaseUser == null || _currentUser.value?.uid != firebaseUser.uid) {
        _currentUser.value?.dispose();
        // Destroy the profile so that any references to the previosly signed in
        // User model do not accidentally get profile of the new user.
        _userProfile?.close();

        if (firebaseUser == null) {
          _currentUser.add(null);
        } else {
          _userProfile = PushStreamWithValue(
            initialValue: constructUserProfile(),
          );

          _currentUser.add(User(
            createdAt: firebaseUser.metadata.creationTime,
            profile: _userProfile,
            uid: firebaseUser.uid,
            database: _database,
            auth: this,
          ));

          // Update latest_online_at node immediately, and also schedule an
          // onDisconnect handler which will set latest_online_at node to the
          // timestamp on the server when a client is disconnected.
          unawaited((FirebaseDatabase.instance
                  .reference()
                  .child('latest_online_at')
                  .child(firebaseUser.uid)
                    // ignore: unawaited_futures
                    ..onDisconnect().set(ServerValue.timestamp))
              .set(ServerValue.timestamp));
        }
      } else {
        // UID stays the same and firebaseUser isn't null -- either ID token or
        // profile change.
        _userProfile.add(constructUserProfile());
      }
    });
  }

  PushStreamWithValue<UserProfile> _userProfile;
  Future<fb_auth.AdditionalUserInfo> _latestSignInAdditionalInfo;

  /// Emits [StreamWithValue.updates] when currently signed in user is no longer
  /// the same user, i.e. UID changed or user signed in or signed out. Does not
  /// emit on profile or ID token changes.
  StreamWithValue<User> get currentUser => _currentUser;
  final _currentUser = PushStreamWithValue<User>();

  bool get authStateKnown => _currentUser.loaded;
  Future<bool> get latestSignInCreatedNewUser async =>
      (await _latestSignInAdditionalInfo)?.isNewUser;

  /// Sign in using a specified provider. If the user is currently signed in
  /// anonymously, try to preserve uid. This will work only if the user hasn't
  /// signed in with this provider before, otherwise throws PlatformException.
  /// For the full list of errors, see both
  /// [fb_auth.FirebaseAuth.signInWithCredential] and
  /// [fb_auth.User.linkWithCredential] methods.
  ///
  /// Some providers may skip through the account picker window if sign in has
  /// already happened (e.g. after a failed account linking). To give user a
  /// choice, we explicitly sign out. If you don't want this behavior, set
  /// [forceAccountPicker] to false.
  ///
  /// NOTE: if the user cancels sign in (e.g. presses "Back" when presented an
  /// account picker), the Future will still complete successfully, but no
  /// changes are done.
  Future<void> signIn(
    AuthProvider provider, {
    bool forceAccountPicker = true,
  }) async {
    if (provider == null) {
      return fb_auth.FirebaseAuth.instance.signInAnonymously();
    }
    final credentialWithMeta = await credentialProviders[provider]
        .getCredential(forceAccountPicker: forceAccountPicker);

    // Credential is unset, usually cancelled by user.
    if (credentialWithMeta == null) {
      return;
    }

    final user = (fb_auth.FirebaseAuth.instance.currentUser == null)
        ? await _signInWithCredential(credentialWithMeta.credential)
        : (await fb_auth.FirebaseAuth.instance.currentUser
                .linkWithCredential(credentialWithMeta.credential))
            .user;

    unawaited(_updateProfileFromProviders(
      user,
      fallbackDisplayName: credentialWithMeta.displayName,
    ));
  }

  /// If user is already signed in, do nothing. If we have existing credential
  /// (e.g. user was signed in at the previous app run), use that credential to
  /// sign in without asking the user.
  Future<void> signInSilently() async {
    var firebaseUser = fb_auth.FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      AuthCredentialWithMetadata credentialWithMetadata;
      for (final provider in credentialProviders.values) {
        if ((credentialWithMetadata =
                await provider.getCredential(silent: true)) !=
            null) {
          break;
        }
      }

      if (credentialWithMetadata != null) {
        firebaseUser =
            await _signInWithCredential(credentialWithMetadata.credential);
      }
    }

    if (firebaseUser != null) {
      await _updateProfileFromProviders(firebaseUser);
    }
  }

  /// Wait for any previous sign in to complete, then get a hold of
  /// [_latestSignInAdditionalInfo]. This is necessary to keep
  /// [FirebaseAuth.userChanges()] from yielding a user to [currentUser] too
  /// soon, i.e., before we get a hold of [fb_auth.AdditionalUserInfo].
  Future<fb_auth.User> _signInWithCredential(
      fb_auth.AuthCredential credential) async {
    fb_auth.UserCredential userCredential;

    final signInComplete = Completer<fb_auth.AdditionalUserInfo>();
    _latestSignInAdditionalInfo = signInComplete.future;
    try {
      userCredential =
          await fb_auth.FirebaseAuth.instance.signInWithCredential(credential);
    } finally {
      signInComplete.complete(userCredential?.additionalUserInfo);
    }

    return userCredential.user;
  }

  /// Sign out of Firebase, but without signing out of linked providers.
  // TODO(dotdoom): this effectively means that upon re-launching the app, the
  //                user will be signed in again (via signInSilently) because
  //                we haven't expired per-provider credentials. Instead, we
  //                should go over all credentials and expire them.
  Future<void> signOut() => fb_auth.FirebaseAuth.instance.signOut();

  /// Collect user facing information from providers and fill it into Firebase
  /// if it was not already there. [fallbackDisplayName] is taken into account
  /// if nothing else works.
  static Future<void> _updateProfileFromProviders(
    fb_auth.User user, {
    String fallbackDisplayName,
  }) {
    var displayName = user.displayName, photoURL = user.photoURL;
    for (final providerData in user.providerData) {
      if (isBlank(displayName) && !isBlank(providerData.displayName)) {
        displayName = providerData.displayName;
        debugPrint(
            'Updating displayName from provider ${providerData.providerId}');
      }
      if (isBlank(photoURL) && !isBlank(providerData.photoURL)) {
        photoURL = providerData.photoURL;
        debugPrint(
            'Updating photoUrl from provider ${providerData.providerId}');
      }
    }

    if (isBlank(displayName)) {
      displayName = fallbackDisplayName;
    }

    return user.updateProfile(displayName: displayName, photoURL: photoURL);
  }
}
