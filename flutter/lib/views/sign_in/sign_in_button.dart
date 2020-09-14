import 'package:delern_flutter/views/helpers/localization.dart';
import 'package:delern_flutter/views/helpers/styles.dart' as app_styles;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

@immutable
class GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  const GoogleSignInButton({this.onPressed});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onPressed,
        child: SignInButtonContainer(
          color: app_styles.kGoogleSignInButtonColor,
          child: Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Text(
                      context.l.signInWithGoogle.toUpperCase(),
                      style: app_styles.signInTextButton,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 2),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    heightFactor: 0.95,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: Colors.white,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Image.asset('images/google_sign_in.png'),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

@immutable
class FacebookSignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  const FacebookSignInButton({this.onPressed});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onPressed,
        child: SignInButtonContainer(
          color: app_styles.kFacebookBlueColor,
          child: Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Text(
                      context.l.signInWithFacebook.toUpperCase(),
                      style: app_styles.signInTextButton,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 1.5),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Image.asset(
                        'images/facebook_sign_in.webp',
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

class AnonymousSignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  const AnonymousSignInButton({this.onPressed});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onPressed,
        child: SignInButtonContainer(
          color: app_styles.kPrimarySwatch,
          child: Center(
            child: Text(
              context.l.continueAnonymously.toUpperCase(),
              style: app_styles.signInTextButton,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      );
}

@immutable
class SignInButtonContainer extends StatelessWidget {
  static const _buttonHeight = 48.0;

  final Widget child;
  final Color color;

  const SignInButtonContainer({
    @required this.child,
    @required this.color,
  })  : assert(child != null),
        assert(color != null);

  @override
  Widget build(BuildContext context) => Padding(
      // Padding around the button to avoid clashing it into other widgets
      // when short on space.
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: SizedBox(
        height: _buttonHeight,
        child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
              boxShadow: const [
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset(0, 4),
                  blurRadius: 6,
                ),
              ],
            ),
            child: child),
      ));
}
