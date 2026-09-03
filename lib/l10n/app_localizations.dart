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
  /// **'FORGOT PASSWORD?'**
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
  /// **'DIDN\'T GET IT? RESEND'**
  String get authResendEmail;

  /// Resend button label during its cooldown
  ///
  /// In en, this message translates to:
  /// **'RESEND IN {seconds}s'**
  String authResendIn(int seconds);

  /// No description provided for @authBackToSignIn.
  ///
  /// In en, this message translates to:
  /// **'BACK TO SIGN IN'**
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
  /// **'BACK'**
  String get onboardingBack;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'NEXT'**
  String get onboardingNext;

  /// No description provided for @onboardingFinishSetup.
  ///
  /// In en, this message translates to:
  /// **'FINISH SETUP'**
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
  /// **'01 — IDENTITY'**
  String get onboardingIdentityLabel;

  /// No description provided for @onboardingIdentityTitle.
  ///
  /// In en, this message translates to:
  /// **'Claim your handle'**
  String get onboardingIdentityTitle;

  /// No description provided for @onboardingFieldName.
  ///
  /// In en, this message translates to:
  /// **'NAME'**
  String get onboardingFieldName;

  /// No description provided for @onboardingNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get onboardingNameHint;

  /// No description provided for @onboardingFieldUsername.
  ///
  /// In en, this message translates to:
  /// **'USERNAME'**
  String get onboardingFieldUsername;

  /// No description provided for @onboardingFieldBio.
  ///
  /// In en, this message translates to:
  /// **'BIO'**
  String get onboardingFieldBio;

  /// No description provided for @onboardingBioHint.
  ///
  /// In en, this message translates to:
  /// **'Tell others a few things about yourself…'**
  String get onboardingBioHint;

  /// No description provided for @onboardingGarageLabel.
  ///
  /// In en, this message translates to:
  /// **'02 — PREFERENCES'**
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
  /// **'YOUR PICKS'**
  String get onboardingFieldYourPicks;

  /// No description provided for @onboardingFieldModels.
  ///
  /// In en, this message translates to:
  /// **'MODELS'**
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
  /// **'ADD ANOTHER BRAND'**
  String get onboardingAddBrand;

  /// No description provided for @onboardingLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'03 — LOCATION'**
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
  /// **'COUNTRY'**
  String get onboardingFieldCountry;

  /// No description provided for @onboardingFieldRegion.
  ///
  /// In en, this message translates to:
  /// **'REGION'**
  String get onboardingFieldRegion;

  /// No description provided for @onboardingFieldCity.
  ///
  /// In en, this message translates to:
  /// **'CITY'**
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
  /// **'DISCOVERY RADIUS'**
  String get onboardingDiscoveryRadius;

  /// No description provided for @onboardingNotificationsLabel.
  ///
  /// In en, this message translates to:
  /// **'04 — NOTIFICATIONS'**
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
  /// **'OPEN SETTINGS'**
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
  /// **'ENABLE'**
  String get onboardingPushEnable;

  /// No description provided for @onboardingNotifGroupContent.
  ///
  /// In en, this message translates to:
  /// **'ON YOUR CONTENT'**
  String get onboardingNotifGroupContent;

  /// No description provided for @onboardingNotifGroupMessages.
  ///
  /// In en, this message translates to:
  /// **'MESSAGES'**
  String get onboardingNotifGroupMessages;

  /// No description provided for @onboardingNotifGroupMeets.
  ///
  /// In en, this message translates to:
  /// **'MEETS & EVENTS · WITHIN {radius} KM'**
  String onboardingNotifGroupMeets(int radius);

  /// No description provided for @onboardingNotifGroupGarage.
  ///
  /// In en, this message translates to:
  /// **'YOUR GARAGE'**
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
  /// **'Shares'**
  String get onboardingNotifSharesTitle;

  /// No description provided for @onboardingNotifSharesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'When your content gets reposted'**
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
  /// **'PROFILE'**
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

  /// No description provided for @profileCreateButton.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get profileCreateButton;

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'EDIT PROFILE'**
  String get editProfileTitle;

  /// No description provided for @editProfileChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get editProfileChangePhoto;

  /// No description provided for @editProfileNameLabel.
  ///
  /// In en, this message translates to:
  /// **'NAME'**
  String get editProfileNameLabel;

  /// No description provided for @editProfileNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your display name'**
  String get editProfileNameHint;

  /// No description provided for @editProfileBioLabel.
  ///
  /// In en, this message translates to:
  /// **'BIO'**
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
  /// **'FOLLOW'**
  String get followActionFollow;

  /// No description provided for @followActionUnfollow.
  ///
  /// In en, this message translates to:
  /// **'UNFOLLOW'**
  String get followActionUnfollow;

  /// No description provided for @followActionRequested.
  ///
  /// In en, this message translates to:
  /// **'REQUESTED'**
  String get followActionRequested;

  /// No description provided for @garageAddButton.
  ///
  /// In en, this message translates to:
  /// **'+ ADD'**
  String get garageAddButton;

  /// No description provided for @garageEmptyOwner.
  ///
  /// In en, this message translates to:
  /// **'Your garage is empty. Add your first car.'**
  String get garageEmptyOwner;

  /// No description provided for @garageEmptyVisitor.
  ///
  /// In en, this message translates to:
  /// **'No cars yet.'**
  String get garageEmptyVisitor;

  /// No description provided for @followActionFollowing.
  ///
  /// In en, this message translates to:
  /// **'FOLLOWING'**
  String get followActionFollowing;

  /// No description provided for @followRemove.
  ///
  /// In en, this message translates to:
  /// **'REMOVE'**
  String get followRemove;

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
  /// **'FOR \"{query}\"'**
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
  /// **'SEARCH'**
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
  /// **'FOR \"{query}\"'**
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

  /// No description provided for @navFeed.
  ///
  /// In en, this message translates to:
  /// **'FEED'**
  String get navFeed;

  /// No description provided for @navMap.
  ///
  /// In en, this message translates to:
  /// **'MAP'**
  String get navMap;

  /// No description provided for @navSearch.
  ///
  /// In en, this message translates to:
  /// **'SEARCH'**
  String get navSearch;

  /// No description provided for @navContests.
  ///
  /// In en, this message translates to:
  /// **'CONTESTS'**
  String get navContests;

  /// No description provided for @navCreate.
  ///
  /// In en, this message translates to:
  /// **'CREATE'**
  String get navCreate;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'PROFILE'**
  String get navProfile;

  /// No description provided for @feedEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your feed is quiet'**
  String get feedEmptyTitle;

  /// No description provided for @feedEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Posts from the community will show up here. Check back soon.'**
  String get feedEmptyMessage;

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

  /// No description provided for @garageRegisterStepIdentity.
  ///
  /// In en, this message translates to:
  /// **'IDENTITY'**
  String get garageRegisterStepIdentity;

  /// No description provided for @garageRegisterStepPerformance.
  ///
  /// In en, this message translates to:
  /// **'PERFORMANCE'**
  String get garageRegisterStepPerformance;

  /// No description provided for @garageRegisterStepConfiguration.
  ///
  /// In en, this message translates to:
  /// **'CONFIGURATION'**
  String get garageRegisterStepConfiguration;

  /// No description provided for @garageRegisterStepStory.
  ///
  /// In en, this message translates to:
  /// **'STORY'**
  String get garageRegisterStepStory;

  /// No description provided for @garageRegisterStepGallery.
  ///
  /// In en, this message translates to:
  /// **'GALLERY'**
  String get garageRegisterStepGallery;

  /// No description provided for @garageRegisterStepMods.
  ///
  /// In en, this message translates to:
  /// **'MODS'**
  String get garageRegisterStepMods;

  /// No description provided for @garageRegisterStart.
  ///
  /// In en, this message translates to:
  /// **'START'**
  String get garageRegisterStart;

  /// No description provided for @garageRegisterFinish.
  ///
  /// In en, this message translates to:
  /// **'FINISH'**
  String get garageRegisterFinish;

  /// No description provided for @garageRegisterStepCounter.
  ///
  /// In en, this message translates to:
  /// **'STEP {current} / {total}'**
  String garageRegisterStepCounter(int current, int total);

  /// No description provided for @garageRegisterBack.
  ///
  /// In en, this message translates to:
  /// **'BACK'**
  String get garageRegisterBack;

  /// No description provided for @garageRegisterNext.
  ///
  /// In en, this message translates to:
  /// **'NEXT'**
  String get garageRegisterNext;

  /// No description provided for @garageRegisterWorking.
  ///
  /// In en, this message translates to:
  /// **'Working…'**
  String get garageRegisterWorking;

  /// No description provided for @garageRegisterAddCar.
  ///
  /// In en, this message translates to:
  /// **'ADD CAR'**
  String get garageRegisterAddCar;

  /// No description provided for @garageRegisterSave.
  ///
  /// In en, this message translates to:
  /// **'SAVE'**
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

  /// No description provided for @garageRegisterIdentityLabel.
  ///
  /// In en, this message translates to:
  /// **'01 — IDENTITY'**
  String get garageRegisterIdentityLabel;

  /// No description provided for @garageRegisterIdentityTitle.
  ///
  /// In en, this message translates to:
  /// **'Visual & basics'**
  String get garageRegisterIdentityTitle;

  /// No description provided for @garageFieldPrimaryAsset.
  ///
  /// In en, this message translates to:
  /// **'PRIMARY ASSET'**
  String get garageFieldPrimaryAsset;

  /// No description provided for @garageFieldMake.
  ///
  /// In en, this message translates to:
  /// **'MAKE'**
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
  /// **'MODEL'**
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
  /// **'YEAR'**
  String get garageFieldYear;

  /// No description provided for @garageFieldChassisCode.
  ///
  /// In en, this message translates to:
  /// **'CHASSIS CODE'**
  String get garageFieldChassisCode;

  /// No description provided for @garageFieldModelCode.
  ///
  /// In en, this message translates to:
  /// **'MODEL CODE'**
  String get garageFieldModelCode;

  /// No description provided for @garageHintModelCode.
  ///
  /// In en, this message translates to:
  /// **'e.g. G30'**
  String get garageHintModelCode;

  /// No description provided for @garagePrimaryAssetBadge.
  ///
  /// In en, this message translates to:
  /// **'PRIMARY · 1 / 1'**
  String get garagePrimaryAssetBadge;

  /// No description provided for @garageStudioShotReplace.
  ///
  /// In en, this message translates to:
  /// **'Studio shot · tap to replace'**
  String get garageStudioShotReplace;

  /// No description provided for @garageAddStudioShot.
  ///
  /// In en, this message translates to:
  /// **'Add the studio shot'**
  String get garageAddStudioShot;

  /// No description provided for @garagePickFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Tap to pick from your gallery'**
  String get garagePickFromGallery;

  /// No description provided for @garageRegisterPerformanceLabel.
  ///
  /// In en, this message translates to:
  /// **'02 — PERFORMANCE'**
  String get garageRegisterPerformanceLabel;

  /// No description provided for @garageRegisterPerformanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Power & weight'**
  String get garageRegisterPerformanceTitle;

  /// No description provided for @garageFieldPower.
  ///
  /// In en, this message translates to:
  /// **'POWER'**
  String get garageFieldPower;

  /// No description provided for @garageFieldTorque.
  ///
  /// In en, this message translates to:
  /// **'TORQUE'**
  String get garageFieldTorque;

  /// No description provided for @garageFieldWeight.
  ///
  /// In en, this message translates to:
  /// **'WEIGHT'**
  String get garageFieldWeight;

  /// No description provided for @garageFieldDisplacement.
  ///
  /// In en, this message translates to:
  /// **'DISPLACEMENT'**
  String get garageFieldDisplacement;

  /// No description provided for @garageFieldEngineCode.
  ///
  /// In en, this message translates to:
  /// **'ENGINE CODE'**
  String get garageFieldEngineCode;

  /// No description provided for @garageHintEngineCode.
  ///
  /// In en, this message translates to:
  /// **'e.g. S58'**
  String get garageHintEngineCode;

  /// No description provided for @garageFieldFuelType.
  ///
  /// In en, this message translates to:
  /// **'FUEL TYPE'**
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

  /// No description provided for @garagePowerToWeight.
  ///
  /// In en, this message translates to:
  /// **'POWER-TO-WEIGHT · AUTO'**
  String get garagePowerToWeight;

  /// No description provided for @garageRegisterConfigurationLabel.
  ///
  /// In en, this message translates to:
  /// **'03 — CONFIGURATION'**
  String get garageRegisterConfigurationLabel;

  /// No description provided for @garageRegisterConfigurationTitle.
  ///
  /// In en, this message translates to:
  /// **'Configuration'**
  String get garageRegisterConfigurationTitle;

  /// No description provided for @garageFieldDrivetrain.
  ///
  /// In en, this message translates to:
  /// **'DRIVETRAIN'**
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
  /// **'COLOR'**
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
  /// **'MILEAGE UNIT'**
  String get garageFieldMileageUnit;

  /// No description provided for @garageFieldMileage.
  ///
  /// In en, this message translates to:
  /// **'MILEAGE'**
  String get garageFieldMileage;

  /// No description provided for @garageHintMileage.
  ///
  /// In en, this message translates to:
  /// **'e.g. 42000'**
  String get garageHintMileage;

  /// No description provided for @garageRegisterStoryLabel.
  ///
  /// In en, this message translates to:
  /// **'04 — STORY'**
  String get garageRegisterStoryLabel;

  /// No description provided for @garageRegisterStoryTitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s this car\'s story? Share it…'**
  String get garageRegisterStoryTitle;

  /// No description provided for @garageFieldStatus.
  ///
  /// In en, this message translates to:
  /// **'STATUS'**
  String get garageFieldStatus;

  /// No description provided for @garageFieldTheStory.
  ///
  /// In en, this message translates to:
  /// **'THE STORY'**
  String get garageFieldTheStory;

  /// No description provided for @garageHintStory.
  ///
  /// In en, this message translates to:
  /// **'What\'s this car\'s story? Share it…'**
  String get garageHintStory;

  /// No description provided for @garageRegisterGalleryLabel.
  ///
  /// In en, this message translates to:
  /// **'05 — GALLERY'**
  String get garageRegisterGalleryLabel;

  /// No description provided for @garageRegisterGalleryTitle.
  ///
  /// In en, this message translates to:
  /// **'Show it off'**
  String get garageRegisterGalleryTitle;

  /// No description provided for @garageFieldPhotos.
  ///
  /// In en, this message translates to:
  /// **'PHOTOS'**
  String get garageFieldPhotos;

  /// No description provided for @garageGalleryAdd.
  ///
  /// In en, this message translates to:
  /// **'ADD'**
  String get garageGalleryAdd;

  /// No description provided for @garageGalleryHint.
  ///
  /// In en, this message translates to:
  /// **'Up to 8 photos. The cover leads your chassis card — drag to reorder.'**
  String get garageGalleryHint;

  /// No description provided for @garageGalleryCover.
  ///
  /// In en, this message translates to:
  /// **'COVER'**
  String get garageGalleryCover;

  /// No description provided for @garageRegisterModsLabel.
  ///
  /// In en, this message translates to:
  /// **'06 — MODS'**
  String get garageRegisterModsLabel;

  /// No description provided for @garageRegisterModsTitle.
  ///
  /// In en, this message translates to:
  /// **'Build log'**
  String get garageRegisterModsTitle;

  /// No description provided for @garageRegisterModsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Optional — log the work that makes it yours.'**
  String get garageRegisterModsSubtitle;

  /// No description provided for @garageModFallbackCategory.
  ///
  /// In en, this message translates to:
  /// **'MODIFICATION'**
  String get garageModFallbackCategory;

  /// No description provided for @garageAddModification.
  ///
  /// In en, this message translates to:
  /// **'ADD MODIFICATION'**
  String get garageAddModification;

  /// No description provided for @garageModSheetLabel.
  ///
  /// In en, this message translates to:
  /// **'— MODIFICATION'**
  String get garageModSheetLabel;

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
  /// **'CATEGORY'**
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
  /// **'TITLE'**
  String get garageFieldTitle;

  /// No description provided for @garageHintModTitle.
  ///
  /// In en, this message translates to:
  /// **'e.g. Stage 2 turbo'**
  String get garageHintModTitle;

  /// No description provided for @garageFieldDescription.
  ///
  /// In en, this message translates to:
  /// **'DESCRIPTION'**
  String get garageFieldDescription;

  /// No description provided for @garageHintModDescription.
  ///
  /// In en, this message translates to:
  /// **'What changed, and what it gained…'**
  String get garageHintModDescription;

  /// No description provided for @garageFieldInstallationDate.
  ///
  /// In en, this message translates to:
  /// **'INSTALLATION DATE'**
  String get garageFieldInstallationDate;

  /// No description provided for @garageSelectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get garageSelectDate;

  /// No description provided for @garageFieldPrice.
  ///
  /// In en, this message translates to:
  /// **'PRICE'**
  String get garageFieldPrice;

  /// No description provided for @garageFieldMileageShort.
  ///
  /// In en, this message translates to:
  /// **'MILEAGE'**
  String get garageFieldMileageShort;

  /// No description provided for @garageModBefore.
  ///
  /// In en, this message translates to:
  /// **'BEFORE'**
  String get garageModBefore;

  /// No description provided for @garageModAfter.
  ///
  /// In en, this message translates to:
  /// **'AFTER'**
  String get garageModAfter;

  /// No description provided for @garageModSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'SAVE CHANGES'**
  String get garageModSaveChanges;

  /// No description provided for @garageModAddToBuildLog.
  ///
  /// In en, this message translates to:
  /// **'ADD TO BUILD LOG'**
  String get garageModAddToBuildLog;

  /// No description provided for @garageModValidationEdit.
  ///
  /// In en, this message translates to:
  /// **'Category, title and date are required.'**
  String get garageModValidationEdit;

  /// No description provided for @garageModValidationAdd.
  ///
  /// In en, this message translates to:
  /// **'Category, title, date and both images are required.'**
  String get garageModValidationAdd;

  /// No description provided for @garageAboutTitle.
  ///
  /// In en, this message translates to:
  /// **'ABOUT'**
  String get garageAboutTitle;

  /// No description provided for @garageBuildIdentifier.
  ///
  /// In en, this message translates to:
  /// **'BUILD IDENTIFIER · {code}'**
  String garageBuildIdentifier(String code);

  /// No description provided for @garageSpecPower.
  ///
  /// In en, this message translates to:
  /// **'POWER'**
  String get garageSpecPower;

  /// No description provided for @garageSpecTorque.
  ///
  /// In en, this message translates to:
  /// **'TORQUE'**
  String get garageSpecTorque;

  /// No description provided for @garageSpecWeight.
  ///
  /// In en, this message translates to:
  /// **'WEIGHT'**
  String get garageSpecWeight;

  /// No description provided for @garageInfoDrivetrain.
  ///
  /// In en, this message translates to:
  /// **'DRIVETRAIN'**
  String get garageInfoDrivetrain;

  /// No description provided for @garageInfoMileage.
  ///
  /// In en, this message translates to:
  /// **'MILEAGE'**
  String get garageInfoMileage;

  /// No description provided for @garageInfoModelCode.
  ///
  /// In en, this message translates to:
  /// **'MODEL CODE'**
  String get garageInfoModelCode;

  /// No description provided for @garageInfoEngineCode.
  ///
  /// In en, this message translates to:
  /// **'ENGINE CODE'**
  String get garageInfoEngineCode;

  /// No description provided for @garageInfoDisplacement.
  ///
  /// In en, this message translates to:
  /// **'DISPLACEMENT'**
  String get garageInfoDisplacement;

  /// No description provided for @garageInfoFuelType.
  ///
  /// In en, this message translates to:
  /// **'FUEL TYPE'**
  String get garageInfoFuelType;

  /// No description provided for @garageInfoStatus.
  ///
  /// In en, this message translates to:
  /// **'STATUS'**
  String get garageInfoStatus;

  /// No description provided for @garageStoryHeading.
  ///
  /// In en, this message translates to:
  /// **'THE STORY'**
  String get garageStoryHeading;

  /// No description provided for @garageGalleryHeading.
  ///
  /// In en, this message translates to:
  /// **'GALLERY'**
  String get garageGalleryHeading;

  /// No description provided for @garageLogBuildIteration.
  ///
  /// In en, this message translates to:
  /// **'+ LOG BUILD ITERATION'**
  String get garageLogBuildIteration;

  /// No description provided for @garageModLogHeading.
  ///
  /// In en, this message translates to:
  /// **'MODIFICATION LOG'**
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

  /// No description provided for @garageDiscardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard this build?'**
  String get garageDiscardTitle;

  /// No description provided for @garageDiscardBody.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t registered this car yet. If you leave now, everything you entered will be lost.'**
  String get garageDiscardBody;

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

  /// No description provided for @garageLogModTitle.
  ///
  /// In en, this message translates to:
  /// **'LOG BUILD ITERATION'**
  String get garageLogModTitle;

  /// No description provided for @garageLogModSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'— MODIFICATION'**
  String get garageLogModSectionLabel;

  /// No description provided for @garageLogModSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Log a build iteration'**
  String get garageLogModSectionTitle;

  /// No description provided for @garageLogModCategoryHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Engine, Suspension, Aesthetics'**
  String get garageLogModCategoryHint;

  /// No description provided for @garageLogModTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Stage 2 turbo upgrade'**
  String get garageLogModTitleHint;

  /// No description provided for @garageLogModDescLabel.
  ///
  /// In en, this message translates to:
  /// **'DESCRIPTION (OPTIONAL)'**
  String get garageLogModDescLabel;

  /// No description provided for @garageLogModDescHint.
  ///
  /// In en, this message translates to:
  /// **'Notes, observations, upgrades done…'**
  String get garageLogModDescHint;

  /// No description provided for @garageLogModBeforeAfter.
  ///
  /// In en, this message translates to:
  /// **'BEFORE & AFTER'**
  String get garageLogModBeforeAfter;

  /// No description provided for @garageLogModInstallDate.
  ///
  /// In en, this message translates to:
  /// **'INSTALLATION DATE'**
  String get garageLogModInstallDate;

  /// No description provided for @garageLogModPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'PRICE (OPTIONAL)'**
  String get garageLogModPriceLabel;

  /// No description provided for @garageLogModMileageLabel.
  ///
  /// In en, this message translates to:
  /// **'MILEAGE AT INSTALL (OPTIONAL)'**
  String get garageLogModMileageLabel;

  /// No description provided for @garageLogModMileageHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 45000'**
  String get garageLogModMileageHint;

  /// No description provided for @garageLogModSubmit.
  ///
  /// In en, this message translates to:
  /// **'LOG MODIFICATION'**
  String get garageLogModSubmit;

  /// No description provided for @garageLogModLogged.
  ///
  /// In en, this message translates to:
  /// **'Modification logged!'**
  String get garageLogModLogged;

  /// No description provided for @garageLogModValCategory.
  ///
  /// In en, this message translates to:
  /// **'Please select a category.'**
  String get garageLogModValCategory;

  /// No description provided for @garageLogModValTitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter a title.'**
  String get garageLogModValTitle;

  /// No description provided for @garageLogModValBefore.
  ///
  /// In en, this message translates to:
  /// **'Please pick a before image.'**
  String get garageLogModValBefore;

  /// No description provided for @garageLogModValAfter.
  ///
  /// In en, this message translates to:
  /// **'Please pick an after image.'**
  String get garageLogModValAfter;

  /// No description provided for @garageLogModValDate.
  ///
  /// In en, this message translates to:
  /// **'Please select the installation date.'**
  String get garageLogModValDate;

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
  /// **'SETTINGS'**
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

  /// No description provided for @postNewPost.
  ///
  /// In en, this message translates to:
  /// **'NEW POST'**
  String get postNewPost;

  /// No description provided for @postStepPhotos.
  ///
  /// In en, this message translates to:
  /// **'PHOTOS'**
  String get postStepPhotos;

  /// No description provided for @postStepCaption.
  ///
  /// In en, this message translates to:
  /// **'CAPTION'**
  String get postStepCaption;

  /// No description provided for @postStepTags.
  ///
  /// In en, this message translates to:
  /// **'TAGS'**
  String get postStepTags;

  /// No description provided for @postStepVisibility.
  ///
  /// In en, this message translates to:
  /// **'VISIBILITY'**
  String get postStepVisibility;

  /// No description provided for @postStepReview.
  ///
  /// In en, this message translates to:
  /// **'REVIEW'**
  String get postStepReview;

  /// No description provided for @postStart.
  ///
  /// In en, this message translates to:
  /// **'START'**
  String get postStart;

  /// No description provided for @postPublishStep.
  ///
  /// In en, this message translates to:
  /// **'PUBLISH'**
  String get postPublishStep;

  /// No description provided for @postBack.
  ///
  /// In en, this message translates to:
  /// **'BACK'**
  String get postBack;

  /// No description provided for @postNext.
  ///
  /// In en, this message translates to:
  /// **'NEXT'**
  String get postNext;

  /// No description provided for @postPublish.
  ///
  /// In en, this message translates to:
  /// **'PUBLISH POST'**
  String get postPublish;

  /// No description provided for @postStepCounter.
  ///
  /// In en, this message translates to:
  /// **'STEP {current} / {total}'**
  String postStepCounter(int current, int total);

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
  /// **'ADD'**
  String get postPhotosAdd;

  /// No description provided for @postPhotosCover.
  ///
  /// In en, this message translates to:
  /// **'COVER'**
  String get postPhotosCover;

  /// No description provided for @postPhotosVideosSoon.
  ///
  /// In en, this message translates to:
  /// **'VIDEOS — COMING SOON'**
  String get postPhotosVideosSoon;

  /// No description provided for @postPhotosCount.
  ///
  /// In en, this message translates to:
  /// **'{count} / {max} PHOTOS'**
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
  /// **'DESCRIPTION'**
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
  /// **'CARS'**
  String get postTagsCars;

  /// No description provided for @postTagsPeople.
  ///
  /// In en, this message translates to:
  /// **'PEOPLE'**
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
  /// **'Hide a counter and others won\'t see that number — they can still like, comment and share.'**
  String get postVisibilitySubtitle;

  /// No description provided for @postVisibilityLabel.
  ///
  /// In en, this message translates to:
  /// **'VISIBLE COUNTS'**
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
  /// **'Show share count'**
  String get postVisibilitySharesTitle;

  /// No description provided for @postVisibilitySharesDesc.
  ///
  /// In en, this message translates to:
  /// **'Others can see how many times it was shared'**
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
  /// **'JUST NOW'**
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

  /// No description provided for @postsLoadMore.
  ///
  /// In en, this message translates to:
  /// **'LOAD MORE'**
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
  /// **'CREATE YOUR FIRST POST'**
  String get postsCreateFirst;

  /// No description provided for @savedPostsTitle.
  ///
  /// In en, this message translates to:
  /// **'SAVED POSTS'**
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
  /// **'POST'**
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
  /// **'EDIT POST'**
  String get postEditTitle;

  /// No description provided for @postEditSave.
  ///
  /// In en, this message translates to:
  /// **'SAVE'**
  String get postEditSave;

  /// No description provided for @postShareTitle.
  ///
  /// In en, this message translates to:
  /// **'SHARE POST'**
  String get postShareTitle;

  /// No description provided for @postShareSend.
  ///
  /// In en, this message translates to:
  /// **'SHARE'**
  String get postShareSend;

  /// No description provided for @postShareNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Add a note'**
  String get postShareNoteLabel;

  /// No description provided for @postShareNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Say something about this post… (optional)'**
  String get postShareNoteHint;

  /// No description provided for @postSharePreviewNoCaption.
  ///
  /// In en, this message translates to:
  /// **'No caption'**
  String get postSharePreviewNoCaption;

  /// No description provided for @postShareSuccess.
  ///
  /// In en, this message translates to:
  /// **'Post shared.'**
  String get postShareSuccess;

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
  /// **'MY REPORTS'**
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
  /// **'FEEDBACK'**
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
  /// **'FEEDBACK TYPE'**
  String get feedbackTypeLabel;

  /// No description provided for @feedbackTypeHint.
  ///
  /// In en, this message translates to:
  /// **'Select a type'**
  String get feedbackTypeHint;

  /// No description provided for @feedbackFeatureLabel.
  ///
  /// In en, this message translates to:
  /// **'RELATED TO AN EXISTING FEATURE?'**
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
  /// **'YOUR FEEDBACK'**
  String get feedbackContentLabel;

  /// No description provided for @feedbackContentLabelBug.
  ///
  /// In en, this message translates to:
  /// **'WHAT HAPPENED'**
  String get feedbackContentLabelBug;

  /// No description provided for @feedbackContentHint.
  ///
  /// In en, this message translates to:
  /// **'Share your thoughts…'**
  String get feedbackContentHint;

  /// No description provided for @feedbackReproductionLabel.
  ///
  /// In en, this message translates to:
  /// **'REPRODUCTION STEPS'**
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
  /// **'MY FEEDBACK'**
  String get myFeedbackTitle;

  /// No description provided for @myFeedbackEmpty.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t sent any feedback yet.'**
  String get myFeedbackEmpty;

  /// No description provided for @myFeedbackResponseLabel.
  ///
  /// In en, this message translates to:
  /// **'RESPONSE'**
  String get myFeedbackResponseLabel;

  /// No description provided for @navForums.
  ///
  /// In en, this message translates to:
  /// **'FORUMS'**
  String get navForums;

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
  /// **'YOUR SHORTCUTS'**
  String get forumsYourShortcuts;

  /// No description provided for @forumsEditShortcuts.
  ///
  /// In en, this message translates to:
  /// **'EDIT'**
  String get forumsEditShortcuts;

  /// No description provided for @forumsDoneEditing.
  ///
  /// In en, this message translates to:
  /// **'DONE'**
  String get forumsDoneEditing;

  /// No description provided for @forumsHotInYourForums.
  ///
  /// In en, this message translates to:
  /// **'HOT IN YOUR FORUMS'**
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
  /// **'Pin the forums you live in'**
  String get forumsEmptyTitle;

  /// No description provided for @forumsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Shortcuts are saved filters — a car, a topic, or both. Pin a few and they land right here.'**
  String get forumsEmptyBody;

  /// No description provided for @forumsPopularHubs.
  ///
  /// In en, this message translates to:
  /// **'POPULAR HUBS TO START WITH'**
  String get forumsPopularHubs;

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
  /// **'BROWSE'**
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
  /// **'MODELS'**
  String get forumsModels;

  /// No description provided for @forumsRefineByTopic.
  ///
  /// In en, this message translates to:
  /// **'REFINE BY TOPIC'**
  String get forumsRefineByTopic;

  /// No description provided for @forumsHotIn.
  ///
  /// In en, this message translates to:
  /// **'HOT IN {name}'**
  String forumsHotIn(String name);

  /// No description provided for @forumsThreadsLabel.
  ///
  /// In en, this message translates to:
  /// **'THREADS'**
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
  /// **'NAME'**
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
  /// **'THREAD'**
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
  /// **'NEW THREAD'**
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
  /// **'BRAND · REQUIRED'**
  String get forumsBrandRequiredLabel;

  /// No description provided for @forumsModelOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'MODEL · OPTIONAL'**
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
  /// **'TOPICS'**
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
  /// **'SAVED'**
  String get forumsSavedTitle;

  /// No description provided for @forumsSavedHeader.
  ///
  /// In en, this message translates to:
  /// **'SAVED THREADS'**
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
  /// **'TAG PEOPLE & CARS'**
  String get forumsTagPeopleAndCars;

  /// No description provided for @forumsTagPeople.
  ///
  /// In en, this message translates to:
  /// **'PEOPLE'**
  String get forumsTagPeople;

  /// No description provided for @forumsTagCars.
  ///
  /// In en, this message translates to:
  /// **'CARS'**
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
  /// **'TAGS'**
  String get forumsTagsSectionLabel;

  /// No description provided for @messagesTitle.
  ///
  /// In en, this message translates to:
  /// **'MESSAGES'**
  String get messagesTitle;

  /// No description provided for @messagesSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search messages'**
  String get messagesSearchHint;

  /// No description provided for @messagesActiveNow.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE NOW'**
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
  /// **'NEW MESSAGE'**
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
  /// **'NOTIFICATIONS'**
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
  /// **'TAGGED IN A POST'**
  String get tagsKindPost;

  /// No description provided for @tagsKindComment.
  ///
  /// In en, this message translates to:
  /// **'TAGGED IN A COMMENT'**
  String get tagsKindComment;

  /// No description provided for @tagsKindThread.
  ///
  /// In en, this message translates to:
  /// **'TAGGED IN A THREAD'**
  String get tagsKindThread;

  /// No description provided for @tagsKindReply.
  ///
  /// In en, this message translates to:
  /// **'TAGGED IN A REPLY'**
  String get tagsKindReply;

  /// No description provided for @tagsOnPostBy.
  ///
  /// In en, this message translates to:
  /// **'on @{author}\'s post'**
  String tagsOnPostBy(String author);

  /// No description provided for @tagsLoadMore.
  ///
  /// In en, this message translates to:
  /// **'LOAD MORE'**
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
  /// **'OPENING HOURS'**
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
  /// **'TRY AGAIN'**
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
  /// **'INSTALL'**
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
  /// **'ATTENDEES'**
  String get mapEventsStatAttendees;

  /// No description provided for @mapEventsStatCars.
  ///
  /// In en, this message translates to:
  /// **'CARS'**
  String get mapEventsStatCars;

  /// No description provided for @mapEventsStatStarts.
  ///
  /// In en, this message translates to:
  /// **'STARTS'**
  String get mapEventsStatStarts;

  /// No description provided for @mapEventsStatStarted.
  ///
  /// In en, this message translates to:
  /// **'STARTED'**
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
  /// **'ATTENDING'**
  String get mapEventsAttending;

  /// No description provided for @mapEventsInterested.
  ///
  /// In en, this message translates to:
  /// **'INTERESTED'**
  String get mapEventsInterested;

  /// No description provided for @mapEventsWantToParticipate.
  ///
  /// In en, this message translates to:
  /// **'WANT TO PARTICIPATE?'**
  String get mapEventsWantToParticipate;

  /// No description provided for @mapEventsParticipateShort.
  ///
  /// In en, this message translates to:
  /// **'PARTICIPATE?'**
  String get mapEventsParticipateShort;

  /// No description provided for @mapEventsParticipating.
  ///
  /// In en, this message translates to:
  /// **'PARTICIPATING'**
  String get mapEventsParticipating;

  /// No description provided for @mapEventsParticipatingCount.
  ///
  /// In en, this message translates to:
  /// **'PARTICIPATING · {count} CARS'**
  String mapEventsParticipatingCount(int count);

  /// No description provided for @mapEventsParticipationPending.
  ///
  /// In en, this message translates to:
  /// **'PENDING'**
  String get mapEventsParticipationPending;

  /// No description provided for @mapEventsWithdrawAction.
  ///
  /// In en, this message translates to:
  /// **'WITHDRAW'**
  String get mapEventsWithdrawAction;

  /// No description provided for @mapEventsViewEvent.
  ///
  /// In en, this message translates to:
  /// **'VIEW EVENT'**
  String get mapEventsViewEvent;

  /// No description provided for @mapEventsCapacityOf.
  ///
  /// In en, this message translates to:
  /// **'of {capacity}'**
  String mapEventsCapacityOf(int capacity);

  /// No description provided for @mapEventsTabOverview.
  ///
  /// In en, this message translates to:
  /// **'OVERVIEW'**
  String get mapEventsTabOverview;

  /// No description provided for @mapEventsTabCars.
  ///
  /// In en, this message translates to:
  /// **'CARS · {count}'**
  String mapEventsTabCars(int count);

  /// No description provided for @mapEventsEntryListTitle.
  ///
  /// In en, this message translates to:
  /// **'On the entry list'**
  String get mapEventsEntryListTitle;

  /// No description provided for @mapEventsApprovedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} APPROVED'**
  String mapEventsApprovedCount(int count);

  /// No description provided for @mapEventsSectionAbout.
  ///
  /// In en, this message translates to:
  /// **'ABOUT THIS EVENT'**
  String get mapEventsSectionAbout;

  /// No description provided for @mapEventsSectionOrganizers.
  ///
  /// In en, this message translates to:
  /// **'ORGANIZERS'**
  String get mapEventsSectionOrganizers;

  /// No description provided for @mapEventsSectionRules.
  ///
  /// In en, this message translates to:
  /// **'NOTES FROM THE ORGANIZER'**
  String get mapEventsSectionRules;

  /// No description provided for @mapEventsSectionContests.
  ///
  /// In en, this message translates to:
  /// **'CONTESTS'**
  String get mapEventsSectionContests;

  /// No description provided for @mapEventsSectionAttendees.
  ///
  /// In en, this message translates to:
  /// **'ATTENDEES'**
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
  /// **'SEE ALL'**
  String get mapEventsSeeAll;

  /// No description provided for @mapEventsSeeAllAttendees.
  ///
  /// In en, this message translates to:
  /// **'SEE ALL ATTENDEES'**
  String get mapEventsSeeAllAttendees;

  /// No description provided for @mapEventsSeeAllCars.
  ///
  /// In en, this message translates to:
  /// **'SEE ALL {count} CARS'**
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
  /// **'GARAGE'**
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
  /// **'TRY AGAIN'**
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
  /// **'WHY'**
  String get mapEventsDeclineReasonHeading;

  /// No description provided for @mapEventsTryAnotherCar.
  ///
  /// In en, this message translates to:
  /// **'TRY ANOTHER CAR'**
  String get mapEventsTryAnotherCar;

  /// No description provided for @mapEventsCancelRequest.
  ///
  /// In en, this message translates to:
  /// **'CANCEL REQUEST'**
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
  /// **'SELECT ALL'**
  String get mapEventsPickCarSelectAll;

  /// No description provided for @mapEventsPickCarClearAll.
  ///
  /// In en, this message translates to:
  /// **'CLEAR'**
  String get mapEventsPickCarClearAll;

  /// No description provided for @mapEventsPickCarRegisterCta.
  ///
  /// In en, this message translates to:
  /// **'REGISTER ({count})'**
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
  /// **'ADD A CAR'**
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
  /// **'NOTE FOR ORGANIZERS (OPTIONAL)'**
  String get mapEventsWithdrawNoteLabel;

  /// No description provided for @mapEventsWithdrawNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Let them know why, if you\'d like…'**
  String get mapEventsWithdrawNoteHint;

  /// No description provided for @mapEventsCancel.
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get mapEventsCancel;

  /// No description provided for @mapEventsAttendeesPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Attendees'**
  String get mapEventsAttendeesPageTitle;

  /// No description provided for @mapEventsFilterAttending.
  ///
  /// In en, this message translates to:
  /// **'ATTENDING'**
  String get mapEventsFilterAttending;

  /// No description provided for @mapEventsFilterInterested.
  ///
  /// In en, this message translates to:
  /// **'INTERESTED'**
  String get mapEventsFilterInterested;

  /// No description provided for @mapEventsCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'NEW EVENT'**
  String get mapEventsCreateTitle;

  /// No description provided for @mapEventsEditTitle.
  ///
  /// In en, this message translates to:
  /// **'EDIT EVENT'**
  String get mapEventsEditTitle;

  /// No description provided for @mapEventsCoverAdd.
  ///
  /// In en, this message translates to:
  /// **'ADD COVER PHOTO'**
  String get mapEventsCoverAdd;

  /// No description provided for @mapEventsCoverHint.
  ///
  /// In en, this message translates to:
  /// **'1600 × 900 recommended'**
  String get mapEventsCoverHint;

  /// No description provided for @mapEventsCoverChange.
  ///
  /// In en, this message translates to:
  /// **'CHANGE COVER'**
  String get mapEventsCoverChange;

  /// No description provided for @mapEventsFieldCover.
  ///
  /// In en, this message translates to:
  /// **'COVER PHOTO'**
  String get mapEventsFieldCover;

  /// No description provided for @mapEventsFieldTitle.
  ///
  /// In en, this message translates to:
  /// **'EVENT TITLE'**
  String get mapEventsFieldTitle;

  /// No description provided for @mapEventsFieldTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Casino Square Cars & Coffee'**
  String get mapEventsFieldTitleHint;

  /// No description provided for @mapEventsFieldCategory.
  ///
  /// In en, this message translates to:
  /// **'EVENT CATEGORY'**
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

  /// No description provided for @mapEventsCategoryCarShow.
  ///
  /// In en, this message translates to:
  /// **'Car Show'**
  String get mapEventsCategoryCarShow;

  /// No description provided for @mapEventsCategoryCruise.
  ///
  /// In en, this message translates to:
  /// **'Cruise'**
  String get mapEventsCategoryCruise;

  /// No description provided for @mapEventsFieldDescription.
  ///
  /// In en, this message translates to:
  /// **'DESCRIPTION'**
  String get mapEventsFieldDescription;

  /// No description provided for @mapEventsFieldDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'What\'s the event about, who\'s it for, anything people should know before showing up…'**
  String get mapEventsFieldDescriptionHint;

  /// No description provided for @mapEventsFieldLocation.
  ///
  /// In en, this message translates to:
  /// **'LOCATION'**
  String get mapEventsFieldLocation;

  /// No description provided for @mapEventsFieldVenueHint.
  ///
  /// In en, this message translates to:
  /// **'Venue name — e.g. Place du Casino'**
  String get mapEventsFieldVenueHint;

  /// No description provided for @mapEventsSetLocationOnMap.
  ///
  /// In en, this message translates to:
  /// **'SET LOCATION ON MAP'**
  String get mapEventsSetLocationOnMap;

  /// No description provided for @mapEventsLocationSet.
  ///
  /// In en, this message translates to:
  /// **'PIN PLACED · TAP TO MOVE'**
  String get mapEventsLocationSet;

  /// No description provided for @mapEventsFieldDateTime.
  ///
  /// In en, this message translates to:
  /// **'DATE & TIME'**
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
  /// **'CLEAR END'**
  String get mapEventsClearEnd;

  /// No description provided for @mapEventsFieldCapacity.
  ///
  /// In en, this message translates to:
  /// **'MAX CAPACITY'**
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
  /// **'No limit — e.g. 40 spots'**
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
  /// **'REGISTRATION DEADLINE'**
  String get mapEventsFieldDeadline;

  /// No description provided for @mapEventsFieldRules.
  ///
  /// In en, this message translates to:
  /// **'RULES & GUIDELINES'**
  String get mapEventsFieldRules;

  /// No description provided for @mapEventsAddRule.
  ///
  /// In en, this message translates to:
  /// **'ADD A RULE'**
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
  /// **'ORGANIZERS'**
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
  /// **'ADD ORGANIZER'**
  String get mapEventsAddOrganizer;

  /// No description provided for @mapEventsRemoveOrganizer.
  ///
  /// In en, this message translates to:
  /// **'Remove organizer'**
  String get mapEventsRemoveOrganizer;

  /// No description provided for @mapEventsCreateCta.
  ///
  /// In en, this message translates to:
  /// **'CREATE EVENT'**
  String get mapEventsCreateCta;

  /// No description provided for @mapEventsCreateCtaIncomplete.
  ///
  /// In en, this message translates to:
  /// **'ADD TITLE, LOCATION & START TIME'**
  String get mapEventsCreateCtaIncomplete;

  /// No description provided for @mapEventsCreateCtaDeadline.
  ///
  /// In en, this message translates to:
  /// **'ADD A REGISTRATION DEADLINE'**
  String get mapEventsCreateCtaDeadline;

  /// No description provided for @mapEventsCreateCtaCover.
  ///
  /// In en, this message translates to:
  /// **'ADD A COVER IMAGE'**
  String get mapEventsCreateCtaCover;

  /// No description provided for @mapEventsSaveCta.
  ///
  /// In en, this message translates to:
  /// **'SAVE CHANGES'**
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
  /// **'DONE'**
  String get mapEventsDone;

  /// No description provided for @mapEventsCoverUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'The event was created, but the cover photo didn\'t upload. You can add it from My events.'**
  String get mapEventsCoverUploadFailed;

  /// No description provided for @mapEventsUseThisLocation.
  ///
  /// In en, this message translates to:
  /// **'USE THIS LOCATION'**
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
  /// **'CITY'**
  String get mapEventsLocationCity;

  /// No description provided for @mapEventsLocationCityHint.
  ///
  /// In en, this message translates to:
  /// **'Cluj-Napoca'**
  String get mapEventsLocationCityHint;

  /// No description provided for @mapEventsLocationStreet.
  ///
  /// In en, this message translates to:
  /// **'STREET'**
  String get mapEventsLocationStreet;

  /// No description provided for @mapEventsLocationStreetHint.
  ///
  /// In en, this message translates to:
  /// **'Strada Memorandumului'**
  String get mapEventsLocationStreetHint;

  /// No description provided for @mapEventsLocationNumber.
  ///
  /// In en, this message translates to:
  /// **'NUMBER'**
  String get mapEventsLocationNumber;

  /// No description provided for @mapEventsLocationNumberHint.
  ///
  /// In en, this message translates to:
  /// **'28B'**
  String get mapEventsLocationNumberHint;

  /// No description provided for @mapEventsLocationSearchButton.
  ///
  /// In en, this message translates to:
  /// **'SEARCH'**
  String get mapEventsLocationSearchButton;

  /// No description provided for @mapEventsLocationSearchIncomplete.
  ///
  /// In en, this message translates to:
  /// **'FILL IN ALL THREE FIELDS'**
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
  /// **'EDIT SEARCH'**
  String get mapEventsLocationEditSearch;

  /// No description provided for @mapEventsLocationBackToResults.
  ///
  /// In en, this message translates to:
  /// **'RESULTS'**
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
  /// **'CREATE AN EVENT'**
  String get mapEventsMineCreate;

  /// No description provided for @mapEventsManageTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage event'**
  String get mapEventsManageTitle;

  /// No description provided for @mapEventsManageEntries.
  ///
  /// In en, this message translates to:
  /// **'ENTRY REQUESTS'**
  String get mapEventsManageEntries;

  /// No description provided for @mapEventsManageWithdrawals.
  ///
  /// In en, this message translates to:
  /// **'WITHDRAWAL REQUESTS'**
  String get mapEventsManageWithdrawals;

  /// No description provided for @mapEventsManageOrganizers.
  ///
  /// In en, this message translates to:
  /// **'ORGANIZERS'**
  String get mapEventsManageOrganizers;

  /// No description provided for @mapEventsManageDanger.
  ///
  /// In en, this message translates to:
  /// **'EVENT'**
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
  /// **'ACCEPT'**
  String get mapEventsAccept;

  /// No description provided for @mapEventsDecline.
  ///
  /// In en, this message translates to:
  /// **'DECLINE'**
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
  /// **'REASON (REQUIRED)'**
  String get mapEventsDeclineReasonLabel;

  /// No description provided for @mapEventsDeclineReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Wrong category for a JDM-only meet…'**
  String get mapEventsDeclineReasonHint;

  /// No description provided for @mapEventsLetThemOut.
  ///
  /// In en, this message translates to:
  /// **'LET THEM OUT'**
  String get mapEventsLetThemOut;

  /// No description provided for @mapEventsKeepThemIn.
  ///
  /// In en, this message translates to:
  /// **'KEEP THEM IN'**
  String get mapEventsKeepThemIn;

  /// No description provided for @mapEventsWithdrawalNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Their note'**
  String get mapEventsWithdrawalNoteLabel;

  /// No description provided for @mapEventsEditEvent.
  ///
  /// In en, this message translates to:
  /// **'EDIT EVENT'**
  String get mapEventsEditEvent;

  /// No description provided for @mapEventsCancelEvent.
  ///
  /// In en, this message translates to:
  /// **'CANCEL EVENT'**
  String get mapEventsCancelEvent;

  /// No description provided for @mapEventsFinishEvent.
  ///
  /// In en, this message translates to:
  /// **'FINISH EVENT'**
  String get mapEventsFinishEvent;

  /// No description provided for @mapEventsDeleteEvent.
  ///
  /// In en, this message translates to:
  /// **'DELETE EVENT'**
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
  /// **'CONFIRM'**
  String get mapEventsConfirm;

  /// No description provided for @mapEventsDelete.
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
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
  /// **'COMMUNITY'**
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
  /// **'NEWEST'**
  String get feedbackFeedSortNewest;

  /// No description provided for @feedbackFeedSortPopular.
  ///
  /// In en, this message translates to:
  /// **'POPULAR'**
  String get feedbackFeedSortPopular;

  /// No description provided for @feedbackFeedSortOldest.
  ///
  /// In en, this message translates to:
  /// **'OLDEST'**
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
  /// **'FEEDBACK COMMUNITY'**
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
  /// **'CATEGORY'**
  String get feedbackFeedCategoryLabel;

  /// No description provided for @feedbackFeedMessageLabel.
  ///
  /// In en, this message translates to:
  /// **'YOUR MESSAGE'**
  String get feedbackFeedMessageLabel;

  /// No description provided for @feedbackFeedMessageHint.
  ///
  /// In en, this message translates to:
  /// **'What’s on your mind — a bug, an idea, a tweak?'**
  String get feedbackFeedMessageHint;

  /// No description provided for @feedbackFeedPostAction.
  ///
  /// In en, this message translates to:
  /// **'POST FEEDBACK'**
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
  /// **'ALL'**
  String get profileBadgesAll;

  /// No description provided for @profileBadgesSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Badges'**
  String get profileBadgesSheetTitle;

  /// Sub-header of the all-badges sheet, e.g. "5 of 9 unlocked"
  ///
  /// In en, this message translates to:
  /// **'{earned} of {total} unlocked'**
  String profileBadgesSheetSubtitle(int earned, int total);

  /// No description provided for @profileBadgesLocked.
  ///
  /// In en, this message translates to:
  /// **'LOCKED'**
  String get profileBadgesLocked;

  /// No description provided for @profileBadgesEmptyOwner.
  ///
  /// In en, this message translates to:
  /// **'No badges yet. Join meets, enter contests and help out on the forums to start collecting.'**
  String get profileBadgesEmptyOwner;

  /// No description provided for @profileBadgesEmptyVisitor.
  ///
  /// In en, this message translates to:
  /// **'No badges yet.'**
  String get profileBadgesEmptyVisitor;

  /// No description provided for @profileBadgesLoadError.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t load the badges. Please try again.'**
  String get profileBadgesLoadError;

  /// No description provided for @garageCarStatYear.
  ///
  /// In en, this message translates to:
  /// **'YEAR'**
  String get garageCarStatYear;

  /// No description provided for @garageCarShareButton.
  ///
  /// In en, this message translates to:
  /// **'Share car'**
  String get garageCarShareButton;

  /// No description provided for @profileBadgesSheetUnlocked.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No badges yet} =1{1 unlocked} other{{count} unlocked}}'**
  String profileBadgesSheetUnlocked(num count);

  /// No description provided for @profileCreatePost.
  ///
  /// In en, this message translates to:
  /// **'New post'**
  String get profileCreatePost;

  /// No description provided for @profileCreatePostHint.
  ///
  /// In en, this message translates to:
  /// **'Share a photo or a story from the road.'**
  String get profileCreatePostHint;

  /// No description provided for @profileCreateEvent.
  ///
  /// In en, this message translates to:
  /// **'New car event'**
  String get profileCreateEvent;

  /// No description provided for @profileCreateEventHint.
  ///
  /// In en, this message translates to:
  /// **'Set up a meet, a cruise or a show.'**
  String get profileCreateEventHint;

  /// No description provided for @garageCarStatPower.
  ///
  /// In en, this message translates to:
  /// **'POWER'**
  String get garageCarStatPower;

  /// No description provided for @garageCarStatTorque.
  ///
  /// In en, this message translates to:
  /// **'TORQUE'**
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
