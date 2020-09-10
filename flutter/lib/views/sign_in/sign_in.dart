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
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _kDivider = Divider(
  height: 2,
  color: app_styles.kSignInSectionSeparationColor,
);

/// A screen with sign in information and buttons.
class SignIn extends StatelessWidget {
  static const routeName = '/signIn';
  static const _kHeightBetweenWidgets = SizedBox(height: 8);

  const SignIn() : super();

  @override
  Widget build(BuildContext context) => Scaffold(
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
                          GoogleSignInButton(
                            onPressed: () {
                              logLoginEvent(GoogleAuthProvider.providerId);
                              _signInWithProvider(
                                  context: context,
                                  provider: GoogleAuthProvider.providerId);
                            },
                          ),
                          _kHeightBetweenWidgets,
                          FacebookSignInButton(
                            onPressed: () {
                              logLoginEvent(FacebookAuthProvider.providerId);
                              _signInWithProvider(
                                  context: context,
                                  provider: FacebookAuthProvider.providerId);
                            },
                          ),
                          _kHeightBetweenWidgets,
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal:
                              MediaQuery.of(context).size.shortestSide * 0.1),
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
                                  color:
                                      app_styles.kSignInSectionSeparationColor),
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
                                MediaQuery.of(context).size.shortestSide * 0.1),
                        child: AnonymousSighInButton(
                          onPressed: () {
                            Auth.instance.currentUser == null
                                ? _signInWithProvider(
                                    context: context, provider: null)
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

Future<void> _signInWithProvider({
  @required BuildContext context,
  @required String provider,
  bool forceAccountPicker = true,
}) async {
  try {
    await Auth.instance.signIn(
      provider,
      forceAccountPicker: forceAccountPicker,
    );
  } on PlatformException catch (e, stackTrace) {
    // Cover only those scenarios where we can recover or an additional action
    // from user can be helpful.
    switch (e.code) {
      case 'ERROR_EMAIL_ALREADY_IN_USE':
      // Already signed in (as anonymous, normally) and trying to link with
      // account that already exists. And on top of that, using a different
      // provider than the one used for initial account registration.
      case 'ERROR_CREDENTIAL_ALREADY_IN_USE':
        // Already signed in (as anonymous, normally) and trying to link with
        // account that already exists.

        // TODO(ksheremet): Merge data
        final signIn = await showSaveUpdatesDialog(
            context: context,
            changesQuestion: context.l.signInCredentialAlreadyInUseWarning,
            yesAnswer: context.l.navigationDrawerSignIn,
            noAnswer: MaterialLocalizations.of(context).cancelButtonLabel);
        if (signIn) {
          // Sign out of Firebase but retain the account that has been picked
          // by user.
          await Auth.instance.signOut();
          return _signInWithProvider(
              context: context, provider: provider, forceAccountPicker: false);
        }
        break;

      case 'ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL':
        // Trying to sign in with a different provider but the same email.
        // Can't showDialog because we don't have Navigator before sign in.
        UserMessages.showMessage(Scaffold.of(context),
            context.l.signInAccountExistWithDifferentCredentialWarning);
        break;

      default:
        UserMessages.showAndReportError(
          () => Scaffold.of(context),
          e,
          stackTrace: stackTrace,
        );
    }
  }
}
