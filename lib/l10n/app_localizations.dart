import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ro.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ro'),
  ];

  /// The application name shown in the OS task switcher
  ///
  /// In en, this message translates to:
  /// **'Tweakd'**
  String get appTitle;

  /// Label for the language selector in settings
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageRomanian.
  ///
  /// In en, this message translates to:
  /// **'Romanian'**
  String get languageRomanian;

  /// Title of the language picker bottom sheet
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get settingsLanguagePickerTitle;

  /// Shown in the language picker when fetching the option list fails
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load the language options. Please try again.'**
  String get settingsLanguageLoadError;

  /// Snackbar shown when picking a language fails to save
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t update your language. Please try again.'**
  String get settingsLanguageUpdateError;

  /// Label for the theme selector in settings
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// Title of the theme picker bottom sheet
  ///
  /// In en, this message translates to:
  /// **'Choose your theme'**
  String get settingsThemePickerTitle;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// Follower count with pluralization
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No followers} =1{1 follower} other{{count} followers}}'**
  String profileFollowers(int count);

  /// Greeting that interpolates the user's name
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}!'**
  String greetingHello(String name);

  /// Login page headline
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get authLoginTitle;

  /// Login page subtitle
  ///
  /// In en, this message translates to:
  /// **''**
  String get authLoginSubtitle;

  /// Sign up page headline
  ///
  /// In en, this message translates to:
  /// **'Join the community'**
  String get authSignupTitle;

  /// Sign up page subtitle
  ///
  /// In en, this message translates to:
  /// **''**
  String get authSignupSubtitle;

  /// No description provided for @authEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmailLabel;

  /// No description provided for @authEmailHint.
  ///
  /// In en, this message translates to:
  /// **'you@email.com'**
  String get authEmailHint;

  /// No description provided for @authPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordLabel;

  /// No description provided for @authPasswordHintLogin.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get authPasswordHintLogin;

  /// No description provided for @authPasswordHintSignup.
  ///
  /// In en, this message translates to:
  /// **'Create a password'**
  String get authPasswordHintSignup;

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgotPassword;

  /// No description provided for @authSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignIn;

  /// No description provided for @authCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authCreateAccount;

  /// No description provided for @authOrContinueWith.
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get authOrContinueWith;

  /// No description provided for @authOrSignUpWith.
  ///
  /// In en, this message translates to:
  /// **'Or sign up with'**
  String get authOrSignUpWith;

  /// Prefix before the 'Create account' link on the login page
  ///
  /// In en, this message translates to:
  /// **'New to Tweakd? '**
  String get authNoAccountPrefix;

  /// Prefix before the 'Sign in' link on the sign up page
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get authHaveAccountPrefix;

  /// No description provided for @authTermsPrefix.
  ///
  /// In en, this message translates to:
  /// **'By creating an account you agree to the '**
  String get authTermsPrefix;

  /// No description provided for @authTermsTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get authTermsTerms;

  /// No description provided for @authTermsAnd.
  ///
  /// In en, this message translates to:
  /// **' & '**
  String get authTermsAnd;

  /// No description provided for @authTermsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get authTermsPrivacy;

  /// Snackbar shown when tapping a social sign-up button before the terms checkbox is ticked
  ///
  /// In en, this message translates to:
  /// **'Please agree to the Terms & Privacy Policy first.'**
  String get authAgreeToTermsFirst;

  /// Snackbar shown when tapping a not-yet-implemented feature
  ///
  /// In en, this message translates to:
  /// **'{feature} is coming soon.'**
  String authComingSoon(String feature);

  /// Feature name for a social provider sign-in, fed into authComingSoon
  ///
  /// In en, this message translates to:
  /// **'{provider} sign-in'**
  String authFeatureProviderSignIn(String provider);

  /// Password checklist rule: minimum length
  ///
  /// In en, this message translates to:
  /// **'At least {count} characters'**
  String authPasswordRuleLength(int count);

  /// No description provided for @authPasswordRuleLowercase.
  ///
  /// In en, this message translates to:
  /// **'A lowercase letter'**
  String get authPasswordRuleLowercase;

  /// No description provided for @authPasswordRuleUppercase.
  ///
  /// In en, this message translates to:
  /// **'An uppercase letter'**
  String get authPasswordRuleUppercase;

  /// No description provided for @authPasswordRuleDigit.
  ///
  /// In en, this message translates to:
  /// **'A number'**
  String get authPasswordRuleDigit;

  /// No description provided for @authPasswordRuleSymbol.
  ///
  /// In en, this message translates to:
  /// **'A symbol (!, @, #, …)'**
  String get authPasswordRuleSymbol;

  /// No description provided for @authConfirmEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Check your inbox'**
  String get authConfirmEmailTitle;

  /// Sign-up confirmation screen subtitle
  ///
  /// In en, this message translates to:
  /// **'We sent a code to {email}. Enter it below to activate your account.'**
  String authConfirmEmailSubtitle(String email);

  /// No description provided for @authConfirmEmailVerify.
  ///
  /// In en, this message translates to:
  /// **'Confirm email'**
  String get authConfirmEmailVerify;

  /// No description provided for @authConfirmEmailResent.
  ///
  /// In en, this message translates to:
  /// **'Confirmation email sent again.'**
  String get authConfirmEmailResent;

  /// No description provided for @authResendEmail.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t get it? Resend'**
  String get authResendEmail;

  /// Resend button label during its cooldown
  ///
  /// In en, this message translates to:
  /// **'RESEND IN {seconds}s'**
  String authResendIn(int seconds);

  /// No description provided for @authBackToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get authBackToSignIn;

  /// No description provided for @authForgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset your password'**
  String get authForgotPasswordTitle;

  /// No description provided for @authForgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we\'ll send you a code.'**
  String get authForgotPasswordSubtitle;

  /// No description provided for @authSendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get authSendCode;

  /// No description provided for @authResetCodeResent.
  ///
  /// In en, this message translates to:
  /// **'A new code is on its way.'**
  String get authResetCodeResent;

  /// No description provided for @authVerifyCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your code'**
  String get authVerifyCodeTitle;

  /// Password reset code entry subtitle
  ///
  /// In en, this message translates to:
  /// **'We sent a code to {email}. It expires shortly, so use it soon.'**
  String authVerifyCodeSubtitle(String email);

  /// No description provided for @authVerifyCode.
  ///
  /// In en, this message translates to:
  /// **'Verify code'**
  String get authVerifyCode;

  /// No description provided for @authNewPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a new password'**
  String get authNewPasswordTitle;

  /// No description provided for @authNewPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Saving this signs out every other device.'**
  String get authNewPasswordSubtitle;

  /// No description provided for @authNewPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get authNewPasswordLabel;

  /// No description provided for @authConfirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get authConfirmPasswordLabel;

  /// No description provided for @authConfirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Repeat your new password'**
  String get authConfirmPasswordHint;

  /// No description provided for @authPasswordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'The passwords don\'t match.'**
  String get authPasswordsDoNotMatch;

  /// No description provided for @authSavePassword.
  ///
  /// In en, this message translates to:
  /// **'Save password'**
  String get authSavePassword;

  /// No description provided for @authPasswordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Your password has been updated.'**
  String get authPasswordUpdated;

  /// No description provided for @onboardingBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get onboardingBack;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingFinishSetup.
  ///
  /// In en, this message translates to:
  /// **'Finish setup'**
  String get onboardingFinishSetup;

  /// No description provided for @onboardingFinishingSetup.
  ///
  /// In en, this message translates to:
  /// **'Finishing setup…'**
  String get onboardingFinishingSetup;

  /// No description provided for @onboardingWorking.
  ///
  /// In en, this message translates to:
  /// **'Working…'**
  String get onboardingWorking;

  /// No description provided for @onboardingOptional.
  ///
  /// In en, this message translates to:
  /// **'OPTIONAL'**
  String get onboardingOptional;

  /// No description provided for @onboardingSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search…'**
  String get onboardingSearchHint;

  /// No description provided for @onboardingNoMatches.
  ///
  /// In en, this message translates to:
  /// **'No matches'**
  String get onboardingNoMatches;

  /// No description provided for @onboardingErrorPickBrand.
  ///
  /// In en, this message translates to:
  /// **'Pick at least one brand you\'re into.'**
  String get onboardingErrorPickBrand;

  /// No description provided for @onboardingErrorSelectCity.
  ///
  /// In en, this message translates to:
  /// **'Select your city to continue.'**
  String get onboardingErrorSelectCity;

  /// No description provided for @onboardingNameErrorEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name.'**
  String get onboardingNameErrorEmpty;

  /// No description provided for @onboardingNameErrorTooShort.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least {min} characters.'**
  String onboardingNameErrorTooShort(int min);

  /// No description provided for @onboardingNameErrorTooLong.
  ///
  /// In en, this message translates to:
  /// **'Name must be at most {max} characters.'**
  String onboardingNameErrorTooLong(int max);

  /// No description provided for @onboardingUsernameErrorEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please choose a handle.'**
  String get onboardingUsernameErrorEmpty;

  /// No description provided for @onboardingUsernameErrorTooShort.
  ///
  /// In en, this message translates to:
  /// **'Handle must be at least {min} characters.'**
  String onboardingUsernameErrorTooShort(int min);

  /// No description provided for @onboardingUsernameErrorTooLong.
  ///
  /// In en, this message translates to:
  /// **'Handle must be at most {max} characters.'**
  String onboardingUsernameErrorTooLong(int max);

  /// No description provided for @onboardingUsernameErrorInvalidChars.
  ///
  /// In en, this message translates to:
  /// **'Use lowercase letters, numbers, dots (.) and underscores (_).'**
  String get onboardingUsernameErrorInvalidChars;

  /// No description provided for @onboardingUsernameChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking availability…'**
  String get onboardingUsernameChecking;

  /// No description provided for @onboardingUsernameTaken.
  ///
  /// In en, this message translates to:
  /// **' is already taken'**
  String get onboardingUsernameTaken;

  /// No description provided for @onboardingUsernameAvailable.
  ///
  /// In en, this message translates to:
  /// **' is available'**
  String get onboardingUsernameAvailable;

  /// No description provided for @onboardingUsernameCheckFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t check availability. Tap Next to try anyway.'**
  String get onboardingUsernameCheckFailed;

  /// No description provided for @onboardingUsernameHint.
  ///
  /// In en, this message translates to:
  /// **'your_handle'**
  String get onboardingUsernameHint;

  /// No description provided for @onboardingErrorLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load onboarding data. Please try again.'**
  String get onboardingErrorLoadFailed;

  /// No description provided for @onboardingErrorUsernameTaken.
  ///
  /// In en, this message translates to:
  /// **'That handle is already taken. Try another one.'**
  String get onboardingErrorUsernameTaken;

  /// No description provided for @onboardingErrorSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session is not active. Please log in again.'**
  String get onboardingErrorSessionExpired;

  /// No description provided for @onboardingErrorInvalidUsername.
  ///
  /// In en, this message translates to:
  /// **'That username isn\'t valid. Please try another.'**
  String get onboardingErrorInvalidUsername;

  /// No description provided for @onboardingErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get onboardingErrorGeneric;

  /// No description provided for @onboardingIdentityLabel.
  ///
  /// In en, this message translates to:
  /// **'01 — Identity'**
  String get onboardingIdentityLabel;

  /// No description provided for @onboardingIdentityTitle.
  ///
  /// In en, this message translates to:
  /// **'Claim your handle'**
  String get onboardingIdentityTitle;

  /// No description provided for @onboardingFieldName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get onboardingFieldName;

  /// No description provided for @onboardingNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get onboardingNameHint;

  /// No description provided for @onboardingFieldUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get onboardingFieldUsername;

  /// No description provided for @onboardingFieldBio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get onboardingFieldBio;

  /// No description provided for @onboardingBioHint.
  ///
  /// In en, this message translates to:
  /// **'Tell others a few things about yourself…'**
  String get onboardingBioHint;

  /// No description provided for @onboardingGarageLabel.
  ///
  /// In en, this message translates to:
  /// **'02 — Preferences'**
  String get onboardingGarageLabel;

  /// No description provided for @onboardingGarageTitle.
  ///
  /// In en, this message translates to:
  /// **'Your garage'**
  String get onboardingGarageTitle;

  /// No description provided for @onboardingGarageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Brands you follow — we’ll tune your feed and the marketplace around them.'**
  String get onboardingGarageSubtitle;

  /// No description provided for @onboardingFieldYourPicks.
  ///
  /// In en, this message translates to:
  /// **'Your picks'**
  String get onboardingFieldYourPicks;

  /// No description provided for @onboardingFieldModels.
  ///
  /// In en, this message translates to:
  /// **'Models'**
  String get onboardingFieldModels;

  /// No description provided for @onboardingSelectBrand.
  ///
  /// In en, this message translates to:
  /// **'Select a brand'**
  String get onboardingSelectBrand;

  /// No description provided for @onboardingAddModels.
  ///
  /// In en, this message translates to:
  /// **'Add models'**
  String get onboardingAddModels;

  /// No description provided for @onboardingBrandModels.
  ///
  /// In en, this message translates to:
  /// **'{brand} models'**
  String onboardingBrandModels(String brand);

  /// No description provided for @onboardingAddBrand.
  ///
  /// In en, this message translates to:
  /// **'Add another brand'**
  String get onboardingAddBrand;

  /// No description provided for @onboardingLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'03 — Location'**
  String get onboardingLocationLabel;

  /// No description provided for @onboardingLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Where does the local community find you?'**
  String get onboardingLocationTitle;

  /// No description provided for @onboardingLocationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your location helps us tailor your experience with local carmeets, events and relevant marketplace finds.'**
  String get onboardingLocationSubtitle;

  /// No description provided for @onboardingFieldCountry.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get onboardingFieldCountry;

  /// No description provided for @onboardingFieldRegion.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get onboardingFieldRegion;

  /// No description provided for @onboardingFieldCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get onboardingFieldCity;

  /// No description provided for @onboardingSelectCountryPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Select your country'**
  String get onboardingSelectCountryPlaceholder;

  /// No description provided for @onboardingSelectRegionPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Select your region'**
  String get onboardingSelectRegionPlaceholder;

  /// No description provided for @onboardingPickCountryFirst.
  ///
  /// In en, this message translates to:
  /// **'Pick a country first'**
  String get onboardingPickCountryFirst;

  /// No description provided for @onboardingSelectCityPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Select your city'**
  String get onboardingSelectCityPlaceholder;

  /// No description provided for @onboardingPickRegionFirst.
  ///
  /// In en, this message translates to:
  /// **'Pick a region first'**
  String get onboardingPickRegionFirst;

  /// No description provided for @onboardingPickerCountry.
  ///
  /// In en, this message translates to:
  /// **'Select country'**
  String get onboardingPickerCountry;

  /// No description provided for @onboardingPickerRegion.
  ///
  /// In en, this message translates to:
  /// **'Select region'**
  String get onboardingPickerRegion;

  /// No description provided for @onboardingPickerCity.
  ///
  /// In en, this message translates to:
  /// **'Select city'**
  String get onboardingPickerCity;

  /// No description provided for @onboardingDiscoveryRadius.
  ///
  /// In en, this message translates to:
  /// **'Discovery radius'**
  String get onboardingDiscoveryRadius;

  /// No description provided for @onboardingNotificationsLabel.
  ///
  /// In en, this message translates to:
  /// **'04 — Notifications'**
  String get onboardingNotificationsLabel;

  /// No description provided for @onboardingNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'What should we ping you about?'**
  String get onboardingNotificationsTitle;

  /// No description provided for @onboardingNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Stay on top of what matters. You can fine-tune any of these later.'**
  String get onboardingNotificationsSubtitle;

  /// No description provided for @onboardingPushGrantedText.
  ///
  /// In en, this message translates to:
  /// **'Push notifications are on. Pick what you want to hear about below.'**
  String get onboardingPushGrantedText;

  /// No description provided for @onboardingPushBlockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Push notifications are turned off'**
  String get onboardingPushBlockedTitle;

  /// No description provided for @onboardingPushBlockedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'They\'re blocked in your system settings. Turn them on to get pinged about the topics below.'**
  String get onboardingPushBlockedSubtitle;

  /// No description provided for @onboardingPushOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get onboardingPushOpenSettings;

  /// No description provided for @onboardingPushEnableTitle.
  ///
  /// In en, this message translates to:
  /// **'Turn on push notifications'**
  String get onboardingPushEnableTitle;

  /// No description provided for @onboardingPushEnableSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications so we can ping you about the topics you pick below.'**
  String get onboardingPushEnableSubtitle;

  /// No description provided for @onboardingPushEnable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get onboardingPushEnable;

  /// No description provided for @onboardingNotifGroupContent.
  ///
  /// In en, this message translates to:
  /// **'On your content'**
  String get onboardingNotifGroupContent;

  /// No description provided for @onboardingNotifGroupMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get onboardingNotifGroupMessages;

  /// No description provided for @onboardingNotifGroupMeets.
  ///
  /// In en, this message translates to:
  /// **'Meets & events · within {radius} km'**
  String onboardingNotifGroupMeets(int radius);

  /// No description provided for @onboardingNotifGroupGarage.
  ///
  /// In en, this message translates to:
  /// **'Your garage'**
  String get onboardingNotifGroupGarage;

  /// No description provided for @onboardingNotifLikesTitle.
  ///
  /// In en, this message translates to:
  /// **'Likes'**
  String get onboardingNotifLikesTitle;

  /// No description provided for @onboardingNotifLikesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'When someone likes your builds & posts'**
  String get onboardingNotifLikesSubtitle;

  /// No description provided for @onboardingNotifCommentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get onboardingNotifCommentsTitle;

  /// No description provided for @onboardingNotifCommentsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Replies and threads on your content'**
  String get onboardingNotifCommentsSubtitle;

  /// No description provided for @onboardingNotifSharesTitle.
  ///
  /// In en, this message translates to:
  /// **'Reposts'**
  String get onboardingNotifSharesTitle;

  /// No description provided for @onboardingNotifSharesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'When someone reposts your post'**
  String get onboardingNotifSharesSubtitle;

  /// No description provided for @onboardingNotifDmsTitle.
  ///
  /// In en, this message translates to:
  /// **'Direct messages'**
  String get onboardingNotifDmsTitle;

  /// No description provided for @onboardingNotifDmsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'New DMs and message requests'**
  String get onboardingNotifDmsSubtitle;

  /// No description provided for @onboardingNotifFlashMeetsTitle.
  ///
  /// In en, this message translates to:
  /// **'Flash meets'**
  String get onboardingNotifFlashMeetsTitle;

  /// No description provided for @onboardingNotifFlashMeetsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Spontaneous link-ups happening near you'**
  String get onboardingNotifFlashMeetsSubtitle;

  /// No description provided for @onboardingNotifEventsTitle.
  ///
  /// In en, this message translates to:
  /// **'Organized events'**
  String get onboardingNotifEventsTitle;

  /// No description provided for @onboardingNotifEventsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Shows, track days & cars-and-coffee'**
  String get onboardingNotifEventsSubtitle;

  /// No description provided for @onboardingNotifEventOrganizerTitle.
  ///
  /// In en, this message translates to:
  /// **'Event organizer'**
  String get onboardingNotifEventOrganizerTitle;

  /// No description provided for @onboardingNotifEventOrganizerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'When someone enters your event, joins as co-organizer, or asks to withdraw'**
  String get onboardingNotifEventOrganizerSubtitle;

  /// No description provided for @onboardingNotifServiceRemindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Service reminders'**
  String get onboardingNotifServiceRemindersTitle;

  /// No description provided for @onboardingNotifServiceRemindersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Upcoming services and expiring documents on your cars'**
  String get onboardingNotifServiceRemindersSubtitle;

  /// No description provided for @onboardingNotifTagsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get onboardingNotifTagsTitle;

  /// No description provided for @onboardingNotifTagsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'When someone tags you or your car'**
  String get onboardingNotifTagsSubtitle;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get profileMessage;

  /// No description provided for @profileStatReputation.
  ///
  /// In en, this message translates to:
  /// **'reputation'**
  String get profileStatReputation;

  /// No description provided for @profileStatFollowers.
  ///
  /// In en, this message translates to:
  /// **'followers'**
  String get profileStatFollowers;

  /// No description provided for @profileStatFollowing.
  ///
  /// In en, this message translates to:
  /// **'following'**
  String get profileStatFollowing;

  /// No description provided for @profileErrorUsernameTaken.
  ///
  /// In en, this message translates to:
  /// **'The username is already taken. Please choose a different one.'**
  String get profileErrorUsernameTaken;

  /// No description provided for @profileErrorSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session is not active. Please log in again.'**
  String get profileErrorSessionExpired;

  /// No description provided for @profileErrorNotFound.
  ///
  /// In en, this message translates to:
  /// **'This profile could not be found.'**
  String get profileErrorNotFound;

  /// No description provided for @profileErrorInvalidUsername.
  ///
  /// In en, this message translates to:
  /// **'That username isn\'t valid. Please try another.'**
  String get profileErrorInvalidUsername;

  /// No description provided for @profileErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get profileErrorGeneric;

  /// No description provided for @profileErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please try again.'**
  String get profileErrorNetwork;

  /// No description provided for @profileEditButton.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get profileEditButton;

  /// No description provided for @profileShareButton.
  ///
  /// In en, this message translates to:
  /// **'Share profile'**
  String get profileShareButton;

  /// No description provided for @profileFeedbackButton.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get profileFeedbackButton;

  /// No description provided for @navFeed.
  ///
  /// In en, this message translates to:
  /// **'Feed'**
  String get navFeed;

  /// No description provided for @navMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get navMap;

  /// No description provided for @navCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get navCreate;

  /// No description provided for @navSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfileTitle;

  /// No description provided for @editProfileChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get editProfileChangePhoto;

  /// No description provided for @editProfileNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get editProfileNameLabel;

  /// No description provided for @editProfileNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your display name'**
  String get editProfileNameHint;

  /// No description provided for @editProfileBioLabel.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get editProfileBioLabel;

  /// No description provided for @editProfileBioHint.
  ///
  /// In en, this message translates to:
  /// **'Tell others a few things about yourself…'**
  String get editProfileBioHint;

  /// No description provided for @editProfileSave.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get editProfileSave;

  /// No description provided for @editProfileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get editProfileSaved;

  /// No description provided for @editProfilePhotoUpdated.
  ///
  /// In en, this message translates to:
  /// **'Photo updated'**
  String get editProfilePhotoUpdated;

  /// No description provided for @editProfileErrorInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please check your name and bio, then try again.'**
  String get editProfileErrorInvalid;

  /// No description provided for @editProfileErrorAvatar.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t update your photo. Please try again.'**
  String get editProfileErrorAvatar;

  /// No description provided for @followActionFollow.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get followActionFollow;

  /// No description provided for @followActionUnfollow.
  ///
  /// In en, this message translates to:
  /// **'Unfollow'**
  String get followActionUnfollow;

  /// No description provided for @followActionRequested.
  ///
  /// In en, this message translates to:
  /// **'Requested'**
  String get followActionRequested;

  /// No description provided for @garageEmptyOwner.
  ///
  /// In en, this message translates to:
  /// **'Your garage is empty. Add your first car.'**
  String get garageEmptyOwner;

  /// No description provided for @garageAddNewCar.
  ///
  /// In en, this message translates to:
  /// **'Add new car'**
  String get garageAddNewCar;

  /// No description provided for @garageEmptyVisitor.
  ///
  /// In en, this message translates to:
  /// **'No cars yet.'**
  String get garageEmptyVisitor;

  /// No description provided for @followActionFollowing.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get followActionFollowing;

  /// No description provided for @followRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get followRemove;

  /// No description provided for @followUnfollowConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Unfollow @{username}?'**
  String followUnfollowConfirmTitle(String username);

  /// No description provided for @followUnfollowConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Their posts will stop showing up in your feed.'**
  String get followUnfollowConfirmBody;

  /// No description provided for @followRemoveConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove @{username}?'**
  String followRemoveConfirmTitle(String username);

  /// No description provided for @followRemoveConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'They\'ll no longer follow you. They can follow you again later.'**
  String get followRemoveConfirmBody;

  /// No description provided for @followSearchFollowersHint.
  ///
  /// In en, this message translates to:
  /// **'Search followers...'**
  String get followSearchFollowersHint;

  /// No description provided for @followSearchFollowingHint.
  ///
  /// In en, this message translates to:
  /// **'Search following...'**
  String get followSearchFollowingHint;

  /// No description provided for @followResultsForQuery.
  ///
  /// In en, this message translates to:
  /// **'For \"{query}\"'**
  String followResultsForQuery(String query);

  /// No description provided for @followNoResultsQuery.
  ///
  /// In en, this message translates to:
  /// **'No results for \"{query}\"'**
  String followNoResultsQuery(String query);

  /// No description provided for @followNoFollowers.
  ///
  /// In en, this message translates to:
  /// **'No followers yet'**
  String get followNoFollowers;

  /// No description provided for @followNoFollowing.
  ///
  /// In en, this message translates to:
  /// **'Not following anyone yet'**
  String get followNoFollowing;

  /// No description provided for @followErrorCannotFollowSelf.
  ///
  /// In en, this message translates to:
  /// **'You can\'t follow yourself.'**
  String get followErrorCannotFollowSelf;

  /// No description provided for @followErrorPrivateProfile.
  ///
  /// In en, this message translates to:
  /// **'This profile is private.'**
  String get followErrorPrivateProfile;

  /// No description provided for @followErrorUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'That user could not be found.'**
  String get followErrorUserNotFound;

  /// No description provided for @followErrorRequestNotFound.
  ///
  /// In en, this message translates to:
  /// **'That follow request could not be found.'**
  String get followErrorRequestNotFound;

  /// No description provided for @followErrorSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session is not active. Please log in again.'**
  String get followErrorSessionExpired;

  /// No description provided for @followErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get followErrorGeneric;

  /// No description provided for @searchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchTitle;

  /// No description provided for @searchInputHint.
  ///
  /// In en, this message translates to:
  /// **'Search by username'**
  String get searchInputHint;

  /// No description provided for @searchEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Search community members'**
  String get searchEmptyTitle;

  /// No description provided for @searchEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Type a username to find members across\nthe community.'**
  String get searchEmptySubtitle;

  /// No description provided for @searchResultsDrivers.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 USER} other{{count} USERS}}'**
  String searchResultsDrivers(int count);

  /// No description provided for @searchForQuery.
  ///
  /// In en, this message translates to:
  /// **'For \"{query}\"'**
  String searchForQuery(String query);

  /// No description provided for @searchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No users found for \"{query}\"'**
  String searchNoResults(String query);

  /// No description provided for @searchErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get searchErrorGeneric;

  /// No description provided for @feedEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your feed is quiet'**
  String get feedEmptyTitle;

  /// No description provided for @feedEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Be one of the first to show your car. Posts from the community land here.'**
  String get feedEmptyMessage;

  /// No description provided for @feedEmptyCta.
  ///
  /// In en, this message translates to:
  /// **'Share a post'**
  String get feedEmptyCta;

  /// No description provided for @feedErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Check your network and try again.'**
  String get feedErrorNetwork;

  /// No description provided for @feedErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the feed. Please try again.'**
  String get feedErrorGeneric;

  /// No description provided for @garageErrorCarNotFound.
  ///
  /// In en, this message translates to:
  /// **'This car could not be found.'**
  String get garageErrorCarNotFound;

  /// No description provided for @garageErrorGarageNotFound.
  ///
  /// In en, this message translates to:
  /// **'This garage could not be found.'**
  String get garageErrorGarageNotFound;

  /// No description provided for @garageErrorPrivateGarage.
  ///
  /// In en, this message translates to:
  /// **'This garage is private.'**
  String get garageErrorPrivateGarage;

  /// No description provided for @garageErrorNotOwner.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission to do that.'**
  String get garageErrorNotOwner;

  /// No description provided for @garageErrorInvalidReference.
  ///
  /// In en, this message translates to:
  /// **'Some of the selected options are invalid.'**
  String get garageErrorInvalidReference;

  /// No description provided for @garageErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get garageErrorGeneric;

  /// No description provided for @garageErrorRefDataLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load form data. Please try again.'**
  String get garageErrorRefDataLoadFailed;

  /// No description provided for @garageErrorCategoriesLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load categories. Please try again.'**
  String get garageErrorCategoriesLoadFailed;

  /// No description provided for @garageErrorPhotoUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Photo upload failed. Please try again.'**
  String get garageErrorPhotoUploadFailed;

  /// No description provided for @garageErrorEditSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Some changes could not be saved. Please try again.'**
  String get garageErrorEditSaveFailed;

  /// No description provided for @garagePhaseCreating.
  ///
  /// In en, this message translates to:
  /// **'Creating car'**
  String get garagePhaseCreating;

  /// No description provided for @garagePhaseUploadingPhotos.
  ///
  /// In en, this message translates to:
  /// **'Uploading photos…'**
  String get garagePhaseUploadingPhotos;

  /// No description provided for @garagePhaseSavingChanges.
  ///
  /// In en, this message translates to:
  /// **'Saving changes…'**
  String get garagePhaseSavingChanges;

  /// No description provided for @garagePhaseSavingPhotos.
  ///
  /// In en, this message translates to:
  /// **'Saving photos…'**
  String get garagePhaseSavingPhotos;

  /// No description provided for @garageRegisterBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get garageRegisterBack;

  /// No description provided for @garageRegisterNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get garageRegisterNext;

  /// No description provided for @garageRegisterWorking.
  ///
  /// In en, this message translates to:
  /// **'Working…'**
  String get garageRegisterWorking;

  /// No description provided for @garageRegisterAddCar.
  ///
  /// In en, this message translates to:
  /// **'Add car'**
  String get garageRegisterAddCar;

  /// No description provided for @garageRegisterSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get garageRegisterSave;

  /// No description provided for @garageOptional.
  ///
  /// In en, this message translates to:
  /// **'OPTIONAL'**
  String get garageOptional;

  /// No description provided for @garageSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search…'**
  String get garageSearchHint;

  /// No description provided for @garageNoMatches.
  ///
  /// In en, this message translates to:
  /// **'No matches'**
  String get garageNoMatches;

  /// No description provided for @garageRegisterSpecsTitle.
  ///
  /// In en, this message translates to:
  /// **'Car details'**
  String get garageRegisterSpecsTitle;

  /// No description provided for @garageSpecsTabBasics.
  ///
  /// In en, this message translates to:
  /// **'Basics'**
  String get garageSpecsTabBasics;

  /// No description provided for @garageSpecsTabPower.
  ///
  /// In en, this message translates to:
  /// **'Power'**
  String get garageSpecsTabPower;

  /// No description provided for @garageSpecsTabConfig.
  ///
  /// In en, this message translates to:
  /// **'Config'**
  String get garageSpecsTabConfig;

  /// No description provided for @garageFieldMake.
  ///
  /// In en, this message translates to:
  /// **'Make'**
  String get garageFieldMake;

  /// No description provided for @garageHintMake.
  ///
  /// In en, this message translates to:
  /// **'e.g. Porsche'**
  String get garageHintMake;

  /// No description provided for @garagePickerMake.
  ///
  /// In en, this message translates to:
  /// **'Select Make'**
  String get garagePickerMake;

  /// No description provided for @garageFieldModel.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get garageFieldModel;

  /// No description provided for @garageHintModelPickMakeFirst.
  ///
  /// In en, this message translates to:
  /// **'Select a make first'**
  String get garageHintModelPickMakeFirst;

  /// No description provided for @garageHintModel.
  ///
  /// In en, this message translates to:
  /// **'e.g. 911 GT3 RS'**
  String get garageHintModel;

  /// No description provided for @garagePickerModel.
  ///
  /// In en, this message translates to:
  /// **'Select Model'**
  String get garagePickerModel;

  /// No description provided for @garageFieldYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get garageFieldYear;

  /// No description provided for @garageFieldChassisCode.
  ///
  /// In en, this message translates to:
  /// **'VIN'**
  String get garageFieldChassisCode;

  /// No description provided for @garageFieldModelCode.
  ///
  /// In en, this message translates to:
  /// **'Model code'**
  String get garageFieldModelCode;

  /// No description provided for @garageHintModelCode.
  ///
  /// In en, this message translates to:
  /// **'e.g. G30'**
  String get garageHintModelCode;

  /// No description provided for @garagePickFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Tap to pick from your gallery'**
  String get garagePickFromGallery;

  /// No description provided for @garageFieldPower.
  ///
  /// In en, this message translates to:
  /// **'Power'**
  String get garageFieldPower;

  /// No description provided for @garageFieldTorque.
  ///
  /// In en, this message translates to:
  /// **'Torque'**
  String get garageFieldTorque;

  /// No description provided for @garageFieldWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get garageFieldWeight;

  /// No description provided for @garageFieldDisplacement.
  ///
  /// In en, this message translates to:
  /// **'Displacement'**
  String get garageFieldDisplacement;

  /// No description provided for @garageFieldEngineCode.
  ///
  /// In en, this message translates to:
  /// **'Engine code'**
  String get garageFieldEngineCode;

  /// No description provided for @garageHintEngineCode.
  ///
  /// In en, this message translates to:
  /// **'e.g. S58'**
  String get garageHintEngineCode;

  /// No description provided for @garageFieldFuelType.
  ///
  /// In en, this message translates to:
  /// **'Fuel type'**
  String get garageFieldFuelType;

  /// No description provided for @garageHintFuelType.
  ///
  /// In en, this message translates to:
  /// **'e.g. Petrol'**
  String get garageHintFuelType;

  /// No description provided for @garagePickerFuelType.
  ///
  /// In en, this message translates to:
  /// **'Select Fuel Type'**
  String get garagePickerFuelType;

  /// No description provided for @garageFieldDrivetrain.
  ///
  /// In en, this message translates to:
  /// **'Drivetrain'**
  String get garageFieldDrivetrain;

  /// No description provided for @garageHintDrivetrain.
  ///
  /// In en, this message translates to:
  /// **'e.g. Rear-Wheel Drive'**
  String get garageHintDrivetrain;

  /// No description provided for @garagePickerDrivetrain.
  ///
  /// In en, this message translates to:
  /// **'Select Drivetrain'**
  String get garagePickerDrivetrain;

  /// No description provided for @garageFieldColor.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get garageFieldColor;

  /// No description provided for @garageHintColor.
  ///
  /// In en, this message translates to:
  /// **'e.g. Inka Orange'**
  String get garageHintColor;

  /// No description provided for @garagePickerColor.
  ///
  /// In en, this message translates to:
  /// **'Select Color'**
  String get garagePickerColor;

  /// No description provided for @garageFieldMileageUnit.
  ///
  /// In en, this message translates to:
  /// **'Mileage unit'**
  String get garageFieldMileageUnit;

  /// No description provided for @garageFieldMileage.
  ///
  /// In en, this message translates to:
  /// **'Mileage'**
  String get garageFieldMileage;

  /// No description provided for @garageHintMileage.
  ///
  /// In en, this message translates to:
  /// **'e.g. 42000'**
  String get garageHintMileage;

  /// No description provided for @garageRegisterStoryTitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s this car\'s story? Share it…'**
  String get garageRegisterStoryTitle;

  /// No description provided for @garageFieldStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get garageFieldStatus;

  /// No description provided for @garageFieldTheStory.
  ///
  /// In en, this message translates to:
  /// **'The story'**
  String get garageFieldTheStory;

  /// No description provided for @garageHintStory.
  ///
  /// In en, this message translates to:
  /// **'What\'s this car\'s story? Share it…'**
  String get garageHintStory;

  /// No description provided for @garageRegisterGalleryTitle.
  ///
  /// In en, this message translates to:
  /// **'Show it off'**
  String get garageRegisterGalleryTitle;

  /// No description provided for @garageFieldGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get garageFieldGallery;

  /// No description provided for @garageAddCoverPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add the cover photo'**
  String get garageAddCoverPhoto;

  /// No description provided for @garageGalleryAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get garageGalleryAdd;

  /// No description provided for @garageGalleryHint.
  ///
  /// In en, this message translates to:
  /// **'Showcase only — your sharpest, most striking shots. Best angles, colour and light. Up to 15 photos.'**
  String get garageGalleryHint;

  /// No description provided for @garageRegisterModsTitle.
  ///
  /// In en, this message translates to:
  /// **'Build log'**
  String get garageRegisterModsTitle;

  /// No description provided for @garageRegisterModsSubtitle.
  ///
  /// In en, this message translates to:
  /// **''**
  String get garageRegisterModsSubtitle;

  /// No description provided for @garageModFallbackCategory.
  ///
  /// In en, this message translates to:
  /// **'Modification'**
  String get garageModFallbackCategory;

  /// No description provided for @garageAddModification.
  ///
  /// In en, this message translates to:
  /// **'Add modification'**
  String get garageAddModification;

  /// No description provided for @garageModSheetTitleEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit build item'**
  String get garageModSheetTitleEdit;

  /// No description provided for @garageModSheetTitleAdd.
  ///
  /// In en, this message translates to:
  /// **'Add a build item'**
  String get garageModSheetTitleAdd;

  /// No description provided for @garageFieldCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get garageFieldCategory;

  /// No description provided for @garageHintCategory.
  ///
  /// In en, this message translates to:
  /// **'e.g. Engine'**
  String get garageHintCategory;

  /// No description provided for @garagePickerCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get garagePickerCategory;

  /// No description provided for @garageFieldTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get garageFieldTitle;

  /// No description provided for @garageHintModTitle.
  ///
  /// In en, this message translates to:
  /// **'e.g. Stage 2 turbo'**
  String get garageHintModTitle;

  /// No description provided for @garageFieldDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get garageFieldDescription;

  /// No description provided for @garageHintModDescription.
  ///
  /// In en, this message translates to:
  /// **'What changed, and what it gained…'**
  String get garageHintModDescription;

  /// No description provided for @garageFieldInstallationDate.
  ///
  /// In en, this message translates to:
  /// **'Installation date'**
  String get garageFieldInstallationDate;

  /// No description provided for @garageSelectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get garageSelectDate;

  /// No description provided for @garageFieldPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get garageFieldPrice;

  /// No description provided for @garageFieldMileageShort.
  ///
  /// In en, this message translates to:
  /// **'Mileage'**
  String get garageFieldMileageShort;

  /// No description provided for @garageModBefore.
  ///
  /// In en, this message translates to:
  /// **'Before'**
  String get garageModBefore;

  /// No description provided for @garageModAfter.
  ///
  /// In en, this message translates to:
  /// **'After'**
  String get garageModAfter;

  /// No description provided for @garageModSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get garageModSaveChanges;

  /// No description provided for @garageModAddToBuildLog.
  ///
  /// In en, this message translates to:
  /// **'Add to build log'**
  String get garageModAddToBuildLog;

  /// No description provided for @garageModValidation.
  ///
  /// In en, this message translates to:
  /// **'Category, title and date are required.'**
  String get garageModValidation;

  /// No description provided for @garageAboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get garageAboutTitle;

  /// No description provided for @garageBuildIdentifier.
  ///
  /// In en, this message translates to:
  /// **'Build identifier · {code}'**
  String garageBuildIdentifier(String code);

  /// No description provided for @garageSpecPower.
  ///
  /// In en, this message translates to:
  /// **'Power'**
  String get garageSpecPower;

  /// No description provided for @garageSpecTorque.
  ///
  /// In en, this message translates to:
  /// **'Torque'**
  String get garageSpecTorque;

  /// No description provided for @garageSpecWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get garageSpecWeight;

  /// No description provided for @garageInfoDrivetrain.
  ///
  /// In en, this message translates to:
  /// **'Drivetrain'**
  String get garageInfoDrivetrain;

  /// No description provided for @garageInfoMileage.
  ///
  /// In en, this message translates to:
  /// **'Mileage'**
  String get garageInfoMileage;

  /// No description provided for @garageInfoModelCode.
  ///
  /// In en, this message translates to:
  /// **'Model code'**
  String get garageInfoModelCode;

  /// No description provided for @garageInfoEngineCode.
  ///
  /// In en, this message translates to:
  /// **'Engine code'**
  String get garageInfoEngineCode;

  /// No description provided for @garageInfoDisplacement.
  ///
  /// In en, this message translates to:
  /// **'Displacement'**
  String get garageInfoDisplacement;

  /// No description provided for @garageInfoFuelType.
  ///
  /// In en, this message translates to:
  /// **'Fuel type'**
  String get garageInfoFuelType;

  /// No description provided for @garageInfoStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get garageInfoStatus;

  /// No description provided for @garageStoryHeading.
  ///
  /// In en, this message translates to:
  /// **'The story'**
  String get garageStoryHeading;

  /// No description provided for @garageGalleryHeading.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get garageGalleryHeading;

  /// No description provided for @garageLogBuildIteration.
  ///
  /// In en, this message translates to:
  /// **'+ Log build iteration'**
  String get garageLogBuildIteration;

  /// No description provided for @garageModLogHeading.
  ///
  /// In en, this message translates to:
  /// **'Modification log'**
  String get garageModLogHeading;

  /// No description provided for @garageEditCar.
  ///
  /// In en, this message translates to:
  /// **'Edit car'**
  String get garageEditCar;

  /// No description provided for @garageDeleteCar.
  ///
  /// In en, this message translates to:
  /// **'Delete car'**
  String get garageDeleteCar;

  /// No description provided for @garageDeleteMachineTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete car?'**
  String get garageDeleteMachineTitle;

  /// No description provided for @garageDeleteMachineBody.
  ///
  /// In en, this message translates to:
  /// **'This will permanently remove this car and all of its modifications from your garage. This action cannot be undone.'**
  String get garageDeleteMachineBody;

  /// No description provided for @garageDialogCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get garageDialogCancel;

  /// No description provided for @garageDialogDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get garageDialogDelete;

  /// No description provided for @garageDeletePhotoTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete photo?'**
  String get garageDeletePhotoTitle;

  /// No description provided for @garageDeletePhotoBody.
  ///
  /// In en, this message translates to:
  /// **'This gallery photo will be permanently removed.'**
  String get garageDeletePhotoBody;

  /// No description provided for @garageDeleteModTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete modification?'**
  String get garageDeleteModTitle;

  /// No description provided for @garageDeleteModBody.
  ///
  /// In en, this message translates to:
  /// **'This will permanently remove this modification and its photos from the build log. This action cannot be undone.'**
  String get garageDeleteModBody;

  /// No description provided for @garageDeleteModMenu.
  ///
  /// In en, this message translates to:
  /// **'Delete modification'**
  String get garageDeleteModMenu;

  /// No description provided for @garageCarRegistered.
  ///
  /// In en, this message translates to:
  /// **'Car registered!'**
  String get garageCarRegistered;

  /// No description provided for @garageChangesSaved.
  ///
  /// In en, this message translates to:
  /// **'Changes saved!'**
  String get garageChangesSaved;

  /// No description provided for @garageShareBuild.
  ///
  /// In en, this message translates to:
  /// **'Share build'**
  String get garageShareBuild;

  /// No description provided for @garageShareSheetLabel.
  ///
  /// In en, this message translates to:
  /// **'Share build'**
  String get garageShareSheetLabel;

  /// No description provided for @garageShareQrTitle.
  ///
  /// In en, this message translates to:
  /// **'Get QR code'**
  String get garageShareQrTitle;

  /// No description provided for @garageShareQrSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Print it, stick it on the car'**
  String get garageShareQrSubtitle;

  /// No description provided for @garageShareCopyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get garageShareCopyLink;

  /// No description provided for @garageShareLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get garageShareLinkCopied;

  /// No description provided for @garageShareChannelMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get garageShareChannelMessages;

  /// No description provided for @garageShareChannelWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get garageShareChannelWhatsApp;

  /// No description provided for @garageShareChannelInstagram.
  ///
  /// In en, this message translates to:
  /// **'Instagram'**
  String get garageShareChannelInstagram;

  /// No description provided for @garageShareChannelX.
  ///
  /// In en, this message translates to:
  /// **'X'**
  String get garageShareChannelX;

  /// No description provided for @garageShareChannelTelegram.
  ///
  /// In en, this message translates to:
  /// **'Telegram'**
  String get garageShareChannelTelegram;

  /// No description provided for @garageShareMessage.
  ///
  /// In en, this message translates to:
  /// **'Check out my {car} on Tweakd 🔧'**
  String garageShareMessage(String car);

  /// No description provided for @garageShareStats.
  ///
  /// In en, this message translates to:
  /// **'Scanned {scans} · Opened {views}'**
  String garageShareStats(int scans, int views);

  /// No description provided for @garageShareToggleLabel.
  ///
  /// In en, this message translates to:
  /// **'Sharing'**
  String get garageShareToggleLabel;

  /// No description provided for @garageSharePausedHint.
  ///
  /// In en, this message translates to:
  /// **'Paused — the link and QR are off'**
  String get garageSharePausedHint;

  /// No description provided for @garageShareLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open the share link.'**
  String get garageShareLoadFailed;

  /// No description provided for @garageShareQrLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the QR code.'**
  String get garageShareQrLoadFailed;

  /// No description provided for @garageShareQrDownload.
  ///
  /// In en, this message translates to:
  /// **'Download QR code'**
  String get garageShareQrDownload;

  /// No description provided for @garageShareQrDownloadSaved.
  ///
  /// In en, this message translates to:
  /// **'QR code saved to your phone.'**
  String get garageShareQrDownloadSaved;

  /// No description provided for @garageShareQrDownloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the file.'**
  String get garageShareQrDownloadFailed;

  /// No description provided for @garageShareRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get garageShareRetry;

  /// No description provided for @garageShareResolving.
  ///
  /// In en, this message translates to:
  /// **'Opening build…'**
  String get garageShareResolving;

  /// No description provided for @garageShareUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Build unavailable'**
  String get garageShareUnavailableTitle;

  /// No description provided for @garageShareUnavailableBody.
  ///
  /// In en, this message translates to:
  /// **'This build is no longer shared on Tweakd.'**
  String get garageShareUnavailableBody;

  /// No description provided for @garageShareBackToFeed.
  ///
  /// In en, this message translates to:
  /// **'Back to feed'**
  String get garageShareBackToFeed;

  /// No description provided for @garageValCoverPhoto.
  ///
  /// In en, this message translates to:
  /// **'Please pick a cover photo.'**
  String get garageValCoverPhoto;

  /// No description provided for @garageValMake.
  ///
  /// In en, this message translates to:
  /// **'Please select a make.'**
  String get garageValMake;

  /// No description provided for @garageValModel.
  ///
  /// In en, this message translates to:
  /// **'Please select a model.'**
  String get garageValModel;

  /// No description provided for @garageValYear.
  ///
  /// In en, this message translates to:
  /// **'Please enter the year.'**
  String get garageValYear;

  /// No description provided for @garageValHorsepower.
  ///
  /// In en, this message translates to:
  /// **'Please enter horsepower.'**
  String get garageValHorsepower;

  /// No description provided for @garageValTorque.
  ///
  /// In en, this message translates to:
  /// **'Please enter torque.'**
  String get garageValTorque;

  /// No description provided for @garageValWeight.
  ///
  /// In en, this message translates to:
  /// **'Please enter weight.'**
  String get garageValWeight;

  /// No description provided for @garageValDisplacement.
  ///
  /// In en, this message translates to:
  /// **'Please enter displacement.'**
  String get garageValDisplacement;

  /// No description provided for @garageValFuelType.
  ///
  /// In en, this message translates to:
  /// **'Please select a fuel type.'**
  String get garageValFuelType;

  /// No description provided for @garageValDrivetrain.
  ///
  /// In en, this message translates to:
  /// **'Please select a drivetrain.'**
  String get garageValDrivetrain;

  /// No description provided for @garageValColor.
  ///
  /// In en, this message translates to:
  /// **'Please select a color.'**
  String get garageValColor;

  /// No description provided for @garageValMileageUnit.
  ///
  /// In en, this message translates to:
  /// **'Please select a mileage unit.'**
  String get garageValMileageUnit;

  /// No description provided for @garageValStatus.
  ///
  /// In en, this message translates to:
  /// **'Please select a status.'**
  String get garageValStatus;

  /// No description provided for @garageKeepEditing.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get garageKeepEditing;

  /// No description provided for @garageDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get garageDiscard;

  /// No description provided for @garageBuildLogDiscardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard this build item?'**
  String get garageBuildLogDiscardTitle;

  /// No description provided for @garageBuildLogDiscardBody.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t added this item to the build log yet. If you leave now, everything you entered here will be lost.'**
  String get garageBuildLogDiscardBody;

  /// No description provided for @garageRegisterDiscardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard this car?'**
  String get garageRegisterDiscardTitle;

  /// No description provided for @garageRegisterDiscardBody.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t added this car to your garage yet. If you leave now, everything you entered will be lost.'**
  String get garageRegisterDiscardBody;

  /// No description provided for @garageEditCarDiscardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard your changes?'**
  String get garageEditCarDiscardTitle;

  /// No description provided for @garageEditCarDiscardBody.
  ///
  /// In en, this message translates to:
  /// **'Your changes to this car won\'t be saved.'**
  String get garageEditCarDiscardBody;

  /// No description provided for @garageLogModLogged.
  ///
  /// In en, this message translates to:
  /// **'Modification logged!'**
  String get garageLogModLogged;

  /// No description provided for @garageAddModCarTitle.
  ///
  /// In en, this message translates to:
  /// **'Which car?'**
  String get garageAddModCarTitle;

  /// No description provided for @garageAddModCarSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick the car this work went into.'**
  String get garageAddModCarSubtitle;

  /// No description provided for @garageAddModNoCarsTitle.
  ///
  /// In en, this message translates to:
  /// **'No cars yet'**
  String get garageAddModNoCarsTitle;

  /// No description provided for @garageAddModNoCarsBody.
  ///
  /// In en, this message translates to:
  /// **'Add a car to your garage first, then log the work you\'ve done on it.'**
  String get garageAddModNoCarsBody;

  /// No description provided for @garageAddModAddCar.
  ///
  /// In en, this message translates to:
  /// **'Add a car'**
  String get garageAddModAddCar;

  /// No description provided for @garageAddModPickCar.
  ///
  /// In en, this message translates to:
  /// **'Pick a car to continue.'**
  String get garageAddModPickCar;

  /// No description provided for @authErrorSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session is not active. Please log in again.'**
  String get authErrorSessionExpired;

  /// No description provided for @authErrorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'That email or password is incorrect.'**
  String get authErrorInvalidCredentials;

  /// No description provided for @authErrorEmailNotConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirm your email address before signing in.'**
  String get authErrorEmailNotConfirmed;

  /// No description provided for @authErrorWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'That password is too weak. Please pick a stronger one.'**
  String get authErrorWeakPassword;

  /// No description provided for @authErrorInvalidCode.
  ///
  /// In en, this message translates to:
  /// **'That code isn\'t right. Please check it and try again.'**
  String get authErrorInvalidCode;

  /// No description provided for @authErrorExpiredCode.
  ///
  /// In en, this message translates to:
  /// **'That code has expired. Request a new one.'**
  String get authErrorExpiredCode;

  /// No description provided for @authErrorRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please wait a moment and try again.'**
  String get authErrorRateLimited;

  /// No description provided for @authErrorSamePassword.
  ///
  /// In en, this message translates to:
  /// **'Your new password must be different from the old one.'**
  String get authErrorSamePassword;

  /// No description provided for @authErrorSignUpDisabled.
  ///
  /// In en, this message translates to:
  /// **'New sign-ups are currently unavailable. Please try again later.'**
  String get authErrorSignUpDisabled;

  /// No description provided for @authErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No connection. Check your network and try again.'**
  String get authErrorNetwork;

  /// No description provided for @authErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get authErrorGeneric;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLogout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get settingsLogout;

  /// No description provided for @settingsLogoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Log out?'**
  String get settingsLogoutTitle;

  /// No description provided for @settingsLogoutBody.
  ///
  /// In en, this message translates to:
  /// **'You will need to sign in again to access your account.'**
  String get settingsLogoutBody;

  /// No description provided for @postBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get postBack;

  /// No description provided for @postNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get postNext;

  /// No description provided for @postPublish.
  ///
  /// In en, this message translates to:
  /// **'Publish post'**
  String get postPublish;

  /// No description provided for @postPhotosTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick your shots'**
  String get postPhotosTitle;

  /// No description provided for @postPhotosSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder — the cover leads your post. Photos only for now.'**
  String get postPhotosSubtitle;

  /// No description provided for @postPhotosAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get postPhotosAdd;

  /// No description provided for @postPhotosCover.
  ///
  /// In en, this message translates to:
  /// **'COVER'**
  String get postPhotosCover;

  /// No description provided for @postPhotosVideosSoon.
  ///
  /// In en, this message translates to:
  /// **'Videos — coming soon'**
  String get postPhotosVideosSoon;

  /// No description provided for @postPhotosCount.
  ///
  /// In en, this message translates to:
  /// **'{count} / {max} photos'**
  String postPhotosCount(int count, int max);

  /// No description provided for @postCaptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Say something'**
  String get postCaptionTitle;

  /// No description provided for @postCaptionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add a description for your post. Mention details, the story, the build.'**
  String get postCaptionSubtitle;

  /// No description provided for @postCaptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get postCaptionLabel;

  /// No description provided for @postCaptionHint.
  ///
  /// In en, this message translates to:
  /// **'Share the story behind this post…'**
  String get postCaptionHint;

  /// No description provided for @postCaptionCounter.
  ///
  /// In en, this message translates to:
  /// **'{count} / {max}'**
  String postCaptionCounter(int count, int max);

  /// No description provided for @postTagsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tag cars & people'**
  String get postTagsTitle;

  /// No description provided for @postTagsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Link the cars in this post from any garage, and tag the people in it.'**
  String get postTagsSubtitle;

  /// No description provided for @postTagsCars.
  ///
  /// In en, this message translates to:
  /// **'Cars'**
  String get postTagsCars;

  /// No description provided for @postTagsPeople.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get postTagsPeople;

  /// No description provided for @postTagsCarHint.
  ///
  /// In en, this message translates to:
  /// **'Search a car in any garage…'**
  String get postTagsCarHint;

  /// No description provided for @postTagsPeopleHint.
  ///
  /// In en, this message translates to:
  /// **'Search people to tag…'**
  String get postTagsPeopleHint;

  /// No description provided for @postTagsAddCar.
  ///
  /// In en, this message translates to:
  /// **'Tag a car'**
  String get postTagsAddCar;

  /// No description provided for @postTagsTagPersonFirst.
  ///
  /// In en, this message translates to:
  /// **'Tag a person first to tag one of their cars.'**
  String get postTagsTagPersonFirst;

  /// No description provided for @postTagsChoosePerson.
  ///
  /// In en, this message translates to:
  /// **'Whose car?'**
  String get postTagsChoosePerson;

  /// No description provided for @postTagsChooseCar.
  ///
  /// In en, this message translates to:
  /// **'Pick a car'**
  String get postTagsChooseCar;

  /// No description provided for @postTagsNoCars.
  ///
  /// In en, this message translates to:
  /// **'This person has no cars to tag.'**
  String get postTagsNoCars;

  /// No description provided for @postTagsNoPeopleFound.
  ///
  /// In en, this message translates to:
  /// **'No people found.'**
  String get postTagsNoPeopleFound;

  /// No description provided for @postTagsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load. Please try again.'**
  String get postTagsLoadError;

  /// No description provided for @postVisibilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Who sees what'**
  String get postVisibilityTitle;

  /// No description provided for @postVisibilitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Hide a counter and others won\'t see that number — they can still like, comment and repost.'**
  String get postVisibilitySubtitle;

  /// No description provided for @postVisibilityLabel.
  ///
  /// In en, this message translates to:
  /// **'Visible counts'**
  String get postVisibilityLabel;

  /// No description provided for @postVisibilityLikesTitle.
  ///
  /// In en, this message translates to:
  /// **'Show like count'**
  String get postVisibilityLikesTitle;

  /// No description provided for @postVisibilityLikesDesc.
  ///
  /// In en, this message translates to:
  /// **'Others can see how many likes this post has'**
  String get postVisibilityLikesDesc;

  /// No description provided for @postVisibilityCommentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Show comment count'**
  String get postVisibilityCommentsTitle;

  /// No description provided for @postVisibilityCommentsDesc.
  ///
  /// In en, this message translates to:
  /// **'Hide the number — comments stay open'**
  String get postVisibilityCommentsDesc;

  /// No description provided for @postVisibilitySharesTitle.
  ///
  /// In en, this message translates to:
  /// **'Show repost count'**
  String get postVisibilitySharesTitle;

  /// No description provided for @postVisibilitySharesDesc.
  ///
  /// In en, this message translates to:
  /// **'Others can see how many times it was reposted'**
  String get postVisibilitySharesDesc;

  /// No description provided for @postVisibilitySavedTitle.
  ///
  /// In en, this message translates to:
  /// **'Show saved count'**
  String get postVisibilitySavedTitle;

  /// No description provided for @postVisibilitySavedDesc.
  ///
  /// In en, this message translates to:
  /// **'Others can see how many times it was saved'**
  String get postVisibilitySavedDesc;

  /// No description provided for @postVisibilityTimeNote.
  ///
  /// In en, this message translates to:
  /// **'Posts show a relative time — \"2h ago\", \"3 days ago\" — never the exact date. This is automatic and always on.'**
  String get postVisibilityTimeNote;

  /// No description provided for @postReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Looking good?'**
  String get postReviewTitle;

  /// No description provided for @postReviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This is exactly how your post appears in the feed.'**
  String get postReviewSubtitle;

  /// No description provided for @postReviewYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get postReviewYou;

  /// No description provided for @postReviewJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get postReviewJustNow;

  /// No description provided for @postValPhotosRequired.
  ///
  /// In en, this message translates to:
  /// **'Add at least one photo to continue.'**
  String get postValPhotosRequired;

  /// No description provided for @postDiscardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard post?'**
  String get postDiscardTitle;

  /// No description provided for @postDiscardBody.
  ///
  /// In en, this message translates to:
  /// **'Your photos, caption and tags won\'t be saved.'**
  String get postDiscardBody;

  /// No description provided for @postKeepEditing.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get postKeepEditing;

  /// No description provided for @postDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get postDiscard;

  /// No description provided for @postEditDiscardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard your changes?'**
  String get postEditDiscardTitle;

  /// No description provided for @postEditDiscardBody.
  ///
  /// In en, this message translates to:
  /// **'Your changes to this post won\'t be saved.'**
  String get postEditDiscardBody;

  /// No description provided for @postCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Post published.'**
  String get postCreatedSuccess;

  /// No description provided for @postPhaseCreating.
  ///
  /// In en, this message translates to:
  /// **'Creating…'**
  String get postPhaseCreating;

  /// No description provided for @postPhaseUploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading photos…'**
  String get postPhaseUploading;

  /// No description provided for @postErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t publish your post. Please try again.'**
  String get postErrorGeneric;

  /// No description provided for @postErrorImageUpload.
  ///
  /// In en, this message translates to:
  /// **'Your photos couldn\'t be uploaded. Please try again.'**
  String get postErrorImageUpload;

  /// No description provided for @postErrorInvalidTags.
  ///
  /// In en, this message translates to:
  /// **'You can\'t tag a car without also tagging its owner.'**
  String get postErrorInvalidTags;

  /// No description provided for @postErrorNotOwner.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission to do that.'**
  String get postErrorNotOwner;

  /// No description provided for @postErrorNotFound.
  ///
  /// In en, this message translates to:
  /// **'This post no longer exists.'**
  String get postErrorNotFound;

  /// No description provided for @profileTabPosts.
  ///
  /// In en, this message translates to:
  /// **'Posts'**
  String get profileTabPosts;

  /// No description provided for @profileTabGarage.
  ///
  /// In en, this message translates to:
  /// **'Garage'**
  String get profileTabGarage;

  /// No description provided for @profileTabTags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get profileTabTags;

  /// No description provided for @profileTabReposts.
  ///
  /// In en, this message translates to:
  /// **'Reposts'**
  String get profileTabReposts;

  /// No description provided for @postsLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get postsLoadMore;

  /// No description provided for @postsEmptyOwner.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t posted yet.'**
  String get postsEmptyOwner;

  /// No description provided for @postsEmptyVisitor.
  ///
  /// In en, this message translates to:
  /// **'No posts yet.'**
  String get postsEmptyVisitor;

  /// No description provided for @postsCreateFirst.
  ///
  /// In en, this message translates to:
  /// **'Create your first post'**
  String get postsCreateFirst;

  /// No description provided for @repostsEmptyOwner.
  ///
  /// In en, this message translates to:
  /// **'Posts you repost show up here.'**
  String get repostsEmptyOwner;

  /// No description provided for @repostsEmptyVisitor.
  ///
  /// In en, this message translates to:
  /// **'No reposts yet.'**
  String get repostsEmptyVisitor;

  /// No description provided for @savedPostsTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved posts'**
  String get savedPostsTitle;

  /// No description provided for @savedPostsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing saved yet'**
  String get savedPostsEmptyTitle;

  /// No description provided for @savedPostsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Save posts you like to find them here later.'**
  String get savedPostsEmptyBody;

  /// No description provided for @postDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get postDetailTitle;

  /// No description provided for @postEditAction.
  ///
  /// In en, this message translates to:
  /// **'Edit post'**
  String get postEditAction;

  /// No description provided for @postDeleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete post'**
  String get postDeleteAction;

  /// No description provided for @postDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete post?'**
  String get postDeleteTitle;

  /// No description provided for @postDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'This post and its photos, likes and comments will be permanently removed.'**
  String get postDeleteBody;

  /// No description provided for @postEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit post'**
  String get postEditTitle;

  /// No description provided for @postEditSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get postEditSave;

  /// No description provided for @postRepostedByOne.
  ///
  /// In en, this message translates to:
  /// **'@{user} reposted'**
  String postRepostedByOne(String user);

  /// No description provided for @postRepostedByTwo.
  ///
  /// In en, this message translates to:
  /// **'@{first} and @{second} reposted'**
  String postRepostedByTwo(String first, String second);

  /// No description provided for @postRepostedByMany.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{@{user} and 1 other reposted} other{@{user} and {count} others reposted}}'**
  String postRepostedByMany(int count, String user);

  /// No description provided for @postTimeNow.
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get postTimeNow;

  /// No description provided for @postTimeMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count}m'**
  String postTimeMinutes(int count);

  /// No description provided for @postTimeHours.
  ///
  /// In en, this message translates to:
  /// **'{count}h'**
  String postTimeHours(int count);

  /// No description provided for @postTimeDays.
  ///
  /// In en, this message translates to:
  /// **'{count}d'**
  String postTimeDays(int count);

  /// No description provided for @postTimeWeeks.
  ///
  /// In en, this message translates to:
  /// **'{count}w'**
  String postTimeWeeks(int count);

  /// No description provided for @postLikesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 like} other{{count} likes}}'**
  String postLikesCount(int count);

  /// No description provided for @postViewAllComments.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{View 1 comment} other{View all {count} comments}}'**
  String postViewAllComments(int count);

  /// No description provided for @postCommentsTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Comments} =1{1 comment} other{{count} comments}}'**
  String postCommentsTitle(int count);

  /// No description provided for @postCommentsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No comments yet. Be the first.'**
  String get postCommentsEmpty;

  /// No description provided for @postCommentsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load comments. Please try again.'**
  String get postCommentsLoadError;

  /// No description provided for @postCommentHint.
  ///
  /// In en, this message translates to:
  /// **'Add a comment…'**
  String get postCommentHint;

  /// No description provided for @postCommentDeleted.
  ///
  /// In en, this message translates to:
  /// **'[deleted]'**
  String get postCommentDeleted;

  /// No description provided for @postCommentDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get postCommentDelete;

  /// No description provided for @postCommentDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete comment?'**
  String get postCommentDeleteTitle;

  /// No description provided for @postCommentDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'This comment will be permanently removed.'**
  String get postCommentDeleteBody;

  /// No description provided for @postCommentLikesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 like} other{{count} likes}}'**
  String postCommentLikesCount(int count);

  /// No description provided for @postCommentReply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get postCommentReply;

  /// No description provided for @postReplyingTo.
  ///
  /// In en, this message translates to:
  /// **'Replying to @{username}'**
  String postReplyingTo(String username);

  /// No description provided for @postRepliesHide.
  ///
  /// In en, this message translates to:
  /// **'Hide replies'**
  String get postRepliesHide;

  /// No description provided for @postRepliesViewGeneric.
  ///
  /// In en, this message translates to:
  /// **'View replies'**
  String get postRepliesViewGeneric;

  /// No description provided for @postRepliesViewMore.
  ///
  /// In en, this message translates to:
  /// **'View more replies'**
  String get postRepliesViewMore;

  /// No description provided for @postRepliesView.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{View 1 reply} other{View {count} replies}}'**
  String postRepliesView(int count);

  /// No description provided for @postLikersTitle.
  ///
  /// In en, this message translates to:
  /// **'Likes'**
  String get postLikersTitle;

  /// No description provided for @postLikersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No likes yet.'**
  String get postLikersEmpty;

  /// No description provided for @postLikersLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load likes. Please try again.'**
  String get postLikersLoadError;

  /// No description provided for @postReport.
  ///
  /// In en, this message translates to:
  /// **'Report post'**
  String get postReport;

  /// No description provided for @commentReport.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get commentReport;

  /// No description provided for @profileReportAccount.
  ///
  /// In en, this message translates to:
  /// **'Report account'**
  String get profileReportAccount;

  /// No description provided for @reportSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit report'**
  String get reportSubmit;

  /// No description provided for @reportClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get reportClose;

  /// No description provided for @reportRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get reportRetry;

  /// No description provided for @reportReasonsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load report reasons. Please try again.'**
  String get reportReasonsLoadError;

  /// No description provided for @reportSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Report received'**
  String get reportSuccessTitle;

  /// No description provided for @reportSuccessBody.
  ///
  /// In en, this message translates to:
  /// **'Thanks for letting us know. Our team will review this shortly.'**
  String get reportSuccessBody;

  /// No description provided for @reportErrorAlreadyReported.
  ///
  /// In en, this message translates to:
  /// **'You\'ve already reported this.'**
  String get reportErrorAlreadyReported;

  /// No description provided for @reportErrorSelf.
  ///
  /// In en, this message translates to:
  /// **'You can\'t report your own content.'**
  String get reportErrorSelf;

  /// No description provided for @reportErrorInvalidReason.
  ///
  /// In en, this message translates to:
  /// **'That reason doesn\'t apply here. Please pick another.'**
  String get reportErrorInvalidReason;

  /// No description provided for @reportErrorNotFound.
  ///
  /// In en, this message translates to:
  /// **'This content is no longer available.'**
  String get reportErrorNotFound;

  /// No description provided for @reportErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please try again.'**
  String get reportErrorNetwork;

  /// No description provided for @reportErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t submit your report. Please try again.'**
  String get reportErrorGeneric;

  /// No description provided for @settingsSavedPosts.
  ///
  /// In en, this message translates to:
  /// **'Your saved posts'**
  String get settingsSavedPosts;

  /// No description provided for @settingsMyReports.
  ///
  /// In en, this message translates to:
  /// **'My reports'**
  String get settingsMyReports;

  /// No description provided for @myReportsTitle.
  ///
  /// In en, this message translates to:
  /// **'My reports'**
  String get myReportsTitle;

  /// No description provided for @myReportsEmpty.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t submitted any reports yet.'**
  String get myReportsEmpty;

  /// No description provided for @reportTargetPost.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get reportTargetPost;

  /// No description provided for @reportTargetComment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get reportTargetComment;

  /// No description provided for @reportTargetProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get reportTargetProfile;

  /// No description provided for @reportTargetForumThread.
  ///
  /// In en, this message translates to:
  /// **'Forum thread'**
  String get reportTargetForumThread;

  /// No description provided for @reportTargetForumReply.
  ///
  /// In en, this message translates to:
  /// **'Forum reply'**
  String get reportTargetForumReply;

  /// No description provided for @reportNoReason.
  ///
  /// In en, this message translates to:
  /// **'No reason given'**
  String get reportNoReason;

  /// No description provided for @reportStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get reportStatusPending;

  /// No description provided for @reportStatusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get reportStatusInProgress;

  /// No description provided for @reportStatusResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get reportStatusResolved;

  /// No description provided for @reportStatusDismissed.
  ///
  /// In en, this message translates to:
  /// **'Dismissed'**
  String get reportStatusDismissed;

  /// No description provided for @settingsSendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send feedback'**
  String get settingsSendFeedback;

  /// No description provided for @settingsMyFeedback.
  ///
  /// In en, this message translates to:
  /// **'My feedback'**
  String get settingsMyFeedback;

  /// No description provided for @feedbackEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedbackEyebrow;

  /// No description provided for @feedbackHeadline.
  ///
  /// In en, this message translates to:
  /// **'Got any suggestions ?'**
  String get feedbackHeadline;

  /// No description provided for @feedbackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Report a bug, request a feature, or just share a thought and it goes straight to us.'**
  String get feedbackSubtitle;

  /// No description provided for @feedbackTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Feedback type'**
  String get feedbackTypeLabel;

  /// No description provided for @feedbackTypeHint.
  ///
  /// In en, this message translates to:
  /// **'Select a type'**
  String get feedbackTypeHint;

  /// No description provided for @feedbackFeatureLabel.
  ///
  /// In en, this message translates to:
  /// **'Related to an existing feature?'**
  String get feedbackFeatureLabel;

  /// No description provided for @feedbackFeatureHint.
  ///
  /// In en, this message translates to:
  /// **'Select a feature'**
  String get feedbackFeatureHint;

  /// No description provided for @feedbackOptional.
  ///
  /// In en, this message translates to:
  /// **'OPTIONAL'**
  String get feedbackOptional;

  /// No description provided for @feedbackContentLabel.
  ///
  /// In en, this message translates to:
  /// **'Your feedback'**
  String get feedbackContentLabel;

  /// No description provided for @feedbackContentLabelBug.
  ///
  /// In en, this message translates to:
  /// **'What happened'**
  String get feedbackContentLabelBug;

  /// No description provided for @feedbackContentHint.
  ///
  /// In en, this message translates to:
  /// **'Share your thoughts…'**
  String get feedbackContentHint;

  /// No description provided for @feedbackReproductionLabel.
  ///
  /// In en, this message translates to:
  /// **'Reproduction steps'**
  String get feedbackReproductionLabel;

  /// No description provided for @feedbackReproductionHint.
  ///
  /// In en, this message translates to:
  /// **'1. Open the …\n2. Tap …\n3. …'**
  String get feedbackReproductionHint;

  /// No description provided for @feedbackTypePickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Feedback type'**
  String get feedbackTypePickerTitle;

  /// No description provided for @feedbackFeaturePickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Related feature'**
  String get feedbackFeaturePickerTitle;

  /// No description provided for @feedbackFeatureNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get feedbackFeatureNone;

  /// No description provided for @feedbackTypeBugDesc.
  ///
  /// In en, this message translates to:
  /// **'Something is broken'**
  String get feedbackTypeBugDesc;

  /// No description provided for @feedbackTypeFeatureDesc.
  ///
  /// In en, this message translates to:
  /// **'Something you wish existed'**
  String get feedbackTypeFeatureDesc;

  /// No description provided for @feedbackTypeGeneralDesc.
  ///
  /// In en, this message translates to:
  /// **'Thoughts, praise or an idea'**
  String get feedbackTypeGeneralDesc;

  /// No description provided for @feedbackSubmit.
  ///
  /// In en, this message translates to:
  /// **'Send feedback'**
  String get feedbackSubmit;

  /// No description provided for @feedbackRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get feedbackRetry;

  /// No description provided for @feedbackLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the feedback form. Please try again.'**
  String get feedbackLoadError;

  /// No description provided for @feedbackSuccess.
  ///
  /// In en, this message translates to:
  /// **'Thanks! Your feedback is on its way.'**
  String get feedbackSuccess;

  /// No description provided for @feedbackErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please try again.'**
  String get feedbackErrorNetwork;

  /// No description provided for @feedbackErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t send your feedback. Please try again.'**
  String get feedbackErrorGeneric;

  /// No description provided for @myFeedbackTitle.
  ///
  /// In en, this message translates to:
  /// **'My feedback'**
  String get myFeedbackTitle;

  /// No description provided for @myFeedbackEmpty.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t sent any feedback yet.'**
  String get myFeedbackEmpty;

  /// No description provided for @myFeedbackResponseLabel.
  ///
  /// In en, this message translates to:
  /// **'Response'**
  String get myFeedbackResponseLabel;

  /// No description provided for @forumsTitle.
  ///
  /// In en, this message translates to:
  /// **'Forums'**
  String get forumsTitle;

  /// No description provided for @forumsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your paddock'**
  String get forumsSubtitle;

  /// No description provided for @forumsYourShortcuts.
  ///
  /// In en, this message translates to:
  /// **'Your shortcuts'**
  String get forumsYourShortcuts;

  /// No description provided for @forumsEditShortcuts.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get forumsEditShortcuts;

  /// No description provided for @forumsDoneEditing.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get forumsDoneEditing;

  /// No description provided for @forumsHotInYourForums.
  ///
  /// In en, this message translates to:
  /// **'Hot in your forums'**
  String get forumsHotInYourForums;

  /// No description provided for @forumsSortHot.
  ///
  /// In en, this message translates to:
  /// **'Hot'**
  String get forumsSortHot;

  /// No description provided for @forumsSortNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get forumsSortNew;

  /// No description provided for @forumsSortActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get forumsSortActive;

  /// No description provided for @forumsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Find the forums you live in'**
  String get forumsEmptyTitle;

  /// No description provided for @forumsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Browse hubs by car, or dive into what\'s popular below. Save the hubs you like as shortcuts and they land right here.'**
  String get forumsEmptyBody;

  /// No description provided for @forumsPopularThreads.
  ///
  /// In en, this message translates to:
  /// **'Popular right now'**
  String get forumsPopularThreads;

  /// No description provided for @forumsCtaTitle.
  ///
  /// In en, this message translates to:
  /// **'Got something to say?'**
  String get forumsCtaTitle;

  /// No description provided for @forumsCtaBody.
  ///
  /// In en, this message translates to:
  /// **'Every great forum started with one thread. Make it yours.'**
  String get forumsCtaBody;

  /// No description provided for @forumsStartFirstThread.
  ///
  /// In en, this message translates to:
  /// **'Start the first thread'**
  String get forumsStartFirstThread;

  /// No description provided for @forumsShortcutSaved.
  ///
  /// In en, this message translates to:
  /// **'Shortcut saved to your paddock.'**
  String get forumsShortcutSaved;

  /// No description provided for @forumsShortcutRemoved.
  ///
  /// In en, this message translates to:
  /// **'Shortcut removed.'**
  String get forumsShortcutRemoved;

  /// No description provided for @forumsBrowseTitle.
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get forumsBrowseTitle;

  /// No description provided for @forumsBrandsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 BRAND} other{{count} BRANDS}}'**
  String forumsBrandsCount(int count);

  /// No description provided for @forumsThreadsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 thread} other{{count} threads}}'**
  String forumsThreadsCount(int count);

  /// No description provided for @forumsModels.
  ///
  /// In en, this message translates to:
  /// **'Models'**
  String get forumsModels;

  /// No description provided for @forumsRefineByTopic.
  ///
  /// In en, this message translates to:
  /// **'Refine by topic'**
  String get forumsRefineByTopic;

  /// No description provided for @forumsHotIn.
  ///
  /// In en, this message translates to:
  /// **'Hot in {name}'**
  String forumsHotIn(String name);

  /// No description provided for @forumsThreadsLabel.
  ///
  /// In en, this message translates to:
  /// **'Threads'**
  String get forumsThreadsLabel;

  /// No description provided for @forumsAllTopics.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get forumsAllTopics;

  /// No description provided for @forumsSaveShortcut.
  ///
  /// In en, this message translates to:
  /// **'Save shortcut'**
  String get forumsSaveShortcut;

  /// No description provided for @forumsSaveShortcutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pin this filter to your paddock for one-tap access.'**
  String get forumsSaveShortcutSubtitle;

  /// No description provided for @forumsShortcutNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get forumsShortcutNameLabel;

  /// No description provided for @forumsNotifyMe.
  ///
  /// In en, this message translates to:
  /// **'Notify me'**
  String get forumsNotifyMe;

  /// No description provided for @forumsNotifyMeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'New hot threads in this filter'**
  String get forumsNotifyMeSubtitle;

  /// No description provided for @forumsNoThreadsTitle.
  ///
  /// In en, this message translates to:
  /// **'No threads here yet.'**
  String get forumsNoThreadsTitle;

  /// No description provided for @forumsNoThreadsBody.
  ///
  /// In en, this message translates to:
  /// **'Be the first — start the conversation.'**
  String get forumsNoThreadsBody;

  /// No description provided for @forumsRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get forumsRetry;

  /// No description provided for @forumsThreadTitle.
  ///
  /// In en, this message translates to:
  /// **'Thread'**
  String get forumsThreadTitle;

  /// No description provided for @forumsPinned.
  ///
  /// In en, this message translates to:
  /// **'PINNED'**
  String get forumsPinned;

  /// No description provided for @forumsLocked.
  ///
  /// In en, this message translates to:
  /// **'LOCKED'**
  String get forumsLocked;

  /// No description provided for @forumsLockedBar.
  ///
  /// In en, this message translates to:
  /// **'This thread is locked — replies are closed.'**
  String get forumsLockedBar;

  /// No description provided for @forumsRepliesHeader.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 REPLY} other{{count} REPLIES}}'**
  String forumsRepliesHeader(int count);

  /// No description provided for @forumsReply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get forumsReply;

  /// No description provided for @forumsShowReplies.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Show 1 reply} other{Show {count} replies}}'**
  String forumsShowReplies(int count);

  /// No description provided for @forumsHideReplies.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get forumsHideReplies;

  /// No description provided for @forumsShowMoreReplies.
  ///
  /// In en, this message translates to:
  /// **'Show more replies'**
  String get forumsShowMoreReplies;

  /// No description provided for @forumsAddReply.
  ///
  /// In en, this message translates to:
  /// **'Add a reply…'**
  String get forumsAddReply;

  /// No description provided for @forumsReplyingTo.
  ///
  /// In en, this message translates to:
  /// **'Replying to @{username}'**
  String forumsReplyingTo(String username);

  /// No description provided for @forumsDeletedPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'[deleted]'**
  String get forumsDeletedPlaceholder;

  /// No description provided for @forumsPosted.
  ///
  /// In en, this message translates to:
  /// **'Posted'**
  String get forumsPosted;

  /// No description provided for @forumsActiveNow.
  ///
  /// In en, this message translates to:
  /// **'active just now'**
  String get forumsActiveNow;

  /// No description provided for @forumsActiveAgo.
  ///
  /// In en, this message translates to:
  /// **'active {time} ago'**
  String forumsActiveAgo(String time);

  /// No description provided for @forumsEditThread.
  ///
  /// In en, this message translates to:
  /// **'Edit body'**
  String get forumsEditThread;

  /// No description provided for @forumsDeleteThread.
  ///
  /// In en, this message translates to:
  /// **'Delete thread'**
  String get forumsDeleteThread;

  /// No description provided for @forumsEditReply.
  ///
  /// In en, this message translates to:
  /// **'Edit reply'**
  String get forumsEditReply;

  /// No description provided for @forumsDeleteReply.
  ///
  /// In en, this message translates to:
  /// **'Delete reply'**
  String get forumsDeleteReply;

  /// No description provided for @forumsDeleteThreadConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this thread?'**
  String get forumsDeleteThreadConfirmTitle;

  /// No description provided for @forumsDeleteThreadConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'If it has replies it stays visible as [deleted]; otherwise it\'s gone for good.'**
  String get forumsDeleteThreadConfirmBody;

  /// No description provided for @forumsDeleteReplyConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this reply?'**
  String get forumsDeleteReplyConfirmTitle;

  /// No description provided for @forumsDeleteReplyConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'If it has replies it becomes a [deleted] placeholder; otherwise it\'s removed.'**
  String get forumsDeleteReplyConfirmBody;

  /// No description provided for @forumsDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get forumsDelete;

  /// No description provided for @forumsEditSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get forumsEditSave;

  /// No description provided for @forumsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get forumsComingSoon;

  /// No description provided for @forumsNewThreadTitle.
  ///
  /// In en, this message translates to:
  /// **'New thread'**
  String get forumsNewThreadTitle;

  /// No description provided for @forumsPost.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get forumsPost;

  /// No description provided for @forumsThreadTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get forumsThreadTitleHint;

  /// No description provided for @forumsThreadBodyHint.
  ///
  /// In en, this message translates to:
  /// **'Share the details, questions, or your writeup…'**
  String get forumsThreadBodyHint;

  /// No description provided for @forumsBrandRequiredLabel.
  ///
  /// In en, this message translates to:
  /// **'Brand · required'**
  String get forumsBrandRequiredLabel;

  /// No description provided for @forumsModelOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Model · optional'**
  String get forumsModelOptionalLabel;

  /// No description provided for @forumsSearchBrandHint.
  ///
  /// In en, this message translates to:
  /// **'Search a brand…'**
  String get forumsSearchBrandHint;

  /// No description provided for @forumsSearchModelHint.
  ///
  /// In en, this message translates to:
  /// **'Search a model…'**
  String get forumsSearchModelHint;

  /// No description provided for @forumsChooseBrand.
  ///
  /// In en, this message translates to:
  /// **'Choose a brand'**
  String get forumsChooseBrand;

  /// No description provided for @forumsChooseModel.
  ///
  /// In en, this message translates to:
  /// **'Choose a model'**
  String get forumsChooseModel;

  /// No description provided for @forumsNoBrandMatches.
  ///
  /// In en, this message translates to:
  /// **'No brands match that search.'**
  String get forumsNoBrandMatches;

  /// No description provided for @forumsNoModelMatches.
  ///
  /// In en, this message translates to:
  /// **'No models match that search.'**
  String get forumsNoModelMatches;

  /// No description provided for @forumsNoModelsForBrand.
  ///
  /// In en, this message translates to:
  /// **'No models listed for this brand.'**
  String get forumsNoModelsForBrand;

  /// No description provided for @forumsTagCarHelper.
  ///
  /// In en, this message translates to:
  /// **'Pick a brand so your thread shows up in the right hub. Adding the exact model is recommended unless your question applies to the whole brand.'**
  String get forumsTagCarHelper;

  /// No description provided for @forumsTopics.
  ///
  /// In en, this message translates to:
  /// **'Topics'**
  String get forumsTopics;

  /// No description provided for @forumsThreadPosted.
  ///
  /// In en, this message translates to:
  /// **'Thread posted.'**
  String get forumsThreadPosted;

  /// No description provided for @forumsShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get forumsShare;

  /// No description provided for @forumsSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get forumsSave;

  /// No description provided for @forumsSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get forumsSaved;

  /// No description provided for @forumsAuthorBadge.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get forumsAuthorBadge;

  /// No description provided for @forumsRepliesOldest.
  ///
  /// In en, this message translates to:
  /// **'Oldest'**
  String get forumsRepliesOldest;

  /// No description provided for @forumsRepliesNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get forumsRepliesNewest;

  /// No description provided for @forumsReportThreadTitle.
  ///
  /// In en, this message translates to:
  /// **'Report thread'**
  String get forumsReportThreadTitle;

  /// No description provided for @forumsReportReplyTitle.
  ///
  /// In en, this message translates to:
  /// **'Report reply'**
  String get forumsReportReplyTitle;

  /// No description provided for @forumsSavedTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get forumsSavedTitle;

  /// No description provided for @forumsSavedHeader.
  ///
  /// In en, this message translates to:
  /// **'Saved threads'**
  String get forumsSavedHeader;

  /// No description provided for @forumsSavedEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing saved yet'**
  String get forumsSavedEmptyTitle;

  /// No description provided for @forumsSavedEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Bookmark threads to find them here later.'**
  String get forumsSavedEmptyBody;

  /// No description provided for @forumsErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please try again.'**
  String get forumsErrorNetwork;

  /// No description provided for @forumsErrorNotFound.
  ///
  /// In en, this message translates to:
  /// **'This content doesn\'t exist anymore.'**
  String get forumsErrorNotFound;

  /// No description provided for @forumsErrorConflict.
  ///
  /// In en, this message translates to:
  /// **'This thread is locked or the content was deleted.'**
  String get forumsErrorConflict;

  /// No description provided for @forumsErrorForbidden.
  ///
  /// In en, this message translates to:
  /// **'You can only edit or delete your own content.'**
  String get forumsErrorForbidden;

  /// No description provided for @forumsErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get forumsErrorGeneric;

  /// No description provided for @forumsErrorInvalidTags.
  ///
  /// In en, this message translates to:
  /// **'One of the tagged profiles or cars is no longer available.'**
  String get forumsErrorInvalidTags;

  /// No description provided for @forumsTagPeopleAndCars.
  ///
  /// In en, this message translates to:
  /// **'Tag people & cars'**
  String get forumsTagPeopleAndCars;

  /// No description provided for @forumsTagPeople.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get forumsTagPeople;

  /// No description provided for @forumsTagCars.
  ///
  /// In en, this message translates to:
  /// **'Cars'**
  String get forumsTagCars;

  /// No description provided for @forumsTagHelper.
  ///
  /// In en, this message translates to:
  /// **'Mention someone to pull cars from their garage. Your own cars can be tagged without mentioning yourself.'**
  String get forumsTagHelper;

  /// No description provided for @forumsTagPeopleHint.
  ///
  /// In en, this message translates to:
  /// **'Search a username…'**
  String get forumsTagPeopleHint;

  /// No description provided for @forumsTagAddCar.
  ///
  /// In en, this message translates to:
  /// **'Tag a car'**
  String get forumsTagAddCar;

  /// No description provided for @forumsTagChoosePerson.
  ///
  /// In en, this message translates to:
  /// **'Whose car?'**
  String get forumsTagChoosePerson;

  /// No description provided for @forumsTagChooseCar.
  ///
  /// In en, this message translates to:
  /// **'Pick a car'**
  String get forumsTagChooseCar;

  /// No description provided for @forumsTagYourGarage.
  ///
  /// In en, this message translates to:
  /// **'Your garage'**
  String get forumsTagYourGarage;

  /// No description provided for @forumsTagNoPeopleFound.
  ///
  /// In en, this message translates to:
  /// **'No profiles match that search.'**
  String get forumsTagNoPeopleFound;

  /// No description provided for @forumsTagLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t load that. Please try again.'**
  String get forumsTagLoadError;

  /// No description provided for @forumsTagNoCars.
  ///
  /// In en, this message translates to:
  /// **'This person has no cars to tag.'**
  String get forumsTagNoCars;

  /// No description provided for @forumsTagNoOwnCars.
  ///
  /// In en, this message translates to:
  /// **'Your garage is empty.'**
  String get forumsTagNoOwnCars;

  /// No description provided for @forumsTagPersonFirst.
  ///
  /// In en, this message translates to:
  /// **'Mention someone first to tag one of their cars.'**
  String get forumsTagPersonFirst;

  /// No description provided for @forumsTagLimitReached.
  ///
  /// In en, this message translates to:
  /// **'You can tag up to {limit} at a time.'**
  String forumsTagLimitReached(int limit);

  /// No description provided for @forumsTagsSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get forumsTagsSheetTitle;

  /// No description provided for @forumsTagsDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get forumsTagsDone;

  /// No description provided for @forumsAddTagsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Tag people & cars'**
  String get forumsAddTagsTooltip;

  /// No description provided for @forumsTagsSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get forumsTagsSectionLabel;

  /// No description provided for @messagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messagesTitle;

  /// No description provided for @messagesSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search messages'**
  String get messagesSearchHint;

  /// No description provided for @messagesActiveNow.
  ///
  /// In en, this message translates to:
  /// **'Active now'**
  String get messagesActiveNow;

  /// No description provided for @messagesRequestsTitle.
  ///
  /// In en, this message translates to:
  /// **'Message requests'**
  String get messagesRequestsTitle;

  /// No description provided for @messagesRequestsOthers.
  ///
  /// In en, this message translates to:
  /// **'{names} & {count} others'**
  String messagesRequestsOthers(String names, int count);

  /// No description provided for @messagesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get messagesEmptyTitle;

  /// No description provided for @messagesEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Start a conversation with drivers you follow — plan meets, swap specs, share runs.'**
  String get messagesEmptyBody;

  /// No description provided for @messagesNewMessage.
  ///
  /// In en, this message translates to:
  /// **'New message'**
  String get messagesNewMessage;

  /// No description provided for @messagesYouPrefix.
  ///
  /// In en, this message translates to:
  /// **'You: {text}'**
  String messagesYouPrefix(String text);

  /// No description provided for @messagesSharedPost.
  ///
  /// In en, this message translates to:
  /// **'Shared a post'**
  String get messagesSharedPost;

  /// No description provided for @messagesTimeNow.
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get messagesTimeNow;

  /// No description provided for @messagesTimeMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count}m'**
  String messagesTimeMinutes(int count);

  /// No description provided for @messagesTimeHours.
  ///
  /// In en, this message translates to:
  /// **'{count}h'**
  String messagesTimeHours(int count);

  /// No description provided for @messagesTimeDays.
  ///
  /// In en, this message translates to:
  /// **'{count}d'**
  String messagesTimeDays(int count);

  /// No description provided for @messagesTimeWeeks.
  ///
  /// In en, this message translates to:
  /// **'{count}w'**
  String messagesTimeWeeks(int count);

  /// No description provided for @messagesActiveNowStatus.
  ///
  /// In en, this message translates to:
  /// **'Active now'**
  String get messagesActiveNowStatus;

  /// No description provided for @messagesMutualFollow.
  ///
  /// In en, this message translates to:
  /// **'You both follow each other · {followers} followers'**
  String messagesMutualFollow(String followers);

  /// No description provided for @messagesDatePill.
  ///
  /// In en, this message translates to:
  /// **'TODAY · {time}'**
  String messagesDatePill(String time);

  /// No description provided for @messagesSeen.
  ///
  /// In en, this message translates to:
  /// **'Seen'**
  String get messagesSeen;

  /// No description provided for @messagesDeletedMessage.
  ///
  /// In en, this message translates to:
  /// **'Message deleted'**
  String get messagesDeletedMessage;

  /// No description provided for @messagesDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete message'**
  String get messagesDeleteMessage;

  /// No description provided for @messagesDeleteMessageBody.
  ///
  /// In en, this message translates to:
  /// **'Removes it for both of you.'**
  String get messagesDeleteMessageBody;

  /// No description provided for @messagesDeleteChat.
  ///
  /// In en, this message translates to:
  /// **'Delete chat'**
  String get messagesDeleteChat;

  /// No description provided for @messagesDeleteChatBody.
  ///
  /// In en, this message translates to:
  /// **'Hides it from your list only — it comes back with a new message.'**
  String get messagesDeleteChatBody;

  /// No description provided for @messagesInputHint.
  ///
  /// In en, this message translates to:
  /// **'Message…'**
  String get messagesInputHint;

  /// No description provided for @messagesEmptyChat.
  ///
  /// In en, this message translates to:
  /// **'No messages yet — say hi 👋'**
  String get messagesEmptyChat;

  /// No description provided for @messagesComposeTitle.
  ///
  /// In en, this message translates to:
  /// **'New message'**
  String get messagesComposeTitle;

  /// No description provided for @messagesComposeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search drivers…'**
  String get messagesComposeSearchHint;

  /// No description provided for @messagesComposeEmpty.
  ///
  /// In en, this message translates to:
  /// **'No drivers found'**
  String get messagesComposeEmpty;

  /// No description provided for @messagesComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get messagesComingSoon;

  /// No description provided for @messagesRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get messagesRetry;

  /// No description provided for @messagesErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please try again.'**
  String get messagesErrorNetwork;

  /// No description provided for @messagesErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get messagesErrorGeneric;

  /// No description provided for @messagesSharedCars.
  ///
  /// In en, this message translates to:
  /// **'Shared cars'**
  String get messagesSharedCars;

  /// No description provided for @messagesShareCarsTitle.
  ///
  /// In en, this message translates to:
  /// **'Share cars'**
  String get messagesShareCarsTitle;

  /// No description provided for @messagesShareCarsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick cars from your garage'**
  String get messagesShareCarsSubtitle;

  /// No description provided for @messagesShareCarsLimit.
  ///
  /// In en, this message translates to:
  /// **'You can share up to {count} cars'**
  String messagesShareCarsLimit(int count);

  /// No description provided for @messagesShareCarsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No cars in your garage yet'**
  String get messagesShareCarsEmpty;

  /// No description provided for @messagesShareCarsError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your garage. Please try again.'**
  String get messagesShareCarsError;

  /// No description provided for @messagesShareCarsConfirm.
  ///
  /// In en, this message translates to:
  /// **'Share {count}'**
  String messagesShareCarsConfirm(int count);

  /// No description provided for @messagesShareCarsConfirmEmpty.
  ///
  /// In en, this message translates to:
  /// **'Share cars'**
  String get messagesShareCarsConfirmEmpty;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get notificationsMarkAllRead;

  /// No description provided for @notificationsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get notificationsEmptyTitle;

  /// No description provided for @notificationsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Likes, comments and replies on your posts and threads will show up here.'**
  String get notificationsEmptyBody;

  /// No description provided for @notificationsRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get notificationsRetry;

  /// No description provided for @notificationsErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please try again.'**
  String get notificationsErrorNetwork;

  /// No description provided for @notificationsErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get notificationsErrorGeneric;

  /// No description provided for @tagsKindPost.
  ///
  /// In en, this message translates to:
  /// **'Tagged in a post'**
  String get tagsKindPost;

  /// No description provided for @tagsKindComment.
  ///
  /// In en, this message translates to:
  /// **'Tagged in a comment'**
  String get tagsKindComment;

  /// No description provided for @tagsKindThread.
  ///
  /// In en, this message translates to:
  /// **'Tagged in a thread'**
  String get tagsKindThread;

  /// No description provided for @tagsKindReply.
  ///
  /// In en, this message translates to:
  /// **'Tagged in a reply'**
  String get tagsKindReply;

  /// No description provided for @tagsOnPostBy.
  ///
  /// In en, this message translates to:
  /// **'on @{author}\'s post'**
  String tagsOnPostBy(String author);

  /// No description provided for @tagsLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get tagsLoadMore;

  /// No description provided for @tagsEmptyOwner.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t been tagged yet.'**
  String get tagsEmptyOwner;

  /// No description provided for @tagsEmptyVisitor.
  ///
  /// In en, this message translates to:
  /// **'No tags yet.'**
  String get tagsEmptyVisitor;

  /// No description provided for @tagsRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove tag'**
  String get tagsRemove;

  /// No description provided for @tagsRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove tag?'**
  String get tagsRemoveTitle;

  /// No description provided for @tagsRemoveBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ll be removed from this content for everyone, along with any of your cars tagged on it. Only the author can tag you again.'**
  String get tagsRemoveBody;

  /// No description provided for @tagsRemoveConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get tagsRemoveConfirm;

  /// No description provided for @tagsErrorContentGone.
  ///
  /// In en, this message translates to:
  /// **'This content no longer exists.'**
  String get tagsErrorContentGone;

  /// No description provided for @tagsErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get tagsErrorGeneric;

  /// No description provided for @mapOpenNow.
  ///
  /// In en, this message translates to:
  /// **'Open now'**
  String get mapOpenNow;

  /// No description provided for @mapClosedNow.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get mapClosedNow;

  /// No description provided for @mapNoReviews.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get mapNoReviews;

  /// No description provided for @mapReviewCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 review} other{{count} reviews}}'**
  String mapReviewCount(int count);

  /// No description provided for @mapFollowerCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 follower} other{{count} followers}}'**
  String mapFollowerCount(int count);

  /// No description provided for @mapHoursTitle.
  ///
  /// In en, this message translates to:
  /// **'Opening hours'**
  String get mapHoursTitle;

  /// No description provided for @mapHoursClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get mapHoursClosed;

  /// No description provided for @mapHoursNextDay.
  ///
  /// In en, this message translates to:
  /// **'(next day)'**
  String get mapHoursNextDay;

  /// No description provided for @mapWeekdayMonday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get mapWeekdayMonday;

  /// No description provided for @mapWeekdayTuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get mapWeekdayTuesday;

  /// No description provided for @mapWeekdayWednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get mapWeekdayWednesday;

  /// No description provided for @mapWeekdayThursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get mapWeekdayThursday;

  /// No description provided for @mapWeekdayFriday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get mapWeekdayFriday;

  /// No description provided for @mapWeekdaySaturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get mapWeekdaySaturday;

  /// No description provided for @mapWeekdaySunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get mapWeekdaySunday;

  /// No description provided for @mapPopupClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get mapPopupClose;

  /// No description provided for @mapRecentre.
  ///
  /// In en, this message translates to:
  /// **'Centre on my location'**
  String get mapRecentre;

  /// No description provided for @mapRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get mapRetry;

  /// No description provided for @mapErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please try again.'**
  String get mapErrorNetwork;

  /// No description provided for @mapErrorBusinessNotFound.
  ///
  /// In en, this message translates to:
  /// **'This business isn\'t available anymore.'**
  String get mapErrorBusinessNotFound;

  /// No description provided for @mapErrorLocationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t get your location. Check that location is turned on for Tweakd.'**
  String get mapErrorLocationUnavailable;

  /// No description provided for @mapErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get mapErrorGeneric;

  /// No description provided for @mapNavigate.
  ///
  /// In en, this message translates to:
  /// **'Navigate'**
  String get mapNavigate;

  /// No description provided for @mapNavigateSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a navigation app'**
  String get mapNavigateSheetTitle;

  /// No description provided for @mapNavigateInstall.
  ///
  /// In en, this message translates to:
  /// **'Install'**
  String get mapNavigateInstall;

  /// No description provided for @mapNavigateFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t open that app.'**
  String get mapNavigateFailed;

  /// No description provided for @mapEventsErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please try again.'**
  String get mapEventsErrorNetwork;

  /// No description provided for @mapEventsErrorNotFound.
  ///
  /// In en, this message translates to:
  /// **'This event isn\'t available anymore.'**
  String get mapEventsErrorNotFound;

  /// No description provided for @mapEventsErrorForbidden.
  ///
  /// In en, this message translates to:
  /// **'Only the organizers can do that.'**
  String get mapEventsErrorForbidden;

  /// No description provided for @mapEventsErrorConflict.
  ///
  /// In en, this message translates to:
  /// **'That isn\'t possible for this event right now.'**
  String get mapEventsErrorConflict;

  /// No description provided for @mapEventsErrorInvalidInput.
  ///
  /// In en, this message translates to:
  /// **'Please check the details and try again.'**
  String get mapEventsErrorInvalidInput;

  /// No description provided for @mapEventsBulkRegisterPartial.
  ///
  /// In en, this message translates to:
  /// **'{registered} of your cars got in before this event reached capacity — {failed} couldn\'t be added and weren\'t automatically removed.'**
  String mapEventsBulkRegisterPartial(int registered, int failed);

  /// No description provided for @mapEventsErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get mapEventsErrorGeneric;

  /// No description provided for @mapEventsStatusUpcoming.
  ///
  /// In en, this message translates to:
  /// **'UPCOMING'**
  String get mapEventsStatusUpcoming;

  /// No description provided for @mapEventsStatusLive.
  ///
  /// In en, this message translates to:
  /// **'LIVE NOW'**
  String get mapEventsStatusLive;

  /// No description provided for @mapEventsStatusPrevious.
  ///
  /// In en, this message translates to:
  /// **'PAST'**
  String get mapEventsStatusPrevious;

  /// No description provided for @mapEventsStatusHidden.
  ///
  /// In en, this message translates to:
  /// **'HIDDEN'**
  String get mapEventsStatusHidden;

  /// No description provided for @mapEventsStatusCanceled.
  ///
  /// In en, this message translates to:
  /// **'CANCELED'**
  String get mapEventsStatusCanceled;

  /// No description provided for @mapEventsApprovalPending.
  ///
  /// In en, this message translates to:
  /// **'PENDING REVIEW'**
  String get mapEventsApprovalPending;

  /// No description provided for @mapEventsApprovalAccepted.
  ///
  /// In en, this message translates to:
  /// **'APPROVED'**
  String get mapEventsApprovalAccepted;

  /// No description provided for @mapEventsApprovalRejected.
  ///
  /// In en, this message translates to:
  /// **'REJECTED'**
  String get mapEventsApprovalRejected;

  /// No description provided for @mapEventsRejectionReason.
  ///
  /// In en, this message translates to:
  /// **'Reason: {reason}'**
  String mapEventsRejectionReason(String reason);

  /// No description provided for @mapEventsClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get mapEventsClose;

  /// No description provided for @mapEventsShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get mapEventsShare;

  /// No description provided for @mapEventsStatAttendees.
  ///
  /// In en, this message translates to:
  /// **'Attendees'**
  String get mapEventsStatAttendees;

  /// No description provided for @mapEventsStatCars.
  ///
  /// In en, this message translates to:
  /// **'Cars'**
  String get mapEventsStatCars;

  /// No description provided for @mapEventsStatStarts.
  ///
  /// In en, this message translates to:
  /// **'Starts'**
  String get mapEventsStatStarts;

  /// No description provided for @mapEventsStatStarted.
  ///
  /// In en, this message translates to:
  /// **'Started'**
  String get mapEventsStatStarted;

  /// No description provided for @mapEventsGoingCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 going} other{{count} going}}'**
  String mapEventsGoingCount(int count);

  /// No description provided for @mapEventsRoleOrganizer.
  ///
  /// In en, this message translates to:
  /// **'organizer'**
  String get mapEventsRoleOrganizer;

  /// No description provided for @mapEventsRoleCreator.
  ///
  /// In en, this message translates to:
  /// **'creator'**
  String get mapEventsRoleCreator;

  /// No description provided for @mapEventsChipIndividual.
  ///
  /// In en, this message translates to:
  /// **'INDIVIDUAL'**
  String get mapEventsChipIndividual;

  /// No description provided for @mapEventsChipBusiness.
  ///
  /// In en, this message translates to:
  /// **'BUSINESS'**
  String get mapEventsChipBusiness;

  /// No description provided for @mapEventsAttending.
  ///
  /// In en, this message translates to:
  /// **'Attending'**
  String get mapEventsAttending;

  /// No description provided for @mapEventsInterested.
  ///
  /// In en, this message translates to:
  /// **'Interested'**
  String get mapEventsInterested;

  /// No description provided for @mapEventsWantToParticipate.
  ///
  /// In en, this message translates to:
  /// **'Want to participate?'**
  String get mapEventsWantToParticipate;

  /// No description provided for @mapEventsParticipateShort.
  ///
  /// In en, this message translates to:
  /// **'Participate?'**
  String get mapEventsParticipateShort;

  /// No description provided for @mapEventsParticipating.
  ///
  /// In en, this message translates to:
  /// **'Participating'**
  String get mapEventsParticipating;

  /// No description provided for @mapEventsParticipatingCount.
  ///
  /// In en, this message translates to:
  /// **'Participating · {count} cars'**
  String mapEventsParticipatingCount(int count);

  /// No description provided for @mapEventsParticipationPending.
  ///
  /// In en, this message translates to:
  /// **'PENDING'**
  String get mapEventsParticipationPending;

  /// No description provided for @mapEventsWithdrawAction.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get mapEventsWithdrawAction;

  /// No description provided for @mapEventsViewEvent.
  ///
  /// In en, this message translates to:
  /// **'View event'**
  String get mapEventsViewEvent;

  /// No description provided for @mapEventsCapacityOf.
  ///
  /// In en, this message translates to:
  /// **'of {capacity}'**
  String mapEventsCapacityOf(int capacity);

  /// No description provided for @mapEventsTabOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get mapEventsTabOverview;

  /// No description provided for @mapEventsTabCars.
  ///
  /// In en, this message translates to:
  /// **'Cars · {count}'**
  String mapEventsTabCars(int count);

  /// No description provided for @mapEventsEntryListTitle.
  ///
  /// In en, this message translates to:
  /// **'On the entry list'**
  String get mapEventsEntryListTitle;

  /// No description provided for @mapEventsApprovedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} approved'**
  String mapEventsApprovedCount(int count);

  /// No description provided for @mapEventsSectionAbout.
  ///
  /// In en, this message translates to:
  /// **'About this event'**
  String get mapEventsSectionAbout;

  /// No description provided for @mapEventsSectionOrganizers.
  ///
  /// In en, this message translates to:
  /// **'Organizers'**
  String get mapEventsSectionOrganizers;

  /// No description provided for @mapEventsSectionRules.
  ///
  /// In en, this message translates to:
  /// **'Notes from the organizer'**
  String get mapEventsSectionRules;

  /// No description provided for @mapEventsSectionContests.
  ///
  /// In en, this message translates to:
  /// **'Contests'**
  String get mapEventsSectionContests;

  /// No description provided for @mapEventsSectionAttendees.
  ///
  /// In en, this message translates to:
  /// **'Attendees'**
  String get mapEventsSectionAttendees;

  /// No description provided for @mapEventsSoon.
  ///
  /// In en, this message translates to:
  /// **'SOON'**
  String get mapEventsSoon;

  /// No description provided for @mapEventsContestsTitle.
  ///
  /// In en, this message translates to:
  /// **'Contests'**
  String get mapEventsContestsTitle;

  /// No description provided for @mapEventsContestsBody.
  ///
  /// In en, this message translates to:
  /// **'Organizers will be able to run votes inside a meet — best build, cleanest bay, loudest exhaust.'**
  String get mapEventsContestsBody;

  /// No description provided for @mapEventsSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get mapEventsSeeAll;

  /// No description provided for @mapEventsSeeAllAttendees.
  ///
  /// In en, this message translates to:
  /// **'See all attendees'**
  String get mapEventsSeeAllAttendees;

  /// No description provided for @mapEventsSeeAllCars.
  ///
  /// In en, this message translates to:
  /// **'See all {count} cars'**
  String mapEventsSeeAllCars(int count);

  /// No description provided for @mapEventsRegisterBefore.
  ///
  /// In en, this message translates to:
  /// **'Register your car before {deadline}'**
  String mapEventsRegisterBefore(String deadline);

  /// No description provided for @mapEventsRegistrationClosed.
  ///
  /// In en, this message translates to:
  /// **'Registration has closed for this event.'**
  String get mapEventsRegistrationClosed;

  /// No description provided for @mapEventsCapacityFull.
  ///
  /// In en, this message translates to:
  /// **'The entry list is full.'**
  String get mapEventsCapacityFull;

  /// No description provided for @mapEventsGarageLink.
  ///
  /// In en, this message translates to:
  /// **'Garage'**
  String get mapEventsGarageLink;

  /// No description provided for @mapEventsEntryListEmpty.
  ///
  /// In en, this message translates to:
  /// **'No cars on the entry list yet.'**
  String get mapEventsEntryListEmpty;

  /// No description provided for @mapEventsAttendeesEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nobody has RSVP\'d yet.'**
  String get mapEventsAttendeesEmpty;

  /// No description provided for @mapEventsRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get mapEventsRetry;

  /// No description provided for @mapEventsStripPendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Request pending'**
  String get mapEventsStripPendingTitle;

  /// No description provided for @mapEventsStripPendingBody.
  ///
  /// In en, this message translates to:
  /// **'The organizers will approve or decline your entry.'**
  String get mapEventsStripPendingBody;

  /// No description provided for @mapEventsStripDeclinedTitle.
  ///
  /// In en, this message translates to:
  /// **'Entry declined'**
  String get mapEventsStripDeclinedTitle;

  /// No description provided for @mapEventsStripDeclinedBody.
  ///
  /// In en, this message translates to:
  /// **'The organizers declined this car for this event.'**
  String get mapEventsStripDeclinedBody;

  /// No description provided for @mapEventsStripWithdrawnTitle.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal requested'**
  String get mapEventsStripWithdrawnTitle;

  /// No description provided for @mapEventsStripWithdrawnBody.
  ///
  /// In en, this message translates to:
  /// **'The organizers are reviewing your request to leave. You can\'t take it back.'**
  String get mapEventsStripWithdrawnBody;

  /// No description provided for @mapEventsDeclineReasonHeading.
  ///
  /// In en, this message translates to:
  /// **'Why'**
  String get mapEventsDeclineReasonHeading;

  /// No description provided for @mapEventsTryAnotherCar.
  ///
  /// In en, this message translates to:
  /// **'Try another car'**
  String get mapEventsTryAnotherCar;

  /// No description provided for @mapEventsCancelRequest.
  ///
  /// In en, this message translates to:
  /// **'Cancel request'**
  String get mapEventsCancelRequest;

  /// No description provided for @mapEventsPickCarTitle.
  ///
  /// In en, this message translates to:
  /// **'Which cars are you bringing?'**
  String get mapEventsPickCarTitle;

  /// No description provided for @mapEventsPickCarSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select at least one car to register'**
  String get mapEventsPickCarSubtitle;

  /// No description provided for @mapEventsPickCarSpotsLeft.
  ///
  /// In en, this message translates to:
  /// **'{count} spots left — select up to that many'**
  String mapEventsPickCarSpotsLeft(int count);

  /// No description provided for @mapEventsPickCarFull.
  ///
  /// In en, this message translates to:
  /// **'This event has reached its participant capacity.'**
  String get mapEventsPickCarFull;

  /// No description provided for @mapEventsPickCarAlreadyIn.
  ///
  /// In en, this message translates to:
  /// **'Already registered'**
  String get mapEventsPickCarAlreadyIn;

  /// No description provided for @mapEventsPickCarSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get mapEventsPickCarSelectAll;

  /// No description provided for @mapEventsPickCarClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get mapEventsPickCarClearAll;

  /// No description provided for @mapEventsPickCarRegisterCta.
  ///
  /// In en, this message translates to:
  /// **'Register ({count})'**
  String mapEventsPickCarRegisterCta(int count);

  /// No description provided for @mapEventsPickCarEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your garage is empty'**
  String get mapEventsPickCarEmptyTitle;

  /// No description provided for @mapEventsPickCarEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add a car to your garage first, then register it for an event.'**
  String get mapEventsPickCarEmptyBody;

  /// No description provided for @mapEventsPickCarAdd.
  ///
  /// In en, this message translates to:
  /// **'Add a car'**
  String get mapEventsPickCarAdd;

  /// No description provided for @mapEventsCarYear.
  ///
  /// In en, this message translates to:
  /// **'{year}'**
  String mapEventsCarYear(String year);

  /// No description provided for @mapEventsWithdrawTitle.
  ///
  /// In en, this message translates to:
  /// **'Withdraw from this event?'**
  String get mapEventsWithdrawTitle;

  /// No description provided for @mapEventsWithdrawBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ll ask the organizers to take you off the entry list, and off any contests running inside this event. Once sent, the request can\'t be taken back.'**
  String get mapEventsWithdrawBody;

  /// No description provided for @mapEventsWithdrawAllCars.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Your car leaves the entry list — an organizer has to approve it first.} other{All {count} of your cars leave the entry list together — there\'s no way to withdraw just one. An organizer has to approve it first.}}'**
  String mapEventsWithdrawAllCars(int count);

  /// No description provided for @mapEventsWithdrawNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note for organizers (optional)'**
  String get mapEventsWithdrawNoteLabel;

  /// No description provided for @mapEventsWithdrawNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Let them know why, if you\'d like…'**
  String get mapEventsWithdrawNoteHint;

  /// No description provided for @mapEventsCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get mapEventsCancel;

  /// No description provided for @mapEventsAttendeesPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Attendees'**
  String get mapEventsAttendeesPageTitle;

  /// No description provided for @mapEventsFilterAttending.
  ///
  /// In en, this message translates to:
  /// **'Attending'**
  String get mapEventsFilterAttending;

  /// No description provided for @mapEventsFilterInterested.
  ///
  /// In en, this message translates to:
  /// **'Interested'**
  String get mapEventsFilterInterested;

  /// No description provided for @mapEventsCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'New event'**
  String get mapEventsCreateTitle;

  /// No description provided for @mapEventsEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit event'**
  String get mapEventsEditTitle;

  /// No description provided for @mapEventsCoverAdd.
  ///
  /// In en, this message translates to:
  /// **'Add cover photo'**
  String get mapEventsCoverAdd;

  /// No description provided for @mapEventsCoverHint.
  ///
  /// In en, this message translates to:
  /// **'1600 × 900 recommended'**
  String get mapEventsCoverHint;

  /// No description provided for @mapEventsCoverChange.
  ///
  /// In en, this message translates to:
  /// **'Change cover'**
  String get mapEventsCoverChange;

  /// No description provided for @mapEventsFieldCover.
  ///
  /// In en, this message translates to:
  /// **'Cover photo'**
  String get mapEventsFieldCover;

  /// No description provided for @mapEventsFieldTitle.
  ///
  /// In en, this message translates to:
  /// **'Event title'**
  String get mapEventsFieldTitle;

  /// No description provided for @mapEventsFieldTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Casino Square Cars & Coffee'**
  String get mapEventsFieldTitleHint;

  /// No description provided for @mapEventsFieldCategory.
  ///
  /// In en, this message translates to:
  /// **'Event category'**
  String get mapEventsFieldCategory;

  /// No description provided for @mapEventsCategoriesSoonNote.
  ///
  /// In en, this message translates to:
  /// **'More categories are coming soon.'**
  String get mapEventsCategoriesSoonNote;

  /// No description provided for @mapEventsCategoryTrackDay.
  ///
  /// In en, this message translates to:
  /// **'Track Day'**
  String get mapEventsCategoryTrackDay;

  /// No description provided for @mapEventsCategoryCarsAndCoffee.
  ///
  /// In en, this message translates to:
  /// **'Cars & Coffee'**
  String get mapEventsCategoryCarsAndCoffee;

  /// No description provided for @mapEventsCategoryCruise.
  ///
  /// In en, this message translates to:
  /// **'Cruise'**
  String get mapEventsCategoryCruise;

  /// No description provided for @mapEventsFieldDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get mapEventsFieldDescription;

  /// No description provided for @mapEventsFieldDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'What\'s the event about ?'**
  String get mapEventsFieldDescriptionHint;

  /// No description provided for @mapEventsFieldLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get mapEventsFieldLocation;

  /// No description provided for @mapEventsFieldVenueHint.
  ///
  /// In en, this message translates to:
  /// **'Venue name — e.g. Place du Casino'**
  String get mapEventsFieldVenueHint;

  /// No description provided for @mapEventsSetLocationOnMap.
  ///
  /// In en, this message translates to:
  /// **'Set location on map'**
  String get mapEventsSetLocationOnMap;

  /// No description provided for @mapEventsLocationSet.
  ///
  /// In en, this message translates to:
  /// **'Pin placed · tap to move'**
  String get mapEventsLocationSet;

  /// No description provided for @mapEventsFieldDateTime.
  ///
  /// In en, this message translates to:
  /// **'Date & time'**
  String get mapEventsFieldDateTime;

  /// No description provided for @mapEventsStartsLabel.
  ///
  /// In en, this message translates to:
  /// **'Starts'**
  String get mapEventsStartsLabel;

  /// No description provided for @mapEventsEndsLabel.
  ///
  /// In en, this message translates to:
  /// **'Ends'**
  String get mapEventsEndsLabel;

  /// No description provided for @mapEventsEndBlankHint.
  ///
  /// In en, this message translates to:
  /// **'Leave the end blank for an open-ended event.'**
  String get mapEventsEndBlankHint;

  /// No description provided for @mapEventsClearEnd.
  ///
  /// In en, this message translates to:
  /// **'Clear end'**
  String get mapEventsClearEnd;

  /// No description provided for @mapEventsFieldCapacity.
  ///
  /// In en, this message translates to:
  /// **'Max capacity'**
  String get mapEventsFieldCapacity;

  /// No description provided for @mapEventsOptional.
  ///
  /// In en, this message translates to:
  /// **'OPTIONAL'**
  String get mapEventsOptional;

  /// No description provided for @mapEventsRequired.
  ///
  /// In en, this message translates to:
  /// **'REQUIRED'**
  String get mapEventsRequired;

  /// No description provided for @mapEventsCapacityHint.
  ///
  /// In en, this message translates to:
  /// **'Empty defaults to no limit'**
  String get mapEventsCapacityHint;

  /// No description provided for @mapEventsCapacityLockedHint.
  ///
  /// In en, this message translates to:
  /// **'A capacity can be raised later, but not removed.'**
  String get mapEventsCapacityLockedHint;

  /// No description provided for @mapEventsApprovalToggleTitle.
  ///
  /// In en, this message translates to:
  /// **'Require approval to join'**
  String get mapEventsApprovalToggleTitle;

  /// No description provided for @mapEventsApprovalToggleBody.
  ///
  /// In en, this message translates to:
  /// **'You and your co-organizers review each request before a participant is added to the entry list.'**
  String get mapEventsApprovalToggleBody;

  /// No description provided for @mapEventsFieldDeadline.
  ///
  /// In en, this message translates to:
  /// **'Registration deadline'**
  String get mapEventsFieldDeadline;

  /// No description provided for @mapEventsFieldRules.
  ///
  /// In en, this message translates to:
  /// **'Rules & guidelines'**
  String get mapEventsFieldRules;

  /// No description provided for @mapEventsAddRule.
  ///
  /// In en, this message translates to:
  /// **'Add a rule'**
  String get mapEventsAddRule;

  /// No description provided for @mapEventsRuleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. No revving or burnouts.'**
  String get mapEventsRuleHint;

  /// No description provided for @mapEventsRemoveRule.
  ///
  /// In en, this message translates to:
  /// **'Remove rule'**
  String get mapEventsRemoveRule;

  /// No description provided for @mapEventsFieldOrganizers.
  ///
  /// In en, this message translates to:
  /// **'Organizers'**
  String get mapEventsFieldOrganizers;

  /// No description provided for @mapEventsOrganizersHint.
  ///
  /// In en, this message translates to:
  /// **'You\'re the creator. Add other individual or certified business accounts to co-organize with you.'**
  String get mapEventsOrganizersHint;

  /// No description provided for @mapEventsYouCreator.
  ///
  /// In en, this message translates to:
  /// **'YOU · CREATOR'**
  String get mapEventsYouCreator;

  /// No description provided for @mapEventsAddOrganizer.
  ///
  /// In en, this message translates to:
  /// **'Add organizer'**
  String get mapEventsAddOrganizer;

  /// No description provided for @mapEventsRemoveOrganizer.
  ///
  /// In en, this message translates to:
  /// **'Remove organizer'**
  String get mapEventsRemoveOrganizer;

  /// No description provided for @mapEventsCreateCta.
  ///
  /// In en, this message translates to:
  /// **'Create event'**
  String get mapEventsCreateCta;

  /// No description provided for @mapEventsCreateCtaIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Add title, location & start time'**
  String get mapEventsCreateCtaIncomplete;

  /// No description provided for @mapEventsCreateCtaDeadline.
  ///
  /// In en, this message translates to:
  /// **'Add a registration deadline'**
  String get mapEventsCreateCtaDeadline;

  /// No description provided for @mapEventsCreateCtaCover.
  ///
  /// In en, this message translates to:
  /// **'Add a cover image'**
  String get mapEventsCreateCtaCover;

  /// No description provided for @mapEventsSaveCta.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get mapEventsSaveCta;

  /// No description provided for @mapEventsSubmitting.
  ///
  /// In en, this message translates to:
  /// **'Just a moment…'**
  String get mapEventsSubmitting;

  /// No description provided for @mapEventsValidationEndBeforeStart.
  ///
  /// In en, this message translates to:
  /// **'The end time has to be after the start time.'**
  String get mapEventsValidationEndBeforeStart;

  /// No description provided for @mapEventsValidationDeadlineAfterStart.
  ///
  /// In en, this message translates to:
  /// **'The registration deadline has to be before the event starts.'**
  String get mapEventsValidationDeadlineAfterStart;

  /// No description provided for @mapEventsValidationCapacity.
  ///
  /// In en, this message translates to:
  /// **'Capacity has to be at least 1.'**
  String get mapEventsValidationCapacity;

  /// No description provided for @mapEventsPendingReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Sent for review'**
  String get mapEventsPendingReviewTitle;

  /// No description provided for @mapEventsPendingReviewBody.
  ///
  /// In en, this message translates to:
  /// **'Our team checks every new event before it shows up on the map. You\'ll find it under Events on your profile in the meantime.'**
  String get mapEventsPendingReviewBody;

  /// No description provided for @mapEventsDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get mapEventsDone;

  /// No description provided for @mapEventsCoverUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'The event was created, but the cover photo didn\'t upload. You can add it from My events.'**
  String get mapEventsCoverUploadFailed;

  /// No description provided for @mapEventsWizardNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get mapEventsWizardNext;

  /// No description provided for @mapEventsWizardBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get mapEventsWizardBack;

  /// No description provided for @mapEventsWizardClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get mapEventsWizardClose;

  /// No description provided for @mapEventsWizardDiscardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard this event?'**
  String get mapEventsWizardDiscardTitle;

  /// No description provided for @mapEventsWizardDiscardBody.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t submitted this event yet. If you leave now, everything you entered will be lost.'**
  String get mapEventsWizardDiscardBody;

  /// No description provided for @mapEventsWizardDiscardDraft.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get mapEventsWizardDiscardDraft;

  /// No description provided for @mapEventsWizardStay.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get mapEventsWizardStay;

  /// No description provided for @mapEventsEditDiscardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard your changes?'**
  String get mapEventsEditDiscardTitle;

  /// No description provided for @mapEventsEditDiscardBody.
  ///
  /// In en, this message translates to:
  /// **'Your changes to this event won\'t be saved.'**
  String get mapEventsEditDiscardBody;

  /// No description provided for @mapEventsDraftRestored.
  ///
  /// In en, this message translates to:
  /// **'Picked up where you left off.'**
  String get mapEventsDraftRestored;

  /// No description provided for @mapEventsDraftStartOver.
  ///
  /// In en, this message translates to:
  /// **'Start over'**
  String get mapEventsDraftStartOver;

  /// No description provided for @mapEventsStepBasicsTitle.
  ///
  /// In en, this message translates to:
  /// **'The basics'**
  String get mapEventsStepBasicsTitle;

  /// No description provided for @mapEventsStepBasicsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s the event called, and what should people expect?'**
  String get mapEventsStepBasicsSubtitle;

  /// No description provided for @mapEventsStepOrganizersTitle.
  ///
  /// In en, this message translates to:
  /// **'Who\'s running it'**
  String get mapEventsStepOrganizersTitle;

  /// No description provided for @mapEventsStepOrganizersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re the creator. Add individual or certified business accounts to co-organize with you.'**
  String get mapEventsStepOrganizersSubtitle;

  /// No description provided for @mapEventsStepOrganizersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No co-organizers yet. You can add them later too.'**
  String get mapEventsStepOrganizersEmpty;

  /// No description provided for @mapEventsStepWhenWhereTitle.
  ///
  /// In en, this message translates to:
  /// **'When & where'**
  String get mapEventsStepWhenWhereTitle;

  /// No description provided for @mapEventsStepWhenWhereSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set the schedule, then drop the pin on the map.'**
  String get mapEventsStepWhenWhereSubtitle;

  /// No description provided for @mapEventsLocationPickCta.
  ///
  /// In en, this message translates to:
  /// **'Pick the location on the map'**
  String get mapEventsLocationPickCta;

  /// No description provided for @mapEventsLocationChangeCta.
  ///
  /// In en, this message translates to:
  /// **'Change location'**
  String get mapEventsLocationChangeCta;

  /// No description provided for @mapEventsLocationCardCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get mapEventsLocationCardCity;

  /// No description provided for @mapEventsLocationCardStreet.
  ///
  /// In en, this message translates to:
  /// **'Street'**
  String get mapEventsLocationCardStreet;

  /// No description provided for @mapEventsLocationCardNumber.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get mapEventsLocationCardNumber;

  /// No description provided for @mapEventsLocationCardPin.
  ///
  /// In en, this message translates to:
  /// **'Pin dropped'**
  String get mapEventsLocationCardPin;

  /// No description provided for @mapEventsLocationEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Pick a location and we\'ll fill in the city, street and number from the address you search.'**
  String get mapEventsLocationEmptyHint;

  /// No description provided for @mapEventsDeadlineHint.
  ///
  /// In en, this message translates to:
  /// **'Car meets need one: the last moment someone can enter a car.'**
  String get mapEventsDeadlineHint;

  /// No description provided for @mapEventsStepRulesTitle.
  ///
  /// In en, this message translates to:
  /// **'Rules & entry'**
  String get mapEventsStepRulesTitle;

  /// No description provided for @mapEventsStepRulesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'House rules, how many cars fit, and whether you vet each one.'**
  String get mapEventsStepRulesSubtitle;

  /// No description provided for @mapEventsRulesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No rules yet. Plenty of meets run fine without any.'**
  String get mapEventsRulesEmpty;

  /// No description provided for @mapEventsCapacityUnlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get mapEventsCapacityUnlimited;

  /// No description provided for @mapEventsCapacityUnlimitedHint.
  ///
  /// In en, this message translates to:
  /// **'Leave it empty for no limit.'**
  String get mapEventsCapacityUnlimitedHint;

  /// No description provided for @mapEventsStepContestsTitle.
  ///
  /// In en, this message translates to:
  /// **'Contests'**
  String get mapEventsStepContestsTitle;

  /// No description provided for @mapEventsStepContestsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Line up the categories people will vote on. You can add, edit or remove them any time after the event is approved.'**
  String get mapEventsStepContestsSubtitle;

  /// No description provided for @mapEventsContestsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No contests yet.'**
  String get mapEventsContestsEmpty;

  /// No description provided for @mapEventsAddContest.
  ///
  /// In en, this message translates to:
  /// **'Add a contest'**
  String get mapEventsAddContest;

  /// No description provided for @mapEventsEditContest.
  ///
  /// In en, this message translates to:
  /// **'Edit contest'**
  String get mapEventsEditContest;

  /// No description provided for @mapEventsRemoveContest.
  ///
  /// In en, this message translates to:
  /// **'Remove contest'**
  String get mapEventsRemoveContest;

  /// No description provided for @mapEventsContestsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Contest categories couldn\'t be loaded. You can add contests from the event page once it\'s approved.'**
  String get mapEventsContestsUnavailable;

  /// No description provided for @mapEventsContestsFullHint.
  ///
  /// In en, this message translates to:
  /// **'An event can hold up to {count} contests.'**
  String mapEventsContestsFullHint(int count);

  /// No description provided for @mapEventsContestsFailed.
  ///
  /// In en, this message translates to:
  /// **'The event was created, but {count} of its contests weren\'t. You can add them from My events.'**
  String mapEventsContestsFailed(int count);

  /// No description provided for @mapEventsContestOpensLabel.
  ///
  /// In en, this message translates to:
  /// **'Voting opens'**
  String get mapEventsContestOpensLabel;

  /// No description provided for @mapEventsContestClosesLabel.
  ///
  /// In en, this message translates to:
  /// **'Voting closes'**
  String get mapEventsContestClosesLabel;

  /// No description provided for @mapEventsContestOpensAtStart.
  ///
  /// In en, this message translates to:
  /// **'When the meet starts'**
  String get mapEventsContestOpensAtStart;

  /// No description provided for @mapEventsContestOpensNow.
  ///
  /// In en, this message translates to:
  /// **'As soon as it\'s approved'**
  String get mapEventsContestOpensNow;

  /// No description provided for @mapEventsContestCustomTime.
  ///
  /// In en, this message translates to:
  /// **'Pick a time'**
  String get mapEventsContestCustomTime;

  /// No description provided for @mapEventsContestClosesManualNote.
  ///
  /// In en, this message translates to:
  /// **'Attendees see this time. You still open and close voting yourself, from the contests list once the event is approved.'**
  String get mapEventsContestClosesManualNote;

  /// No description provided for @mapEventsContestTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Contest title'**
  String get mapEventsContestTitleLabel;

  /// No description provided for @mapEventsContestTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Best exhaust system'**
  String get mapEventsContestTitleHint;

  /// No description provided for @mapEventsContestCriteriaLabel.
  ///
  /// In en, this message translates to:
  /// **'Judging note'**
  String get mapEventsContestCriteriaLabel;

  /// No description provided for @mapEventsContestCriteriaHint.
  ///
  /// In en, this message translates to:
  /// **'What are people voting on?'**
  String get mapEventsContestCriteriaHint;

  /// No description provided for @mapEventsContestCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get mapEventsContestCategoryLabel;

  /// No description provided for @mapEventsContestSave.
  ///
  /// In en, this message translates to:
  /// **'Save contest'**
  String get mapEventsContestSave;

  /// No description provided for @mapEventsStepCoverTitle.
  ///
  /// In en, this message translates to:
  /// **'Cover photo'**
  String get mapEventsStepCoverTitle;

  /// No description provided for @mapEventsStepCoverSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The one image people see on the map, in the feed and at the top of the event.'**
  String get mapEventsStepCoverSubtitle;

  /// No description provided for @mapEventsStepReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review & publish'**
  String get mapEventsStepReviewTitle;

  /// No description provided for @mapEventsStepReviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This is how people will see it. Tap any section to go back and change it.'**
  String get mapEventsStepReviewSubtitle;

  /// No description provided for @mapEventsReviewEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get mapEventsReviewEdit;

  /// No description provided for @mapEventsReviewNoDescription.
  ///
  /// In en, this message translates to:
  /// **'No description yet'**
  String get mapEventsReviewNoDescription;

  /// No description provided for @mapEventsReviewNoRules.
  ///
  /// In en, this message translates to:
  /// **'No rules'**
  String get mapEventsReviewNoRules;

  /// No description provided for @mapEventsReviewNoContests.
  ///
  /// In en, this message translates to:
  /// **'No contests'**
  String get mapEventsReviewNoContests;

  /// No description provided for @mapEventsReviewNoOrganizers.
  ///
  /// In en, this message translates to:
  /// **'Just you'**
  String get mapEventsReviewNoOrganizers;

  /// No description provided for @mapEventsReviewOpenEnded.
  ///
  /// In en, this message translates to:
  /// **'Open-ended'**
  String get mapEventsReviewOpenEnded;

  /// No description provided for @mapEventsReviewApprovalOn.
  ///
  /// In en, this message translates to:
  /// **'You approve each car'**
  String get mapEventsReviewApprovalOn;

  /// No description provided for @mapEventsReviewApprovalOff.
  ///
  /// In en, this message translates to:
  /// **'Anyone can enter a car'**
  String get mapEventsReviewApprovalOff;

  /// No description provided for @mapEventsReviewSectionOrganizers.
  ///
  /// In en, this message translates to:
  /// **'Organizers'**
  String get mapEventsReviewSectionOrganizers;

  /// No description provided for @mapEventsReviewSectionSchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get mapEventsReviewSectionSchedule;

  /// No description provided for @mapEventsReviewSectionEntry.
  ///
  /// In en, this message translates to:
  /// **'Entry'**
  String get mapEventsReviewSectionEntry;

  /// No description provided for @mapEventsPublishCta.
  ///
  /// In en, this message translates to:
  /// **'Publish for review'**
  String get mapEventsPublishCta;

  /// No description provided for @mapEventsValidationTitle.
  ///
  /// In en, this message translates to:
  /// **'Give the event a title.'**
  String get mapEventsValidationTitle;

  /// No description provided for @mapEventsValidationDescription.
  ///
  /// In en, this message translates to:
  /// **'Add a short description so people know what it is.'**
  String get mapEventsValidationDescription;

  /// No description provided for @mapEventsValidationLocation.
  ///
  /// In en, this message translates to:
  /// **'Pick the location on the map.'**
  String get mapEventsValidationLocation;

  /// No description provided for @mapEventsValidationStart.
  ///
  /// In en, this message translates to:
  /// **'Set when the event starts.'**
  String get mapEventsValidationStart;

  /// No description provided for @mapEventsValidationDeadlineRequired.
  ///
  /// In en, this message translates to:
  /// **'A car meet needs a registration deadline.'**
  String get mapEventsValidationDeadlineRequired;

  /// No description provided for @mapEventsValidationCover.
  ///
  /// In en, this message translates to:
  /// **'Add a cover photo.'**
  String get mapEventsValidationCover;

  /// No description provided for @mapEventsUseThisLocation.
  ///
  /// In en, this message translates to:
  /// **'Use this location'**
  String get mapEventsUseThisLocation;

  /// No description provided for @mapEventsLocationFormTitle.
  ///
  /// In en, this message translates to:
  /// **'Find the address'**
  String get mapEventsLocationFormTitle;

  /// No description provided for @mapEventsLocationFormSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll point the map at it. You place the exact pin yourself.'**
  String get mapEventsLocationFormSubtitle;

  /// No description provided for @mapEventsLocationCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get mapEventsLocationCity;

  /// No description provided for @mapEventsLocationCityHint.
  ///
  /// In en, this message translates to:
  /// **'eg: Cluj-Napoca'**
  String get mapEventsLocationCityHint;

  /// No description provided for @mapEventsLocationStreet.
  ///
  /// In en, this message translates to:
  /// **'Street'**
  String get mapEventsLocationStreet;

  /// No description provided for @mapEventsLocationStreetHint.
  ///
  /// In en, this message translates to:
  /// **'eg: Strada Memorandumului'**
  String get mapEventsLocationStreetHint;

  /// No description provided for @mapEventsLocationNumber.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get mapEventsLocationNumber;

  /// No description provided for @mapEventsLocationNumberHint.
  ///
  /// In en, this message translates to:
  /// **'eg: 28B'**
  String get mapEventsLocationNumberHint;

  /// No description provided for @mapEventsLocationSearchButton.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get mapEventsLocationSearchButton;

  /// No description provided for @mapEventsLocationSearchIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Fill in all three fields'**
  String get mapEventsLocationSearchIncomplete;

  /// No description provided for @mapEventsLocationSearchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No matches for that address. Check the spelling, or search the street without the number.'**
  String get mapEventsLocationSearchNoResults;

  /// No description provided for @mapEventsLocationResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the closest match'**
  String get mapEventsLocationResultsTitle;

  /// No description provided for @mapEventsLocationResultsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This only moves the map — you still drop the pin.'**
  String get mapEventsLocationResultsSubtitle;

  /// No description provided for @mapEventsLocationEditSearch.
  ///
  /// In en, this message translates to:
  /// **'Edit search'**
  String get mapEventsLocationEditSearch;

  /// No description provided for @mapEventsLocationBackToResults.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get mapEventsLocationBackToResults;

  /// No description provided for @mapEventsLocationDropPinTitle.
  ///
  /// In en, this message translates to:
  /// **'Tap the map to drop your pin'**
  String get mapEventsLocationDropPinTitle;

  /// No description provided for @mapEventsLocationDropPinBody.
  ///
  /// In en, this message translates to:
  /// **'Tap the exact spot — the entrance, the yard, the parking area.'**
  String get mapEventsLocationDropPinBody;

  /// No description provided for @mapEventsLocationPinDropped.
  ///
  /// In en, this message translates to:
  /// **'Pin dropped. Tap again to move it.'**
  String get mapEventsLocationPinDropped;

  /// No description provided for @mapEventsLocationPrecisionExact.
  ///
  /// In en, this message translates to:
  /// **'EXACT ADDRESS'**
  String get mapEventsLocationPrecisionExact;

  /// No description provided for @mapEventsLocationPrecisionPoint.
  ///
  /// In en, this message translates to:
  /// **'NEARBY POINT'**
  String get mapEventsLocationPrecisionPoint;

  /// No description provided for @mapEventsLocationPrecisionIntersection.
  ///
  /// In en, this message translates to:
  /// **'INTERSECTION'**
  String get mapEventsLocationPrecisionIntersection;

  /// No description provided for @mapEventsLocationPrecisionApproximate.
  ///
  /// In en, this message translates to:
  /// **'APPROXIMATE'**
  String get mapEventsLocationPrecisionApproximate;

  /// No description provided for @mapEventsLocationPrecisionStreet.
  ///
  /// In en, this message translates to:
  /// **'STREET LEVEL'**
  String get mapEventsLocationPrecisionStreet;

  /// No description provided for @mapEventsLocationPrecisionAddress.
  ///
  /// In en, this message translates to:
  /// **'ADDRESS'**
  String get mapEventsLocationPrecisionAddress;

  /// No description provided for @mapEventsLocationPrecisionPostcode.
  ///
  /// In en, this message translates to:
  /// **'POSTCODE AREA'**
  String get mapEventsLocationPrecisionPostcode;

  /// No description provided for @mapEventsLocationPrecisionArea.
  ///
  /// In en, this message translates to:
  /// **'WIDER AREA'**
  String get mapEventsLocationPrecisionArea;

  /// No description provided for @mapEventsSearchOrganizersTitle.
  ///
  /// In en, this message translates to:
  /// **'Add an organizer'**
  String get mapEventsSearchOrganizersTitle;

  /// No description provided for @mapEventsSearchOrganizersHint.
  ///
  /// In en, this message translates to:
  /// **'Search people and businesses'**
  String get mapEventsSearchOrganizersHint;

  /// No description provided for @mapEventsSearchOrganizersEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nobody matched that.'**
  String get mapEventsSearchOrganizersEmpty;

  /// No description provided for @mapEventsSearchOrganizersPrompt.
  ///
  /// In en, this message translates to:
  /// **'Start typing a name to find people and certified businesses.'**
  String get mapEventsSearchOrganizersPrompt;

  /// No description provided for @profileTabEvents.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get profileTabEvents;

  /// No description provided for @mapEventsMineTitle.
  ///
  /// In en, this message translates to:
  /// **'My events'**
  String get mapEventsMineTitle;

  /// No description provided for @mapEventsMineEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No events yet'**
  String get mapEventsMineEmptyTitle;

  /// No description provided for @mapEventsMineEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Events you create show up here — including the ones still waiting for review.'**
  String get mapEventsMineEmptyBody;

  /// No description provided for @mapEventsMineCreate.
  ///
  /// In en, this message translates to:
  /// **'Create an event'**
  String get mapEventsMineCreate;

  /// No description provided for @mapEventsManageTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage event'**
  String get mapEventsManageTitle;

  /// No description provided for @mapEventsManageEntries.
  ///
  /// In en, this message translates to:
  /// **'Entry requests'**
  String get mapEventsManageEntries;

  /// No description provided for @mapEventsManageWithdrawals.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal requests'**
  String get mapEventsManageWithdrawals;

  /// No description provided for @mapEventsManageOrganizers.
  ///
  /// In en, this message translates to:
  /// **'Organizers'**
  String get mapEventsManageOrganizers;

  /// No description provided for @mapEventsManageDanger.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get mapEventsManageDanger;

  /// No description provided for @mapEventsNoPendingEntries.
  ///
  /// In en, this message translates to:
  /// **'No entry requests waiting.'**
  String get mapEventsNoPendingEntries;

  /// No description provided for @mapEventsNoWithdrawals.
  ///
  /// In en, this message translates to:
  /// **'No withdrawal requests waiting.'**
  String get mapEventsNoWithdrawals;

  /// No description provided for @mapEventsAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get mapEventsAccept;

  /// No description provided for @mapEventsDecline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get mapEventsDecline;

  /// No description provided for @mapEventsDeclineTitle.
  ///
  /// In en, this message translates to:
  /// **'Decline this entry?'**
  String get mapEventsDeclineTitle;

  /// No description provided for @mapEventsDeclineBody.
  ///
  /// In en, this message translates to:
  /// **'{car} won\'t be on the entry list. The owner sees your reason, so make it something they can act on.'**
  String mapEventsDeclineBody(String car);

  /// No description provided for @mapEventsDeclineReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reason (required)'**
  String get mapEventsDeclineReasonLabel;

  /// No description provided for @mapEventsDeclineReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Wrong category for a JDM-only meet…'**
  String get mapEventsDeclineReasonHint;

  /// No description provided for @mapEventsLetThemOut.
  ///
  /// In en, this message translates to:
  /// **'Let them out'**
  String get mapEventsLetThemOut;

  /// No description provided for @mapEventsKeepThemIn.
  ///
  /// In en, this message translates to:
  /// **'Keep them in'**
  String get mapEventsKeepThemIn;

  /// No description provided for @mapEventsWithdrawalNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Their note'**
  String get mapEventsWithdrawalNoteLabel;

  /// No description provided for @mapEventsEditEvent.
  ///
  /// In en, this message translates to:
  /// **'Edit event'**
  String get mapEventsEditEvent;

  /// No description provided for @mapEventsCancelEvent.
  ///
  /// In en, this message translates to:
  /// **'Cancel event'**
  String get mapEventsCancelEvent;

  /// No description provided for @mapEventsFinishEvent.
  ///
  /// In en, this message translates to:
  /// **'Finish event'**
  String get mapEventsFinishEvent;

  /// No description provided for @mapEventsDeleteEvent.
  ///
  /// In en, this message translates to:
  /// **'Delete event'**
  String get mapEventsDeleteEvent;

  /// No description provided for @mapEventsEditLockedHint.
  ///
  /// In en, this message translates to:
  /// **'An event can only be edited while it\'s waiting for review or after it\'s been rejected.'**
  String get mapEventsEditLockedHint;

  /// No description provided for @mapEventsConfirmCancelTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel this event?'**
  String get mapEventsConfirmCancelTitle;

  /// No description provided for @mapEventsConfirmCancelBody.
  ///
  /// In en, this message translates to:
  /// **'It stays visible but is marked as canceled, and nobody can register a car anymore.'**
  String get mapEventsConfirmCancelBody;

  /// No description provided for @mapEventsConfirmFinishTitle.
  ///
  /// In en, this message translates to:
  /// **'Finish this event?'**
  String get mapEventsConfirmFinishTitle;

  /// No description provided for @mapEventsConfirmFinishBody.
  ///
  /// In en, this message translates to:
  /// **'It moves to your past events. RSVPs and the entry list stay as they are.'**
  String get mapEventsConfirmFinishBody;

  /// No description provided for @mapEventsConfirmDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this event?'**
  String get mapEventsConfirmDeleteTitle;

  /// No description provided for @mapEventsConfirmDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'This can\'t be undone. The entry list and every RSVP go with it.'**
  String get mapEventsConfirmDeleteBody;

  /// No description provided for @mapEventsConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get mapEventsConfirm;

  /// No description provided for @mapEventsDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get mapEventsDelete;

  /// No description provided for @mapEventsWithdrawalCarsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 car} other{{count} cars}}'**
  String mapEventsWithdrawalCarsCount(int count);

  /// No description provided for @mapSearchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search meets, shops, cities…'**
  String get mapSearchPlaceholder;

  /// No description provided for @mapCreateEvent.
  ///
  /// In en, this message translates to:
  /// **'Create an event'**
  String get mapCreateEvent;

  /// No description provided for @mapEventsCopied.
  ///
  /// In en, this message translates to:
  /// **'Event details copied.'**
  String get mapEventsCopied;

  /// No description provided for @mapEventsDateCardTitle.
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get mapEventsDateCardTitle;

  /// No description provided for @feedbackFeedEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get feedbackFeedEyebrow;

  /// No description provided for @feedbackFeedTitle.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedbackFeedTitle;

  /// No description provided for @feedbackFeedNew.
  ///
  /// In en, this message translates to:
  /// **'NEW'**
  String get feedbackFeedNew;

  /// No description provided for @feedbackFeedSortNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get feedbackFeedSortNewest;

  /// No description provided for @feedbackFeedSortPopular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get feedbackFeedSortPopular;

  /// No description provided for @feedbackFeedSortOldest.
  ///
  /// In en, this message translates to:
  /// **'Oldest'**
  String get feedbackFeedSortOldest;

  /// No description provided for @feedbackFeedCompletedLink.
  ///
  /// In en, this message translates to:
  /// **'Completed requests'**
  String get feedbackFeedCompletedLink;

  /// No description provided for @feedbackFeedCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Completed requests'**
  String get feedbackFeedCompletedTitle;

  /// No description provided for @feedbackFeedComposeEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Feedback community'**
  String get feedbackFeedComposeEyebrow;

  /// No description provided for @feedbackFeedComposeTitle.
  ///
  /// In en, this message translates to:
  /// **'Share feedback'**
  String get feedbackFeedComposeTitle;

  /// No description provided for @feedbackFeedComposeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Visible to everyone. Other drivers can upvote or downvote it.'**
  String get feedbackFeedComposeSubtitle;

  /// No description provided for @feedbackFeedCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get feedbackFeedCategoryLabel;

  /// No description provided for @feedbackFeedMessageLabel.
  ///
  /// In en, this message translates to:
  /// **'Your message'**
  String get feedbackFeedMessageLabel;

  /// No description provided for @feedbackFeedMessageHint.
  ///
  /// In en, this message translates to:
  /// **'What’s on your mind — a bug, an idea, a tweak?'**
  String get feedbackFeedMessageHint;

  /// No description provided for @feedbackFeedPostAction.
  ///
  /// In en, this message translates to:
  /// **'Post feedback'**
  String get feedbackFeedPostAction;

  /// No description provided for @feedbackFeedPostSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your feedback is live.'**
  String get feedbackFeedPostSuccess;

  /// No description provided for @feedbackFeedYou.
  ///
  /// In en, this message translates to:
  /// **'you'**
  String get feedbackFeedYou;

  /// No description provided for @feedbackFeedNetVotes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 net vote} other{{count} net votes}}'**
  String feedbackFeedNetVotes(int count);

  /// No description provided for @feedbackFeedShippedAgo.
  ///
  /// In en, this message translates to:
  /// **'shipped {time} ago'**
  String feedbackFeedShippedAgo(String time);

  /// No description provided for @feedbackFeedTimeAgo.
  ///
  /// In en, this message translates to:
  /// **'{time} ago'**
  String feedbackFeedTimeAgo(String time);

  /// No description provided for @feedbackFeedStaffLabel.
  ///
  /// In en, this message translates to:
  /// **'TWEAKD TEAM'**
  String get feedbackFeedStaffLabel;

  /// No description provided for @feedbackFeedDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get feedbackFeedDelete;

  /// No description provided for @feedbackFeedDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this feedback?'**
  String get feedbackFeedDeleteTitle;

  /// No description provided for @feedbackFeedDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'This can’t be undone. The votes it collected go with it.'**
  String get feedbackFeedDeleteBody;

  /// No description provided for @feedbackFeedDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Feedback deleted.'**
  String get feedbackFeedDeleteSuccess;

  /// No description provided for @feedbackFeedCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get feedbackFeedCancel;

  /// No description provided for @feedbackFeedEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get feedbackFeedEmptyTitle;

  /// No description provided for @feedbackFeedEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Be the first to report a bug or pitch an idea.'**
  String get feedbackFeedEmptyBody;

  /// No description provided for @feedbackFeedCompletedEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing shipped yet'**
  String get feedbackFeedCompletedEmptyTitle;

  /// No description provided for @feedbackFeedCompletedEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Once we finish a request, it lands here.'**
  String get feedbackFeedCompletedEmptyBody;

  /// No description provided for @feedbackFeedRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get feedbackFeedRetry;

  /// No description provided for @feedbackFeedErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please try again.'**
  String get feedbackFeedErrorNetwork;

  /// No description provided for @feedbackFeedErrorNotFound.
  ///
  /// In en, this message translates to:
  /// **'This feedback no longer exists.'**
  String get feedbackFeedErrorNotFound;

  /// No description provided for @feedbackFeedErrorLocked.
  ///
  /// In en, this message translates to:
  /// **'We’ve already picked this up, so it can’t be deleted anymore.'**
  String get feedbackFeedErrorLocked;

  /// No description provided for @feedbackFeedErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get feedbackFeedErrorGeneric;

  /// No description provided for @profileBadgesAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get profileBadgesAll;

  /// No description provided for @profileBadgesSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Badges'**
  String get profileBadgesSheetTitle;

  /// No description provided for @profileBadgesEmptyVisitor.
  ///
  /// In en, this message translates to:
  /// **'No badges yet.'**
  String get profileBadgesEmptyVisitor;

  /// No description provided for @garageCarStatYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get garageCarStatYear;

  /// No description provided for @profileBadgesSheetUnlocked.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No badges yet} =1{1 unlocked} other{{count} unlocked}}'**
  String profileBadgesSheetUnlocked(num count);

  /// No description provided for @createPostTitle.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get createPostTitle;

  /// No description provided for @createPostSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Photos of your build, a drive or a detail'**
  String get createPostSubtitle;

  /// No description provided for @createThreadTitle.
  ///
  /// In en, this message translates to:
  /// **'Forum thread'**
  String get createThreadTitle;

  /// No description provided for @createThreadSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ask a question or start a discussion'**
  String get createThreadSubtitle;

  /// No description provided for @createEventTitle.
  ///
  /// In en, this message translates to:
  /// **'Car event'**
  String get createEventTitle;

  /// No description provided for @createEventSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Host a meet, a cruise or a track day'**
  String get createEventSubtitle;

  /// No description provided for @createModTitle.
  ///
  /// In en, this message translates to:
  /// **'Add modification'**
  String get createModTitle;

  /// No description provided for @createModSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log a new part or upgrade on one of your cars'**
  String get createModSubtitle;

  /// No description provided for @feedSegmentFeed.
  ///
  /// In en, this message translates to:
  /// **'Feed'**
  String get feedSegmentFeed;

  /// No description provided for @forumsBrowseAction.
  ///
  /// In en, this message translates to:
  /// **'Browse forums'**
  String get forumsBrowseAction;

  /// No description provided for @forumsSavedAction.
  ///
  /// In en, this message translates to:
  /// **'Saved threads'**
  String get forumsSavedAction;

  /// No description provided for @garageCarStatPower.
  ///
  /// In en, this message translates to:
  /// **'Power'**
  String get garageCarStatPower;

  /// No description provided for @garageCarStatTorque.
  ///
  /// In en, this message translates to:
  /// **'Torque'**
  String get garageCarStatTorque;

  /// No description provided for @garageCarUnitPower.
  ///
  /// In en, this message translates to:
  /// **'hp'**
  String get garageCarUnitPower;

  /// No description provided for @garageCarUnitTorque.
  ///
  /// In en, this message translates to:
  /// **'lb-ft'**
  String get garageCarUnitTorque;

  /// No description provided for @commonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// Eyebrow above the badge name in the full-screen unlock celebration
  ///
  /// In en, this message translates to:
  /// **'New badge unlocked!'**
  String get badgeCelebrationHeadline;

  /// No description provided for @contestsTab.
  ///
  /// In en, this message translates to:
  /// **'Contests'**
  String get contestsTab;

  /// No description provided for @contestsSectionVotingOpen.
  ///
  /// In en, this message translates to:
  /// **'Voting open now'**
  String get contestsSectionVotingOpen;

  /// No description provided for @contestsSectionOpensLater.
  ///
  /// In en, this message translates to:
  /// **'Opens later'**
  String get contestsSectionOpensLater;

  /// No description provided for @contestsSectionResults.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get contestsSectionResults;

  /// No description provided for @contestsStandingEntered.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Your car is entered in 1 contest} other{Your car is entered in {count} contests}}'**
  String contestsStandingEntered(int count);

  /// No description provided for @contestsStandingNotEntered.
  ///
  /// In en, this message translates to:
  /// **'Your car isn\'t entered yet'**
  String get contestsStandingNotEntered;

  /// No description provided for @contestsVotesOpenToYou.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{You\'ve voted in every open contest} =1{1 vote still open to you} other{{count} votes still open to you}}'**
  String contestsVotesOpenToYou(int count);

  /// No description provided for @contestsManage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get contestsManage;

  /// No description provided for @contestsEnterCar.
  ///
  /// In en, this message translates to:
  /// **'Enter'**
  String get contestsEnterCar;

  /// No description provided for @contestsFooterNote.
  ///
  /// In en, this message translates to:
  /// **'One vote per contest. You can change it any time until the organizer closes voting.'**
  String get contestsFooterNote;

  /// No description provided for @contestsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No contests here'**
  String get contestsEmptyTitle;

  /// No description provided for @contestsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'The organizer hasn\'t opened any votes for this meet.'**
  String get contestsEmptyBody;

  /// No description provided for @contestsAllCount.
  ///
  /// In en, this message translates to:
  /// **'All {count} contests'**
  String contestsAllCount(int count);

  /// No description provided for @contestsCarsAndVotes.
  ///
  /// In en, this message translates to:
  /// **'{cars, plural, =1{1 car} other{{cars} cars}} · {votes, plural, =1{1 vote} other{{votes} votes}}'**
  String contestsCarsAndVotes(int cars, int votes);

  /// No description provided for @contestsCarsEnteredCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 car entered} other{{count} cars entered}}'**
  String contestsCarsEnteredCount(int count);

  /// No description provided for @contestsYoursIsIn.
  ///
  /// In en, this message translates to:
  /// **'· yours is in'**
  String get contestsYoursIsIn;

  /// No description provided for @contestsCastYourVote.
  ///
  /// In en, this message translates to:
  /// **'Cast your vote'**
  String get contestsCastYourVote;

  /// No description provided for @contestsVoteBeforeClose.
  ///
  /// In en, this message translates to:
  /// **'Vote before it closes'**
  String get contestsVoteBeforeClose;

  /// No description provided for @contestsVote.
  ///
  /// In en, this message translates to:
  /// **'Vote'**
  String get contestsVote;

  /// No description provided for @contestsVoted.
  ///
  /// In en, this message translates to:
  /// **'Voted'**
  String get contestsVoted;

  /// No description provided for @contestsYourVote.
  ///
  /// In en, this message translates to:
  /// **'Your vote'**
  String get contestsYourVote;

  /// No description provided for @contestsChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get contestsChange;

  /// No description provided for @contestsTimeLeftHours.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m left'**
  String contestsTimeLeftHours(int hours, int minutes);

  /// No description provided for @contestsTimeLeftMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m left'**
  String contestsTimeLeftMinutes(int minutes);

  /// No description provided for @contestsOpensInHours.
  ///
  /// In en, this message translates to:
  /// **'opens in {hours}h {minutes}m'**
  String contestsOpensInHours(int hours, int minutes);

  /// No description provided for @contestsOpensInMinutes.
  ///
  /// In en, this message translates to:
  /// **'opens in {minutes}m'**
  String contestsOpensInMinutes(int minutes);

  /// No description provided for @contestsOpensSoon.
  ///
  /// In en, this message translates to:
  /// **'waiting for the organizer'**
  String get contestsOpensSoon;

  /// No description provided for @contestsVotingOpenNow.
  ///
  /// In en, this message translates to:
  /// **'voting open'**
  String get contestsVotingOpenNow;

  /// No description provided for @contestsClosing.
  ///
  /// In en, this message translates to:
  /// **'closing'**
  String get contestsClosing;

  /// No description provided for @contestsResultsIn.
  ///
  /// In en, this message translates to:
  /// **'Results in'**
  String get contestsResultsIn;

  /// No description provided for @contestsClosed.
  ///
  /// In en, this message translates to:
  /// **'CLOSED'**
  String get contestsClosed;

  /// No description provided for @contestsStatVotesCast.
  ///
  /// In en, this message translates to:
  /// **'Votes cast'**
  String get contestsStatVotesCast;

  /// No description provided for @contestsStatCarsIn.
  ///
  /// In en, this message translates to:
  /// **'Cars in'**
  String get contestsStatCarsIn;

  /// No description provided for @contestsStatRemaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get contestsStatRemaining;

  /// No description provided for @contestsStatStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get contestsStatStatus;

  /// No description provided for @contestsStatVoting.
  ///
  /// In en, this message translates to:
  /// **'Voting'**
  String get contestsStatVoting;

  /// No description provided for @contestsHowItWorks.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get contestsHowItWorks;

  /// No description provided for @contestsHowItWasJudged.
  ///
  /// In en, this message translates to:
  /// **'How it was judged'**
  String get contestsHowItWasJudged;

  /// No description provided for @contestsSetBy.
  ///
  /// In en, this message translates to:
  /// **'Set by @{username}'**
  String contestsSetBy(String username);

  /// No description provided for @contestsLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get contestsLeaderboard;

  /// No description provided for @contestsCarsEntered.
  ///
  /// In en, this message translates to:
  /// **'Cars entered'**
  String get contestsCarsEntered;

  /// No description provided for @contestsFinalStandings.
  ///
  /// In en, this message translates to:
  /// **'Final standings'**
  String get contestsFinalStandings;

  /// No description provided for @contestsUpdatingLive.
  ///
  /// In en, this message translates to:
  /// **'UPDATING LIVE'**
  String get contestsUpdatingLive;

  /// No description provided for @contestsVotingOpensAt.
  ///
  /// In en, this message translates to:
  /// **'Planned to open at {time} — the organizer starts it'**
  String contestsVotingOpensAt(String time);

  /// No description provided for @contestsNoEntriesYet.
  ///
  /// In en, this message translates to:
  /// **'No cars on the ballot yet.'**
  String get contestsNoEntriesYet;

  /// No description provided for @contestsWinner.
  ///
  /// In en, this message translates to:
  /// **'WINNER'**
  String get contestsWinner;

  /// No description provided for @contestsVotesOf.
  ///
  /// In en, this message translates to:
  /// **'{votes} of {total} votes'**
  String contestsVotesOf(int votes, int total);

  /// No description provided for @contestsBadgeAwarded.
  ///
  /// In en, this message translates to:
  /// **'{category} badge awarded'**
  String contestsBadgeAwarded(String category);

  /// No description provided for @contestsBadgeAwardedBody.
  ///
  /// In en, this message translates to:
  /// **'Now on the car and the owner\'s profile'**
  String get contestsBadgeAwardedBody;

  /// No description provided for @contestsNoWinner.
  ///
  /// In en, this message translates to:
  /// **'Nobody voted, so there is no winner this time.'**
  String get contestsNoWinner;

  /// No description provided for @contestsThatsYourCar.
  ///
  /// In en, this message translates to:
  /// **'That\'s your car'**
  String get contestsThatsYourCar;

  /// No description provided for @contestsPostToFeedHint.
  ///
  /// In en, this message translates to:
  /// **'Post the card to your feed'**
  String get contestsPostToFeedHint;

  /// No description provided for @contestsShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get contestsShare;

  /// No description provided for @contestsShareYourWin.
  ///
  /// In en, this message translates to:
  /// **'Share your win'**
  String get contestsShareYourWin;

  /// No description provided for @contestsShareTheResult.
  ///
  /// In en, this message translates to:
  /// **'Share the result'**
  String get contestsShareTheResult;

  /// No description provided for @contestsShareSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Share your win'**
  String get contestsShareSheetTitle;

  /// No description provided for @contestsShareResultSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Share the result'**
  String get contestsShareResultSheetTitle;

  /// No description provided for @contestsPostToFeed.
  ///
  /// In en, this message translates to:
  /// **'Post to feed'**
  String get contestsPostToFeed;

  /// No description provided for @contestsPostedTitle.
  ///
  /// In en, this message translates to:
  /// **'Posted to the feed'**
  String get contestsPostedTitle;

  /// No description provided for @contestsPostedBody.
  ///
  /// In en, this message translates to:
  /// **'Your followers can see it now'**
  String get contestsPostedBody;

  /// No description provided for @contestsPostFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t post the card. Try again.'**
  String get contestsPostFailed;

  /// No description provided for @contestsCaptionHint.
  ///
  /// In en, this message translates to:
  /// **'Say something about the win (optional)'**
  String get contestsCaptionHint;

  /// No description provided for @contestsShareText.
  ///
  /// In en, this message translates to:
  /// **'{car} took {place} in \"{contest}\" at {event} on Tweakd'**
  String contestsShareText(
    String car,
    String place,
    String contest,
    String event,
  );

  /// No description provided for @contestsOfVotes.
  ///
  /// In en, this message translates to:
  /// **'Of {total} votes'**
  String contestsOfVotes(int total);

  /// No description provided for @contestsPickFavourite.
  ///
  /// In en, this message translates to:
  /// **'Pick your favourite'**
  String get contestsPickFavourite;

  /// No description provided for @contestsChangeYourVote.
  ///
  /// In en, this message translates to:
  /// **'Change your vote'**
  String get contestsChangeYourVote;

  /// No description provided for @contestsSaveNewVote.
  ///
  /// In en, this message translates to:
  /// **'Save new vote'**
  String get contestsSaveNewVote;

  /// No description provided for @contestsCastVote.
  ///
  /// In en, this message translates to:
  /// **'Cast vote'**
  String get contestsCastVote;

  /// No description provided for @contestsYourCar.
  ///
  /// In en, this message translates to:
  /// **'Your car'**
  String get contestsYourCar;

  /// No description provided for @contestsEnterTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your car'**
  String get contestsEnterTitle;

  /// No description provided for @contestsApprovedForMeet.
  ///
  /// In en, this message translates to:
  /// **'Approved for this meet'**
  String get contestsApprovedForMeet;

  /// No description provided for @contestsEnterHint.
  ///
  /// In en, this message translates to:
  /// **'Pick the categories you want to be judged in. The organizer approves each entry. You can pull out until voting opens.'**
  String get contestsEnterHint;

  /// No description provided for @contestsEntryLocked.
  ///
  /// In en, this message translates to:
  /// **'Voting open — entry locked in'**
  String get contestsEntryLocked;

  /// No description provided for @contestsVotingAlreadyOpen.
  ///
  /// In en, this message translates to:
  /// **'Voting already open'**
  String get contestsVotingAlreadyOpen;

  /// No description provided for @contestsEntryPending.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the organizer'**
  String get contestsEntryPending;

  /// No description provided for @contestsEntryRejected.
  ///
  /// In en, this message translates to:
  /// **'Not accepted'**
  String get contestsEntryRejected;

  /// No description provided for @contestsWhy.
  ///
  /// In en, this message translates to:
  /// **'Why'**
  String get contestsWhy;

  /// No description provided for @contestsSaveEntries.
  ///
  /// In en, this message translates to:
  /// **'Save entries'**
  String get contestsSaveEntries;

  /// No description provided for @contestsEntriesSaved.
  ///
  /// In en, this message translates to:
  /// **'Entries updated'**
  String get contestsEntriesSaved;

  /// No description provided for @contestsVoteCounted.
  ///
  /// In en, this message translates to:
  /// **'Vote counted for {car}'**
  String contestsVoteCounted(String car);

  /// No description provided for @contestsCannotVoteOwnCar.
  ///
  /// In en, this message translates to:
  /// **'You can\'t vote for your own car'**
  String get contestsCannotVoteOwnCar;

  /// No description provided for @contestsVotingClosedHint.
  ///
  /// In en, this message translates to:
  /// **'Voting has closed'**
  String get contestsVotingClosedHint;

  /// No description provided for @contestsAttendToVote.
  ///
  /// In en, this message translates to:
  /// **'RSVP as attending to vote in this contest'**
  String get contestsAttendToVote;

  /// No description provided for @contestsOrganizerTitle.
  ///
  /// In en, this message translates to:
  /// **'Contests'**
  String get contestsOrganizerTitle;

  /// No description provided for @contestsOrganizerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{event} · you\'re an organizer'**
  String contestsOrganizerSubtitle(String event);

  /// No description provided for @contestsNew.
  ///
  /// In en, this message translates to:
  /// **'NEW'**
  String get contestsNew;

  /// No description provided for @contestsStatRunning.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get contestsStatRunning;

  /// No description provided for @contestsStatScheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get contestsStatScheduled;

  /// No description provided for @contestsStatVotesTonight.
  ///
  /// In en, this message translates to:
  /// **'Votes so far'**
  String get contestsStatVotesTonight;

  /// No description provided for @contestsRunningNow.
  ///
  /// In en, this message translates to:
  /// **'Running now'**
  String get contestsRunningNow;

  /// No description provided for @contestsScheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get contestsScheduled;

  /// No description provided for @contestsFinished.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get contestsFinished;

  /// No description provided for @contestsChipOpen.
  ///
  /// In en, this message translates to:
  /// **'OPEN'**
  String get contestsChipOpen;

  /// No description provided for @contestsChipClosed.
  ///
  /// In en, this message translates to:
  /// **'CLOSED'**
  String get contestsChipClosed;

  /// No description provided for @contestsChipScheduled.
  ///
  /// In en, this message translates to:
  /// **'SCHEDULED'**
  String get contestsChipScheduled;

  /// No description provided for @contestsFullBoard.
  ///
  /// In en, this message translates to:
  /// **'Full board'**
  String get contestsFullBoard;

  /// No description provided for @contestsFinishNow.
  ///
  /// In en, this message translates to:
  /// **'Finish now'**
  String get contestsFinishNow;

  /// No description provided for @contestsEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get contestsEdit;

  /// No description provided for @contestsOpenVotingNow.
  ///
  /// In en, this message translates to:
  /// **'Open voting now'**
  String get contestsOpenVotingNow;

  /// No description provided for @contestsExtend.
  ///
  /// In en, this message translates to:
  /// **'Extend'**
  String get contestsExtend;

  /// No description provided for @contestsDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get contestsDelete;

  /// No description provided for @contestsResultsPublished.
  ///
  /// In en, this message translates to:
  /// **'Results published · badge awarded'**
  String get contestsResultsPublished;

  /// No description provided for @contestsNoVotesResult.
  ///
  /// In en, this message translates to:
  /// **'Closed with no votes'**
  String get contestsNoVotesResult;

  /// No description provided for @contestsAddAnother.
  ///
  /// In en, this message translates to:
  /// **'Add another contest'**
  String get contestsAddAnother;

  /// No description provided for @contestsAddFirst.
  ///
  /// In en, this message translates to:
  /// **'Create a contest'**
  String get contestsAddFirst;

  /// No description provided for @contestsOrganizerEmpty.
  ///
  /// In en, this message translates to:
  /// **'No contests yet. Open a vote and everyone at the meet can pick their favourite.'**
  String get contestsOrganizerEmpty;

  /// No description provided for @contestsClosedAtVotes.
  ///
  /// In en, this message translates to:
  /// **'Closed {time} · {votes, plural, =1{1 vote} other{{votes} votes}}'**
  String contestsClosedAtVotes(String time, int votes);

  /// No description provided for @contestsLeftAndVotes.
  ///
  /// In en, this message translates to:
  /// **'{left} · {votes, plural, =1{1 vote} other{{votes} votes}}'**
  String contestsLeftAndVotes(String left, int votes);

  /// No description provided for @contestsOpensAndCars.
  ///
  /// In en, this message translates to:
  /// **'{opens} · {cars, plural, =1{1 car entered} other{{cars} cars entered}}'**
  String contestsOpensAndCars(String opens, int cars);

  /// No description provided for @contestsFinishTitle.
  ///
  /// In en, this message translates to:
  /// **'Finish \"{title}\"?'**
  String contestsFinishTitle(String title);

  /// No description provided for @contestsFinishBody.
  ///
  /// In en, this message translates to:
  /// **'Voting closes immediately — {timeLeft} early. The standings freeze as they are now and the winner gets the badge.'**
  String contestsFinishBody(String timeLeft);

  /// No description provided for @contestsFinishBodyNoVotes.
  ///
  /// In en, this message translates to:
  /// **'Voting closes immediately. Nobody has voted yet, so there will be no winner.'**
  String get contestsFinishBodyNoVotes;

  /// No description provided for @contestsFinishBodyPastPlan.
  ///
  /// In en, this message translates to:
  /// **'Voting closes immediately. It has been running past the time you planned. The standings freeze as they are now and the winner gets the badge.'**
  String get contestsFinishBodyPastPlan;

  /// No description provided for @contestsWinsIfFinishNow.
  ///
  /// In en, this message translates to:
  /// **'Wins if you finish now'**
  String get contestsWinsIfFinishNow;

  /// No description provided for @contestsCloseRace.
  ///
  /// In en, this message translates to:
  /// **'{gap, plural, =1{Only 1 vote ahead of second — it could still flip.} other{Only {gap} votes ahead of second — it could still flip.}}'**
  String contestsCloseRace(int gap);

  /// No description provided for @contestsClearLead.
  ///
  /// In en, this message translates to:
  /// **'Clear lead — {gap} votes ahead of second.'**
  String contestsClearLead(int gap);

  /// No description provided for @contestsKeepOpen.
  ///
  /// In en, this message translates to:
  /// **'Keep it open'**
  String get contestsKeepOpen;

  /// No description provided for @contestsFinishPublish.
  ///
  /// In en, this message translates to:
  /// **'Finish & publish'**
  String get contestsFinishPublish;

  /// No description provided for @contestsFinishedBanner.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" finished'**
  String contestsFinishedBanner(String title);

  /// No description provided for @contestsFinishedBannerBody.
  ///
  /// In en, this message translates to:
  /// **'Results are live · everyone at the meet was notified'**
  String get contestsFinishedBannerBody;

  /// No description provided for @contestsPendingEntries.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 CAR WAITING} other{{count} CARS WAITING}}'**
  String contestsPendingEntries(int count);

  /// No description provided for @contestsAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get contestsAccept;

  /// No description provided for @contestsDecline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get contestsDecline;

  /// No description provided for @contestsDeclineEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Decline this car?'**
  String get contestsDeclineEntryTitle;

  /// No description provided for @contestsDeclineEntryHint.
  ///
  /// In en, this message translates to:
  /// **'Tell the owner why. They\'ll see this.'**
  String get contestsDeclineEntryHint;

  /// No description provided for @contestsExtendTitle.
  ///
  /// In en, this message translates to:
  /// **'Extend voting'**
  String get contestsExtendTitle;

  /// No description provided for @contestsExtendBody.
  ///
  /// In en, this message translates to:
  /// **'Pick the new closing time attendees see. It is a plan, not a deadline — voting runs until you finish the contest.'**
  String get contestsExtendBody;

  /// No description provided for @contestsExtendClosesAt.
  ///
  /// In en, this message translates to:
  /// **'Closes {time}'**
  String contestsExtendClosesAt(String time);

  /// No description provided for @contestsExtendConfirm.
  ///
  /// In en, this message translates to:
  /// **'Extend voting'**
  String get contestsExtendConfirm;

  /// No description provided for @contestsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this contest?'**
  String get contestsDeleteTitle;

  /// No description provided for @contestsDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'It hasn\'t opened yet, so nothing is lost — the cars that entered are simply released.'**
  String get contestsDeleteBody;

  /// No description provided for @contestsCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'New contest'**
  String get contestsCreateTitle;

  /// No description provided for @contestsEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit contest'**
  String get contestsEditTitle;

  /// No description provided for @contestsCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get contestsCategory;

  /// No description provided for @contestsCategoryCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get contestsCategoryCustom;

  /// No description provided for @contestsName.
  ///
  /// In en, this message translates to:
  /// **'Contest name'**
  String get contestsName;

  /// No description provided for @contestsNameHint.
  ///
  /// In en, this message translates to:
  /// **'Name shown to attendees'**
  String get contestsNameHint;

  /// No description provided for @contestsNameHintCustom.
  ///
  /// In en, this message translates to:
  /// **'e.g. Best daily driver'**
  String get contestsNameHintCustom;

  /// No description provided for @contestsCriteria.
  ///
  /// In en, this message translates to:
  /// **'How should people judge it?'**
  String get contestsCriteria;

  /// No description provided for @contestsCriteriaHint.
  ///
  /// In en, this message translates to:
  /// **'One or two lines. Attendees see this above the leaderboard.'**
  String get contestsCriteriaHint;

  /// No description provided for @contestsVotingOpens.
  ///
  /// In en, this message translates to:
  /// **'Voting opens'**
  String get contestsVotingOpens;

  /// No description provided for @contestsOpensNow.
  ///
  /// In en, this message translates to:
  /// **'Right away'**
  String get contestsOpensNow;

  /// No description provided for @contestsOpensAtStart.
  ///
  /// In en, this message translates to:
  /// **'At the start of the meet'**
  String get contestsOpensAtStart;

  /// No description provided for @contestsSetATime.
  ///
  /// In en, this message translates to:
  /// **'Set a time'**
  String get contestsSetATime;

  /// No description provided for @contestsVotingCloses.
  ///
  /// In en, this message translates to:
  /// **'Voting closes'**
  String get contestsVotingCloses;

  /// No description provided for @contestsFinishEarlyNote.
  ///
  /// In en, this message translates to:
  /// **'These times are what attendees see. You open the voting and close it yourself, from the contests list.'**
  String get contestsFinishEarlyNote;

  /// No description provided for @contestsLockedOpenNote.
  ///
  /// In en, this message translates to:
  /// **'Voting is open: only the judging note and the closing time can change now.'**
  String get contestsLockedOpenNote;

  /// No description provided for @contestsPublish.
  ///
  /// In en, this message translates to:
  /// **'Publish contest'**
  String get contestsPublish;

  /// No description provided for @contestsSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get contestsSaveChanges;

  /// No description provided for @contestsManageSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Contests'**
  String get contestsManageSectionTitle;

  /// No description provided for @contestsManageOpen.
  ///
  /// In en, this message translates to:
  /// **'Open contests'**
  String get contestsManageOpen;

  /// No description provided for @contestsManageSummary.
  ///
  /// In en, this message translates to:
  /// **'{running, plural, =0{None running} =1{1 running} other{{running} running}} · {scheduled, plural, =0{none scheduled} =1{1 scheduled} other{{scheduled} scheduled}}'**
  String contestsManageSummary(int running, int scheduled);

  /// No description provided for @contestsErrorNotEligible.
  ///
  /// In en, this message translates to:
  /// **'You can\'t vote in this contest.'**
  String get contestsErrorNotEligible;

  /// No description provided for @contestsRank1.
  ///
  /// In en, this message translates to:
  /// **'1st'**
  String get contestsRank1;

  /// No description provided for @contestsRank2.
  ///
  /// In en, this message translates to:
  /// **'2nd'**
  String get contestsRank2;

  /// No description provided for @contestsRank3.
  ///
  /// In en, this message translates to:
  /// **'3rd'**
  String get contestsRank3;

  /// No description provided for @contestsRankN.
  ///
  /// In en, this message translates to:
  /// **'{rank}th'**
  String contestsRankN(int rank);

  /// No description provided for @participantCardPlace.
  ///
  /// In en, this message translates to:
  /// **'{rank} Place'**
  String participantCardPlace(String rank);

  /// No description provided for @participantCardEvent.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get participantCardEvent;

  /// No description provided for @participantCardContests.
  ///
  /// In en, this message translates to:
  /// **'Contests entered'**
  String get participantCardContests;

  /// No description provided for @participantCardContestWithRank.
  ///
  /// In en, this message translates to:
  /// **'{contest} ({rank})'**
  String participantCardContestWithRank(String contest, String rank);

  /// No description provided for @participantCardMore.
  ///
  /// In en, this message translates to:
  /// **'+{count} more'**
  String participantCardMore(int count);

  /// No description provided for @participantCardAttendees.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nobody checked in at the event.} =1{1 person was at the event.} other{{count} people were at the event.}}'**
  String participantCardAttendees(int count);

  /// No description provided for @participantCardContestsSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Contests entered'**
  String get participantCardContestsSheetTitle;

  /// No description provided for @participantCardTookPart.
  ///
  /// In en, this message translates to:
  /// **'Took part'**
  String get participantCardTookPart;

  /// No description provided for @participantCardShareSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Share your card'**
  String get participantCardShareSheetTitle;

  /// No description provided for @participantCardShareText.
  ///
  /// In en, this message translates to:
  /// **'{car} was at {event} on Tweakd'**
  String participantCardShareText(String car, String event);

  /// No description provided for @participantCardShareTextPlaced.
  ///
  /// In en, this message translates to:
  /// **'{car} took {place} in \"{contest}\" at {event} on Tweakd'**
  String participantCardShareTextPlaced(
    String car,
    String place,
    String contest,
    String event,
  );

  /// No description provided for @participantCardShare.
  ///
  /// In en, this message translates to:
  /// **'Share the card'**
  String get participantCardShare;

  /// No description provided for @participantCardSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{YOUR CARD} other{YOUR CARDS}}'**
  String participantCardSectionTitle(int count);

  /// No description provided for @participantCardYourCard.
  ///
  /// In en, this message translates to:
  /// **'Your card'**
  String get participantCardYourCard;

  /// No description provided for @participantCardNotReady.
  ///
  /// In en, this message translates to:
  /// **'Your card will be ready once the organizer finishes the event.'**
  String get participantCardNotReady;

  /// No description provided for @participantCardCooldown.
  ///
  /// In en, this message translates to:
  /// **'You shared this card recently. You can share it again on {date}.'**
  String participantCardCooldown(String date);

  /// No description provided for @carEventsContestBadges.
  ///
  /// In en, this message translates to:
  /// **'Contest badges'**
  String get carEventsContestBadges;

  /// No description provided for @carEventsBadgesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 CONTEST BADGE} other{{count} CONTEST BADGES}}'**
  String carEventsBadgesCount(int count);

  /// No description provided for @carEventsAttended.
  ///
  /// In en, this message translates to:
  /// **'Attended events'**
  String get carEventsAttended;

  /// No description provided for @carEventsWhereFrom.
  ///
  /// In en, this message translates to:
  /// **'Where they came from'**
  String get carEventsWhereFrom;

  /// No description provided for @carEventsPlacement.
  ///
  /// In en, this message translates to:
  /// **'{rank} · {category}'**
  String carEventsPlacement(String rank, String category);

  /// No description provided for @settingsBlockedAccounts.
  ///
  /// In en, this message translates to:
  /// **'Blocked accounts'**
  String get settingsBlockedAccounts;

  /// No description provided for @blockedAccountsTitle.
  ///
  /// In en, this message translates to:
  /// **'Blocked accounts'**
  String get blockedAccountsTitle;

  /// No description provided for @blockedAccountsEmpty.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t blocked anyone.'**
  String get blockedAccountsEmpty;

  /// No description provided for @blockedAccountsEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'When you block someone, they\'ll show up here. You can unblock them anytime.'**
  String get blockedAccountsEmptyHint;

  /// No description provided for @blockedAccountsUnblock.
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get blockedAccountsUnblock;

  /// No description provided for @blockedAccountsUnblockTitle.
  ///
  /// In en, this message translates to:
  /// **'Unblock @{username}?'**
  String blockedAccountsUnblockTitle(String username);

  /// No description provided for @blockedAccountsUnblockBody.
  ///
  /// In en, this message translates to:
  /// **'They\'ll be able to find your profile, see your posts and message you again. Follows you had before won\'t come back. They won\'t be notified.'**
  String get blockedAccountsUnblockBody;

  /// No description provided for @blockedAccountsUnblocked.
  ///
  /// In en, this message translates to:
  /// **'You unblocked @{username}'**
  String blockedAccountsUnblocked(String username);

  /// No description provided for @blockedAccountsUnblockError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t unblock @{username}. Please try again.'**
  String blockedAccountsUnblockError(String username);

  /// No description provided for @blockedAccountsLoadError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load your blocked accounts. Please try again.'**
  String get blockedAccountsLoadError;

  /// No description provided for @profileBlockAccount.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get profileBlockAccount;

  /// No description provided for @profileBlockTitle.
  ///
  /// In en, this message translates to:
  /// **'Block @{username}?'**
  String profileBlockTitle(String username);

  /// No description provided for @profileBlockBody.
  ///
  /// In en, this message translates to:
  /// **'They won\'t be able to find your profile, see your posts or message you, and you\'ll stop following each other. They won\'t be notified. You can unblock them anytime in Settings.'**
  String get profileBlockBody;

  /// No description provided for @profileBlockConfirm.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get profileBlockConfirm;

  /// No description provided for @profileBlocked.
  ///
  /// In en, this message translates to:
  /// **'You blocked @{username}'**
  String profileBlocked(String username);

  /// No description provided for @blockErrorSelf.
  ///
  /// In en, this message translates to:
  /// **'You can\'t block your own account.'**
  String get blockErrorSelf;

  /// No description provided for @blockErrorNotFound.
  ///
  /// In en, this message translates to:
  /// **'This account is no longer available.'**
  String get blockErrorNotFound;

  /// No description provided for @blockErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please try again.'**
  String get blockErrorNetwork;

  /// No description provided for @blockErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get blockErrorGeneric;

  /// App-wide banner title shown when the backend rate-limits the user (HTTP 429)
  ///
  /// In en, this message translates to:
  /// **'You\'re doing that too fast'**
  String get rateLimitTitle;

  /// No description provided for @rateLimitRetryInSeconds.
  ///
  /// In en, this message translates to:
  /// **'Try again in {count, plural, =1{1 second} other{{count} seconds}}.'**
  String rateLimitRetryInSeconds(int count);

  /// No description provided for @rateLimitRetryInMinutes.
  ///
  /// In en, this message translates to:
  /// **'Try again in {count, plural, =1{1 minute} other{{count} minutes}}.'**
  String rateLimitRetryInMinutes(int count);

  /// No description provided for @rateLimitRetryInHours.
  ///
  /// In en, this message translates to:
  /// **'Try again in {count, plural, =1{1 hour} other{{count} hours}}.'**
  String rateLimitRetryInHours(int count);

  /// No description provided for @rateLimitRetrySoon.
  ///
  /// In en, this message translates to:
  /// **'Wait a moment and try again.'**
  String get rateLimitRetrySoon;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ro'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ro':
      return AppLocalizationsRo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
