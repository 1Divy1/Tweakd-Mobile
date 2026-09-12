// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Tweakd';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageRomanian => 'Romanian';

  @override
  String get settingsLanguagePickerTitle => 'Choose your language';

  @override
  String get settingsLanguageLoadError =>
      'We couldn\'t load the language options. Please try again.';

  @override
  String get settingsLanguageUpdateError =>
      'We couldn\'t update your language. Please try again.';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get settingsThemePickerTitle => 'Choose your theme';

  @override
  String get commonSave => 'Save';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonRetry => 'Retry';

  @override
  String profileFollowers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count followers',
      one: '1 follower',
      zero: 'No followers',
    );
    return '$_temp0';
  }

  @override
  String greetingHello(String name) {
    return 'Hello, $name!';
  }

  @override
  String get authLoginTitle => 'Welcome back';

  @override
  String get authLoginSubtitle => '';

  @override
  String get authSignupTitle => 'Join the community';

  @override
  String get authSignupSubtitle => '';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authEmailHint => 'you@email.com';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authPasswordHintLogin => 'Enter your password';

  @override
  String get authPasswordHintSignup => 'Create a password';

  @override
  String get authForgotPassword => 'FORGOT PASSWORD?';

  @override
  String get authSignIn => 'Sign in';

  @override
  String get authCreateAccount => 'Create account';

  @override
  String get authOrContinueWith => 'Or continue with';

  @override
  String get authOrSignUpWith => 'Or sign up with';

  @override
  String get authNoAccountPrefix => 'New to Tweakd? ';

  @override
  String get authHaveAccountPrefix => 'Already have an account? ';

  @override
  String get authTermsPrefix => 'By creating an account you agree to the ';

  @override
  String get authTermsTerms => 'Terms';

  @override
  String get authTermsAnd => ' & ';

  @override
  String get authTermsPrivacy => 'Privacy Policy';

  @override
  String get authAgreeToTermsFirst =>
      'Please agree to the Terms & Privacy Policy first.';

  @override
  String authComingSoon(String feature) {
    return '$feature is coming soon.';
  }

  @override
  String authFeatureProviderSignIn(String provider) {
    return '$provider sign-in';
  }

  @override
  String authPasswordRuleLength(int count) {
    return 'At least $count characters';
  }

  @override
  String get authPasswordRuleLowercase => 'A lowercase letter';

  @override
  String get authPasswordRuleUppercase => 'An uppercase letter';

  @override
  String get authPasswordRuleDigit => 'A number';

  @override
  String get authPasswordRuleSymbol => 'A symbol (!, @, #, …)';

  @override
  String get authConfirmEmailTitle => 'Check your inbox';

  @override
  String authConfirmEmailSubtitle(String email) {
    return 'We sent a code to $email. Enter it below to activate your account.';
  }

  @override
  String get authConfirmEmailVerify => 'Confirm email';

  @override
  String get authConfirmEmailResent => 'Confirmation email sent again.';

  @override
  String get authResendEmail => 'DIDN\'T GET IT? RESEND';

  @override
  String authResendIn(int seconds) {
    return 'RESEND IN ${seconds}s';
  }

  @override
  String get authBackToSignIn => 'BACK TO SIGN IN';

  @override
  String get authForgotPasswordTitle => 'Reset your password';

  @override
  String get authForgotPasswordSubtitle =>
      'Enter your email address and we\'ll send you a code.';

  @override
  String get authSendCode => 'Send code';

  @override
  String get authResetCodeResent => 'A new code is on its way.';

  @override
  String get authVerifyCodeTitle => 'Enter your code';

  @override
  String authVerifyCodeSubtitle(String email) {
    return 'We sent a code to $email. It expires shortly, so use it soon.';
  }

  @override
  String get authVerifyCode => 'Verify code';

  @override
  String get authNewPasswordTitle => 'Choose a new password';

  @override
  String get authNewPasswordSubtitle =>
      'Saving this signs out every other device.';

  @override
  String get authNewPasswordLabel => 'New password';

  @override
  String get authConfirmPasswordLabel => 'Confirm password';

  @override
  String get authConfirmPasswordHint => 'Repeat your new password';

  @override
  String get authPasswordsDoNotMatch => 'The passwords don\'t match.';

  @override
  String get authSavePassword => 'Save password';

  @override
  String get authPasswordUpdated => 'Your password has been updated.';

  @override
  String get onboardingBack => 'BACK';

  @override
  String get onboardingNext => 'NEXT';

  @override
  String get onboardingFinishSetup => 'FINISH SETUP';

  @override
  String get onboardingFinishingSetup => 'Finishing setup…';

  @override
  String get onboardingWorking => 'Working…';

  @override
  String get onboardingOptional => 'OPTIONAL';

  @override
  String get onboardingSearchHint => 'Search…';

  @override
  String get onboardingNoMatches => 'No matches';

  @override
  String get onboardingErrorPickBrand =>
      'Pick at least one brand you\'re into.';

  @override
  String get onboardingErrorSelectCity => 'Select your city to continue.';

  @override
  String get onboardingNameErrorEmpty => 'Please enter your name.';

  @override
  String onboardingNameErrorTooShort(int min) {
    return 'Name must be at least $min characters.';
  }

  @override
  String onboardingNameErrorTooLong(int max) {
    return 'Name must be at most $max characters.';
  }

  @override
  String get onboardingUsernameErrorEmpty => 'Please choose a handle.';

  @override
  String onboardingUsernameErrorTooShort(int min) {
    return 'Handle must be at least $min characters.';
  }

  @override
  String onboardingUsernameErrorTooLong(int max) {
    return 'Handle must be at most $max characters.';
  }

  @override
  String get onboardingUsernameErrorInvalidChars =>
      'Use lowercase letters, numbers, dots (.) and underscores (_).';

  @override
  String get onboardingUsernameChecking => 'Checking availability…';

  @override
  String get onboardingUsernameTaken => ' is already taken';

  @override
  String get onboardingUsernameAvailable => ' is available';

  @override
  String get onboardingUsernameCheckFailed =>
      'Couldn\'t check availability. Tap Next to try anyway.';

  @override
  String get onboardingUsernameHint => 'your_handle';

  @override
  String get onboardingErrorLoadFailed =>
      'Failed to load onboarding data. Please try again.';

  @override
  String get onboardingErrorUsernameTaken =>
      'That handle is already taken. Try another one.';

  @override
  String get onboardingErrorSessionExpired =>
      'Your session is not active. Please log in again.';

  @override
  String get onboardingErrorInvalidUsername =>
      'That username isn\'t valid. Please try another.';

  @override
  String get onboardingErrorGeneric =>
      'Something went wrong. Please try again.';

  @override
  String get onboardingIdentityLabel => '01 — IDENTITY';

  @override
  String get onboardingIdentityTitle => 'Claim your handle';

  @override
  String get onboardingFieldName => 'NAME';

  @override
  String get onboardingNameHint => 'Your name';

  @override
  String get onboardingFieldUsername => 'USERNAME';

  @override
  String get onboardingFieldBio => 'BIO';

  @override
  String get onboardingBioHint => 'Tell others a few things about yourself…';

  @override
  String get onboardingGarageLabel => '02 — PREFERENCES';

  @override
  String get onboardingGarageTitle => 'Your garage';

  @override
  String get onboardingGarageSubtitle =>
      'Brands you follow — we’ll tune your feed and the marketplace around them.';

  @override
  String get onboardingFieldYourPicks => 'YOUR PICKS';

  @override
  String get onboardingFieldModels => 'MODELS';

  @override
  String get onboardingSelectBrand => 'Select a brand';

  @override
  String get onboardingAddModels => 'Add models';

  @override
  String onboardingBrandModels(String brand) {
    return '$brand models';
  }

  @override
  String get onboardingAddBrand => 'ADD ANOTHER BRAND';

  @override
  String get onboardingLocationLabel => '03 — LOCATION';

  @override
  String get onboardingLocationTitle =>
      'Where does the local community find you?';

  @override
  String get onboardingLocationSubtitle =>
      'Your location helps us tailor your experience with local carmeets, events and relevant marketplace finds.';

  @override
  String get onboardingFieldCountry => 'COUNTRY';

  @override
  String get onboardingFieldRegion => 'REGION';

  @override
  String get onboardingFieldCity => 'CITY';

  @override
  String get onboardingSelectCountryPlaceholder => 'Select your country';

  @override
  String get onboardingSelectRegionPlaceholder => 'Select your region';

  @override
  String get onboardingPickCountryFirst => 'Pick a country first';

  @override
  String get onboardingSelectCityPlaceholder => 'Select your city';

  @override
  String get onboardingPickRegionFirst => 'Pick a region first';

  @override
  String get onboardingPickerCountry => 'Select country';

  @override
  String get onboardingPickerRegion => 'Select region';

  @override
  String get onboardingPickerCity => 'Select city';

  @override
  String get onboardingDiscoveryRadius => 'DISCOVERY RADIUS';

  @override
  String get onboardingNotificationsLabel => '04 — NOTIFICATIONS';

  @override
  String get onboardingNotificationsTitle => 'What should we ping you about?';

  @override
  String get onboardingNotificationsSubtitle =>
      'Stay on top of what matters. You can fine-tune any of these later.';

  @override
  String get onboardingPushGrantedText =>
      'Push notifications are on. Pick what you want to hear about below.';

  @override
  String get onboardingPushBlockedTitle => 'Push notifications are turned off';

  @override
  String get onboardingPushBlockedSubtitle =>
      'They\'re blocked in your system settings. Turn them on to get pinged about the topics below.';

  @override
  String get onboardingPushOpenSettings => 'OPEN SETTINGS';

  @override
  String get onboardingPushEnableTitle => 'Turn on push notifications';

  @override
  String get onboardingPushEnableSubtitle =>
      'Allow notifications so we can ping you about the topics you pick below.';

  @override
  String get onboardingPushEnable => 'ENABLE';

  @override
  String get onboardingNotifGroupContent => 'ON YOUR CONTENT';

  @override
  String get onboardingNotifGroupMessages => 'MESSAGES';

  @override
  String onboardingNotifGroupMeets(int radius) {
    return 'MEETS & EVENTS · WITHIN $radius KM';
  }

  @override
  String get onboardingNotifGroupGarage => 'YOUR GARAGE';

  @override
  String get onboardingNotifLikesTitle => 'Likes';

  @override
  String get onboardingNotifLikesSubtitle =>
      'When someone likes your builds & posts';

  @override
  String get onboardingNotifCommentsTitle => 'Comments';

  @override
  String get onboardingNotifCommentsSubtitle =>
      'Replies and threads on your content';

  @override
  String get onboardingNotifSharesTitle => 'Shares';

  @override
  String get onboardingNotifSharesSubtitle => 'When your content gets reposted';

  @override
  String get onboardingNotifDmsTitle => 'Direct messages';

  @override
  String get onboardingNotifDmsSubtitle => 'New DMs and message requests';

  @override
  String get onboardingNotifFlashMeetsTitle => 'Flash meets';

  @override
  String get onboardingNotifFlashMeetsSubtitle =>
      'Spontaneous link-ups happening near you';

  @override
  String get onboardingNotifEventsTitle => 'Organized events';

  @override
  String get onboardingNotifEventsSubtitle =>
      'Shows, track days & cars-and-coffee';

  @override
  String get onboardingNotifEventOrganizerTitle => 'Event organizer';

  @override
  String get onboardingNotifEventOrganizerSubtitle =>
      'When someone enters your event, joins as co-organizer, or asks to withdraw';

  @override
  String get onboardingNotifServiceRemindersTitle => 'Service reminders';

  @override
  String get onboardingNotifServiceRemindersSubtitle =>
      'Upcoming services and expiring documents on your cars';

  @override
  String get onboardingNotifTagsTitle => 'Tags';

  @override
  String get onboardingNotifTagsSubtitle => 'When someone tags you or your car';

  @override
  String get profileTitle => 'PROFILE';

  @override
  String get profileMessage => 'Message';

  @override
  String get profileStatReputation => 'reputation';

  @override
  String get profileStatFollowers => 'followers';

  @override
  String get profileStatFollowing => 'following';

  @override
  String get profileErrorUsernameTaken =>
      'The username is already taken. Please choose a different one.';

  @override
  String get profileErrorSessionExpired =>
      'Your session is not active. Please log in again.';

  @override
  String get profileErrorNotFound => 'This profile could not be found.';

  @override
  String get profileErrorInvalidUsername =>
      'That username isn\'t valid. Please try another.';

  @override
  String get profileErrorGeneric => 'Something went wrong. Please try again.';

  @override
  String get profileErrorNetwork => 'No internet connection. Please try again.';

  @override
  String get profileEditButton => 'Edit profile';

  @override
  String get profileShareButton => 'Share profile';

  @override
  String get profileFeedbackButton => 'Feedback';

  @override
  String get navFeed => 'Feed';

  @override
  String get navMap => 'Map';

  @override
  String get navCreate => 'Create';

  @override
  String get navSearch => 'Search';

  @override
  String get navProfile => 'Profile';

  @override
  String get editProfileTitle => 'EDIT PROFILE';

  @override
  String get editProfileChangePhoto => 'Change photo';

  @override
  String get editProfileNameLabel => 'NAME';

  @override
  String get editProfileNameHint => 'Your display name';

  @override
  String get editProfileBioLabel => 'BIO';

  @override
  String get editProfileBioHint => 'Tell others a few things about yourself…';

  @override
  String get editProfileSave => 'Save changes';

  @override
  String get editProfileSaved => 'Profile updated';

  @override
  String get editProfilePhotoUpdated => 'Photo updated';

  @override
  String get editProfileErrorInvalid =>
      'Please check your name and bio, then try again.';

  @override
  String get editProfileErrorAvatar =>
      'We couldn\'t update your photo. Please try again.';

  @override
  String get followActionFollow => 'FOLLOW';

  @override
  String get followActionUnfollow => 'UNFOLLOW';

  @override
  String get followActionRequested => 'REQUESTED';

  @override
  String get garageEmptyOwner => 'Your garage is empty. Add your first car.';

  @override
  String get garageEmptyVisitor => 'No cars yet.';

  @override
  String get followActionFollowing => 'FOLLOWING';

  @override
  String get followRemove => 'REMOVE';

  @override
  String get followSearchFollowersHint => 'Search followers...';

  @override
  String get followSearchFollowingHint => 'Search following...';

  @override
  String followResultsForQuery(String query) {
    return 'FOR \"$query\"';
  }

  @override
  String followNoResultsQuery(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String get followNoFollowers => 'No followers yet';

  @override
  String get followNoFollowing => 'Not following anyone yet';

  @override
  String get followErrorCannotFollowSelf => 'You can\'t follow yourself.';

  @override
  String get followErrorPrivateProfile => 'This profile is private.';

  @override
  String get followErrorUserNotFound => 'That user could not be found.';

  @override
  String get followErrorRequestNotFound =>
      'That follow request could not be found.';

  @override
  String get followErrorSessionExpired =>
      'Your session is not active. Please log in again.';

  @override
  String get followErrorGeneric => 'Something went wrong. Please try again.';

  @override
  String get searchTitle => 'SEARCH';

  @override
  String get searchInputHint => 'Search by username';

  @override
  String get searchEmptyTitle => 'Search community members';

  @override
  String get searchEmptySubtitle =>
      'Type a username to find members across\nthe community.';

  @override
  String searchResultsDrivers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count USERS',
      one: '1 USER',
    );
    return '$_temp0';
  }

  @override
  String searchForQuery(String query) {
    return 'FOR \"$query\"';
  }

  @override
  String searchNoResults(String query) {
    return 'No users found for \"$query\"';
  }

  @override
  String get searchErrorGeneric => 'Something went wrong. Please try again.';

  @override
  String get feedEmptyTitle => 'Your feed is quiet';

  @override
  String get feedEmptyMessage =>
      'Be one of the first to show your car. Posts from the community land here.';

  @override
  String get feedEmptyCta => 'Share a post';

  @override
  String get feedErrorNetwork =>
      'No internet connection. Check your network and try again.';

  @override
  String get feedErrorGeneric => 'Couldn\'t load the feed. Please try again.';

  @override
  String get garageErrorCarNotFound => 'This car could not be found.';

  @override
  String get garageErrorGarageNotFound => 'This garage could not be found.';

  @override
  String get garageErrorPrivateGarage => 'This garage is private.';

  @override
  String get garageErrorNotOwner => 'You don\'t have permission to do that.';

  @override
  String get garageErrorInvalidReference =>
      'Some of the selected options are invalid.';

  @override
  String get garageErrorGeneric => 'Something went wrong. Please try again.';

  @override
  String get garageErrorRefDataLoadFailed =>
      'Failed to load form data. Please try again.';

  @override
  String get garageErrorCategoriesLoadFailed =>
      'Failed to load categories. Please try again.';

  @override
  String get garageErrorPhotoUploadFailed =>
      'Photo upload failed. Please try again.';

  @override
  String get garageErrorEditSaveFailed =>
      'Some changes could not be saved. Please try again.';

  @override
  String get garagePhaseCreating => 'Creating car';

  @override
  String get garagePhaseUploadingPhotos => 'Uploading photos…';

  @override
  String get garagePhaseSavingChanges => 'Saving changes…';

  @override
  String get garagePhaseSavingPhotos => 'Saving photos…';

  @override
  String get garageRegisterBack => 'BACK';

  @override
  String get garageRegisterNext => 'NEXT';

  @override
  String get garageRegisterWorking => 'Working…';

  @override
  String get garageRegisterAddCar => 'ADD CAR';

  @override
  String get garageRegisterSave => 'SAVE';

  @override
  String get garageOptional => 'OPTIONAL';

  @override
  String get garageSearchHint => 'Search…';

  @override
  String get garageNoMatches => 'No matches';

  @override
  String get garageRegisterSpecsTitle => 'Car details';

  @override
  String get garageSpecsTabBasics => 'BASICS';

  @override
  String get garageSpecsTabPower => 'POWER';

  @override
  String get garageSpecsTabConfig => 'CONFIG';

  @override
  String get garageFieldMake => 'MAKE';

  @override
  String get garageHintMake => 'e.g. Porsche';

  @override
  String get garagePickerMake => 'Select Make';

  @override
  String get garageFieldModel => 'MODEL';

  @override
  String get garageHintModelPickMakeFirst => 'Select a make first';

  @override
  String get garageHintModel => 'e.g. 911 GT3 RS';

  @override
  String get garagePickerModel => 'Select Model';

  @override
  String get garageFieldYear => 'YEAR';

  @override
  String get garageFieldChassisCode => 'VIN';

  @override
  String get garageFieldModelCode => 'MODEL CODE';

  @override
  String get garageHintModelCode => 'e.g. G30';

  @override
  String get garagePickFromGallery => 'Tap to pick from your gallery';

  @override
  String get garageFieldPower => 'POWER';

  @override
  String get garageFieldTorque => 'TORQUE';

  @override
  String get garageFieldWeight => 'WEIGHT';

  @override
  String get garageFieldDisplacement => 'DISPLACEMENT';

  @override
  String get garageFieldEngineCode => 'ENGINE CODE';

  @override
  String get garageHintEngineCode => 'e.g. S58';

  @override
  String get garageFieldFuelType => 'FUEL TYPE';

  @override
  String get garageHintFuelType => 'e.g. Petrol';

  @override
  String get garagePickerFuelType => 'Select Fuel Type';

  @override
  String get garageFieldDrivetrain => 'DRIVETRAIN';

  @override
  String get garageHintDrivetrain => 'e.g. Rear-Wheel Drive';

  @override
  String get garagePickerDrivetrain => 'Select Drivetrain';

  @override
  String get garageFieldColor => 'COLOR';

  @override
  String get garageHintColor => 'e.g. Inka Orange';

  @override
  String get garagePickerColor => 'Select Color';

  @override
  String get garageFieldMileageUnit => 'MILEAGE UNIT';

  @override
  String get garageFieldMileage => 'MILEAGE';

  @override
  String get garageHintMileage => 'e.g. 42000';

  @override
  String get garageRegisterStoryTitle => 'What\'s this car\'s story? Share it…';

  @override
  String get garageFieldStatus => 'STATUS';

  @override
  String get garageFieldTheStory => 'THE STORY';

  @override
  String get garageHintStory => 'What\'s this car\'s story? Share it…';

  @override
  String get garageRegisterGalleryTitle => 'Show it off';

  @override
  String get garageFieldGallery => 'GALLERY';

  @override
  String get garageAddCoverPhoto => 'Add the cover photo';

  @override
  String get garageGalleryAdd => 'ADD';

  @override
  String get garageGalleryHint =>
      'Showcase only — your sharpest, most striking shots. Best angles, colour and light. Up to 15 photos.';

  @override
  String get garageRegisterModsTitle => 'Build log';

  @override
  String get garageRegisterModsSubtitle => '';

  @override
  String get garageModFallbackCategory => 'MODIFICATION';

  @override
  String get garageAddModification => 'ADD MODIFICATION';

  @override
  String get garageModSheetTitleEdit => 'Edit build item';

  @override
  String get garageModSheetTitleAdd => 'Add a build item';

  @override
  String get garageFieldCategory => 'CATEGORY';

  @override
  String get garageHintCategory => 'e.g. Engine';

  @override
  String get garagePickerCategory => 'Select Category';

  @override
  String get garageFieldTitle => 'TITLE';

  @override
  String get garageHintModTitle => 'e.g. Stage 2 turbo';

  @override
  String get garageFieldDescription => 'DESCRIPTION';

  @override
  String get garageHintModDescription => 'What changed, and what it gained…';

  @override
  String get garageFieldInstallationDate => 'INSTALLATION DATE';

  @override
  String get garageSelectDate => 'Select date';

  @override
  String get garageFieldPrice => 'PRICE';

  @override
  String get garageFieldMileageShort => 'MILEAGE';

  @override
  String get garageModBefore => 'BEFORE';

  @override
  String get garageModAfter => 'AFTER';

  @override
  String get garageModSaveChanges => 'SAVE CHANGES';

  @override
  String get garageModAddToBuildLog => 'ADD TO BUILD LOG';

  @override
  String get garageModValidation => 'Category, title and date are required.';

  @override
  String get garageAboutTitle => 'ABOUT';

  @override
  String garageBuildIdentifier(String code) {
    return 'BUILD IDENTIFIER · $code';
  }

  @override
  String get garageSpecPower => 'POWER';

  @override
  String get garageSpecTorque => 'TORQUE';

  @override
  String get garageSpecWeight => 'WEIGHT';

  @override
  String get garageInfoDrivetrain => 'DRIVETRAIN';

  @override
  String get garageInfoMileage => 'MILEAGE';

  @override
  String get garageInfoModelCode => 'MODEL CODE';

  @override
  String get garageInfoEngineCode => 'ENGINE CODE';

  @override
  String get garageInfoDisplacement => 'DISPLACEMENT';

  @override
  String get garageInfoFuelType => 'FUEL TYPE';

  @override
  String get garageInfoStatus => 'STATUS';

  @override
  String get garageStoryHeading => 'THE STORY';

  @override
  String get garageGalleryHeading => 'GALLERY';

  @override
  String get garageLogBuildIteration => '+ LOG BUILD ITERATION';

  @override
  String get garageModLogHeading => 'MODIFICATION LOG';

  @override
  String get garageEditCar => 'Edit car';

  @override
  String get garageDeleteCar => 'Delete car';

  @override
  String get garageDeleteMachineTitle => 'Delete car?';

  @override
  String get garageDeleteMachineBody =>
      'This will permanently remove this car and all of its modifications from your garage. This action cannot be undone.';

  @override
  String get garageDialogCancel => 'Cancel';

  @override
  String get garageDialogDelete => 'Delete';

  @override
  String get garageDeletePhotoTitle => 'Delete photo?';

  @override
  String get garageDeletePhotoBody =>
      'This gallery photo will be permanently removed.';

  @override
  String get garageDeleteModTitle => 'Delete modification?';

  @override
  String get garageDeleteModBody =>
      'This will permanently remove this modification and its photos from the build log. This action cannot be undone.';

  @override
  String get garageDeleteModMenu => 'Delete modification';

  @override
  String get garageCarRegistered => 'Car registered!';

  @override
  String get garageChangesSaved => 'Changes saved!';

  @override
  String get garageShareBuild => 'Share build';

  @override
  String get garageShareSheetLabel => 'SHARE BUILD';

  @override
  String get garageShareQrTitle => 'Get QR code';

  @override
  String get garageShareQrSubtitle => 'Print it, stick it on the car';

  @override
  String get garageShareCopyLink => 'Copy link';

  @override
  String get garageShareLinkCopied => 'Link copied';

  @override
  String get garageShareChannelMessages => 'Messages';

  @override
  String get garageShareChannelWhatsApp => 'WhatsApp';

  @override
  String get garageShareChannelInstagram => 'Instagram';

  @override
  String get garageShareChannelX => 'X';

  @override
  String get garageShareChannelTelegram => 'Telegram';

  @override
  String garageShareMessage(String car) {
    return 'Check out my $car on Tweakd 🔧';
  }

  @override
  String garageShareStats(int scans, int views) {
    return 'Scanned $scans · Opened $views';
  }

  @override
  String get garageShareToggleLabel => 'Sharing';

  @override
  String get garageSharePausedHint => 'Paused — the link and QR are off';

  @override
  String get garageShareLoadFailed => 'Couldn\'t open the share link.';

  @override
  String get garageShareQrLoadFailed => 'Couldn\'t load the QR code.';

  @override
  String get garageShareQrDownload => 'Download QR code';

  @override
  String get garageShareQrDownloadSaved => 'QR code saved to your phone.';

  @override
  String get garageShareQrDownloadFailed => 'Couldn\'t save the file.';

  @override
  String get garageShareRetry => 'Try again';

  @override
  String get garageShareResolving => 'Opening build…';

  @override
  String get garageShareUnavailableTitle => 'Build unavailable';

  @override
  String get garageShareUnavailableBody =>
      'This build is no longer shared on Tweakd.';

  @override
  String get garageShareBackToFeed => 'Back to feed';

  @override
  String get garageValCoverPhoto => 'Please pick a cover photo.';

  @override
  String get garageValMake => 'Please select a make.';

  @override
  String get garageValModel => 'Please select a model.';

  @override
  String get garageValYear => 'Please enter the year.';

  @override
  String get garageValHorsepower => 'Please enter horsepower.';

  @override
  String get garageValTorque => 'Please enter torque.';

  @override
  String get garageValWeight => 'Please enter weight.';

  @override
  String get garageValDisplacement => 'Please enter displacement.';

  @override
  String get garageValFuelType => 'Please select a fuel type.';

  @override
  String get garageValDrivetrain => 'Please select a drivetrain.';

  @override
  String get garageValColor => 'Please select a color.';

  @override
  String get garageValMileageUnit => 'Please select a mileage unit.';

  @override
  String get garageValStatus => 'Please select a status.';

  @override
  String get garageKeepEditing => 'Keep editing';

  @override
  String get garageDiscard => 'Discard';

  @override
  String get garageBuildLogDiscardTitle => 'Discard this build item?';

  @override
  String get garageBuildLogDiscardBody =>
      'You haven\'t added this item to the build log yet. If you leave now, everything you entered here will be lost.';

  @override
  String get garageLogModLogged => 'Modification logged!';

  @override
  String get garageAddModCarTitle => 'Which car?';

  @override
  String get garageAddModCarSubtitle => 'Pick the car this work went into.';

  @override
  String get garageAddModNoCarsTitle => 'No cars yet';

  @override
  String get garageAddModNoCarsBody =>
      'Add a car to your garage first, then log the work you\'ve done on it.';

  @override
  String get garageAddModAddCar => 'ADD A CAR';

  @override
  String get garageAddModPickCar => 'Pick a car to continue.';

  @override
  String get authErrorSessionExpired =>
      'Your session is not active. Please log in again.';

  @override
  String get authErrorInvalidCredentials =>
      'That email or password is incorrect.';

  @override
  String get authErrorEmailNotConfirmed =>
      'Confirm your email address before signing in.';

  @override
  String get authErrorWeakPassword =>
      'That password is too weak. Please pick a stronger one.';

  @override
  String get authErrorInvalidCode =>
      'That code isn\'t right. Please check it and try again.';

  @override
  String get authErrorExpiredCode =>
      'That code has expired. Request a new one.';

  @override
  String get authErrorRateLimited =>
      'Too many attempts. Please wait a moment and try again.';

  @override
  String get authErrorSamePassword =>
      'Your new password must be different from the old one.';

  @override
  String get authErrorSignUpDisabled =>
      'New sign-ups are currently unavailable. Please try again later.';

  @override
  String get authErrorNetwork =>
      'No connection. Check your network and try again.';

  @override
  String get authErrorGeneric => 'Something went wrong. Please try again.';

  @override
  String get settingsTitle => 'SETTINGS';

  @override
  String get settingsLogout => 'Log out';

  @override
  String get settingsLogoutTitle => 'Log out?';

  @override
  String get settingsLogoutBody =>
      'You will need to sign in again to access your account.';

  @override
  String get postBack => 'BACK';

  @override
  String get postNext => 'NEXT';

  @override
  String get postPublish => 'PUBLISH POST';

  @override
  String get postPhotosTitle => 'Pick your shots';

  @override
  String get postPhotosSubtitle =>
      'Drag to reorder — the cover leads your post. Photos only for now.';

  @override
  String get postPhotosAdd => 'ADD';

  @override
  String get postPhotosCover => 'COVER';

  @override
  String get postPhotosVideosSoon => 'VIDEOS — COMING SOON';

  @override
  String postPhotosCount(int count, int max) {
    return '$count / $max PHOTOS';
  }

  @override
  String get postCaptionTitle => 'Say something';

  @override
  String get postCaptionSubtitle =>
      'Add a description for your post. Mention details, the story, the build.';

  @override
  String get postCaptionLabel => 'DESCRIPTION';

  @override
  String get postCaptionHint => 'Share the story behind this post…';

  @override
  String postCaptionCounter(int count, int max) {
    return '$count / $max';
  }

  @override
  String get postTagsTitle => 'Tag cars & people';

  @override
  String get postTagsSubtitle =>
      'Link the cars in this post from any garage, and tag the people in it.';

  @override
  String get postTagsCars => 'CARS';

  @override
  String get postTagsPeople => 'PEOPLE';

  @override
  String get postTagsCarHint => 'Search a car in any garage…';

  @override
  String get postTagsPeopleHint => 'Search people to tag…';

  @override
  String get postTagsAddCar => 'Tag a car';

  @override
  String get postTagsTagPersonFirst =>
      'Tag a person first to tag one of their cars.';

  @override
  String get postTagsChoosePerson => 'Whose car?';

  @override
  String get postTagsChooseCar => 'Pick a car';

  @override
  String get postTagsNoCars => 'This person has no cars to tag.';

  @override
  String get postTagsNoPeopleFound => 'No people found.';

  @override
  String get postTagsLoadError => 'Couldn\'t load. Please try again.';

  @override
  String get postVisibilityTitle => 'Who sees what';

  @override
  String get postVisibilitySubtitle =>
      'Hide a counter and others won\'t see that number — they can still like, comment and share.';

  @override
  String get postVisibilityLabel => 'VISIBLE COUNTS';

  @override
  String get postVisibilityLikesTitle => 'Show like count';

  @override
  String get postVisibilityLikesDesc =>
      'Others can see how many likes this post has';

  @override
  String get postVisibilityCommentsTitle => 'Show comment count';

  @override
  String get postVisibilityCommentsDesc =>
      'Hide the number — comments stay open';

  @override
  String get postVisibilitySharesTitle => 'Show share count';

  @override
  String get postVisibilitySharesDesc =>
      'Others can see how many times it was shared';

  @override
  String get postVisibilitySavedTitle => 'Show saved count';

  @override
  String get postVisibilitySavedDesc =>
      'Others can see how many times it was saved';

  @override
  String get postVisibilityTimeNote =>
      'Posts show a relative time — \"2h ago\", \"3 days ago\" — never the exact date. This is automatic and always on.';

  @override
  String get postReviewTitle => 'Looking good?';

  @override
  String get postReviewSubtitle =>
      'This is exactly how your post appears in the feed.';

  @override
  String get postReviewYou => 'You';

  @override
  String get postReviewJustNow => 'JUST NOW';

  @override
  String get postValPhotosRequired => 'Add at least one photo to continue.';

  @override
  String get postDiscardTitle => 'Discard post?';

  @override
  String get postDiscardBody =>
      'Your photos, caption and tags won\'t be saved.';

  @override
  String get postKeepEditing => 'Keep editing';

  @override
  String get postDiscard => 'Discard';

  @override
  String get postCreatedSuccess => 'Post published.';

  @override
  String get postPhaseCreating => 'Creating…';

  @override
  String get postPhaseUploading => 'Uploading photos…';

  @override
  String get postErrorGeneric =>
      'Couldn\'t publish your post. Please try again.';

  @override
  String get postErrorImageUpload =>
      'Your photos couldn\'t be uploaded. Please try again.';

  @override
  String get postErrorInvalidTags =>
      'You can\'t tag a car without also tagging its owner.';

  @override
  String get postErrorNotOwner => 'You don\'t have permission to do that.';

  @override
  String get postErrorNotFound => 'This post no longer exists.';

  @override
  String get profileTabPosts => 'Posts';

  @override
  String get profileTabGarage => 'Garage';

  @override
  String get profileTabTags => 'Tags';

  @override
  String get postsLoadMore => 'LOAD MORE';

  @override
  String get postsEmptyOwner => 'You haven\'t posted yet.';

  @override
  String get postsEmptyVisitor => 'No posts yet.';

  @override
  String get postsCreateFirst => 'CREATE YOUR FIRST POST';

  @override
  String get savedPostsTitle => 'SAVED POSTS';

  @override
  String get savedPostsEmptyTitle => 'Nothing saved yet';

  @override
  String get savedPostsEmptyBody =>
      'Save posts you like to find them here later.';

  @override
  String get postDetailTitle => 'POST';

  @override
  String get postEditAction => 'Edit post';

  @override
  String get postDeleteAction => 'Delete post';

  @override
  String get postDeleteTitle => 'Delete post?';

  @override
  String get postDeleteBody =>
      'This post and its photos, likes and comments will be permanently removed.';

  @override
  String get postEditTitle => 'EDIT POST';

  @override
  String get postEditSave => 'SAVE';

  @override
  String get postShareTitle => 'SHARE POST';

  @override
  String get postShareSend => 'SHARE';

  @override
  String get postShareNoteLabel => 'Add a note';

  @override
  String get postShareNoteHint => 'Say something about this post… (optional)';

  @override
  String get postSharePreviewNoCaption => 'No caption';

  @override
  String get postShareSuccess => 'Post shared.';

  @override
  String get postTimeNow => 'now';

  @override
  String postTimeMinutes(int count) {
    return '${count}m';
  }

  @override
  String postTimeHours(int count) {
    return '${count}h';
  }

  @override
  String postTimeDays(int count) {
    return '${count}d';
  }

  @override
  String postTimeWeeks(int count) {
    return '${count}w';
  }

  @override
  String postLikesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count likes',
      one: '1 like',
    );
    return '$_temp0';
  }

  @override
  String postViewAllComments(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'View all $count comments',
      one: 'View 1 comment',
    );
    return '$_temp0';
  }

  @override
  String postCommentsTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count comments',
      one: '1 comment',
      zero: 'Comments',
    );
    return '$_temp0';
  }

  @override
  String get postCommentsEmpty => 'No comments yet. Be the first.';

  @override
  String get postCommentsLoadError =>
      'Couldn\'t load comments. Please try again.';

  @override
  String get postCommentHint => 'Add a comment…';

  @override
  String get postCommentDeleted => '[deleted]';

  @override
  String get postCommentDelete => 'Delete';

  @override
  String get postCommentDeleteTitle => 'Delete comment?';

  @override
  String get postCommentDeleteBody =>
      'This comment will be permanently removed.';

  @override
  String postCommentLikesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count likes',
      one: '1 like',
    );
    return '$_temp0';
  }

  @override
  String get postCommentReply => 'Reply';

  @override
  String postReplyingTo(String username) {
    return 'Replying to @$username';
  }

  @override
  String get postRepliesHide => 'Hide replies';

  @override
  String get postRepliesViewGeneric => 'View replies';

  @override
  String get postRepliesViewMore => 'View more replies';

  @override
  String postRepliesView(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'View $count replies',
      one: 'View 1 reply',
    );
    return '$_temp0';
  }

  @override
  String get postLikersTitle => 'Likes';

  @override
  String get postLikersEmpty => 'No likes yet.';

  @override
  String get postLikersLoadError => 'Couldn\'t load likes. Please try again.';

  @override
  String get postReport => 'Report post';

  @override
  String get commentReport => 'Report';

  @override
  String get profileReportAccount => 'Report account';

  @override
  String get reportSubmit => 'Submit report';

  @override
  String get reportClose => 'Close';

  @override
  String get reportRetry => 'Try again';

  @override
  String get reportReasonsLoadError =>
      'Couldn\'t load report reasons. Please try again.';

  @override
  String get reportSuccessTitle => 'Report received';

  @override
  String get reportSuccessBody =>
      'Thanks for letting us know. Our team will review this shortly.';

  @override
  String get reportErrorAlreadyReported => 'You\'ve already reported this.';

  @override
  String get reportErrorSelf => 'You can\'t report your own content.';

  @override
  String get reportErrorInvalidReason =>
      'That reason doesn\'t apply here. Please pick another.';

  @override
  String get reportErrorNotFound => 'This content is no longer available.';

  @override
  String get reportErrorNetwork => 'No internet connection. Please try again.';

  @override
  String get reportErrorGeneric =>
      'Couldn\'t submit your report. Please try again.';

  @override
  String get settingsSavedPosts => 'Your saved posts';

  @override
  String get settingsMyReports => 'My reports';

  @override
  String get myReportsTitle => 'MY REPORTS';

  @override
  String get myReportsEmpty => 'You haven\'t submitted any reports yet.';

  @override
  String get reportTargetPost => 'Post';

  @override
  String get reportTargetComment => 'Comment';

  @override
  String get reportTargetProfile => 'Profile';

  @override
  String get reportTargetForumThread => 'Forum thread';

  @override
  String get reportTargetForumReply => 'Forum reply';

  @override
  String get reportNoReason => 'No reason given';

  @override
  String get reportStatusPending => 'Pending';

  @override
  String get reportStatusInProgress => 'In progress';

  @override
  String get reportStatusResolved => 'Resolved';

  @override
  String get reportStatusDismissed => 'Dismissed';

  @override
  String get settingsSendFeedback => 'Send feedback';

  @override
  String get settingsMyFeedback => 'My feedback';

  @override
  String get feedbackEyebrow => 'FEEDBACK';

  @override
  String get feedbackHeadline => 'Got any suggestions ?';

  @override
  String get feedbackSubtitle =>
      'Report a bug, request a feature, or just share a thought and it goes straight to us.';

  @override
  String get feedbackTypeLabel => 'FEEDBACK TYPE';

  @override
  String get feedbackTypeHint => 'Select a type';

  @override
  String get feedbackFeatureLabel => 'RELATED TO AN EXISTING FEATURE?';

  @override
  String get feedbackFeatureHint => 'Select a feature';

  @override
  String get feedbackOptional => 'OPTIONAL';

  @override
  String get feedbackContentLabel => 'YOUR FEEDBACK';

  @override
  String get feedbackContentLabelBug => 'WHAT HAPPENED';

  @override
  String get feedbackContentHint => 'Share your thoughts…';

  @override
  String get feedbackReproductionLabel => 'REPRODUCTION STEPS';

  @override
  String get feedbackReproductionHint => '1. Open the …\n2. Tap …\n3. …';

  @override
  String get feedbackTypePickerTitle => 'Feedback type';

  @override
  String get feedbackFeaturePickerTitle => 'Related feature';

  @override
  String get feedbackFeatureNone => 'None';

  @override
  String get feedbackTypeBugDesc => 'Something is broken';

  @override
  String get feedbackTypeFeatureDesc => 'Something you wish existed';

  @override
  String get feedbackTypeGeneralDesc => 'Thoughts, praise or an idea';

  @override
  String get feedbackSubmit => 'Send feedback';

  @override
  String get feedbackRetry => 'Try again';

  @override
  String get feedbackLoadError =>
      'Couldn\'t load the feedback form. Please try again.';

  @override
  String get feedbackSuccess => 'Thanks! Your feedback is on its way.';

  @override
  String get feedbackErrorNetwork =>
      'No internet connection. Please try again.';

  @override
  String get feedbackErrorGeneric =>
      'Couldn\'t send your feedback. Please try again.';

  @override
  String get myFeedbackTitle => 'MY FEEDBACK';

  @override
  String get myFeedbackEmpty => 'You haven\'t sent any feedback yet.';

  @override
  String get myFeedbackResponseLabel => 'RESPONSE';

  @override
  String get forumsTitle => 'Forums';

  @override
  String get forumsSubtitle => 'Your paddock';

  @override
  String get forumsYourShortcuts => 'YOUR SHORTCUTS';

  @override
  String get forumsEditShortcuts => 'EDIT';

  @override
  String get forumsDoneEditing => 'DONE';

  @override
  String get forumsHotInYourForums => 'HOT IN YOUR FORUMS';

  @override
  String get forumsSortHot => 'Hot';

  @override
  String get forumsSortNew => 'New';

  @override
  String get forumsSortActive => 'Active';

  @override
  String get forumsEmptyTitle => 'Find the forums you live in';

  @override
  String get forumsEmptyBody =>
      'Tap a hub to see its threads. Once you\'ve had a look around, save it as a shortcut and it lands right here.';

  @override
  String get forumsPopularHubs => 'POPULAR HUBS TO START WITH';

  @override
  String get forumsCtaTitle => 'Got something to say?';

  @override
  String get forumsCtaBody =>
      'Every great forum started with one thread. Make it yours.';

  @override
  String get forumsStartFirstThread => 'Start the first thread';

  @override
  String get forumsShortcutSaved => 'Shortcut saved to your paddock.';

  @override
  String get forumsShortcutRemoved => 'Shortcut removed.';

  @override
  String get forumsBrowseTitle => 'BROWSE';

  @override
  String forumsBrandsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count BRANDS',
      one: '1 BRAND',
    );
    return '$_temp0';
  }

  @override
  String forumsThreadsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count threads',
      one: '1 thread',
    );
    return '$_temp0';
  }

  @override
  String get forumsModels => 'MODELS';

  @override
  String get forumsRefineByTopic => 'REFINE BY TOPIC';

  @override
  String forumsHotIn(String name) {
    return 'HOT IN $name';
  }

  @override
  String get forumsThreadsLabel => 'THREADS';

  @override
  String get forumsAllTopics => 'All';

  @override
  String get forumsSaveShortcut => 'Save shortcut';

  @override
  String get forumsSaveShortcutSubtitle =>
      'Pin this filter to your paddock for one-tap access.';

  @override
  String get forumsShortcutNameLabel => 'NAME';

  @override
  String get forumsNotifyMe => 'Notify me';

  @override
  String get forumsNotifyMeSubtitle => 'New hot threads in this filter';

  @override
  String get forumsNoThreadsTitle => 'No threads here yet.';

  @override
  String get forumsNoThreadsBody => 'Be the first — start the conversation.';

  @override
  String get forumsRetry => 'Try again';

  @override
  String get forumsThreadTitle => 'THREAD';

  @override
  String get forumsPinned => 'PINNED';

  @override
  String get forumsLocked => 'LOCKED';

  @override
  String get forumsLockedBar => 'This thread is locked — replies are closed.';

  @override
  String forumsRepliesHeader(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count REPLIES',
      one: '1 REPLY',
    );
    return '$_temp0';
  }

  @override
  String get forumsReply => 'Reply';

  @override
  String forumsShowReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Show $count replies',
      one: 'Show 1 reply',
    );
    return '$_temp0';
  }

  @override
  String get forumsHideReplies => 'Hide';

  @override
  String get forumsShowMoreReplies => 'Show more replies';

  @override
  String get forumsAddReply => 'Add a reply…';

  @override
  String forumsReplyingTo(String username) {
    return 'Replying to @$username';
  }

  @override
  String get forumsDeletedPlaceholder => '[deleted]';

  @override
  String get forumsPosted => 'Posted';

  @override
  String get forumsActiveNow => 'active just now';

  @override
  String forumsActiveAgo(String time) {
    return 'active $time ago';
  }

  @override
  String get forumsEditThread => 'Edit body';

  @override
  String get forumsDeleteThread => 'Delete thread';

  @override
  String get forumsEditReply => 'Edit reply';

  @override
  String get forumsDeleteReply => 'Delete reply';

  @override
  String get forumsDeleteThreadConfirmTitle => 'Delete this thread?';

  @override
  String get forumsDeleteThreadConfirmBody =>
      'If it has replies it stays visible as [deleted]; otherwise it\'s gone for good.';

  @override
  String get forumsDeleteReplyConfirmTitle => 'Delete this reply?';

  @override
  String get forumsDeleteReplyConfirmBody =>
      'If it has replies it becomes a [deleted] placeholder; otherwise it\'s removed.';

  @override
  String get forumsDelete => 'Delete';

  @override
  String get forumsEditSave => 'Save';

  @override
  String get forumsComingSoon => 'Coming soon';

  @override
  String get forumsNewThreadTitle => 'NEW THREAD';

  @override
  String get forumsPost => 'Post';

  @override
  String get forumsThreadTitleHint => 'Title';

  @override
  String get forumsThreadBodyHint =>
      'Share the details, questions, or your writeup…';

  @override
  String get forumsBrandRequiredLabel => 'BRAND · REQUIRED';

  @override
  String get forumsModelOptionalLabel => 'MODEL · OPTIONAL';

  @override
  String get forumsSearchBrandHint => 'Search a brand…';

  @override
  String get forumsSearchModelHint => 'Search a model…';

  @override
  String get forumsChooseBrand => 'Choose a brand';

  @override
  String get forumsChooseModel => 'Choose a model';

  @override
  String get forumsNoBrandMatches => 'No brands match that search.';

  @override
  String get forumsNoModelMatches => 'No models match that search.';

  @override
  String get forumsNoModelsForBrand => 'No models listed for this brand.';

  @override
  String get forumsTagCarHelper =>
      'Pick a brand so your thread shows up in the right hub. Adding the exact model is recommended unless your question applies to the whole brand.';

  @override
  String get forumsTopics => 'TOPICS';

  @override
  String get forumsThreadPosted => 'Thread posted.';

  @override
  String get forumsShare => 'Share';

  @override
  String get forumsSave => 'Save';

  @override
  String get forumsSaved => 'Saved';

  @override
  String get forumsAuthorBadge => 'Author';

  @override
  String get forumsRepliesOldest => 'Oldest';

  @override
  String get forumsRepliesNewest => 'Newest';

  @override
  String get forumsReportThreadTitle => 'Report thread';

  @override
  String get forumsReportReplyTitle => 'Report reply';

  @override
  String get forumsSavedTitle => 'SAVED';

  @override
  String get forumsSavedHeader => 'SAVED THREADS';

  @override
  String get forumsSavedEmptyTitle => 'Nothing saved yet';

  @override
  String get forumsSavedEmptyBody =>
      'Bookmark threads to find them here later.';

  @override
  String get forumsErrorNetwork => 'No internet connection. Please try again.';

  @override
  String get forumsErrorNotFound => 'This content doesn\'t exist anymore.';

  @override
  String get forumsErrorConflict =>
      'This thread is locked or the content was deleted.';

  @override
  String get forumsErrorForbidden =>
      'You can only edit or delete your own content.';

  @override
  String get forumsErrorGeneric => 'Something went wrong. Please try again.';

  @override
  String get forumsErrorInvalidTags =>
      'One of the tagged profiles or cars is no longer available.';

  @override
  String get forumsTagPeopleAndCars => 'TAG PEOPLE & CARS';

  @override
  String get forumsTagPeople => 'PEOPLE';

  @override
  String get forumsTagCars => 'CARS';

  @override
  String get forumsTagHelper =>
      'Mention someone to pull cars from their garage. Your own cars can be tagged without mentioning yourself.';

  @override
  String get forumsTagPeopleHint => 'Search a username…';

  @override
  String get forumsTagAddCar => 'Tag a car';

  @override
  String get forumsTagChoosePerson => 'Whose car?';

  @override
  String get forumsTagChooseCar => 'Pick a car';

  @override
  String get forumsTagYourGarage => 'Your garage';

  @override
  String get forumsTagNoPeopleFound => 'No profiles match that search.';

  @override
  String get forumsTagLoadError => 'Couldn’t load that. Please try again.';

  @override
  String get forumsTagNoCars => 'This person has no cars to tag.';

  @override
  String get forumsTagNoOwnCars => 'Your garage is empty.';

  @override
  String get forumsTagPersonFirst =>
      'Mention someone first to tag one of their cars.';

  @override
  String forumsTagLimitReached(int limit) {
    return 'You can tag up to $limit at a time.';
  }

  @override
  String get forumsTagsSheetTitle => 'Tags';

  @override
  String get forumsTagsDone => 'Done';

  @override
  String get forumsAddTagsTooltip => 'Tag people & cars';

  @override
  String get forumsTagsSectionLabel => 'TAGS';

  @override
  String get messagesTitle => 'MESSAGES';

  @override
  String get messagesSearchHint => 'Search messages';

  @override
  String get messagesActiveNow => 'ACTIVE NOW';

  @override
  String get messagesRequestsTitle => 'Message requests';

  @override
  String messagesRequestsOthers(String names, int count) {
    return '$names & $count others';
  }

  @override
  String get messagesEmptyTitle => 'No messages yet';

  @override
  String get messagesEmptyBody =>
      'Start a conversation with drivers you follow — plan meets, swap specs, share runs.';

  @override
  String get messagesNewMessage => 'NEW MESSAGE';

  @override
  String messagesYouPrefix(String text) {
    return 'You: $text';
  }

  @override
  String get messagesSharedPost => 'Shared a post';

  @override
  String get messagesTimeNow => 'now';

  @override
  String messagesTimeMinutes(int count) {
    return '${count}m';
  }

  @override
  String messagesTimeHours(int count) {
    return '${count}h';
  }

  @override
  String messagesTimeDays(int count) {
    return '${count}d';
  }

  @override
  String messagesTimeWeeks(int count) {
    return '${count}w';
  }

  @override
  String get messagesActiveNowStatus => 'Active now';

  @override
  String messagesMutualFollow(String followers) {
    return 'You both follow each other · $followers followers';
  }

  @override
  String messagesDatePill(String time) {
    return 'TODAY · $time';
  }

  @override
  String get messagesSeen => 'Seen';

  @override
  String get messagesDeletedMessage => 'Message deleted';

  @override
  String get messagesDeleteMessage => 'Delete message';

  @override
  String get messagesDeleteMessageBody => 'Removes it for both of you.';

  @override
  String get messagesDeleteChat => 'Delete chat';

  @override
  String get messagesDeleteChatBody =>
      'Hides it from your list only — it comes back with a new message.';

  @override
  String get messagesInputHint => 'Message…';

  @override
  String get messagesEmptyChat => 'No messages yet — say hi 👋';

  @override
  String get messagesComposeTitle => 'New message';

  @override
  String get messagesComposeSearchHint => 'Search drivers…';

  @override
  String get messagesComposeEmpty => 'No drivers found';

  @override
  String get messagesComingSoon => 'Coming soon';

  @override
  String get messagesRetry => 'Try again';

  @override
  String get messagesErrorNetwork =>
      'No internet connection. Please try again.';

  @override
  String get messagesErrorGeneric => 'Something went wrong. Please try again.';

  @override
  String get messagesSharedCars => 'Shared cars';

  @override
  String get messagesShareCarsTitle => 'Share cars';

  @override
  String get messagesShareCarsSubtitle => 'Pick cars from your garage';

  @override
  String messagesShareCarsLimit(int count) {
    return 'You can share up to $count cars';
  }

  @override
  String get messagesShareCarsEmpty => 'No cars in your garage yet';

  @override
  String get messagesShareCarsError =>
      'Couldn\'t load your garage. Please try again.';

  @override
  String messagesShareCarsConfirm(int count) {
    return 'Share $count';
  }

  @override
  String get messagesShareCarsConfirmEmpty => 'Share cars';

  @override
  String get notificationsTitle => 'NOTIFICATIONS';

  @override
  String get notificationsMarkAllRead => 'Mark all as read';

  @override
  String get notificationsEmptyTitle => 'No notifications yet';

  @override
  String get notificationsEmptyBody =>
      'Likes, comments and replies on your posts and threads will show up here.';

  @override
  String get notificationsRetry => 'Try again';

  @override
  String get notificationsErrorNetwork =>
      'No internet connection. Please try again.';

  @override
  String get notificationsErrorGeneric =>
      'Something went wrong. Please try again.';

  @override
  String get tagsKindPost => 'TAGGED IN A POST';

  @override
  String get tagsKindComment => 'TAGGED IN A COMMENT';

  @override
  String get tagsKindThread => 'TAGGED IN A THREAD';

  @override
  String get tagsKindReply => 'TAGGED IN A REPLY';

  @override
  String tagsOnPostBy(String author) {
    return 'on @$author\'s post';
  }

  @override
  String get tagsLoadMore => 'LOAD MORE';

  @override
  String get tagsEmptyOwner => 'You haven\'t been tagged yet.';

  @override
  String get tagsEmptyVisitor => 'No tags yet.';

  @override
  String get tagsRemove => 'Remove tag';

  @override
  String get tagsRemoveTitle => 'Remove tag?';

  @override
  String get tagsRemoveBody =>
      'You\'ll be removed from this content for everyone, along with any of your cars tagged on it. Only the author can tag you again.';

  @override
  String get tagsRemoveConfirm => 'Remove';

  @override
  String get tagsErrorContentGone => 'This content no longer exists.';

  @override
  String get tagsErrorGeneric => 'Something went wrong. Please try again.';

  @override
  String get mapOpenNow => 'Open now';

  @override
  String get mapClosedNow => 'Closed';

  @override
  String get mapNoReviews => 'No reviews yet';

  @override
  String mapReviewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reviews',
      one: '1 review',
    );
    return '$_temp0';
  }

  @override
  String mapFollowerCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count followers',
      one: '1 follower',
    );
    return '$_temp0';
  }

  @override
  String get mapHoursTitle => 'OPENING HOURS';

  @override
  String get mapHoursClosed => 'Closed';

  @override
  String get mapHoursNextDay => '(next day)';

  @override
  String get mapWeekdayMonday => 'Monday';

  @override
  String get mapWeekdayTuesday => 'Tuesday';

  @override
  String get mapWeekdayWednesday => 'Wednesday';

  @override
  String get mapWeekdayThursday => 'Thursday';

  @override
  String get mapWeekdayFriday => 'Friday';

  @override
  String get mapWeekdaySaturday => 'Saturday';

  @override
  String get mapWeekdaySunday => 'Sunday';

  @override
  String get mapPopupClose => 'Close';

  @override
  String get mapRecentre => 'Centre on my location';

  @override
  String get mapRetry => 'TRY AGAIN';

  @override
  String get mapErrorNetwork => 'No internet connection. Please try again.';

  @override
  String get mapErrorBusinessNotFound =>
      'This business isn\'t available anymore.';

  @override
  String get mapErrorLocationUnavailable =>
      'We couldn\'t get your location. Check that location is turned on for Tweakd.';

  @override
  String get mapErrorGeneric => 'Something went wrong. Please try again.';

  @override
  String get mapNavigate => 'Navigate';

  @override
  String get mapNavigateSheetTitle => 'Choose a navigation app';

  @override
  String get mapNavigateInstall => 'INSTALL';

  @override
  String get mapNavigateFailed => 'We couldn\'t open that app.';

  @override
  String get mapEventsErrorNetwork =>
      'No internet connection. Please try again.';

  @override
  String get mapEventsErrorNotFound => 'This event isn\'t available anymore.';

  @override
  String get mapEventsErrorForbidden => 'Only the organizers can do that.';

  @override
  String get mapEventsErrorConflict =>
      'That isn\'t possible for this event right now.';

  @override
  String get mapEventsErrorInvalidInput =>
      'Please check the details and try again.';

  @override
  String mapEventsBulkRegisterPartial(int registered, int failed) {
    return '$registered of your cars got in before this event reached capacity — $failed couldn\'t be added and weren\'t automatically removed.';
  }

  @override
  String get mapEventsErrorGeneric => 'Something went wrong. Please try again.';

  @override
  String get mapEventsStatusUpcoming => 'UPCOMING';

  @override
  String get mapEventsStatusLive => 'LIVE NOW';

  @override
  String get mapEventsStatusPrevious => 'PAST';

  @override
  String get mapEventsStatusHidden => 'HIDDEN';

  @override
  String get mapEventsStatusCanceled => 'CANCELED';

  @override
  String get mapEventsApprovalPending => 'PENDING REVIEW';

  @override
  String get mapEventsApprovalAccepted => 'APPROVED';

  @override
  String get mapEventsApprovalRejected => 'REJECTED';

  @override
  String mapEventsRejectionReason(String reason) {
    return 'Reason: $reason';
  }

  @override
  String get mapEventsClose => 'Close';

  @override
  String get mapEventsShare => 'Share';

  @override
  String get mapEventsStatAttendees => 'ATTENDEES';

  @override
  String get mapEventsStatCars => 'CARS';

  @override
  String get mapEventsStatStarts => 'STARTS';

  @override
  String get mapEventsStatStarted => 'STARTED';

  @override
  String mapEventsGoingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count going',
      one: '1 going',
    );
    return '$_temp0';
  }

  @override
  String get mapEventsRoleOrganizer => 'organizer';

  @override
  String get mapEventsRoleCreator => 'creator';

  @override
  String get mapEventsChipIndividual => 'INDIVIDUAL';

  @override
  String get mapEventsChipBusiness => 'BUSINESS';

  @override
  String get mapEventsAttending => 'ATTENDING';

  @override
  String get mapEventsInterested => 'INTERESTED';

  @override
  String get mapEventsWantToParticipate => 'WANT TO PARTICIPATE?';

  @override
  String get mapEventsParticipateShort => 'PARTICIPATE?';

  @override
  String get mapEventsParticipating => 'PARTICIPATING';

  @override
  String mapEventsParticipatingCount(int count) {
    return 'PARTICIPATING · $count CARS';
  }

  @override
  String get mapEventsParticipationPending => 'PENDING';

  @override
  String get mapEventsWithdrawAction => 'WITHDRAW';

  @override
  String get mapEventsViewEvent => 'VIEW EVENT';

  @override
  String mapEventsCapacityOf(int capacity) {
    return 'of $capacity';
  }

  @override
  String get mapEventsTabOverview => 'OVERVIEW';

  @override
  String mapEventsTabCars(int count) {
    return 'CARS · $count';
  }

  @override
  String get mapEventsEntryListTitle => 'On the entry list';

  @override
  String mapEventsApprovedCount(int count) {
    return '$count APPROVED';
  }

  @override
  String get mapEventsSectionAbout => 'ABOUT THIS EVENT';

  @override
  String get mapEventsSectionOrganizers => 'ORGANIZERS';

  @override
  String get mapEventsSectionRules => 'NOTES FROM THE ORGANIZER';

  @override
  String get mapEventsSectionContests => 'CONTESTS';

  @override
  String get mapEventsSectionAttendees => 'ATTENDEES';

  @override
  String get mapEventsSoon => 'SOON';

  @override
  String get mapEventsContestsTitle => 'Contests';

  @override
  String get mapEventsContestsBody =>
      'Organizers will be able to run votes inside a meet — best build, cleanest bay, loudest exhaust.';

  @override
  String get mapEventsSeeAll => 'SEE ALL';

  @override
  String get mapEventsSeeAllAttendees => 'SEE ALL ATTENDEES';

  @override
  String mapEventsSeeAllCars(int count) {
    return 'SEE ALL $count CARS';
  }

  @override
  String mapEventsRegisterBefore(String deadline) {
    return 'Register your car before $deadline';
  }

  @override
  String get mapEventsRegistrationClosed =>
      'Registration has closed for this event.';

  @override
  String get mapEventsCapacityFull => 'The entry list is full.';

  @override
  String get mapEventsGarageLink => 'GARAGE';

  @override
  String get mapEventsEntryListEmpty => 'No cars on the entry list yet.';

  @override
  String get mapEventsAttendeesEmpty => 'Nobody has RSVP\'d yet.';

  @override
  String get mapEventsRetry => 'TRY AGAIN';

  @override
  String get mapEventsStripPendingTitle => 'Request pending';

  @override
  String get mapEventsStripPendingBody =>
      'The organizers will approve or decline your entry.';

  @override
  String get mapEventsStripDeclinedTitle => 'Entry declined';

  @override
  String get mapEventsStripDeclinedBody =>
      'The organizers declined this car for this event.';

  @override
  String get mapEventsStripWithdrawnTitle => 'Withdrawal requested';

  @override
  String get mapEventsStripWithdrawnBody =>
      'The organizers are reviewing your request to leave. You can\'t take it back.';

  @override
  String get mapEventsDeclineReasonHeading => 'WHY';

  @override
  String get mapEventsTryAnotherCar => 'TRY ANOTHER CAR';

  @override
  String get mapEventsCancelRequest => 'CANCEL REQUEST';

  @override
  String get mapEventsPickCarTitle => 'Which cars are you bringing?';

  @override
  String get mapEventsPickCarSubtitle => 'Select at least one car to register';

  @override
  String mapEventsPickCarSpotsLeft(int count) {
    return '$count spots left — select up to that many';
  }

  @override
  String get mapEventsPickCarFull =>
      'This event has reached its participant capacity.';

  @override
  String get mapEventsPickCarAlreadyIn => 'Already registered';

  @override
  String get mapEventsPickCarSelectAll => 'SELECT ALL';

  @override
  String get mapEventsPickCarClearAll => 'CLEAR';

  @override
  String mapEventsPickCarRegisterCta(int count) {
    return 'REGISTER ($count)';
  }

  @override
  String get mapEventsPickCarEmptyTitle => 'Your garage is empty';

  @override
  String get mapEventsPickCarEmptyBody =>
      'Add a car to your garage first, then register it for an event.';

  @override
  String get mapEventsPickCarAdd => 'ADD A CAR';

  @override
  String mapEventsCarYear(String year) {
    return '$year';
  }

  @override
  String get mapEventsWithdrawTitle => 'Withdraw from this event?';

  @override
  String get mapEventsWithdrawBody =>
      'You\'ll ask the organizers to take you off the entry list, and off any contests running inside this event. Once sent, the request can\'t be taken back.';

  @override
  String mapEventsWithdrawAllCars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'All $count of your cars leave the entry list together — there\'s no way to withdraw just one. An organizer has to approve it first.',
      one:
          'Your car leaves the entry list — an organizer has to approve it first.',
    );
    return '$_temp0';
  }

  @override
  String get mapEventsWithdrawNoteLabel => 'NOTE FOR ORGANIZERS (OPTIONAL)';

  @override
  String get mapEventsWithdrawNoteHint => 'Let them know why, if you\'d like…';

  @override
  String get mapEventsCancel => 'CANCEL';

  @override
  String get mapEventsAttendeesPageTitle => 'Attendees';

  @override
  String get mapEventsFilterAttending => 'ATTENDING';

  @override
  String get mapEventsFilterInterested => 'INTERESTED';

  @override
  String get mapEventsCreateTitle => 'NEW EVENT';

  @override
  String get mapEventsEditTitle => 'EDIT EVENT';

  @override
  String get mapEventsCoverAdd => 'ADD COVER PHOTO';

  @override
  String get mapEventsCoverHint => '1600 × 900 recommended';

  @override
  String get mapEventsCoverChange => 'CHANGE COVER';

  @override
  String get mapEventsFieldCover => 'COVER PHOTO';

  @override
  String get mapEventsFieldTitle => 'EVENT TITLE';

  @override
  String get mapEventsFieldTitleHint => 'e.g. Casino Square Cars & Coffee';

  @override
  String get mapEventsFieldCategory => 'EVENT CATEGORY';

  @override
  String get mapEventsCategoriesSoonNote => 'More categories are coming soon.';

  @override
  String get mapEventsCategoryTrackDay => 'Track Day';

  @override
  String get mapEventsCategoryCarsAndCoffee => 'Cars & Coffee';

  @override
  String get mapEventsCategoryCruise => 'Cruise';

  @override
  String get mapEventsFieldDescription => 'DESCRIPTION';

  @override
  String get mapEventsFieldDescriptionHint => 'What\'s the event about ?';

  @override
  String get mapEventsFieldLocation => 'LOCATION';

  @override
  String get mapEventsFieldVenueHint => 'Venue name — e.g. Place du Casino';

  @override
  String get mapEventsSetLocationOnMap => 'SET LOCATION ON MAP';

  @override
  String get mapEventsLocationSet => 'PIN PLACED · TAP TO MOVE';

  @override
  String get mapEventsFieldDateTime => 'DATE & TIME';

  @override
  String get mapEventsStartsLabel => 'Starts';

  @override
  String get mapEventsEndsLabel => 'Ends';

  @override
  String get mapEventsEndBlankHint =>
      'Leave the end blank for an open-ended event.';

  @override
  String get mapEventsClearEnd => 'CLEAR END';

  @override
  String get mapEventsFieldCapacity => 'MAX CAPACITY';

  @override
  String get mapEventsOptional => 'OPTIONAL';

  @override
  String get mapEventsRequired => 'REQUIRED';

  @override
  String get mapEventsCapacityHint => 'Empty defaults to no limit';

  @override
  String get mapEventsCapacityLockedHint =>
      'A capacity can be raised later, but not removed.';

  @override
  String get mapEventsApprovalToggleTitle => 'Require approval to join';

  @override
  String get mapEventsApprovalToggleBody =>
      'You and your co-organizers review each request before a participant is added to the entry list.';

  @override
  String get mapEventsFieldDeadline => 'REGISTRATION DEADLINE';

  @override
  String get mapEventsFieldRules => 'RULES & GUIDELINES';

  @override
  String get mapEventsAddRule => 'ADD A RULE';

  @override
  String get mapEventsRuleHint => 'e.g. No revving or burnouts.';

  @override
  String get mapEventsRemoveRule => 'Remove rule';

  @override
  String get mapEventsFieldOrganizers => 'ORGANIZERS';

  @override
  String get mapEventsOrganizersHint =>
      'You\'re the creator. Add other individual or certified business accounts to co-organize with you.';

  @override
  String get mapEventsYouCreator => 'YOU · CREATOR';

  @override
  String get mapEventsAddOrganizer => 'ADD ORGANIZER';

  @override
  String get mapEventsRemoveOrganizer => 'Remove organizer';

  @override
  String get mapEventsCreateCta => 'CREATE EVENT';

  @override
  String get mapEventsCreateCtaIncomplete => 'ADD TITLE, LOCATION & START TIME';

  @override
  String get mapEventsCreateCtaDeadline => 'ADD A REGISTRATION DEADLINE';

  @override
  String get mapEventsCreateCtaCover => 'ADD A COVER IMAGE';

  @override
  String get mapEventsSaveCta => 'SAVE CHANGES';

  @override
  String get mapEventsSubmitting => 'Just a moment…';

  @override
  String get mapEventsValidationEndBeforeStart =>
      'The end time has to be after the start time.';

  @override
  String get mapEventsValidationDeadlineAfterStart =>
      'The registration deadline has to be before the event starts.';

  @override
  String get mapEventsValidationCapacity => 'Capacity has to be at least 1.';

  @override
  String get mapEventsPendingReviewTitle => 'Sent for review';

  @override
  String get mapEventsPendingReviewBody =>
      'Our team checks every new event before it shows up on the map. You\'ll find it under Events on your profile in the meantime.';

  @override
  String get mapEventsDone => 'DONE';

  @override
  String get mapEventsCoverUploadFailed =>
      'The event was created, but the cover photo didn\'t upload. You can add it from My events.';

  @override
  String get mapEventsWizardNext => 'NEXT';

  @override
  String get mapEventsWizardBack => 'BACK';

  @override
  String get mapEventsWizardClose => 'Close';

  @override
  String get mapEventsWizardDiscardTitle => 'Leave the event draft?';

  @override
  String get mapEventsWizardDiscardBody =>
      'Your progress is saved on this device, so you can pick it up where you left off. Or throw it away and start fresh next time.';

  @override
  String get mapEventsWizardKeepDraft => 'SAVE & LEAVE';

  @override
  String get mapEventsWizardDiscardDraft => 'DISCARD';

  @override
  String get mapEventsWizardStay => 'KEEP EDITING';

  @override
  String get mapEventsDraftRestored => 'Picked up where you left off.';

  @override
  String get mapEventsDraftStartOver => 'START OVER';

  @override
  String get mapEventsStepBasicsTitle => 'The basics';

  @override
  String get mapEventsStepBasicsSubtitle =>
      'What\'s the event called, and what should people expect?';

  @override
  String get mapEventsStepOrganizersTitle => 'Who\'s running it';

  @override
  String get mapEventsStepOrganizersSubtitle =>
      'You\'re the creator. Add individual or certified business accounts to co-organize with you.';

  @override
  String get mapEventsStepOrganizersEmpty =>
      'No co-organizers yet. You can add them later too.';

  @override
  String get mapEventsStepWhenWhereTitle => 'When & where';

  @override
  String get mapEventsStepWhenWhereSubtitle =>
      'Set the schedule, then drop the pin on the map.';

  @override
  String get mapEventsLocationPickCta => 'PICK THE LOCATION ON THE MAP';

  @override
  String get mapEventsLocationChangeCta => 'CHANGE LOCATION';

  @override
  String get mapEventsLocationCardCity => 'City';

  @override
  String get mapEventsLocationCardStreet => 'Street';

  @override
  String get mapEventsLocationCardNumber => 'Number';

  @override
  String get mapEventsLocationCardPin => 'Pin dropped';

  @override
  String get mapEventsLocationEmptyHint =>
      'Pick a location and we\'ll fill in the city, street and number from the address you search.';

  @override
  String get mapEventsDeadlineHint =>
      'Car meets need one: the last moment someone can enter a car.';

  @override
  String get mapEventsStepRulesTitle => 'Rules & entry';

  @override
  String get mapEventsStepRulesSubtitle =>
      'House rules, how many cars fit, and whether you vet each one.';

  @override
  String get mapEventsRulesEmpty =>
      'No rules yet. Plenty of meets run fine without any.';

  @override
  String get mapEventsCapacityUnlimited => 'Unlimited';

  @override
  String get mapEventsCapacityUnlimitedHint => 'Leave it empty for no limit.';

  @override
  String get mapEventsStepContestsTitle => 'Contests';

  @override
  String get mapEventsStepContestsSubtitle =>
      'Line up the categories people will vote on. You can add, edit or remove them any time after the event is approved.';

  @override
  String get mapEventsContestsEmpty => 'No contests yet.';

  @override
  String get mapEventsAddContest => 'ADD A CONTEST';

  @override
  String get mapEventsEditContest => 'Edit contest';

  @override
  String get mapEventsRemoveContest => 'Remove contest';

  @override
  String get mapEventsContestsUnavailable =>
      'Contest categories couldn\'t be loaded. You can add contests from the event page once it\'s approved.';

  @override
  String mapEventsContestsFullHint(int count) {
    return 'An event can hold up to $count contests.';
  }

  @override
  String mapEventsContestsFailed(int count) {
    return 'The event was created, but $count of its contests weren\'t. You can add them from My events.';
  }

  @override
  String get mapEventsContestOpensLabel => 'Voting opens';

  @override
  String get mapEventsContestClosesLabel => 'Voting closes';

  @override
  String get mapEventsContestOpensAtStart => 'When the meet starts';

  @override
  String get mapEventsContestOpensNow => 'As soon as it\'s approved';

  @override
  String get mapEventsContestCustomTime => 'Pick a time';

  @override
  String get mapEventsContestClosesManualNote =>
      'Attendees see this time. You still open and close voting yourself, from the contests list once the event is approved.';

  @override
  String get mapEventsContestTitleLabel => 'CONTEST TITLE';

  @override
  String get mapEventsContestTitleHint => 'e.g. Best exhaust system';

  @override
  String get mapEventsContestCriteriaLabel => 'JUDGING NOTE';

  @override
  String get mapEventsContestCriteriaHint => 'What are people voting on?';

  @override
  String get mapEventsContestCategoryLabel => 'CATEGORY';

  @override
  String get mapEventsContestSave => 'SAVE CONTEST';

  @override
  String get mapEventsStepCoverTitle => 'Cover photo';

  @override
  String get mapEventsStepCoverSubtitle =>
      'The one image people see on the map, in the feed and at the top of the event.';

  @override
  String get mapEventsStepReviewTitle => 'Review & publish';

  @override
  String get mapEventsStepReviewSubtitle =>
      'This is how people will see it. Tap any section to go back and change it.';

  @override
  String get mapEventsReviewEdit => 'EDIT';

  @override
  String get mapEventsReviewNoDescription => 'No description yet';

  @override
  String get mapEventsReviewNoRules => 'No rules';

  @override
  String get mapEventsReviewNoContests => 'No contests';

  @override
  String get mapEventsReviewNoOrganizers => 'Just you';

  @override
  String get mapEventsReviewOpenEnded => 'Open-ended';

  @override
  String get mapEventsReviewApprovalOn => 'You approve each car';

  @override
  String get mapEventsReviewApprovalOff => 'Anyone can enter a car';

  @override
  String get mapEventsReviewSectionOrganizers => 'ORGANIZERS';

  @override
  String get mapEventsReviewSectionSchedule => 'SCHEDULE';

  @override
  String get mapEventsReviewSectionEntry => 'ENTRY';

  @override
  String get mapEventsPublishCta => 'PUBLISH FOR REVIEW';

  @override
  String get mapEventsValidationTitle => 'Give the event a title.';

  @override
  String get mapEventsValidationDescription =>
      'Add a short description so people know what it is.';

  @override
  String get mapEventsValidationLocation => 'Pick the location on the map.';

  @override
  String get mapEventsValidationStart => 'Set when the event starts.';

  @override
  String get mapEventsValidationDeadlineRequired =>
      'A car meet needs a registration deadline.';

  @override
  String get mapEventsValidationCover => 'Add a cover photo.';

  @override
  String get mapEventsUseThisLocation => 'USE THIS LOCATION';

  @override
  String get mapEventsLocationFormTitle => 'Find the address';

  @override
  String get mapEventsLocationFormSubtitle =>
      'We\'ll point the map at it. You place the exact pin yourself.';

  @override
  String get mapEventsLocationCity => 'CITY';

  @override
  String get mapEventsLocationCityHint => 'eg: Cluj-Napoca';

  @override
  String get mapEventsLocationStreet => 'STREET';

  @override
  String get mapEventsLocationStreetHint => 'eg: Strada Memorandumului';

  @override
  String get mapEventsLocationNumber => 'NUMBER';

  @override
  String get mapEventsLocationNumberHint => 'eg: 28B';

  @override
  String get mapEventsLocationSearchButton => 'SEARCH';

  @override
  String get mapEventsLocationSearchIncomplete => 'FILL IN ALL THREE FIELDS';

  @override
  String get mapEventsLocationSearchNoResults =>
      'No matches for that address. Check the spelling, or search the street without the number.';

  @override
  String get mapEventsLocationResultsTitle => 'Choose the closest match';

  @override
  String get mapEventsLocationResultsSubtitle =>
      'This only moves the map — you still drop the pin.';

  @override
  String get mapEventsLocationEditSearch => 'EDIT SEARCH';

  @override
  String get mapEventsLocationBackToResults => 'RESULTS';

  @override
  String get mapEventsLocationDropPinTitle => 'Tap the map to drop your pin';

  @override
  String get mapEventsLocationDropPinBody =>
      'Tap the exact spot — the entrance, the yard, the parking area.';

  @override
  String get mapEventsLocationPinDropped =>
      'Pin dropped. Tap again to move it.';

  @override
  String get mapEventsLocationPrecisionExact => 'EXACT ADDRESS';

  @override
  String get mapEventsLocationPrecisionPoint => 'NEARBY POINT';

  @override
  String get mapEventsLocationPrecisionIntersection => 'INTERSECTION';

  @override
  String get mapEventsLocationPrecisionApproximate => 'APPROXIMATE';

  @override
  String get mapEventsLocationPrecisionStreet => 'STREET LEVEL';

  @override
  String get mapEventsLocationPrecisionAddress => 'ADDRESS';

  @override
  String get mapEventsLocationPrecisionPostcode => 'POSTCODE AREA';

  @override
  String get mapEventsLocationPrecisionArea => 'WIDER AREA';

  @override
  String get mapEventsSearchOrganizersTitle => 'Add an organizer';

  @override
  String get mapEventsSearchOrganizersHint => 'Search people and businesses';

  @override
  String get mapEventsSearchOrganizersEmpty => 'Nobody matched that.';

  @override
  String get mapEventsSearchOrganizersPrompt =>
      'Start typing a name to find people and certified businesses.';

  @override
  String get profileTabEvents => 'Events';

  @override
  String get mapEventsMineTitle => 'My events';

  @override
  String get mapEventsMineEmptyTitle => 'No events yet';

  @override
  String get mapEventsMineEmptyBody =>
      'Events you create show up here — including the ones still waiting for review.';

  @override
  String get mapEventsMineCreate => 'CREATE AN EVENT';

  @override
  String get mapEventsManageTitle => 'Manage event';

  @override
  String get mapEventsManageEntries => 'ENTRY REQUESTS';

  @override
  String get mapEventsManageWithdrawals => 'WITHDRAWAL REQUESTS';

  @override
  String get mapEventsManageOrganizers => 'ORGANIZERS';

  @override
  String get mapEventsManageDanger => 'EVENT';

  @override
  String get mapEventsNoPendingEntries => 'No entry requests waiting.';

  @override
  String get mapEventsNoWithdrawals => 'No withdrawal requests waiting.';

  @override
  String get mapEventsAccept => 'ACCEPT';

  @override
  String get mapEventsDecline => 'DECLINE';

  @override
  String get mapEventsDeclineTitle => 'Decline this entry?';

  @override
  String mapEventsDeclineBody(String car) {
    return '$car won\'t be on the entry list. The owner sees your reason, so make it something they can act on.';
  }

  @override
  String get mapEventsDeclineReasonLabel => 'REASON (REQUIRED)';

  @override
  String get mapEventsDeclineReasonHint =>
      'Wrong category for a JDM-only meet…';

  @override
  String get mapEventsLetThemOut => 'LET THEM OUT';

  @override
  String get mapEventsKeepThemIn => 'KEEP THEM IN';

  @override
  String get mapEventsWithdrawalNoteLabel => 'Their note';

  @override
  String get mapEventsEditEvent => 'EDIT EVENT';

  @override
  String get mapEventsCancelEvent => 'CANCEL EVENT';

  @override
  String get mapEventsFinishEvent => 'FINISH EVENT';

  @override
  String get mapEventsDeleteEvent => 'DELETE EVENT';

  @override
  String get mapEventsEditLockedHint =>
      'An event can only be edited while it\'s waiting for review or after it\'s been rejected.';

  @override
  String get mapEventsConfirmCancelTitle => 'Cancel this event?';

  @override
  String get mapEventsConfirmCancelBody =>
      'It stays visible but is marked as canceled, and nobody can register a car anymore.';

  @override
  String get mapEventsConfirmFinishTitle => 'Finish this event?';

  @override
  String get mapEventsConfirmFinishBody =>
      'It moves to your past events. RSVPs and the entry list stay as they are.';

  @override
  String get mapEventsConfirmDeleteTitle => 'Delete this event?';

  @override
  String get mapEventsConfirmDeleteBody =>
      'This can\'t be undone. The entry list and every RSVP go with it.';

  @override
  String get mapEventsConfirm => 'CONFIRM';

  @override
  String get mapEventsDelete => 'DELETE';

  @override
  String mapEventsWithdrawalCarsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cars',
      one: '1 car',
    );
    return '$_temp0';
  }

  @override
  String get mapSearchPlaceholder => 'Search meets, shops, cities…';

  @override
  String get mapCreateEvent => 'Create an event';

  @override
  String get mapEventsCopied => 'Event details copied.';

  @override
  String get mapEventsDateCardTitle => 'When';

  @override
  String get feedbackFeedEyebrow => 'COMMUNITY';

  @override
  String get feedbackFeedTitle => 'Feedback';

  @override
  String get feedbackFeedNew => 'NEW';

  @override
  String get feedbackFeedSortNewest => 'NEWEST';

  @override
  String get feedbackFeedSortPopular => 'POPULAR';

  @override
  String get feedbackFeedSortOldest => 'OLDEST';

  @override
  String get feedbackFeedCompletedLink => 'Completed requests';

  @override
  String get feedbackFeedCompletedTitle => 'Completed requests';

  @override
  String get feedbackFeedComposeEyebrow => 'FEEDBACK COMMUNITY';

  @override
  String get feedbackFeedComposeTitle => 'Share feedback';

  @override
  String get feedbackFeedComposeSubtitle =>
      'Visible to everyone. Other drivers can upvote or downvote it.';

  @override
  String get feedbackFeedCategoryLabel => 'CATEGORY';

  @override
  String get feedbackFeedMessageLabel => 'YOUR MESSAGE';

  @override
  String get feedbackFeedMessageHint =>
      'What’s on your mind — a bug, an idea, a tweak?';

  @override
  String get feedbackFeedPostAction => 'POST FEEDBACK';

  @override
  String get feedbackFeedPostSuccess => 'Your feedback is live.';

  @override
  String get feedbackFeedYou => 'you';

  @override
  String feedbackFeedNetVotes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count net votes',
      one: '1 net vote',
    );
    return '$_temp0';
  }

  @override
  String feedbackFeedShippedAgo(String time) {
    return 'shipped $time ago';
  }

  @override
  String feedbackFeedTimeAgo(String time) {
    return '$time ago';
  }

  @override
  String get feedbackFeedStaffLabel => 'TWEAKD TEAM';

  @override
  String get feedbackFeedDelete => 'Delete';

  @override
  String get feedbackFeedDeleteTitle => 'Delete this feedback?';

  @override
  String get feedbackFeedDeleteBody =>
      'This can’t be undone. The votes it collected go with it.';

  @override
  String get feedbackFeedDeleteSuccess => 'Feedback deleted.';

  @override
  String get feedbackFeedCancel => 'Cancel';

  @override
  String get feedbackFeedEmptyTitle => 'Nothing here yet';

  @override
  String get feedbackFeedEmptyBody =>
      'Be the first to report a bug or pitch an idea.';

  @override
  String get feedbackFeedCompletedEmptyTitle => 'Nothing shipped yet';

  @override
  String get feedbackFeedCompletedEmptyBody =>
      'Once we finish a request, it lands here.';

  @override
  String get feedbackFeedRetry => 'Try again';

  @override
  String get feedbackFeedErrorNetwork =>
      'No internet connection. Please try again.';

  @override
  String get feedbackFeedErrorNotFound => 'This feedback no longer exists.';

  @override
  String get feedbackFeedErrorLocked =>
      'We’ve already picked this up, so it can’t be deleted anymore.';

  @override
  String get feedbackFeedErrorGeneric =>
      'Something went wrong. Please try again.';

  @override
  String get profileBadgesAll => 'ALL';

  @override
  String get profileBadgesSheetTitle => 'Badges';

  @override
  String get profileBadgesEmptyVisitor => 'No badges yet.';

  @override
  String get garageCarStatYear => 'YEAR';

  @override
  String profileBadgesSheetUnlocked(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString unlocked',
      one: '1 unlocked',
      zero: 'No badges yet',
    );
    return '$_temp0';
  }

  @override
  String get createPostTitle => 'Post';

  @override
  String get createPostSubtitle => 'Photos of your build, a drive or a detail';

  @override
  String get createThreadTitle => 'Forum thread';

  @override
  String get createThreadSubtitle => 'Ask a question or start a discussion';

  @override
  String get createEventTitle => 'Car event';

  @override
  String get createEventSubtitle => 'Host a meet, a cruise or a track day';

  @override
  String get createModTitle => 'Add modification';

  @override
  String get createModSubtitle =>
      'Log a new part or upgrade on one of your cars';

  @override
  String get feedSegmentFeed => 'Feed';

  @override
  String get forumsBrowseAction => 'Browse forums';

  @override
  String get forumsSavedAction => 'Saved threads';

  @override
  String get garageCarStatPower => 'POWER';

  @override
  String get garageCarStatTorque => 'TORQUE';

  @override
  String get garageCarUnitPower => 'hp';

  @override
  String get garageCarUnitTorque => 'lb-ft';

  @override
  String get commonContinue => 'Continue';

  @override
  String get badgeCelebrationHeadline => 'New badge unlocked!';

  @override
  String get contestsTab => 'CONTESTS';

  @override
  String get contestsSectionVotingOpen => 'VOTING OPEN NOW';

  @override
  String get contestsSectionOpensLater => 'OPENS LATER';

  @override
  String get contestsSectionResults => 'RESULTS';

  @override
  String contestsStandingEntered(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Your car is entered in $count contests',
      one: 'Your car is entered in 1 contest',
    );
    return '$_temp0';
  }

  @override
  String get contestsStandingNotEntered => 'Your car isn\'t entered yet';

  @override
  String contestsVotesOpenToYou(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count votes still open to you',
      one: '1 vote still open to you',
      zero: 'You\'ve voted in every open contest',
    );
    return '$_temp0';
  }

  @override
  String get contestsManage => 'MANAGE';

  @override
  String get contestsEnterCar => 'ENTER';

  @override
  String get contestsFooterNote =>
      'One vote per contest. You can change it any time until the organizer closes voting.';

  @override
  String get contestsEmptyTitle => 'No contests here';

  @override
  String get contestsEmptyBody =>
      'The organizer hasn\'t opened any votes for this meet.';

  @override
  String contestsAllCount(int count) {
    return 'ALL $count CONTESTS';
  }

  @override
  String contestsCarsAndVotes(int cars, int votes) {
    String _temp0 = intl.Intl.pluralLogic(
      cars,
      locale: localeName,
      other: '$cars cars',
      one: '1 car',
    );
    String _temp1 = intl.Intl.pluralLogic(
      votes,
      locale: localeName,
      other: '$votes votes',
      one: '1 vote',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String contestsCarsEnteredCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cars entered',
      one: '1 car entered',
    );
    return '$_temp0';
  }

  @override
  String get contestsYoursIsIn => '· yours is in';

  @override
  String get contestsCastYourVote => 'CAST YOUR VOTE';

  @override
  String get contestsVoteBeforeClose => 'VOTE BEFORE IT CLOSES';

  @override
  String get contestsVote => 'VOTE';

  @override
  String get contestsVoted => 'VOTED';

  @override
  String get contestsYourVote => 'YOUR VOTE';

  @override
  String get contestsChange => 'CHANGE';

  @override
  String contestsTimeLeftHours(int hours, int minutes) {
    return '${hours}h ${minutes}m left';
  }

  @override
  String contestsTimeLeftMinutes(int minutes) {
    return '${minutes}m left';
  }

  @override
  String contestsOpensInHours(int hours, int minutes) {
    return 'opens in ${hours}h ${minutes}m';
  }

  @override
  String contestsOpensInMinutes(int minutes) {
    return 'opens in ${minutes}m';
  }

  @override
  String get contestsOpensSoon => 'waiting for the organizer';

  @override
  String get contestsVotingOpenNow => 'voting open';

  @override
  String get contestsClosing => 'closing';

  @override
  String get contestsResultsIn => 'RESULTS IN';

  @override
  String get contestsClosed => 'CLOSED';

  @override
  String get contestsStatVotesCast => 'VOTES CAST';

  @override
  String get contestsStatCarsIn => 'CARS IN';

  @override
  String get contestsStatRemaining => 'REMAINING';

  @override
  String get contestsStatStatus => 'STATUS';

  @override
  String get contestsStatVoting => 'VOTING';

  @override
  String get contestsHowItWorks => 'HOW IT WORKS';

  @override
  String get contestsHowItWasJudged => 'HOW IT WAS JUDGED';

  @override
  String contestsSetBy(String username) {
    return 'Set by @$username';
  }

  @override
  String get contestsLeaderboard => 'LEADERBOARD';

  @override
  String get contestsCarsEntered => 'CARS ENTERED';

  @override
  String get contestsFinalStandings => 'FINAL STANDINGS';

  @override
  String get contestsUpdatingLive => 'UPDATING LIVE';

  @override
  String contestsVotingOpensAt(String time) {
    return 'Planned to open at $time — the organizer starts it';
  }

  @override
  String get contestsNoEntriesYet => 'No cars on the ballot yet.';

  @override
  String get contestsWinner => 'WINNER';

  @override
  String contestsVotesOf(int votes, int total) {
    return '$votes of $total votes';
  }

  @override
  String contestsBadgeAwarded(String category) {
    return '$category badge awarded';
  }

  @override
  String get contestsBadgeAwardedBody =>
      'Now on the car and the owner\'s profile';

  @override
  String get contestsNoWinner =>
      'Nobody voted, so there is no winner this time.';

  @override
  String get contestsThatsYourCar => 'That\'s your car';

  @override
  String get contestsPostToFeedHint => 'Post the card to your feed';

  @override
  String get contestsShare => 'SHARE';

  @override
  String get contestsShareYourWin => 'SHARE YOUR WIN';

  @override
  String get contestsShareTheResult => 'SHARE THE RESULT';

  @override
  String get contestsShareSheetTitle => 'Share your win';

  @override
  String get contestsShareResultSheetTitle => 'Share the result';

  @override
  String get contestsPostToFeed => 'POST TO FEED';

  @override
  String get contestsPostedTitle => 'Posted to the feed';

  @override
  String get contestsPostedBody => 'Your followers can see it now';

  @override
  String get contestsPostFailed => 'Couldn\'t post the card. Try again.';

  @override
  String get contestsCaptionHint => 'Say something about the win (optional)';

  @override
  String contestsShareText(
    String car,
    String place,
    String contest,
    String event,
  ) {
    return '$car took $place in \"$contest\" at $event on Tweakd';
  }

  @override
  String contestsOfVotes(int total) {
    return 'OF $total VOTES';
  }

  @override
  String get contestsPickFavourite => 'Pick your favourite';

  @override
  String get contestsChangeYourVote => 'Change your vote';

  @override
  String get contestsSaveNewVote => 'SAVE NEW VOTE';

  @override
  String get contestsCastVote => 'CAST VOTE';

  @override
  String get contestsYourCar => 'YOUR CAR';

  @override
  String get contestsEnterTitle => 'Enter your car';

  @override
  String get contestsApprovedForMeet => 'Approved for this meet';

  @override
  String get contestsEnterHint =>
      'Pick the categories you want to be judged in. The organizer approves each entry. You can pull out until voting opens.';

  @override
  String get contestsEntryLocked => 'Voting open — entry locked in';

  @override
  String get contestsVotingAlreadyOpen => 'Voting already open';

  @override
  String get contestsEntryPending => 'Waiting for the organizer';

  @override
  String get contestsEntryRejected => 'Not accepted';

  @override
  String get contestsWhy => 'WHY';

  @override
  String get contestsSaveEntries => 'SAVE ENTRIES';

  @override
  String get contestsEntriesSaved => 'Entries updated';

  @override
  String contestsVoteCounted(String car) {
    return 'Vote counted for $car';
  }

  @override
  String get contestsCannotVoteOwnCar => 'You can\'t vote for your own car';

  @override
  String get contestsVotingClosedHint => 'Voting has closed';

  @override
  String get contestsAttendToVote =>
      'RSVP as attending to vote in this contest';

  @override
  String get contestsOrganizerTitle => 'Contests';

  @override
  String contestsOrganizerSubtitle(String event) {
    return '$event · you\'re an organizer';
  }

  @override
  String get contestsNew => 'NEW';

  @override
  String get contestsStatRunning => 'RUNNING';

  @override
  String get contestsStatScheduled => 'SCHEDULED';

  @override
  String get contestsStatVotesTonight => 'VOTES SO FAR';

  @override
  String get contestsRunningNow => 'RUNNING NOW';

  @override
  String get contestsScheduled => 'SCHEDULED';

  @override
  String get contestsFinished => 'FINISHED';

  @override
  String get contestsChipOpen => 'OPEN';

  @override
  String get contestsChipClosed => 'CLOSED';

  @override
  String get contestsChipScheduled => 'SCHEDULED';

  @override
  String get contestsFullBoard => 'FULL BOARD';

  @override
  String get contestsFinishNow => 'FINISH NOW';

  @override
  String get contestsEdit => 'EDIT';

  @override
  String get contestsOpenVotingNow => 'OPEN VOTING NOW';

  @override
  String get contestsExtend => 'EXTEND';

  @override
  String get contestsDelete => 'DELETE';

  @override
  String get contestsResultsPublished => 'Results published · badge awarded';

  @override
  String get contestsNoVotesResult => 'Closed with no votes';

  @override
  String get contestsAddAnother => 'ADD ANOTHER CONTEST';

  @override
  String get contestsAddFirst => 'CREATE A CONTEST';

  @override
  String get contestsOrganizerEmpty =>
      'No contests yet. Open a vote and everyone at the meet can pick their favourite.';

  @override
  String contestsClosedAtVotes(String time, int votes) {
    String _temp0 = intl.Intl.pluralLogic(
      votes,
      locale: localeName,
      other: '$votes votes',
      one: '1 vote',
    );
    return 'Closed $time · $_temp0';
  }

  @override
  String contestsLeftAndVotes(String left, int votes) {
    String _temp0 = intl.Intl.pluralLogic(
      votes,
      locale: localeName,
      other: '$votes votes',
      one: '1 vote',
    );
    return '$left · $_temp0';
  }

  @override
  String contestsOpensAndCars(String opens, int cars) {
    String _temp0 = intl.Intl.pluralLogic(
      cars,
      locale: localeName,
      other: '$cars cars entered',
      one: '1 car entered',
    );
    return '$opens · $_temp0';
  }

  @override
  String contestsFinishTitle(String title) {
    return 'Finish \"$title\"?';
  }

  @override
  String contestsFinishBody(String timeLeft) {
    return 'Voting closes immediately — $timeLeft early. The standings freeze as they are now and the winner gets the badge.';
  }

  @override
  String get contestsFinishBodyNoVotes =>
      'Voting closes immediately. Nobody has voted yet, so there will be no winner.';

  @override
  String get contestsFinishBodyPastPlan =>
      'Voting closes immediately. It has been running past the time you planned. The standings freeze as they are now and the winner gets the badge.';

  @override
  String get contestsWinsIfFinishNow => 'WINS IF YOU FINISH NOW';

  @override
  String contestsCloseRace(int gap) {
    String _temp0 = intl.Intl.pluralLogic(
      gap,
      locale: localeName,
      other: 'Only $gap votes ahead of second — it could still flip.',
      one: 'Only 1 vote ahead of second — it could still flip.',
    );
    return '$_temp0';
  }

  @override
  String contestsClearLead(int gap) {
    return 'Clear lead — $gap votes ahead of second.';
  }

  @override
  String get contestsKeepOpen => 'KEEP IT OPEN';

  @override
  String get contestsFinishPublish => 'FINISH & PUBLISH';

  @override
  String contestsFinishedBanner(String title) {
    return '\"$title\" finished';
  }

  @override
  String get contestsFinishedBannerBody =>
      'Results are live · everyone at the meet was notified';

  @override
  String contestsPendingEntries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count CARS WAITING',
      one: '1 CAR WAITING',
    );
    return '$_temp0';
  }

  @override
  String get contestsAccept => 'ACCEPT';

  @override
  String get contestsDecline => 'DECLINE';

  @override
  String get contestsDeclineEntryTitle => 'Decline this car?';

  @override
  String get contestsDeclineEntryHint =>
      'Tell the owner why. They\'ll see this.';

  @override
  String get contestsExtendTitle => 'Extend voting';

  @override
  String get contestsExtendBody =>
      'Pick the new closing time attendees see. It is a plan, not a deadline — voting runs until you finish the contest.';

  @override
  String contestsExtendClosesAt(String time) {
    return 'Closes $time';
  }

  @override
  String get contestsExtendConfirm => 'EXTEND VOTING';

  @override
  String get contestsDeleteTitle => 'Delete this contest?';

  @override
  String get contestsDeleteBody =>
      'It hasn\'t opened yet, so nothing is lost — the cars that entered are simply released.';

  @override
  String get contestsCreateTitle => 'New contest';

  @override
  String get contestsEditTitle => 'Edit contest';

  @override
  String get contestsCategory => 'CATEGORY';

  @override
  String get contestsCategoryCustom => 'Custom';

  @override
  String get contestsName => 'CONTEST NAME';

  @override
  String get contestsNameHint => 'Name shown to attendees';

  @override
  String get contestsNameHintCustom => 'e.g. Best daily driver';

  @override
  String get contestsCriteria => 'HOW SHOULD PEOPLE JUDGE IT?';

  @override
  String get contestsCriteriaHint =>
      'One or two lines. Attendees see this above the leaderboard.';

  @override
  String get contestsVotingOpens => 'VOTING OPENS';

  @override
  String get contestsOpensNow => 'Right away';

  @override
  String get contestsOpensAtStart => 'At the start of the meet';

  @override
  String get contestsSetATime => 'Set a time';

  @override
  String get contestsVotingCloses => 'VOTING CLOSES';

  @override
  String get contestsFinishEarlyNote =>
      'These times are what attendees see. You open the voting and close it yourself, from the contests list.';

  @override
  String get contestsLockedOpenNote =>
      'Voting is open: only the judging note and the closing time can change now.';

  @override
  String get contestsPublish => 'PUBLISH CONTEST';

  @override
  String get contestsSaveChanges => 'SAVE CHANGES';

  @override
  String get contestsManageSectionTitle => 'CONTESTS';

  @override
  String get contestsManageOpen => 'Open contests';

  @override
  String contestsManageSummary(int running, int scheduled) {
    String _temp0 = intl.Intl.pluralLogic(
      running,
      locale: localeName,
      other: '$running running',
      one: '1 running',
      zero: 'None running',
    );
    String _temp1 = intl.Intl.pluralLogic(
      scheduled,
      locale: localeName,
      other: '$scheduled scheduled',
      one: '1 scheduled',
      zero: 'none scheduled',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String get contestsErrorNotEligible => 'You can\'t vote in this contest.';

  @override
  String get contestsRank1 => '1st';

  @override
  String get contestsRank2 => '2nd';

  @override
  String get contestsRank3 => '3rd';

  @override
  String contestsRankN(int rank) {
    return '${rank}th';
  }

  @override
  String participantCardPlace(String rank) {
    return '$rank Place';
  }

  @override
  String get participantCardEvent => 'EVENT';

  @override
  String get participantCardContests => 'CONTESTS ENTERED';

  @override
  String participantCardContestWithRank(String contest, String rank) {
    return '$contest ($rank)';
  }

  @override
  String participantCardMore(int count) {
    return '+$count more';
  }

  @override
  String participantCardAttendees(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people were at the event.',
      one: '1 person was at the event.',
      zero: 'Nobody checked in at the event.',
    );
    return '$_temp0';
  }

  @override
  String get participantCardContestsSheetTitle => 'Contests entered';

  @override
  String get participantCardTookPart => 'Took part';

  @override
  String get participantCardShareSheetTitle => 'Share your card';

  @override
  String participantCardShareText(String car, String event) {
    return '$car was at $event on Tweakd';
  }

  @override
  String participantCardShareTextPlaced(
    String car,
    String place,
    String contest,
    String event,
  ) {
    return '$car took $place in \"$contest\" at $event on Tweakd';
  }

  @override
  String get participantCardShare => 'SHARE THE CARD';

  @override
  String participantCardSectionTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'YOUR CARDS',
      one: 'YOUR CARD',
    );
    return '$_temp0';
  }

  @override
  String get participantCardYourCard => 'YOUR CARD';

  @override
  String get participantCardNotReady =>
      'Your card will be ready once the organizer finishes the event.';

  @override
  String participantCardCooldown(String date) {
    return 'You shared this card recently. You can share it again on $date.';
  }

  @override
  String get carEventsContestBadges => 'CONTEST BADGES';

  @override
  String carEventsBadgesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count CONTEST BADGES',
      one: '1 CONTEST BADGE',
    );
    return '$_temp0';
  }

  @override
  String get carEventsAttended => 'ATTENDED EVENTS';

  @override
  String get carEventsWhereFrom => 'WHERE THEY CAME FROM';

  @override
  String carEventsPlacement(String rank, String category) {
    return '$rank · $category';
  }
}
