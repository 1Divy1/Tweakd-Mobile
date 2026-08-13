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
  String get authLoginSubtitle => 'Sign in to get back in the garage.';

  @override
  String get authSignupTitle => 'Join the grid';

  @override
  String get authSignupSubtitle =>
      'Create your account and connect with the community';

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
  String get authUsernameLabel => 'Username';

  @override
  String get authUsernameHint => 'username';

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
  String authComingSoon(String feature) {
    return '$feature is coming soon.';
  }

  @override
  String authFeatureProviderSignIn(String provider) {
    return '$provider sign-in';
  }

  @override
  String get authFeaturePasswordRecovery => 'Password recovery';

  @override
  String get authFeatureEmailSignUp => 'Email sign up';

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
  String get onboardingStart => 'START';

  @override
  String get onboardingFinish => 'FINISH';

  @override
  String onboardingStepCounter(int current, int total) {
    return 'STEP $current / $total';
  }

  @override
  String get onboardingOptional => 'OPTIONAL';

  @override
  String get onboardingSearchHint => 'Search…';

  @override
  String get onboardingNoMatches => 'No matches';

  @override
  String get onboardingStepIdentity => 'IDENTITY';

  @override
  String get onboardingStepGarage => 'PREFERENCES';

  @override
  String get onboardingStepRole => 'ROLE';

  @override
  String get onboardingStepTaste => 'TASTE';

  @override
  String get onboardingStepLocation => 'LOCATION';

  @override
  String get onboardingStepNotifications => 'NOTIFICATIONS';

  @override
  String get onboardingErrorPickRole => 'Pick at least one role.';

  @override
  String onboardingErrorPickCategory(int count) {
    return 'Pick at least $count category to continue.';
  }

  @override
  String get onboardingErrorSelectCity => 'Select your city to continue.';

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
  String get onboardingUsernameHelp => 'This will be your public handle.';

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
  String get onboardingIdentitySubtitle =>
      'This is how the community finds and mentions you. Add a short bio so people get your vibe at a glance.';

  @override
  String get onboardingFieldUsername => 'USERNAME';

  @override
  String get onboardingFieldBio => 'BIO';

  @override
  String get onboardingBioHint => 'Tell others a few things about yourself…';

  @override
  String get onboardingGarageLabel => '02 — PREFERENCES';

  @override
  String get onboardingGarageTitle => 'Brands & models you love';

  @override
  String get onboardingGarageSubtitle =>
      'Pick your favorite brands and models. We’ll tune your feed around them.';

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
  String get onboardingRoleLabel => '03 — ROLE';

  @override
  String get onboardingRoleTitle => 'Your role in the scene';

  @override
  String get onboardingRoleSubtitle =>
      'How do you show up in the community? Choose all that apply.';

  @override
  String get onboardingFieldRoles => 'ROLES';

  @override
  String get onboardingTasteLabel => '04 — TASTE';

  @override
  String get onboardingTasteTitle => 'Categories you’re into';

  @override
  String get onboardingTasteSubtitle =>
      'Select the categories you’re passionate about. We’ll lead with these across your feed and the marketplace.';

  @override
  String get onboardingFieldCategories => 'CATEGORIES';

  @override
  String onboardingTasteSelectedCount(int count) {
    return '$count selected';
  }

  @override
  String get onboardingTastePickHint =>
      ' · pick at least 1 to calibrate your feed.';

  @override
  String get onboardingLocationLabel => '05 — LOCATION';

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
  String get onboardingNotificationsLabel => '06 — NOTIFICATIONS';

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
  String get onboardingNotifGroupMarketplace => 'MARKETPLACE';

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
  String get onboardingNotifPriceDropsTitle => 'Price drops';

  @override
  String get onboardingNotifPriceDropsSubtitle =>
      'When a saved item gets a discount';

  @override
  String get onboardingNotifTagsTitle => 'Tags';

  @override
  String get onboardingNotifTagsSubtitle => 'When someone tags you or your car';

  @override
  String get profileTitle => 'PROFILE';

  @override
  String get profileMessage => 'Message';

  @override
  String get profileStatFollowers => 'FOLLOWERS';

  @override
  String get profileStatFollowing => 'FOLLOWING';

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
  String get garageSectionEyebrow => 'THE GARAGE';

  @override
  String garageMachineCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Cars',
      one: '1 Car',
      zero: '0 Cars',
    );
    return '$_temp0';
  }

  @override
  String get garageAddButton => '+ ADD';

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
  String get navFeed => 'FEED';

  @override
  String get navMap => 'MAP';

  @override
  String get navSearch => 'SEARCH';

  @override
  String get navContests => 'CONTESTS';

  @override
  String get navCreate => 'CREATE';

  @override
  String get navProfile => 'PROFILE';

  @override
  String get feedEmptyTitle => 'Your feed is quiet';

  @override
  String get feedEmptyMessage =>
      'Posts from the community will show up here. Check back soon.';

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
  String get garageRegisterStepIdentity => 'IDENTITY';

  @override
  String get garageRegisterStepPerformance => 'PERFORMANCE';

  @override
  String get garageRegisterStepConfiguration => 'CONFIGURATION';

  @override
  String get garageRegisterStepStory => 'STORY';

  @override
  String get garageRegisterStepGallery => 'GALLERY';

  @override
  String get garageRegisterStepMods => 'MODS';

  @override
  String get garageRegisterStart => 'START';

  @override
  String get garageRegisterFinish => 'FINISH';

  @override
  String garageRegisterStepCounter(int current, int total) {
    return 'STEP $current / $total';
  }

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
  String get garageRegisterIdentityLabel => '01 — IDENTITY';

  @override
  String get garageRegisterIdentityTitle => 'Visual & basics';

  @override
  String get garageFieldPrimaryAsset => 'PRIMARY ASSET';

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
  String get garageFieldChassisCode => 'CHASSIS CODE';

  @override
  String get garageFieldModelCode => 'MODEL CODE';

  @override
  String get garageHintModelCode => 'e.g. G30';

  @override
  String get garagePrimaryAssetBadge => 'PRIMARY · 1 / 1';

  @override
  String get garageStudioShotReplace => 'Studio shot · tap to replace';

  @override
  String get garageAddStudioShot => 'Add the studio shot';

  @override
  String get garagePickFromGallery => 'Tap to pick from your gallery';

  @override
  String get garageRegisterPerformanceLabel => '02 — PERFORMANCE';

  @override
  String get garageRegisterPerformanceTitle => 'Power & weight';

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
  String get garagePowerToWeight => 'POWER-TO-WEIGHT · AUTO';

  @override
  String get garageRegisterConfigurationLabel => '03 — CONFIGURATION';

  @override
  String get garageRegisterConfigurationTitle => 'Configuration';

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
  String get garageRegisterStoryLabel => '04 — STORY';

  @override
  String get garageRegisterStoryTitle => 'What\'s this car\'s story? Share it…';

  @override
  String get garageFieldStatus => 'STATUS';

  @override
  String get garageFieldTheStory => 'THE STORY';

  @override
  String get garageHintStory => 'What\'s this car\'s story? Share it…';

  @override
  String get garageRegisterGalleryLabel => '05 — GALLERY';

  @override
  String get garageRegisterGalleryTitle => 'Show it off';

  @override
  String get garageFieldPhotos => 'PHOTOS';

  @override
  String get garageGalleryAdd => 'ADD';

  @override
  String get garageGalleryHint =>
      'Up to 8 photos. The cover leads your chassis card — drag to reorder.';

  @override
  String get garageGalleryCover => 'COVER';

  @override
  String get garageRegisterModsLabel => '06 — MODS';

  @override
  String get garageRegisterModsTitle => 'Build log';

  @override
  String get garageRegisterModsSubtitle =>
      'Optional — log the work that makes it yours.';

  @override
  String get garageModFallbackCategory => 'MODIFICATION';

  @override
  String get garageAddModification => 'ADD MODIFICATION';

  @override
  String get garageModSheetLabel => '— MODIFICATION';

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
  String get garageModValidationEdit =>
      'Category, title and date are required.';

  @override
  String get garageModValidationAdd =>
      'Category, title, date and both images are required.';

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
  String get garageDiscardTitle => 'Discard this build?';

  @override
  String get garageDiscardBody =>
      'You haven\'t registered this car yet. If you leave now, everything you entered will be lost.';

  @override
  String get garageKeepEditing => 'Keep editing';

  @override
  String get garageDiscard => 'Discard';

  @override
  String get garageLogModTitle => 'LOG BUILD ITERATION';

  @override
  String get garageLogModSectionLabel => '— MODIFICATION';

  @override
  String get garageLogModSectionTitle => 'Log a build iteration';

  @override
  String get garageLogModCategoryHint => 'e.g. Engine, Suspension, Aesthetics';

  @override
  String get garageLogModTitleHint => 'e.g. Stage 2 turbo upgrade';

  @override
  String get garageLogModDescLabel => 'DESCRIPTION (OPTIONAL)';

  @override
  String get garageLogModDescHint => 'Notes, observations, upgrades done…';

  @override
  String get garageLogModBeforeAfter => 'BEFORE & AFTER';

  @override
  String get garageLogModInstallDate => 'INSTALLATION DATE';

  @override
  String get garageLogModPriceLabel => 'PRICE (OPTIONAL)';

  @override
  String get garageLogModMileageLabel => 'MILEAGE AT INSTALL (OPTIONAL)';

  @override
  String get garageLogModMileageHint => 'e.g. 45000';

  @override
  String get garageLogModSubmit => 'LOG MODIFICATION';

  @override
  String get garageLogModLogged => 'Modification logged!';

  @override
  String get garageLogModValCategory => 'Please select a category.';

  @override
  String get garageLogModValTitle => 'Please enter a title.';

  @override
  String get garageLogModValBefore => 'Please pick a before image.';

  @override
  String get garageLogModValAfter => 'Please pick an after image.';

  @override
  String get garageLogModValDate => 'Please select the installation date.';

  @override
  String get authErrorSessionExpired =>
      'Your session is not active. Please log in again.';

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
  String get postNewPost => 'NEW POST';

  @override
  String get postStepPhotos => 'PHOTOS';

  @override
  String get postStepCaption => 'CAPTION';

  @override
  String get postStepTags => 'TAGS';

  @override
  String get postStepVisibility => 'VISIBILITY';

  @override
  String get postStepReview => 'REVIEW';

  @override
  String get postStart => 'START';

  @override
  String get postPublishStep => 'PUBLISH';

  @override
  String get postBack => 'BACK';

  @override
  String get postNext => 'NEXT';

  @override
  String get postPublish => 'PUBLISH POST';

  @override
  String postStepCounter(int current, int total) {
    return 'STEP $current / $total';
  }

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
  String get profileTabPosts => 'POSTS';

  @override
  String get profileTabGarage => 'GARAGE';

  @override
  String get profileTabTags => 'TAGS';

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
  String get navForums => 'FORUMS';

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
  String get forumsEmptyTitle => 'Pin the forums you live in';

  @override
  String get forumsEmptyBody =>
      'Shortcuts are saved filters — a car, a topic, or both. Pin a few and they land right here.';

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
  String get mapEventsParticipationPending => 'PENDING';

  @override
  String get mapEventsWithdrawAction => 'WITHDRAW';

  @override
  String mapEventsCarOnEntryList(String car) {
    return 'Your $car is on the entry list';
  }

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
  String get mapEventsPickCarTitle => 'Which car are you bringing?';

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
  String get mapEventsCategoryCarShow => 'Car Show';

  @override
  String get mapEventsCategoryCruise => 'Cruise';

  @override
  String get mapEventsFieldDescription => 'DESCRIPTION';

  @override
  String get mapEventsFieldDescriptionHint =>
      'What\'s the event about, who\'s it for, anything people should know before showing up…';

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
  String get mapEventsCapacityHint => 'No limit — e.g. 40 spots';

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
  String get mapEventsPickLocationTitle => 'Place the pin';

  @override
  String get mapEventsPickLocationHint =>
      'Move the map so the pin sits where the event happens.';

  @override
  String get mapEventsUseThisLocation => 'USE THIS LOCATION';

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
  String get profileTabEvents => 'EVENTS';

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
}
