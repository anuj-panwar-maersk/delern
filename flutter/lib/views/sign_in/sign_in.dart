import 'package:delern_flutter/remote/analytics.dart';
import 'package:delern_flutter/remote/auth.dart';
import 'package:delern_flutter/views/helpers/legal.dart';
import 'package:delern_flutter/views/helpers/localization.dart';
import 'package:delern_flutter/views/helpers/save_updates_dialog.dart';
import 'package:delern_flutter/views/helpers/styles.dart' as app_styles;
import 'package:delern_flutter/views/helpers/url_launcher.dart';
import 'package:delern_flutter/views/helpers/user_messages.dart';
import 'package:delern_flutter/views/sign_in/sign_in_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

const _kDivider = Divider(
  height: 2,
  color: app_styles.kSignInSectionSeparationColor,
);

enum SignInMode {
  initialSignIn,
  linkToAccount,
}

/// A screen with sign in information and buttons.
@immutable
class SignIn extends StatefulWidget {
  static const linkAccountRouteName = '/link_account';

  final SignInMode signInMode;

  /// Since this widget comes above the `CurrentUserWidget`, we need an instance
  /// of [Auth] to operate sign in.
  final Auth auth;

  const SignIn(
    this.signInMode, {
    @required this.auth,
  }) : assert(auth != null);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  static const _kHeightBetweenWidgets = SizedBox(height: 8);

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) => Scaffold(
        key: _scaffoldKey,
        backgroundColor: app_styles.signInBackgroundColor,
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                  flex: 2,
                  child:
                      LogoImage(width: MediaQuery.of(context).size.width / 2)),
              _kDivider,
              Expanded(
                flex: 8,
                child: _buildSignInControls(context),
              ),
            ],
          ),
        ),
      );

  Widget _buildSignInControls(BuildContext context) => LayoutBuilder(
        builder: (_, viewportConstraints) => SingleChildScrollView(
          child: ConstrainedBox(
            // SingleChildScrollView will shrink-wrap the content, even when
            // there's enough room on the viewport (screen) to provide
            // comfortable spacing between the items in Column.
            // Setting minimum constraints ensures that the column becomes
            // either as big as viewport, or as big as the contents, whichever
            // is biggest. For more information, see:
            // https://api.flutter.dev/flutter/widgets/SingleChildScrollView-class.html#centering-spacing-or-aligning-fixed-height-content
            constraints: BoxConstraints(
              minHeight: viewportConstraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                // We put two Column widgets inside one with spaceBetween so
                // that any space unoccupied by the two is in between them.
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    flex: 6,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal:
                              MediaQuery.of(context).size.shortestSide * 0.1),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Center(
                              child: Text(
                                context.l.signInWithLabel.toUpperCase(),
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6
                                    .copyWith(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ),
                          ...signInButtonOrder(),
                          _kHeightBetweenWidgets
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal:
                            MediaQuery.of(context).size.shortestSide * 0.1,
                      ),
                      child: Center(
                        child: Text(
                          context.l.splashScreenFeatures,
                          style: app_styles.secondaryText.copyWith(
                            color: app_styles.kSignInTextColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      _kHeightBetweenWidgets,
                      Row(
                        children: <Widget>[
                          const Expanded(child: _kDivider),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Text(
                              context.l.signInScreenOr.toUpperCase(),
                              style: app_styles.secondaryText.copyWith(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: app_styles.kSignInSectionSeparationColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const Expanded(child: _kDivider),
                        ],
                      ),
                      _kHeightBetweenWidgets,
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal:
                              MediaQuery.of(context).size.shortestSide * 0.1,
                        ),
                        child: AnonymousSignInButton(
                          onPressed: () {
                            widget.signInMode == SignInMode.initialSignIn
                                ? _signInWithProvider(
                                    provider: null,
                                  )
                                : Navigator.of(context).pop();
                          },
                        ),
                      ),
                      _kHeightBetweenWidgets,
                      const LegalInfoWidget(),
                      const SafeArea(
                        child: _kHeightBetweenWidgets,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  Iterable<Widget> signInButtonOrder() {
    final buttons = <Widget>[
      GoogleSignInButton(
        onPressed: () {
          logLoginEvent('google');
          _signInWithProvider(
            provider: AuthProvider.google,
          );
        },
      ),
      _kHeightBetweenWidgets,
      FacebookSignInButton(
        onPressed: () {
          logLoginEvent('facebook');
          _signInWithProvider(
            provider: AuthProvider.facebook,
          );
        },
      ),
      _kHeightBetweenWidgets,
      AppleSignInButton(
        onPressed: () {
          logLoginEvent('apple');
          // TODO(dotdoom): implement logic
        },
      ),
    ];

    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return buttons.reversed;
    }

    return buttons;
  }

  Future<void> _signInWithProvider({
    @required AuthProvider provider,
    bool forceAccountPicker = true,
  }) async {
    try {
      await widget.auth.signIn(
        provider,
        forceAccountPicker: forceAccountPicker,
      );
    } on FirebaseAuthException catch (e, stackTrace) {
      // Cover only those scenarios where we can recover or an additional action
      // from user can be helpful.
      switch (e.code) {
        case 'email-already-in-use':
        // Already signed in (as anonymous, normally) and trying to link with
        // account that already exists. And on top of that, using a different
        // provider than the one used for initial account registration.
        case 'credential-already-in-use':
          // Already signed in (as anonymous, normally) and trying to link with
          // account that already exists.

          // TODO(ksheremet): Merge data
          final signIn = await showSaveUpdatesDialog(
            context: context,
            changesQuestion: context.l.signInCredentialAlreadyInUseWarning,
            yesAnswer: context.l.navigationDrawerSignIn,
            noAnswer: MaterialLocalizations.of(context).cancelButtonLabel,
          );
          if (signIn) {
            // Sign out of Firebase but retain the account that has been picked
            // by user.
            await widget.auth.signOut();
            return _signInWithProvider(
              provider: provider,
              forceAccountPicker: false,
            );
          }
          break;

        case 'account-exists-with-different-credential':
          // Trying to sign in with a different provider but the same email.
          // Can't showDialog because we don't have Navigator before sign in.
          UserMessages.showMessage(
            _scaffoldKey.currentState,
            context.l.signInAccountExistWithDifferentCredentialWarning,
          );
          break;

        default:
          UserMessages.showAndReportError(
            () => _scaffoldKey.currentState,
            e,
            stackTrace: stackTrace,
          );
      }
    } catch (e, stackTrace) {
      UserMessages.showAndReportError(
        () => _scaffoldKey.currentState,
        e,
        stackTrace: stackTrace,
      );
    }
  }
}

@immutable
class LogoImage extends StatelessWidget {
  final double width;

  const LogoImage({@required this.width}) : assert(width != null);

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'images/delern_with_logo.png',
              width: width,
            ),
          ],
        ),
      );
}

@immutable
class LegalInfoWidget extends StatelessWidget {
  const LegalInfoWidget();

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.shortestSide * 0.1),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: app_styles.secondaryText
                .copyWith(color: app_styles.kSignInTextColor),
            children: <TextSpan>[
              TextSpan(text: context.l.legacyAcceptanceLabel),
              _buildLegalUrl(
                  context: context,
                  url: kPrivacyPolicy,
                  text: context.l.privacyPolicy),
              TextSpan(text: context.l.legacyPartsConnector),
              _buildLegalUrl(
                  context: context,
                  url: kTermsOfService,
                  text: context.l.termsOfService),
            ],
          ),
        ),
      );

  TextSpan _buildLegalUrl({
    @required BuildContext context,
    @required String url,
    @required String text,
  }) =>
      TextSpan(
        text: text,
        style: app_styles.secondaryText.copyWith(
          decoration: TextDecoration.underline,
          color: app_styles.kHyperlinkColor,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            launchUrl(url, context);
          },
      );
}
