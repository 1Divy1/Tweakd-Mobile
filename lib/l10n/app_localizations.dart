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
  /// **'Sign in to get back in the garage.'**
  String get authLoginSubtitle;

  /// Sign up page headline
  ///
  /// In en, this message translates to:
  /// **'Join the grid'**
  String get authSignupTitle;

  /// Sign up page subtitle
  ///
  /// In en, this message translates to:
  /// **'Create your account and connect with the community'**
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

  /// No description provided for @authUsernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get authUsernameLabel;

  /// No description provided for @authUsernameHint.
  ///
  /// In en, this message translates to:
  /// **'username'**
  String get authUsernameHint;

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

  /// No description provided for @authFeaturePasswordRecovery.
  ///
  /// In en, this message translates to:
  /// **'Password recovery'**
  String get authFeaturePasswordRecovery;

  /// No description provided for @authFeatureEmailSignUp.
  ///
  /// In en, this message translates to:
  /// **'Email sign up'**
  String get authFeatureEmailSignUp;

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

  /// No description provided for @onboardingStart.
  ///
  /// In en, this message translates to:
  /// **'START'**
  String get onboardingStart;

  /// No description provided for @onboardingFinish.
  ///
  /// In en, this message translates to:
  /// **'FINISH'**
  String get onboardingFinish;

  /// No description provided for @onboardingStepCounter.
  ///
  /// In en, this message translates to:
  /// **'STEP {current} / {total}'**
  String onboardingStepCounter(int current, int total);

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

  /// No description provided for @onboardingStepIdentity.
  ///
  /// In en, this message translates to:
  /// **'IDENTITY'**
  String get onboardingStepIdentity;

  /// No description provided for @onboardingStepGarage.
  ///
  /// In en, this message translates to:
  /// **'PREFERENCES'**
  String get onboardingStepGarage;

  /// No description provided for @onboardingStepRole.
  ///
  /// In en, this message translates to:
  /// **'ROLE'**
  String get onboardingStepRole;

  /// No description provided for @onboardingStepTaste.
  ///
  /// In en, this message translates to:
  /// **'TASTE'**
  String get onboardingStepTaste;

  /// No description provided for @onboardingStepLocation.
  ///
  /// In en, this message translates to:
  /// **'LOCATION'**
  String get onboardingStepLocation;

  /// No description provided for @onboardingStepNotifications.
  ///
  /// In en, this message translates to:
  /// **'NOTIFICATIONS'**
  String get onboardingStepNotifications;

  /// No description provided for @onboardingErrorPickRole.
  ///
  /// In en, this message translates to:
  /// **'Pick at least one role.'**
  String get onboardingErrorPickRole;

  /// No description provided for @onboardingErrorPickCategory.
  ///
  /// In en, this message translates to:
  /// **'Pick at least {count} category to continue.'**
  String onboardingErrorPickCategory(int count);

  /// No description provided for @onboardingErrorSelectCity.
  ///
  /// In en, this message translates to:
  /// **'Select your city to continue.'**
  String get onboardingErrorSelectCity;

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

  /// No description provided for @onboardingUsernameHelp.
  ///
  /// In en, this message translates to:
  /// **'This will be your public handle.'**
  String get onboardingUsernameHelp;

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

  /// No description provided for @onboardingIdentitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'This is how the community finds and mentions you. Add a short bio so people get your vibe at a glance.'**
  String get onboardingIdentitySubtitle;

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
  /// **'Brands & models you love'**
  String get onboardingGarageTitle;

  /// No description provided for @onboardingGarageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick your favorite brands and models. We’ll tune your feed around them.'**
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

  /// No description provided for @onboardingRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'03 — ROLE'**
  String get onboardingRoleLabel;

  /// No description provided for @onboardingRoleTitle.
  ///
  /// In en, this message translates to:
  /// **'Your role in the scene'**
  String get onboardingRoleTitle;

  /// No description provided for @onboardingRoleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'How do you show up in the community? Choose all that apply.'**
  String get onboardingRoleSubtitle;

  /// No description provided for @onboardingFieldRoles.
  ///
  /// In en, this message translates to:
  /// **'ROLES'**
  String get onboardingFieldRoles;

  /// No description provided for @onboardingTasteLabel.
  ///
  /// In en, this message translates to:
  /// **'04 — TASTE'**
  String get onboardingTasteLabel;

  /// No description provided for @onboardingTasteTitle.
  ///
  /// In en, this message translates to:
  /// **'Categories you’re into'**
  String get onboardingTasteTitle;

  /// No description provided for @onboardingTasteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select the categories you’re passionate about. We’ll lead with these across your feed and the marketplace.'**
  String get onboardingTasteSubtitle;

  /// No description provided for @onboardingFieldCategories.
  ///
  /// In en, this message translates to:
  /// **'CATEGORIES'**
  String get onboardingFieldCategories;

  /// No description provided for @onboardingTasteSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String onboardingTasteSelectedCount(int count);

  /// No description provided for @onboardingTastePickHint.
  ///
  /// In en, this message translates to:
  /// **' · pick at least 1 to calibrate your feed.'**
  String get onboardingTastePickHint;

  /// No description provided for @onboardingLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'05 — LOCATION'**
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
  /// **'06 — NOTIFICATIONS'**
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

  /// No description provided for @onboardingNotifGroupMarketplace.
  ///
  /// In en, this message translates to:
  /// **'MARKETPLACE'**
  String get onboardingNotifGroupMarketplace;

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

  /// No description provided for @onboardingNotifPriceDropsTitle.
  ///
  /// In en, this message translates to:
  /// **'Price drops'**
  String get onboardingNotifPriceDropsTitle;

  /// No description provided for @onboardingNotifPriceDropsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'When a saved item gets a discount'**
  String get onboardingNotifPriceDropsSubtitle;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'PROFILE'**
  String get profileTitle;

  /// No description provided for @profileStatFollowers.
  ///
  /// In en, this message translates to:
  /// **'FOLLOWERS'**
  String get profileStatFollowers;

  /// No description provided for @profileStatFollowing.
  ///
  /// In en, this message translates to:
  /// **'FOLLOWING'**
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

  /// No description provided for @garageSectionEyebrow.
  ///
  /// In en, this message translates to:
  /// **'THE GARAGE'**
  String get garageSectionEyebrow;

  /// No description provided for @garageMachineCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 Machines} =1{1 Machine} other{{count} Machines}}'**
  String garageMachineCount(int count);

  /// No description provided for @garageAddButton.
  ///
  /// In en, this message translates to:
  /// **'+ ADD'**
  String get garageAddButton;

  /// No description provided for @garageEmptyOwner.
  ///
  /// In en, this message translates to:
  /// **'Your garage is empty. Add your first machine.'**
  String get garageEmptyOwner;

  /// No description provided for @garageEmptyVisitor.
  ///
  /// In en, this message translates to:
  /// **'No machines yet.'**
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

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'PROFILE'**
  String get navProfile;

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
  /// **'Creating machine…'**
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
  /// **'Delete machine?'**
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
  /// **'Machine registered!'**
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
  /// **'You haven\'t registered this machine yet. If you leave now, everything you entered will be lost.'**
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
