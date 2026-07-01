// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Romanian Moldavian Moldovan (`ro`).
class AppLocalizationsRo extends AppLocalizations {
  AppLocalizationsRo([String locale = 'ro']) : super(locale);

  @override
  String get appTitle => 'Tweakd';

  @override
  String get settingsLanguage => 'Limbă';

  @override
  String get languageEnglish => 'Engleză';

  @override
  String get languageRomanian => 'Română';

  @override
  String get commonSave => 'Salvează';

  @override
  String get commonCancel => 'Anulează';

  @override
  String get commonRetry => 'Reîncearcă';

  @override
  String profileFollowers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count de urmăritori',
      one: '1 urmăritor',
      zero: 'Niciun urmăritor',
    );
    return '$_temp0';
  }

  @override
  String greetingHello(String name) {
    return 'Salut, $name!';
  }

  @override
  String get authLoginTitle => 'Bine ai revenit';

  @override
  String get authLoginSubtitle => '';

  @override
  String get authSignupTitle => '';

  @override
  String get authSignupSubtitle =>
      'Crează-ți un cont și conectează-te cu ceilalți membrii ai comunității';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authEmailHint => 'tu@email.com';

  @override
  String get authPasswordLabel => 'Parolă';

  @override
  String get authPasswordHintLogin => 'Introdu parola';

  @override
  String get authPasswordHintSignup => 'Creează o parolă';

  @override
  String get authUsernameLabel => 'Nume de utilizator';

  @override
  String get authUsernameHint => 'nume utilizator';

  @override
  String get authForgotPassword => 'AI UITAT PAROLA?';

  @override
  String get authSignIn => 'Conectează-te';

  @override
  String get authCreateAccount => 'Creează cont';

  @override
  String get authOrContinueWith => 'Sau continuă cu';

  @override
  String get authOrSignUpWith => 'Sau înregistrează-te cu';

  @override
  String get authNoAccountPrefix => 'Nou pe Tweakd? ';

  @override
  String get authHaveAccountPrefix => 'Ai deja un cont? ';

  @override
  String get authTermsPrefix => 'Prin crearea unui cont ești de acord cu ';

  @override
  String get authTermsTerms => 'Termenii';

  @override
  String get authTermsAnd => ' și ';

  @override
  String get authTermsPrivacy => 'Politica de confidențialitate';

  @override
  String authComingSoon(String feature) {
    return '$feature va fi disponibil în curând.';
  }

  @override
  String authFeatureProviderSignIn(String provider) {
    return 'Conectarea cu $provider';
  }

  @override
  String get authFeaturePasswordRecovery => 'Recuperarea parolei';

  @override
  String get authFeatureEmailSignUp => 'Înregistrarea prin email';

  @override
  String get onboardingBack => 'ÎNAPOI';

  @override
  String get onboardingNext => 'CONTINUĂ';

  @override
  String get onboardingFinishSetup => 'FINALIZEAZĂ';

  @override
  String get onboardingFinishingSetup => 'Se finalizează…';

  @override
  String get onboardingWorking => 'Se procesează…';

  @override
  String get onboardingStart => 'START';

  @override
  String get onboardingFinish => 'FINAL';

  @override
  String onboardingStepCounter(int current, int total) {
    return 'PASUL $current / $total';
  }

  @override
  String get onboardingOptional => 'OPȚIONAL';

  @override
  String get onboardingSearchHint => 'Caută…';

  @override
  String get onboardingNoMatches => 'Niciun rezultat';

  @override
  String get onboardingStepIdentity => 'IDENTITATE';

  @override
  String get onboardingStepGarage => 'PREFERINȚE';

  @override
  String get onboardingStepRole => 'ROL';

  @override
  String get onboardingStepTaste => 'STILURI';

  @override
  String get onboardingStepLocation => 'LOCAȚIE';

  @override
  String get onboardingStepNotifications => 'NOTIFICĂRI';

  @override
  String get onboardingErrorPickRole => 'Alege cel puțin un rol.';

  @override
  String onboardingErrorPickCategory(int count) {
    return 'Alege cel puțin $count categorie pentru a continua.';
  }

  @override
  String get onboardingErrorSelectCity =>
      'Selectează orașul pentru a continua.';

  @override
  String get onboardingUsernameErrorEmpty => 'Alege un nume de utilizator.';

  @override
  String onboardingUsernameErrorTooShort(int min) {
    return 'Numele trebuie să aibă cel puțin $min caractere.';
  }

  @override
  String onboardingUsernameErrorTooLong(int max) {
    return 'Numele poate avea cel mult $max caractere.';
  }

  @override
  String get onboardingUsernameErrorInvalidChars =>
      'Folosește litere mici, cifre, puncte (.) și liniuțe de subliniere (_).';

  @override
  String get onboardingUsernameChecking => 'Se verifică disponibilitatea…';

  @override
  String get onboardingUsernameTaken => ' este deja folosit';

  @override
  String get onboardingUsernameAvailable => ' este disponibil';

  @override
  String get onboardingUsernameCheckFailed =>
      'Nu am putut verifica disponibilitatea. Apasă Continuă pentru a încerca oricum.';

  @override
  String get onboardingUsernameHelp => 'Acesta va fi numele tău public.';

  @override
  String get onboardingUsernameHint => 'numele_tau';

  @override
  String get onboardingErrorLoadFailed =>
      'Nu am putut încărca datele. Încearcă din nou.';

  @override
  String get onboardingErrorUsernameTaken =>
      'Acest nume este deja folosit. Încearcă altul.';

  @override
  String get onboardingErrorSessionExpired =>
      'Sesiunea ta nu mai este activă. Te rugăm să te conectezi din nou.';

  @override
  String get onboardingErrorInvalidUsername =>
      'Acest nume nu este valid. Încearcă altul.';

  @override
  String get onboardingErrorGeneric => 'Ceva nu a mers bine. Încearcă din nou.';

  @override
  String get onboardingIdentityLabel => '01 — IDENTITATE';

  @override
  String get onboardingIdentityTitle => 'Alege-ți numele';

  @override
  String get onboardingIdentitySubtitle =>
      'Așa te găsește comunitatea și te menționează. Adaugă o scurtă descriere ca lumea să-ți prindă stilul dintr-o privire.';

  @override
  String get onboardingFieldUsername => 'NUME DE UTILIZATOR';

  @override
  String get onboardingFieldBio => 'DESCRIERE';

  @override
  String get onboardingBioHint =>
      'Spune-le celorlalți câteva lucruri despre tine...';

  @override
  String get onboardingGarageLabel => '02 — PREFERINȚE';

  @override
  String get onboardingGarageTitle => 'Mărci și modele preferate';

  @override
  String get onboardingGarageSubtitle =>
      'Alege mărcile și modelele preferate. Îți vom personaliza feed-ul în jurul lor.';

  @override
  String get onboardingFieldYourPicks => 'ALEGERILE TALE';

  @override
  String get onboardingFieldModels => 'MODELE';

  @override
  String get onboardingSelectBrand => 'Alege o marcă';

  @override
  String get onboardingAddModels => 'Adaugă modele';

  @override
  String onboardingBrandModels(String brand) {
    return 'Modele $brand';
  }

  @override
  String get onboardingAddBrand => 'ADAUGĂ ALTĂ MARCĂ';

  @override
  String get onboardingRoleLabel => '03 — ROL';

  @override
  String get onboardingRoleTitle => 'Rolul tău în comunitate';

  @override
  String get onboardingRoleSubtitle =>
      'Cum te implici în comunitate? Alege tot ce ți se potrivește.';

  @override
  String get onboardingFieldRoles => 'ROLURI';

  @override
  String get onboardingTasteLabel => '04 — STILURI';

  @override
  String get onboardingTasteTitle => 'Categoriile care îți plac';

  @override
  String get onboardingTasteSubtitle =>
      'Selectează categoriile care te pasionează. Le vom pune în prim-plan în feed și în marketplace.';

  @override
  String get onboardingFieldCategories => 'CATEGORII';

  @override
  String onboardingTasteSelectedCount(int count) {
    return '$count selectate';
  }

  @override
  String get onboardingTastePickHint =>
      ' · alege cel puțin 1 pentru a-ți calibra feed-ul.';

  @override
  String get onboardingLocationLabel => '05 — LOCAȚIE';

  @override
  String get onboardingLocationTitle => 'Unde te găsește comunitatea locală?';

  @override
  String get onboardingLocationSubtitle =>
      'Locația ne ajută să-ți personalizăm experiența în aplicație cu carmeet-uri locale, evenimente și oferte din marketplace relevante';

  @override
  String get onboardingFieldCountry => 'ȚARĂ';

  @override
  String get onboardingFieldRegion => 'REGIUNE';

  @override
  String get onboardingFieldCity => 'ORAȘ';

  @override
  String get onboardingSelectCountryPlaceholder => 'Selectează țara';

  @override
  String get onboardingSelectRegionPlaceholder => 'Selectează regiunea';

  @override
  String get onboardingPickCountryFirst => 'Alege mai întâi o țară';

  @override
  String get onboardingSelectCityPlaceholder => 'Selectează orașul';

  @override
  String get onboardingPickRegionFirst => 'Alege mai întâi o regiune';

  @override
  String get onboardingPickerCountry => 'Selectează țara';

  @override
  String get onboardingPickerRegion => 'Selectează regiunea';

  @override
  String get onboardingPickerCity => 'Selectează orașul';

  @override
  String get onboardingDiscoveryRadius => 'RAZĂ DE DESCOPERIRE';

  @override
  String get onboardingNotificationsLabel => '06 — NOTIFICĂRI';

  @override
  String get onboardingNotificationsTitle => 'Despre ce să te anunțăm?';

  @override
  String get onboardingNotificationsSubtitle =>
      'Fii la curent cu ce contează. Poți ajusta oricare dintre acestea mai târziu.';

  @override
  String get onboardingPushGrantedText =>
      'Notificările push sunt activate. Alege mai jos despre ce vrei să afli.';

  @override
  String get onboardingPushBlockedTitle => 'Notificările push sunt dezactivate';

  @override
  String get onboardingPushBlockedSubtitle =>
      'Sunt blocate în setările sistemului. Activează-le ca să te anunțăm despre subiectele de mai jos.';

  @override
  String get onboardingPushOpenSettings => 'DESCHIDE SETĂRILE';

  @override
  String get onboardingPushEnableTitle => 'Activează notificările push';

  @override
  String get onboardingPushEnableSubtitle =>
      'Permite notificările ca să te putem anunța despre subiectele alese mai jos.';

  @override
  String get onboardingPushEnable => 'ACTIVEAZĂ';

  @override
  String get onboardingNotifGroupContent => 'PE CONȚINUTUL TĂU';

  @override
  String get onboardingNotifGroupMessages => 'MESAJE';

  @override
  String onboardingNotifGroupMeets(int radius) {
    return 'ÎNTÂLNIRI & EVENIMENTE · LA MAX $radius KM';
  }

  @override
  String get onboardingNotifGroupMarketplace => 'MARKETPLACE';

  @override
  String get onboardingNotifLikesTitle => 'Aprecieri';

  @override
  String get onboardingNotifLikesSubtitle =>
      'Când cineva apreciază proiectele și postările tale';

  @override
  String get onboardingNotifCommentsTitle => 'Comentarii';

  @override
  String get onboardingNotifCommentsSubtitle =>
      'Răspunsuri și discuții pe conținutul tău';

  @override
  String get onboardingNotifSharesTitle => 'Distribuiri';

  @override
  String get onboardingNotifSharesSubtitle =>
      'Când conținutul tău este redistribuit';

  @override
  String get onboardingNotifDmsTitle => 'Mesaje directe';

  @override
  String get onboardingNotifDmsSubtitle => 'Mesaje noi și cereri de mesaje';

  @override
  String get onboardingNotifFlashMeetsTitle => 'Întâlniri spontane';

  @override
  String get onboardingNotifFlashMeetsSubtitle =>
      'Întâlniri spontane care au loc lângă tine';

  @override
  String get onboardingNotifEventsTitle => 'Evenimente organizate';

  @override
  String get onboardingNotifEventsSubtitle =>
      'Expoziții, zile pe circuit și cars-and-coffee';

  @override
  String get onboardingNotifPriceDropsTitle => 'Scăderi de preț';

  @override
  String get onboardingNotifPriceDropsSubtitle =>
      'Când un articol salvat primește o reducere';

  @override
  String get profileTitle => 'PROFIL';

  @override
  String get profileStatFollowers => 'URMĂRITORI';

  @override
  String get profileStatFollowing => 'URMĂREȘTE';

  @override
  String get profileErrorUsernameTaken =>
      'Acest nume de utilizator este deja folosit. Alege altul.';

  @override
  String get profileErrorSessionExpired =>
      'Sesiunea ta nu mai este activă. Te rugăm să te conectezi din nou.';

  @override
  String get profileErrorNotFound => 'Acest profil nu a putut fi găsit.';

  @override
  String get profileErrorInvalidUsername =>
      'Acest nume de utilizator nu este valid. Încearcă altul.';

  @override
  String get profileErrorGeneric => 'Ceva nu a mers bine. Încearcă din nou.';

  @override
  String get followActionFollow => 'URMĂREȘTE';

  @override
  String get followActionUnfollow => 'NU MAI URMĂRI';

  @override
  String get followActionRequested => 'SOLICITAT';

  @override
  String get garageSectionEyebrow => 'GARAJUL';

  @override
  String garageMachineCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mașini',
      one: '1 mașină',
      zero: '0 mașini',
    );
    return '$_temp0';
  }

  @override
  String get garageAddButton => '+ ADAUGĂ';

  @override
  String get garageEmptyOwner =>
      'Garajul tău este gol. Adaugă prima ta mașină.';

  @override
  String get garageEmptyVisitor => 'Nicio mașină încă.';

  @override
  String get followActionFollowing => 'URMĂREȘTI';

  @override
  String get followRemove => 'ELIMINĂ';

  @override
  String get followSearchFollowersHint => 'Caută urmăritori...';

  @override
  String get followSearchFollowingHint => 'Caută urmăriri...';

  @override
  String followResultsForQuery(String query) {
    return 'PENTRU \"$query\"';
  }

  @override
  String followNoResultsQuery(String query) {
    return 'Niciun rezultat pentru \"$query\"';
  }

  @override
  String get followNoFollowers => 'Niciun urmăritor încă';

  @override
  String get followNoFollowing => 'Nu urmărește pe nimeni încă';

  @override
  String get followErrorCannotFollowSelf => 'Nu te poți urmări pe tine însuți.';

  @override
  String get followErrorPrivateProfile => 'Acest profil este privat.';

  @override
  String get followErrorUserNotFound => 'Acest utilizator nu a putut fi găsit.';

  @override
  String get followErrorRequestNotFound =>
      'Această cerere de urmărire nu a putut fi găsită.';

  @override
  String get followErrorSessionExpired =>
      'Sesiunea ta nu mai este activă. Te rugăm să te conectezi din nou.';

  @override
  String get followErrorGeneric => 'Ceva nu a mers bine. Încearcă din nou.';

  @override
  String get searchTitle => 'CĂUTARE';

  @override
  String get searchInputHint => 'Caută după nume de utilizator';

  @override
  String get searchEmptyTitle => 'Caută membrii ai comunității';

  @override
  String get searchEmptySubtitle =>
      'Scrie un nume de utilizator ca să găsești\nmembrii din comunitate.';

  @override
  String searchResultsDrivers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count UTILIZATORI',
      one: '1 UTILIZATOR',
    );
    return '$_temp0';
  }

  @override
  String searchForQuery(String query) {
    return 'PENTRU \"$query\"';
  }

  @override
  String searchNoResults(String query) {
    return 'Niciun utilizator găsit pentru \"$query\"';
  }

  @override
  String get searchErrorGeneric => 'Ceva nu a mers bine. Încearcă din nou.';

  @override
  String get navFeed => 'FEED';

  @override
  String get navMap => 'HARTĂ';

  @override
  String get navSearch => 'CĂUTARE';

  @override
  String get navContests => 'CONCURSURI';

  @override
  String get navCreate => 'CREEAZĂ';

  @override
  String get navProfile => 'PROFIL';

  @override
  String get feedComingSoon => 'În curând';

  @override
  String get feedEmptyTitle => 'Feedul tău e liniștit';

  @override
  String get feedEmptyMessage =>
      'Postările din comunitate vor apărea aici. Revino în curând.';

  @override
  String get feedErrorNetwork =>
      'Nicio conexiune la internet. Verifică rețeaua și încearcă din nou.';

  @override
  String get feedErrorGeneric =>
      'Nu am putut încărca feedul. Te rugăm să încerci din nou.';

  @override
  String get garageErrorCarNotFound => 'Această mașină nu a putut fi găsită.';

  @override
  String get garageErrorGarageNotFound => 'Acest garaj nu a putut fi găsit.';

  @override
  String get garageErrorPrivateGarage => 'Acest garaj este privat.';

  @override
  String get garageErrorNotOwner => 'Nu ai permisiunea să faci asta.';

  @override
  String get garageErrorInvalidReference =>
      'Unele dintre opțiunile selectate nu sunt valide.';

  @override
  String get garageErrorGeneric => 'Ceva nu a mers bine. Încearcă din nou.';

  @override
  String get garageErrorRefDataLoadFailed =>
      'Nu am putut încărca datele formularului. Încearcă din nou.';

  @override
  String get garageErrorCategoriesLoadFailed =>
      'Nu am putut încărca categoriile. Încearcă din nou.';

  @override
  String get garageErrorPhotoUploadFailed =>
      'Încărcarea fotografiilor a eșuat. Încearcă din nou.';

  @override
  String get garageErrorEditSaveFailed =>
      'Unele modificări nu au putut fi salvate. Încearcă din nou.';

  @override
  String get garagePhaseCreating => 'Se creează mașina…';

  @override
  String get garagePhaseUploadingPhotos => 'Se încarcă fotografiile…';

  @override
  String get garagePhaseSavingChanges => 'Se salvează modificările…';

  @override
  String get garagePhaseSavingPhotos => 'Se salvează fotografiile…';

  @override
  String get garageRegisterStepIdentity => 'IDENTITATE';

  @override
  String get garageRegisterStepPerformance => 'PERFORMANȚĂ';

  @override
  String get garageRegisterStepConfiguration => 'CONFIGURAȚIE';

  @override
  String get garageRegisterStepStory => 'POVESTE';

  @override
  String get garageRegisterStepGallery => 'GALERIE';

  @override
  String get garageRegisterStepMods => 'MODIFICĂRI';

  @override
  String get garageRegisterStart => 'START';

  @override
  String get garageRegisterFinish => 'FINAL';

  @override
  String garageRegisterStepCounter(int current, int total) {
    return 'PASUL $current / $total';
  }

  @override
  String get garageRegisterBack => 'ÎNAPOI';

  @override
  String get garageRegisterNext => 'CONTINUĂ';

  @override
  String get garageRegisterWorking => 'Se procesează…';

  @override
  String get garageRegisterAddCar => 'ADAUGĂ MAȘINA';

  @override
  String get garageRegisterSave => 'SALVEAZĂ';

  @override
  String get garageOptional => 'OPȚIONAL';

  @override
  String get garageSearchHint => 'Caută…';

  @override
  String get garageNoMatches => 'Niciun rezultat';

  @override
  String get garageRegisterIdentityLabel => '01 — IDENTITATE';

  @override
  String get garageRegisterIdentityTitle => 'Imagine & detalii';

  @override
  String get garageFieldPrimaryAsset => 'IMAGINE PRINCIPALĂ';

  @override
  String get garageFieldMake => 'MARCĂ';

  @override
  String get garageHintMake => 'ex. Porsche';

  @override
  String get garagePickerMake => 'Alege marca';

  @override
  String get garageFieldModel => 'MODEL';

  @override
  String get garageHintModelPickMakeFirst => 'Alege mai întâi o marcă';

  @override
  String get garageHintModel => 'ex. 911 GT3 RS';

  @override
  String get garagePickerModel => 'Alege modelul';

  @override
  String get garageFieldYear => 'AN';

  @override
  String get garageFieldChassisCode => 'COD ȘASIU';

  @override
  String get garageFieldModelCode => 'COD MODEL';

  @override
  String get garageHintModelCode => 'ex. G30';

  @override
  String get garagePrimaryAssetBadge => 'PRINCIPALĂ · 1 / 1';

  @override
  String get garageStudioShotReplace =>
      'Cadru de studio · atinge pentru a înlocui';

  @override
  String get garageAddStudioShot => 'Adaugă cadrul de studio';

  @override
  String get garagePickFromGallery => 'Atinge pentru a alege din galerie';

  @override
  String get garageRegisterPerformanceLabel => '02 — PERFORMANȚĂ';

  @override
  String get garageRegisterPerformanceTitle => 'Putere & greutate';

  @override
  String get garageFieldPower => 'PUTERE';

  @override
  String get garageFieldTorque => 'CUPLU';

  @override
  String get garageFieldWeight => 'GREUTATE';

  @override
  String get garageFieldDisplacement => 'CILINDREE';

  @override
  String get garageFieldEngineCode => 'COD MOTOR';

  @override
  String get garageHintEngineCode => 'ex. S58';

  @override
  String get garageFieldFuelType => 'TIP COMBUSTIBIL';

  @override
  String get garageHintFuelType => 'ex. Benzină';

  @override
  String get garagePickerFuelType => 'Alege tipul de combustibil';

  @override
  String get garagePowerToWeight => 'PUTERE-LA-GREUTATE · AUTO';

  @override
  String get garageRegisterConfigurationLabel => '03 — CONFIGURAȚIE';

  @override
  String get garageRegisterConfigurationTitle => 'Configurație';

  @override
  String get garageFieldDrivetrain => 'TRACȚIUNE';

  @override
  String get garageHintDrivetrain => 'ex. Tracțiune spate';

  @override
  String get garagePickerDrivetrain => 'Alege tracțiunea';

  @override
  String get garageFieldColor => 'CULOARE';

  @override
  String get garageHintColor => 'ex. Portocaliu Inka';

  @override
  String get garagePickerColor => 'Alege culoarea';

  @override
  String get garageFieldMileageUnit => 'UNITATE KILOMETRAJ';

  @override
  String get garageFieldMileage => 'KILOMETRAJ';

  @override
  String get garageHintMileage => 'ex. 42000';

  @override
  String get garageRegisterStoryLabel => '04 — POVESTE';

  @override
  String get garageRegisterStoryTitle =>
      'Care e povestea acestei mașini? Spune-o…';

  @override
  String get garageFieldStatus => 'STARE';

  @override
  String get garageFieldTheStory => 'POVESTEA';

  @override
  String get garageHintStory => 'Care e povestea acestei mașini? Spune-o…';

  @override
  String get garageRegisterGalleryLabel => '05 — GALERIE';

  @override
  String get garageRegisterGalleryTitle => 'Arat-o';

  @override
  String get garageFieldPhotos => 'FOTOGRAFII';

  @override
  String get garageGalleryAdd => 'ADAUGĂ';

  @override
  String get garageGalleryHint =>
      'Până la 8 fotografii. Coperta deschide fișa mașinii — trage pentru a reordona.';

  @override
  String get garageGalleryCover => 'COPERTĂ';

  @override
  String get garageRegisterModsLabel => '06 — MODIFICĂRI';

  @override
  String get garageRegisterModsTitle => 'Jurnal de proiect';

  @override
  String get garageRegisterModsSubtitle =>
      'Opțional — notează munca ce o face a ta.';

  @override
  String get garageModFallbackCategory => 'MODIFICARE';

  @override
  String get garageAddModification => 'ADAUGĂ MODIFICARE';

  @override
  String get garageModSheetLabel => '— MODIFICARE';

  @override
  String get garageModSheetTitleEdit => 'Editează elementul';

  @override
  String get garageModSheetTitleAdd => 'Adaugă un element';

  @override
  String get garageFieldCategory => 'CATEGORIE';

  @override
  String get garageHintCategory => 'ex. Motor';

  @override
  String get garagePickerCategory => 'Alege categoria';

  @override
  String get garageFieldTitle => 'TITLU';

  @override
  String get garageHintModTitle => 'ex. Turbo stage 2';

  @override
  String get garageFieldDescription => 'DESCRIERE';

  @override
  String get garageHintModDescription => 'Ce s-a schimbat și ce a câștigat…';

  @override
  String get garageFieldInstallationDate => 'DATA INSTALĂRII';

  @override
  String get garageSelectDate => 'Alege data';

  @override
  String get garageFieldPrice => 'PREȚ';

  @override
  String get garageFieldMileageShort => 'KILOMETRAJ';

  @override
  String get garageModBefore => 'ÎNAINTE';

  @override
  String get garageModAfter => 'DUPĂ';

  @override
  String get garageModSaveChanges => 'SALVEAZĂ MODIFICĂRILE';

  @override
  String get garageModAddToBuildLog => 'ADAUGĂ ÎN JURNAL';

  @override
  String get garageModValidationEdit =>
      'Categoria, titlul și data sunt obligatorii.';

  @override
  String get garageModValidationAdd =>
      'Categoria, titlul, data și ambele imagini sunt obligatorii.';

  @override
  String get garageAboutTitle => 'DESPRE';

  @override
  String garageBuildIdentifier(String code) {
    return 'IDENTIFICATOR · $code';
  }

  @override
  String get garageSpecPower => 'PUTERE';

  @override
  String get garageSpecTorque => 'CUPLU';

  @override
  String get garageSpecWeight => 'GREUTATE';

  @override
  String get garageInfoDrivetrain => 'TRACȚIUNE';

  @override
  String get garageInfoMileage => 'KILOMETRAJ';

  @override
  String get garageInfoModelCode => 'COD MODEL';

  @override
  String get garageInfoEngineCode => 'COD MOTOR';

  @override
  String get garageInfoDisplacement => 'CILINDREE';

  @override
  String get garageInfoFuelType => 'TIP COMBUSTIBIL';

  @override
  String get garageInfoStatus => 'STARE';

  @override
  String get garageStoryHeading => 'POVESTEA';

  @override
  String get garageGalleryHeading => 'GALERIE';

  @override
  String get garageLogBuildIteration => '+ ADAUGĂ MODIFICARE';

  @override
  String get garageModLogHeading => 'JURNAL MODIFICĂRI';

  @override
  String get garageEditCar => 'Editează mașina';

  @override
  String get garageDeleteCar => 'Șterge mașina';

  @override
  String get garageDeleteMachineTitle => 'Ștergi mașina?';

  @override
  String get garageDeleteMachineBody =>
      'Aceasta va elimina definitiv mașina și toate modificările ei din garajul tău. Acțiunea nu poate fi anulată.';

  @override
  String get garageDialogCancel => 'Anulează';

  @override
  String get garageDialogDelete => 'Șterge';

  @override
  String get garageDeletePhotoTitle => 'Ștergi fotografia?';

  @override
  String get garageDeletePhotoBody =>
      'Această fotografie din galerie va fi eliminată definitiv.';

  @override
  String get garageDeleteModTitle => 'Ștergi modificarea?';

  @override
  String get garageDeleteModBody =>
      'Aceasta va elimina definitiv modificarea și fotografiile ei din jurnal. Acțiunea nu poate fi anulată.';

  @override
  String get garageDeleteModMenu => 'Șterge modificarea';

  @override
  String get garageCarRegistered => 'Mașină înregistrată!';

  @override
  String get garageChangesSaved => 'Modificări salvate!';

  @override
  String get garageValCoverPhoto => 'Alege o fotografie de copertă.';

  @override
  String get garageValMake => 'Selectează o marcă.';

  @override
  String get garageValModel => 'Selectează un model.';

  @override
  String get garageValYear => 'Introdu anul.';

  @override
  String get garageValHorsepower => 'Introdu puterea.';

  @override
  String get garageValTorque => 'Introdu cuplul.';

  @override
  String get garageValWeight => 'Introdu greutatea.';

  @override
  String get garageValDisplacement => 'Introdu cilindreea.';

  @override
  String get garageValFuelType => 'Selectează tipul de combustibil.';

  @override
  String get garageValDrivetrain => 'Selectează tracțiunea.';

  @override
  String get garageValColor => 'Selectează culoarea.';

  @override
  String get garageValMileageUnit => 'Selectează unitatea de kilometraj.';

  @override
  String get garageValStatus => 'Selectează o stare.';

  @override
  String get garageDiscardTitle => 'Renunți la acest proiect?';

  @override
  String get garageDiscardBody =>
      'Încă nu ai înregistrat această mașină. Dacă pleci acum, tot ce ai introdus se va pierde.';

  @override
  String get garageKeepEditing => 'Continuă editarea';

  @override
  String get garageDiscard => 'Renunță';

  @override
  String get garageLogModTitle => 'ADAUGĂ MODIFICARE';

  @override
  String get garageLogModSectionLabel => '— MODIFICARE';

  @override
  String get garageLogModSectionTitle => 'Adaugă o modificare';

  @override
  String get garageLogModCategoryHint => 'ex. Motor, Suspensie, Estetică';

  @override
  String get garageLogModTitleHint => 'ex. Upgrade turbo stage 2';

  @override
  String get garageLogModDescLabel => 'DESCRIERE (OPȚIONAL)';

  @override
  String get garageLogModDescHint => 'Note, observații, upgrade-uri făcute…';

  @override
  String get garageLogModBeforeAfter => 'ÎNAINTE & DUPĂ';

  @override
  String get garageLogModInstallDate => 'DATA INSTALĂRII';

  @override
  String get garageLogModPriceLabel => 'PREȚ (OPȚIONAL)';

  @override
  String get garageLogModMileageLabel => 'KILOMETRAJ LA INSTALARE (OPȚIONAL)';

  @override
  String get garageLogModMileageHint => 'ex. 45000';

  @override
  String get garageLogModSubmit => 'ADAUGĂ MODIFICAREA';

  @override
  String get garageLogModLogged => 'Modificare adăugată!';

  @override
  String get garageLogModValCategory => 'Selectează o categorie.';

  @override
  String get garageLogModValTitle => 'Introdu un titlu.';

  @override
  String get garageLogModValBefore => 'Alege o imagine „înainte”.';

  @override
  String get garageLogModValAfter => 'Alege o imagine „după”.';

  @override
  String get garageLogModValDate => 'Selectează data instalării.';

  @override
  String get authErrorSessionExpired =>
      'Sesiunea ta nu mai este activă. Te rugăm să te conectezi din nou.';

  @override
  String get authErrorGeneric => 'Ceva nu a mers bine. Încearcă din nou.';

  @override
  String get settingsTitle => 'SETĂRI';

  @override
  String get settingsLogout => 'Deconectare';

  @override
  String get settingsLogoutTitle => 'Te deconectezi?';

  @override
  String get settingsLogoutBody =>
      'Va trebui să te conectezi din nou pentru a-ți accesa contul.';

  @override
  String get postNewPost => 'POSTARE NOUĂ';

  @override
  String get postStepPhotos => 'POZE';

  @override
  String get postStepCaption => 'DESCRIERE';

  @override
  String get postStepTags => 'ETICHETE';

  @override
  String get postStepVisibility => 'VIZIBILITATE';

  @override
  String get postStepReview => 'VERIFICARE';

  @override
  String get postStart => 'START';

  @override
  String get postPublishStep => 'PUBLICĂ';

  @override
  String get postBack => 'ÎNAPOI';

  @override
  String get postNext => 'ÎNAINTE';

  @override
  String get postPublish => 'PUBLICĂ POSTAREA';

  @override
  String postStepCounter(int current, int total) {
    return 'PASUL $current / $total';
  }

  @override
  String get postPhotosTitle => 'Alege-ți cadrele';

  @override
  String get postPhotosSubtitle =>
      'Trage pentru a reordona — coperta deschide postarea. Deocamdată doar poze.';

  @override
  String get postPhotosAdd => 'ADAUGĂ';

  @override
  String get postPhotosCover => 'COPERTĂ';

  @override
  String get postPhotosVideosSoon => 'VIDEO — ÎN CURÂND';

  @override
  String postPhotosCount(int count, int max) {
    return '$count / $max POZE';
  }

  @override
  String get postCaptionTitle => 'Spune ceva';

  @override
  String get postCaptionSubtitle =>
      'Adaugă o descriere pentru postare. Menționează detalii, povestea, build-ul.';

  @override
  String get postCaptionLabel => 'DESCRIERE';

  @override
  String get postCaptionHint => 'Spune povestea din spatele acestei postări…';

  @override
  String postCaptionCounter(int count, int max) {
    return '$count / $max';
  }

  @override
  String get postTagsTitle => 'Etichetează mașini și persoane';

  @override
  String get postTagsSubtitle =>
      'Leagă mașinile din această postare din orice garaj și etichetează persoanele din ea.';

  @override
  String get postTagsCars => 'MAȘINI';

  @override
  String get postTagsPeople => 'PERSOANE';

  @override
  String get postTagsCarHint => 'Caută o mașină în orice garaj…';

  @override
  String get postTagsPeopleHint => 'Caută persoane de etichetat…';

  @override
  String get postTagsAddCar => 'Etichetează o mașină';

  @override
  String get postTagsTagPersonFirst =>
      'Etichetează mai întâi o persoană pentru a-i eticheta una dintre mașini.';

  @override
  String get postTagsChoosePerson => 'A cui mașină?';

  @override
  String get postTagsChooseCar => 'Alege o mașină';

  @override
  String get postTagsNoCars => 'Această persoană nu are mașini de etichetat.';

  @override
  String get postTagsNoPeopleFound => 'Nicio persoană găsită.';

  @override
  String get postTagsLoadError => 'Încărcarea a eșuat. Încearcă din nou.';

  @override
  String get postVisibilityTitle => 'Cine ce vede';

  @override
  String get postVisibilitySubtitle =>
      'Ascunde un contor și ceilalți nu vor vedea acel număr — pot în continuare să dea like, să comenteze și să distribuie.';

  @override
  String get postVisibilityLabel => 'CONTOARE VIZIBILE';

  @override
  String get postVisibilityLikesTitle => 'Arată numărul de aprecieri';

  @override
  String get postVisibilityLikesDesc =>
      'Ceilalți pot vedea câte aprecieri are postarea';

  @override
  String get postVisibilityCommentsTitle => 'Arată numărul de comentarii';

  @override
  String get postVisibilityCommentsDesc =>
      'Ascunde numărul — comentariile rămân deschise';

  @override
  String get postVisibilitySharesTitle => 'Arată numărul de distribuiri';

  @override
  String get postVisibilitySharesDesc =>
      'Ceilalți pot vedea de câte ori a fost distribuită';

  @override
  String get postVisibilitySavedTitle => 'Arată numărul de salvări';

  @override
  String get postVisibilitySavedDesc =>
      'Ceilalți pot vedea de câte ori a fost salvată';

  @override
  String get postVisibilityTimeNote =>
      'Postările arată un timp relativ — „acum 2h”, „acum 3 zile” — niciodată data exactă. Aceasta este automată și mereu activă.';

  @override
  String get postReviewTitle => 'Arată bine?';

  @override
  String get postReviewSubtitle => 'Exact așa apare postarea ta în feed.';

  @override
  String get postReviewYou => 'Tu';

  @override
  String get postReviewJustNow => 'ACUM';

  @override
  String get postValPhotosRequired =>
      'Adaugă cel puțin o poză pentru a continua.';

  @override
  String get postDiscardTitle => 'Renunți la postare?';

  @override
  String get postDiscardBody =>
      'Pozele, descrierea și etichetele tale nu vor fi salvate.';

  @override
  String get postKeepEditing => 'Continuă editarea';

  @override
  String get postDiscard => 'Renunță';

  @override
  String get postCreatedSuccess => 'Postare publicată.';

  @override
  String get postPhaseCreating => 'Se creează…';

  @override
  String get postPhaseUploading => 'Se încarcă pozele…';

  @override
  String get postErrorGeneric =>
      'Postarea nu a putut fi publicată. Încearcă din nou.';

  @override
  String get postErrorImageUpload =>
      'Pozele nu au putut fi încărcate. Încearcă din nou.';

  @override
  String get postErrorInvalidTags =>
      'Nu poți eticheta o mașină fără a-i eticheta și proprietarul.';

  @override
  String get postErrorNotOwner => 'Nu ai permisiunea să faci asta.';

  @override
  String get postErrorNotFound => 'Această postare nu mai există.';

  @override
  String get profileTabPosts => 'POSTĂRI';

  @override
  String get profileTabGarage => 'GARAJ';

  @override
  String get postsLoadMore => 'ÎNCARCĂ MAI MULT';

  @override
  String get postsEmptyOwner => 'Încă nu ai postat nimic.';

  @override
  String get postsEmptyVisitor => 'Nicio postare încă.';

  @override
  String get postsCreateFirst => 'CREEAZĂ PRIMA POSTARE';

  @override
  String get postDetailTitle => 'POSTARE';

  @override
  String get postEditAction => 'Editează postarea';

  @override
  String get postDeleteAction => 'Șterge postarea';

  @override
  String get postDeleteTitle => 'Ștergi postarea?';

  @override
  String get postDeleteBody =>
      'Această postare și pozele, aprecierile și comentariile sale vor fi șterse definitiv.';

  @override
  String get postEditTitle => 'EDITEAZĂ POSTAREA';

  @override
  String get postEditSave => 'SALVEAZĂ';

  @override
  String get postShareTitle => 'DISTRIBUIE POSTAREA';

  @override
  String get postShareSend => 'DISTRIBUIE';

  @override
  String get postShareNoteLabel => 'Adaugă o notă';

  @override
  String get postShareNoteHint =>
      'Spune ceva despre această postare… (opțional)';

  @override
  String get postSharePreviewNoCaption => 'Fără descriere';

  @override
  String get postShareSuccess => 'Postare distribuită.';

  @override
  String get postTimeNow => 'acum';

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
    return '${count}z';
  }

  @override
  String postTimeWeeks(int count) {
    return '${count}săpt';
  }

  @override
  String postLikesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aprecieri',
      one: '1 apreciere',
    );
    return '$_temp0';
  }

  @override
  String postViewAllComments(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vezi toate cele $count comentarii',
      one: 'Vezi 1 comentariu',
    );
    return '$_temp0';
  }

  @override
  String postCommentsTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count comentarii',
      one: '1 comentariu',
      zero: 'Comentarii',
    );
    return '$_temp0';
  }

  @override
  String get postCommentsEmpty => 'Niciun comentariu încă. Fii primul.';

  @override
  String get postCommentsLoadError =>
      'Comentariile nu au putut fi încărcate. Încearcă din nou.';

  @override
  String get postCommentHint => 'Adaugă un comentariu…';

  @override
  String get postCommentDeleted => '[șters]';

  @override
  String get postCommentDelete => 'Șterge';

  @override
  String get postCommentDeleteTitle => 'Ștergi comentariul?';

  @override
  String get postCommentDeleteBody => 'Acest comentariu va fi șters definitiv.';

  @override
  String postCommentLikesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aprecieri',
      one: '1 apreciere',
    );
    return '$_temp0';
  }

  @override
  String get postCommentReply => 'Răspunde';

  @override
  String postReplyingTo(String username) {
    return 'Răspunzi lui @$username';
  }

  @override
  String get postRepliesHide => 'Ascunde răspunsurile';

  @override
  String get postRepliesViewGeneric => 'Vezi răspunsurile';

  @override
  String get postRepliesViewMore => 'Vezi mai multe răspunsuri';

  @override
  String postRepliesView(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vezi $count răspunsuri',
      one: 'Vezi 1 răspuns',
    );
    return '$_temp0';
  }

  @override
  String get postLikersTitle => 'Aprecieri';

  @override
  String get postLikersEmpty => 'Nicio apreciere încă.';

  @override
  String get postLikersLoadError =>
      'Aprecierile nu au putut fi încărcate. Încearcă din nou.';

  @override
  String get postReport => 'Raportează postarea';

  @override
  String get commentReport => 'Raportează';

  @override
  String get profileReportAccount => 'Raportează contul';

  @override
  String get reportSubmit => 'Trimite raportul';

  @override
  String get reportClose => 'Închide';

  @override
  String get reportRetry => 'Încearcă din nou';

  @override
  String get reportReasonsLoadError =>
      'Motivele de raportare nu au putut fi încărcate. Încearcă din nou.';

  @override
  String get reportSuccessTitle => 'Raport primit';

  @override
  String get reportSuccessBody =>
      'Îți mulțumim că ne-ai anunțat. Echipa noastră va analiza în curând.';

  @override
  String get reportErrorAlreadyReported => 'Ai raportat deja acest lucru.';

  @override
  String get reportErrorSelf => 'Nu îți poți raporta propriul conținut.';

  @override
  String get reportErrorInvalidReason =>
      'Acel motiv nu se aplică aici. Alege altul.';

  @override
  String get reportErrorNotFound => 'Acest conținut nu mai este disponibil.';

  @override
  String get reportErrorNetwork =>
      'Fără conexiune la internet. Încearcă din nou.';

  @override
  String get reportErrorGeneric =>
      'Raportul nu a putut fi trimis. Încearcă din nou.';

  @override
  String get settingsMyReports => 'Rapoartele mele';

  @override
  String get myReportsTitle => 'RAPOARTELE MELE';

  @override
  String get myReportsEmpty => 'Nu ai trimis încă niciun raport.';

  @override
  String get reportTargetPost => 'Postare';

  @override
  String get reportTargetComment => 'Comentariu';

  @override
  String get reportTargetProfile => 'Profil';

  @override
  String get reportNoReason => 'Niciun motiv specificat';

  @override
  String get reportStatusPending => 'În așteptare';

  @override
  String get reportStatusInProgress => 'În curs';

  @override
  String get reportStatusResolved => 'Rezolvat';

  @override
  String get reportStatusDismissed => 'Respins';
}
