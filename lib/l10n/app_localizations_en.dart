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
  String get profileTitle => 'PROFILE';

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
      other: '$count Machines',
      one: '1 Machine',
      zero: '0 Machines',
    );
    return '$_temp0';
  }

  @override
  String get garageAddButton => '+ ADD';

  @override
  String get garageEmptyOwner =>
      'Your garage is empty. Add your first machine.';

  @override
  String get garageEmptyVisitor => 'No machines yet.';

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
  String get feedComingSoon => 'Coming soon';

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
  String get garagePhaseCreating => 'Creating machine…';

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
  String get garageDeleteMachineTitle => 'Delete machine?';

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
  String get garageCarRegistered => 'Machine registered!';

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
      'You haven\'t registered this machine yet. If you leave now, everything you entered will be lost.';

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
  String get postsLoadMore => 'LOAD MORE';

  @override
  String get postsEmptyOwner => 'You haven\'t posted yet.';

  @override
  String get postsEmptyVisitor => 'No posts yet.';

  @override
  String get postsCreateFirst => 'CREATE YOUR FIRST POST';

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
}
