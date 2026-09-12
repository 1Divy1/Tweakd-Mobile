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
  String get settingsLanguagePickerTitle => 'Alege limba';

  @override
  String get settingsLanguageLoadError =>
      'Nu am putut încărca opțiunile de limbă. Te rugăm să încerci din nou.';

  @override
  String get settingsLanguageUpdateError =>
      'Nu am putut actualiza limba. Te rugăm să încerci din nou.';

  @override
  String get settingsTheme => 'Temă';

  @override
  String get themeLight => 'Deschisă';

  @override
  String get themeDark => 'Întunecată';

  @override
  String get themeSystem => 'Sistem';

  @override
  String get settingsThemePickerTitle => 'Alege tema';

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
  String get authLoginTitle => 'Bine ai revenit în comunitate !';

  @override
  String get authLoginSubtitle => '';

  @override
  String get authSignupTitle => 'Comunitatea te așteaptă !';

  @override
  String get authSignupSubtitle => '';

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
  String get authAgreeToTermsFirst =>
      'Te rugăm să fii de acord cu Termenii și Politica de confidențialitate mai întâi.';

  @override
  String authComingSoon(String feature) {
    return '$feature va fi disponibil în curând.';
  }

  @override
  String authFeatureProviderSignIn(String provider) {
    return 'Conectarea cu $provider';
  }

  @override
  String authPasswordRuleLength(int count) {
    return 'Cel puțin $count caractere';
  }

  @override
  String get authPasswordRuleLowercase => 'O literă mică';

  @override
  String get authPasswordRuleUppercase => 'O literă mare';

  @override
  String get authPasswordRuleDigit => 'O cifră';

  @override
  String get authPasswordRuleSymbol => 'Un simbol (!, @, #, …)';

  @override
  String get authConfirmEmailTitle => 'Verifică-ți emailul';

  @override
  String authConfirmEmailSubtitle(String email) {
    return 'Am trimis un cod către $email. Introdu-l mai jos pentru a-ți activa contul.';
  }

  @override
  String get authConfirmEmailVerify => 'Confirmă emailul';

  @override
  String get authConfirmEmailResent =>
      'Emailul de confirmare a fost trimis din nou.';

  @override
  String get authResendEmail => 'NU L-AI PRIMIT? RETRIMITE';

  @override
  String authResendIn(int seconds) {
    return 'RETRIMITE ÎN ${seconds}s';
  }

  @override
  String get authBackToSignIn => 'ÎNAPOI LA CONECTARE';

  @override
  String get authForgotPasswordTitle => 'Resetează-ți parola';

  @override
  String get authForgotPasswordSubtitle =>
      'Introdu adresa de email și îți trimitem un cod.';

  @override
  String get authSendCode => 'Trimite codul';

  @override
  String get authResetCodeResent => 'Un cod nou este pe drum.';

  @override
  String get authVerifyCodeTitle => 'Introdu codul';

  @override
  String authVerifyCodeSubtitle(String email) {
    return 'Am trimis un cod către $email. Expiră în scurt timp, așa că folosește-l repede.';
  }

  @override
  String get authVerifyCode => 'Verifică codul';

  @override
  String get authNewPasswordTitle => 'Alege o parolă nouă';

  @override
  String get authNewPasswordSubtitle =>
      'Salvarea deconectează toate celelalte dispozitive.';

  @override
  String get authNewPasswordLabel => 'Parolă nouă';

  @override
  String get authConfirmPasswordLabel => 'Confirmă parola';

  @override
  String get authConfirmPasswordHint => 'Repetă parola nouă';

  @override
  String get authPasswordsDoNotMatch => 'Parolele nu coincid.';

  @override
  String get authSavePassword => 'Salvează parola';

  @override
  String get authPasswordUpdated => 'Parola ta a fost actualizată.';

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
  String get onboardingOptional => 'OPȚIONAL';

  @override
  String get onboardingSearchHint => 'Caută…';

  @override
  String get onboardingNoMatches => 'Niciun rezultat';

  @override
  String get onboardingErrorPickBrand =>
      'Alege cel puțin o marcă care îți place.';

  @override
  String get onboardingErrorSelectCity =>
      'Selectează orașul pentru a continua.';

  @override
  String get onboardingNameErrorEmpty => 'Introdu-ți numele.';

  @override
  String onboardingNameErrorTooShort(int min) {
    return 'Numele trebuie să aibă cel puțin $min caractere.';
  }

  @override
  String onboardingNameErrorTooLong(int max) {
    return 'Numele poate avea cel mult $max caractere.';
  }

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
  String get onboardingFieldName => 'NUME';

  @override
  String get onboardingNameHint => 'Numele tău';

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
  String get onboardingGarageTitle => 'Garajul tău';

  @override
  String get onboardingGarageSubtitle =>
      'Mărcile pe care le urmărești — îți vom personaliza feed-ul și marketplace-ul în funcție de ele.';

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
  String get onboardingLocationLabel => '03 — LOCAȚIE';

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
  String get onboardingNotificationsLabel => '04 — NOTIFICĂRI';

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
  String get onboardingNotifGroupGarage => 'GARAJUL TĂU';

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
  String get onboardingNotifEventOrganizerTitle => 'Organizator eveniment';

  @override
  String get onboardingNotifEventOrganizerSubtitle =>
      'Când cineva se înscrie la evenimentul tău, devine co-organizator sau cere să se retragă';

  @override
  String get onboardingNotifServiceRemindersTitle => 'Mementouri service';

  @override
  String get onboardingNotifServiceRemindersSubtitle =>
      'Servicii programate și documente care expiră pentru mașinile tale';

  @override
  String get onboardingNotifTagsTitle => 'Etichetări';

  @override
  String get onboardingNotifTagsSubtitle =>
      'Când cineva te etichetează pe tine sau mașina ta';

  @override
  String get profileTitle => 'PROFIL';

  @override
  String get profileMessage => 'Mesaj';

  @override
  String get profileStatReputation => 'reputație';

  @override
  String get profileStatFollowers => 'urmăritori';

  @override
  String get profileStatFollowing => 'urmărește';

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
  String get profileErrorNetwork =>
      'Fără conexiune la internet. Te rugăm să încerci din nou.';

  @override
  String get profileEditButton => 'Editează profilul';

  @override
  String get profileShareButton => 'Distribuie profilul';

  @override
  String get profileFeedbackButton => 'Feedback';

  @override
  String get navFeed => 'Feed';

  @override
  String get navMap => 'Hartă';

  @override
  String get navCreate => 'Creează';

  @override
  String get navSearch => 'Caută';

  @override
  String get navProfile => 'Profil';

  @override
  String get editProfileTitle => 'EDITEAZĂ PROFILUL';

  @override
  String get editProfileChangePhoto => 'Schimbă poza';

  @override
  String get editProfileNameLabel => 'NUME';

  @override
  String get editProfileNameHint => 'Numele tău afișat';

  @override
  String get editProfileBioLabel => 'BIO';

  @override
  String get editProfileBioHint =>
      'Spune-le altora câteva lucruri despre tine…';

  @override
  String get editProfileSave => 'Salvează modificările';

  @override
  String get editProfileSaved => 'Profil actualizat';

  @override
  String get editProfilePhotoUpdated => 'Poză actualizată';

  @override
  String get editProfileErrorInvalid =>
      'Verifică numele și bio-ul, apoi încearcă din nou.';

  @override
  String get editProfileErrorAvatar =>
      'Nu am putut actualiza poza. Te rugăm să încerci din nou.';

  @override
  String get followActionFollow => 'URMĂREȘTE';

  @override
  String get followActionUnfollow => 'NU MAI URMĂRI';

  @override
  String get followActionRequested => 'SOLICITAT';

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
  String get feedEmptyTitle => 'Feedul tău e liniștit';

  @override
  String get feedEmptyMessage =>
      'Fii printre primii care își arată mașina. Postările din comunitate apar aici.';

  @override
  String get feedEmptyCta => 'Publică o postare';

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
  String get garageRegisterSpecsTitle => 'Detaliile mașinii';

  @override
  String get garageSpecsTabBasics => 'GENERAL';

  @override
  String get garageSpecsTabPower => 'PUTERE';

  @override
  String get garageSpecsTabConfig => 'CONFIG';

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
  String get garageFieldChassisCode => 'SERIA DE ȘASIU';

  @override
  String get garageFieldModelCode => 'COD MODEL';

  @override
  String get garageHintModelCode => 'ex. G30';

  @override
  String get garagePickFromGallery => 'Atinge pentru a alege din galerie';

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
  String get garageRegisterStoryTitle =>
      'Care e povestea acestei mașini? Spune-o…';

  @override
  String get garageFieldStatus => 'STARE';

  @override
  String get garageFieldTheStory => 'POVESTEA';

  @override
  String get garageHintStory => 'Care e povestea acestei mașini? Spune-o…';

  @override
  String get garageRegisterGalleryTitle => 'Arat-o';

  @override
  String get garageFieldGallery => 'GALERIE';

  @override
  String get garageAddCoverPhoto => 'Adaugă fotografia principală';

  @override
  String get garageGalleryAdd => 'ADAUGĂ';

  @override
  String get garageGalleryHint =>
      'Doar pentru showcase — cele mai clare și mai spectaculoase cadre. Cele mai bune unghiuri, culori și lumini. Până la 15 fotografii.';

  @override
  String get garageRegisterModsTitle => 'Jurnal de proiect';

  @override
  String get garageRegisterModsSubtitle => '';

  @override
  String get garageModFallbackCategory => 'MODIFICARE';

  @override
  String get garageAddModification => 'ADAUGĂ MODIFICARE';

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
  String get garageModValidation =>
      'Categoria, titlul și data sunt obligatorii.';

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
  String get garageShareBuild => 'Distribuie mașina';

  @override
  String get garageShareSheetLabel => 'DISTRIBUIE';

  @override
  String get garageShareQrTitle => 'Obține codul QR';

  @override
  String get garageShareQrSubtitle => 'Printează-l și lipește-l pe mașină';

  @override
  String get garageShareCopyLink => 'Copiază linkul';

  @override
  String get garageShareLinkCopied => 'Link copiat';

  @override
  String get garageShareChannelMessages => 'Mesaje';

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
    return 'Aruncă un ochi pe $car pe Tweakd 🔧';
  }

  @override
  String garageShareStats(int scans, int views) {
    return 'Scanat de $scans ori · Deschis de $views ori';
  }

  @override
  String get garageShareToggleLabel => 'Distribuire';

  @override
  String get garageSharePausedHint =>
      'Pe pauză — linkul și codul QR sunt oprite';

  @override
  String get garageShareLoadFailed =>
      'Nu am putut deschide linkul de distribuire.';

  @override
  String get garageShareQrLoadFailed => 'Nu am putut încărca codul QR.';

  @override
  String get garageShareQrDownload => 'Descarcă codul QR';

  @override
  String get garageShareQrDownloadSaved => 'Codul QR a fost salvat pe telefon.';

  @override
  String get garageShareQrDownloadFailed => 'Nu am putut salva fișierul.';

  @override
  String get garageShareRetry => 'Încearcă din nou';

  @override
  String get garageShareResolving => 'Se deschide mașina…';

  @override
  String get garageShareUnavailableTitle => 'Mașină indisponibilă';

  @override
  String get garageShareUnavailableBody =>
      'Această mașină nu mai este distribuită pe Tweakd.';

  @override
  String get garageShareBackToFeed => 'Înapoi la feed';

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
  String get garageKeepEditing => 'Continuă editarea';

  @override
  String get garageDiscard => 'Renunță';

  @override
  String get garageBuildLogDiscardTitle => 'Renunți la această intrare?';

  @override
  String get garageBuildLogDiscardBody =>
      'Încă nu ai adăugat această intrare în jurnalul de modificări. Dacă pleci acum, tot ce ai completat aici se va pierde.';

  @override
  String get garageLogModLogged => 'Modificare adăugată!';

  @override
  String get garageAddModCarTitle => 'Care mașină?';

  @override
  String get garageAddModCarSubtitle => 'Alege mașina la care ai lucrat.';

  @override
  String get garageAddModNoCarsTitle => 'Nicio mașină încă';

  @override
  String get garageAddModNoCarsBody =>
      'Adaugă mai întâi o mașină în garaj, apoi notează ce i-ai făcut.';

  @override
  String get garageAddModAddCar => 'ADAUGĂ O MAȘINĂ';

  @override
  String get garageAddModPickCar => 'Alege o mașină ca să continui.';

  @override
  String get authErrorSessionExpired =>
      'Sesiunea ta nu mai este activă. Te rugăm să te conectezi din nou.';

  @override
  String get authErrorInvalidCredentials =>
      'Emailul sau parola nu sunt corecte.';

  @override
  String get authErrorEmailNotConfirmed =>
      'Confirmă-ți adresa de email înainte de a te conecta.';

  @override
  String get authErrorWeakPassword =>
      'Parola este prea slabă. Alege una mai puternică.';

  @override
  String get authErrorInvalidCode =>
      'Codul nu este corect. Verifică-l și încearcă din nou.';

  @override
  String get authErrorExpiredCode => 'Codul a expirat. Solicită unul nou.';

  @override
  String get authErrorRateLimited =>
      'Prea multe încercări. Așteaptă puțin și încearcă din nou.';

  @override
  String get authErrorSamePassword =>
      'Parola nouă trebuie să fie diferită de cea veche.';

  @override
  String get authErrorSignUpDisabled =>
      'Înregistrările noi nu sunt disponibile momentan. Încearcă mai târziu.';

  @override
  String get authErrorNetwork =>
      'Fără conexiune. Verifică rețeaua și încearcă din nou.';

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
  String get postBack => 'ÎNAPOI';

  @override
  String get postNext => 'ÎNAINTE';

  @override
  String get postPublish => 'PUBLICĂ POSTAREA';

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
  String get profileTabPosts => 'Postări';

  @override
  String get profileTabGarage => 'Garaj';

  @override
  String get profileTabTags => 'Etichetări';

  @override
  String get postsLoadMore => 'ÎNCARCĂ MAI MULT';

  @override
  String get postsEmptyOwner => 'Încă nu ai postat nimic.';

  @override
  String get postsEmptyVisitor => 'Nicio postare încă.';

  @override
  String get postsCreateFirst => 'CREEAZĂ PRIMA POSTARE';

  @override
  String get savedPostsTitle => 'POSTĂRI SALVATE';

  @override
  String get savedPostsEmptyTitle => 'Nimic salvat încă';

  @override
  String get savedPostsEmptyBody =>
      'Salvează postările care îți plac ca să le găsești aici mai târziu.';

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
  String get settingsSavedPosts => 'Postările tale salvate';

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
  String get reportTargetForumThread => 'Thread din forum';

  @override
  String get reportTargetForumReply => 'Răspuns din forum';

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

  @override
  String get settingsSendFeedback => 'Trimite feedback';

  @override
  String get settingsMyFeedback => 'Feedbackul meu';

  @override
  String get feedbackEyebrow => 'FEEDBACK';

  @override
  String get feedbackHeadline => 'Ai o sugestie ?';

  @override
  String get feedbackSubtitle =>
      'Raportează o eroare, cere o funcție sau împărtășește un gând și ajunge direct la noi.';

  @override
  String get feedbackTypeLabel => 'TIP DE FEEDBACK';

  @override
  String get feedbackTypeHint => 'Alege un tip';

  @override
  String get feedbackFeatureLabel => 'LEGAT DE O FUNCȚIE EXISTENTĂ?';

  @override
  String get feedbackFeatureHint => 'Alege o funcție';

  @override
  String get feedbackOptional => 'OPȚIONAL';

  @override
  String get feedbackContentLabel => 'FEEDBACKUL TĂU';

  @override
  String get feedbackContentLabelBug => 'CE S-A ÎNTÂMPLAT';

  @override
  String get feedbackContentHint => 'Spune-ne ce gândești…';

  @override
  String get feedbackReproductionLabel => 'PAȘI DE REPRODUCERE';

  @override
  String get feedbackReproductionHint => '1. Deschide …\n2. Apasă …\n3. …';

  @override
  String get feedbackTypePickerTitle => 'Tip de feedback';

  @override
  String get feedbackFeaturePickerTitle => 'Funcție asociată';

  @override
  String get feedbackFeatureNone => 'Niciuna';

  @override
  String get feedbackTypeBugDesc => 'Ceva nu funcționează';

  @override
  String get feedbackTypeFeatureDesc => 'Ceva ce ți-ai dori să existe';

  @override
  String get feedbackTypeGeneralDesc => 'Gânduri, aprecieri sau o idee';

  @override
  String get feedbackSubmit => 'Trimite feedback';

  @override
  String get feedbackRetry => 'Încearcă din nou';

  @override
  String get feedbackLoadError =>
      'Formularul de feedback nu a putut fi încărcat. Încearcă din nou.';

  @override
  String get feedbackSuccess => 'Mulțumim! Feedbackul tău este pe drum.';

  @override
  String get feedbackErrorNetwork =>
      'Fără conexiune la internet. Încearcă din nou.';

  @override
  String get feedbackErrorGeneric =>
      'Feedbackul nu a putut fi trimis. Încearcă din nou.';

  @override
  String get myFeedbackTitle => 'FEEDBACKUL MEU';

  @override
  String get myFeedbackEmpty => 'Nu ai trimis încă niciun feedback.';

  @override
  String get myFeedbackResponseLabel => 'RĂSPUNS';

  @override
  String get forumsTitle => 'Forumuri';

  @override
  String get forumsSubtitle => 'Paddock-ul tău';

  @override
  String get forumsYourShortcuts => 'SCURTĂTURILE TALE';

  @override
  String get forumsEditShortcuts => 'EDITEAZĂ';

  @override
  String get forumsDoneEditing => 'GATA';

  @override
  String get forumsHotInYourForums => 'HOT ÎN FORUMURILE TALE';

  @override
  String get forumsSortHot => 'Hot';

  @override
  String get forumsSortNew => 'Noi';

  @override
  String get forumsSortActive => 'Active';

  @override
  String get forumsEmptyTitle => 'Găsește forumurile în care trăiești';

  @override
  String get forumsEmptyBody =>
      'Atinge un hub ca să-i vezi thread-urile. După ce te-ai uitat prin el, salvează-l ca scurtătură și apare chiar aici.';

  @override
  String get forumsPopularHubs => 'HUB-URI POPULARE PENTRU ÎNCEPUT';

  @override
  String get forumsCtaTitle => 'Ai ceva de spus?';

  @override
  String get forumsCtaBody =>
      'Orice forum grozav a început cu un singur thread. Fă-l pe al tău.';

  @override
  String get forumsStartFirstThread => 'Începe primul thread';

  @override
  String get forumsShortcutSaved => 'Scurtătură salvată în paddock.';

  @override
  String get forumsShortcutRemoved => 'Scurtătură ștearsă.';

  @override
  String get forumsBrowseTitle => 'EXPLOREAZĂ';

  @override
  String forumsBrandsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count MĂRCI',
      one: '1 MARCĂ',
    );
    return '$_temp0';
  }

  @override
  String forumsThreadsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count thread-uri',
      one: '1 thread',
    );
    return '$_temp0';
  }

  @override
  String get forumsModels => 'MODELE';

  @override
  String get forumsRefineByTopic => 'FILTREAZĂ DUPĂ SUBIECT';

  @override
  String forumsHotIn(String name) {
    return 'HOT ÎN $name';
  }

  @override
  String get forumsThreadsLabel => 'THREAD-URI';

  @override
  String get forumsAllTopics => 'Toate';

  @override
  String get forumsSaveShortcut => 'Salvează scurtătura';

  @override
  String get forumsSaveShortcutSubtitle =>
      'Fixează acest filtru în paddock pentru acces dintr-o atingere.';

  @override
  String get forumsShortcutNameLabel => 'NUME';

  @override
  String get forumsNotifyMe => 'Notifică-mă';

  @override
  String get forumsNotifyMeSubtitle => 'Thread-uri noi hot în acest filtru';

  @override
  String get forumsNoThreadsTitle => 'Niciun thread aici încă.';

  @override
  String get forumsNoThreadsBody => 'Fii primul — pornește conversația.';

  @override
  String get forumsRetry => 'Încearcă din nou';

  @override
  String get forumsThreadTitle => 'THREAD';

  @override
  String get forumsPinned => 'FIXAT';

  @override
  String get forumsLocked => 'BLOCAT';

  @override
  String get forumsLockedBar =>
      'Acest thread este blocat — nu se mai pot adăuga răspunsuri.';

  @override
  String forumsRepliesHeader(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count RĂSPUNSURI',
      one: '1 RĂSPUNS',
    );
    return '$_temp0';
  }

  @override
  String get forumsReply => 'Răspunde';

  @override
  String forumsShowReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Arată $count răspunsuri',
      one: 'Arată 1 răspuns',
    );
    return '$_temp0';
  }

  @override
  String get forumsHideReplies => 'Ascunde';

  @override
  String get forumsShowMoreReplies => 'Arată mai multe răspunsuri';

  @override
  String get forumsAddReply => 'Adaugă un răspuns…';

  @override
  String forumsReplyingTo(String username) {
    return 'Îi răspunzi lui @$username';
  }

  @override
  String get forumsDeletedPlaceholder => '[șters]';

  @override
  String get forumsPosted => 'Postat';

  @override
  String get forumsActiveNow => 'activ chiar acum';

  @override
  String forumsActiveAgo(String time) {
    return 'activ acum $time';
  }

  @override
  String get forumsEditThread => 'Editează conținutul';

  @override
  String get forumsDeleteThread => 'Șterge thread-ul';

  @override
  String get forumsEditReply => 'Editează răspunsul';

  @override
  String get forumsDeleteReply => 'Șterge răspunsul';

  @override
  String get forumsDeleteThreadConfirmTitle => 'Ștergi acest thread?';

  @override
  String get forumsDeleteThreadConfirmBody =>
      'Dacă are răspunsuri rămâne vizibil ca [șters]; altfel dispare definitiv.';

  @override
  String get forumsDeleteReplyConfirmTitle => 'Ștergi acest răspuns?';

  @override
  String get forumsDeleteReplyConfirmBody =>
      'Dacă are răspunsuri devine un marcaj [șters]; altfel este eliminat.';

  @override
  String get forumsDelete => 'Șterge';

  @override
  String get forumsEditSave => 'Salvează';

  @override
  String get forumsComingSoon => 'În curând';

  @override
  String get forumsNewThreadTitle => 'THREAD NOU';

  @override
  String get forumsPost => 'Postează';

  @override
  String get forumsThreadTitleHint => 'Titlu';

  @override
  String get forumsThreadBodyHint =>
      'Împărtășește detalii, întrebări sau writeup-ul tău…';

  @override
  String get forumsBrandRequiredLabel => 'MARCĂ · OBLIGATORIU';

  @override
  String get forumsModelOptionalLabel => 'MODEL · OPȚIONAL';

  @override
  String get forumsSearchBrandHint => 'Caută o marcă…';

  @override
  String get forumsSearchModelHint => 'Caută un model…';

  @override
  String get forumsChooseBrand => 'Alege o marcă';

  @override
  String get forumsChooseModel => 'Alege un model';

  @override
  String get forumsNoBrandMatches => 'Nicio marcă nu corespunde căutării.';

  @override
  String get forumsNoModelMatches => 'Niciun model nu corespunde căutării.';

  @override
  String get forumsNoModelsForBrand =>
      'Niciun model listat pentru această marcă.';

  @override
  String get forumsTagCarHelper =>
      'Alege o marcă pentru ca thread-ul tău să apară în hub-ul potrivit. Este recomandat să adaugi și modelul exact, dacă întrebarea nu se referă la întreaga marcă.';

  @override
  String get forumsTopics => 'SUBIECTE';

  @override
  String get forumsThreadPosted => 'Thread postat.';

  @override
  String get forumsShare => 'Distribuie';

  @override
  String get forumsSave => 'Salvează';

  @override
  String get forumsSaved => 'Salvat';

  @override
  String get forumsAuthorBadge => 'Autor';

  @override
  String get forumsRepliesOldest => 'Cele mai vechi';

  @override
  String get forumsRepliesNewest => 'Cele mai noi';

  @override
  String get forumsReportThreadTitle => 'Raportează thread-ul';

  @override
  String get forumsReportReplyTitle => 'Raportează răspunsul';

  @override
  String get forumsSavedTitle => 'SALVATE';

  @override
  String get forumsSavedHeader => 'THREAD-URI SALVATE';

  @override
  String get forumsSavedEmptyTitle => 'Nimic salvat încă';

  @override
  String get forumsSavedEmptyBody =>
      'Salvează thread-uri ca să le găsești aici mai târziu.';

  @override
  String get forumsErrorNetwork =>
      'Nu există conexiune la internet. Încearcă din nou.';

  @override
  String get forumsErrorNotFound => 'Acest conținut nu mai există.';

  @override
  String get forumsErrorConflict =>
      'Thread-ul este blocat sau conținutul a fost șters.';

  @override
  String get forumsErrorForbidden =>
      'Poți edita sau șterge doar conținutul tău.';

  @override
  String get forumsErrorGeneric => 'Ceva n-a mers bine. Încearcă din nou.';

  @override
  String get forumsErrorInvalidTags =>
      'Unul dintre profilurile sau mașinile etichetate nu mai este disponibil.';

  @override
  String get forumsTagPeopleAndCars => 'ETICHETEAZĂ PERSOANE ȘI MAȘINI';

  @override
  String get forumsTagPeople => 'PERSOANE';

  @override
  String get forumsTagCars => 'MAȘINI';

  @override
  String get forumsTagHelper =>
      'Menționează pe cineva ca să alegi mașini din garajul lui. Mașinile tale pot fi etichetate fără să te menționezi.';

  @override
  String get forumsTagPeopleHint => 'Caută un nume de utilizator…';

  @override
  String get forumsTagAddCar => 'Etichetează o mașină';

  @override
  String get forumsTagChoosePerson => 'A cui mașină?';

  @override
  String get forumsTagChooseCar => 'Alege o mașină';

  @override
  String get forumsTagYourGarage => 'Garajul tău';

  @override
  String get forumsTagNoPeopleFound => 'Niciun profil nu se potrivește.';

  @override
  String get forumsTagLoadError => 'Nu s-a putut încărca. Încearcă din nou.';

  @override
  String get forumsTagNoCars => 'Persoana nu are mașini de etichetat.';

  @override
  String get forumsTagNoOwnCars => 'Garajul tău este gol.';

  @override
  String get forumsTagPersonFirst =>
      'Menționează întâi pe cineva ca să-i etichetezi o mașină.';

  @override
  String forumsTagLimitReached(int limit) {
    return 'Poți eticheta cel mult $limit deodată.';
  }

  @override
  String get forumsTagsSheetTitle => 'Etichete';

  @override
  String get forumsTagsDone => 'Gata';

  @override
  String get forumsAddTagsTooltip => 'Etichetează persoane și mașini';

  @override
  String get forumsTagsSectionLabel => 'ETICHETE';

  @override
  String get messagesTitle => 'MESAJE';

  @override
  String get messagesSearchHint => 'Caută în mesaje';

  @override
  String get messagesActiveNow => 'ACTIVI ACUM';

  @override
  String get messagesRequestsTitle => 'Cereri de mesaje';

  @override
  String messagesRequestsOthers(String names, int count) {
    return '$names & încă $count';
  }

  @override
  String get messagesEmptyTitle => 'Niciun mesaj încă';

  @override
  String get messagesEmptyBody =>
      'Începe o conversație cu șoferii pe care îi urmărești — planificați întâlniri, comparați specificații, împărtășiți ture.';

  @override
  String get messagesNewMessage => 'MESAJ NOU';

  @override
  String messagesYouPrefix(String text) {
    return 'Tu: $text';
  }

  @override
  String get messagesSharedPost => 'A distribuit o postare';

  @override
  String get messagesTimeNow => 'acum';

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
    return '${count}z';
  }

  @override
  String messagesTimeWeeks(int count) {
    return '${count}s';
  }

  @override
  String get messagesActiveNowStatus => 'Activ acum';

  @override
  String messagesMutualFollow(String followers) {
    return 'Vă urmăriți reciproc · $followers urmăritori';
  }

  @override
  String messagesDatePill(String time) {
    return 'AZI · $time';
  }

  @override
  String get messagesSeen => 'Văzut';

  @override
  String get messagesDeletedMessage => 'Mesaj șters';

  @override
  String get messagesDeleteMessage => 'Șterge mesajul';

  @override
  String get messagesDeleteMessageBody => 'Îl elimină pentru amândoi.';

  @override
  String get messagesDeleteChat => 'Șterge conversația';

  @override
  String get messagesDeleteChatBody =>
      'O ascunde doar din lista ta — revine la un mesaj nou.';

  @override
  String get messagesInputHint => 'Mesaj…';

  @override
  String get messagesEmptyChat => 'Niciun mesaj încă — salută 👋';

  @override
  String get messagesComposeTitle => 'Mesaj nou';

  @override
  String get messagesComposeSearchHint => 'Caută șoferi…';

  @override
  String get messagesComposeEmpty => 'Niciun șofer găsit';

  @override
  String get messagesComingSoon => 'În curând';

  @override
  String get messagesRetry => 'Încearcă din nou';

  @override
  String get messagesErrorNetwork =>
      'Nu există conexiune la internet. Încearcă din nou.';

  @override
  String get messagesErrorGeneric => 'Ceva n-a mers bine. Încearcă din nou.';

  @override
  String get messagesSharedCars => 'Mașini partajate';

  @override
  String get messagesShareCarsTitle => 'Partajează mașini';

  @override
  String get messagesShareCarsSubtitle => 'Alege mașini din garajul tău';

  @override
  String messagesShareCarsLimit(int count) {
    return 'Poți partaja cel mult $count mașini';
  }

  @override
  String get messagesShareCarsEmpty => 'Nu ai încă nicio mașină în garaj';

  @override
  String get messagesShareCarsError =>
      'Nu am putut încărca garajul. Încearcă din nou.';

  @override
  String messagesShareCarsConfirm(int count) {
    return 'Partajează $count';
  }

  @override
  String get messagesShareCarsConfirmEmpty => 'Partajează mașini';

  @override
  String get notificationsTitle => 'NOTIFICĂRI';

  @override
  String get notificationsMarkAllRead => 'Marchează toate ca citite';

  @override
  String get notificationsEmptyTitle => 'Nicio notificare încă';

  @override
  String get notificationsEmptyBody =>
      'Aprecierile, comentariile și răspunsurile la postările și discuțiile tale vor apărea aici.';

  @override
  String get notificationsRetry => 'Încearcă din nou';

  @override
  String get notificationsErrorNetwork =>
      'Fără conexiune la internet. Te rugăm să încerci din nou.';

  @override
  String get notificationsErrorGeneric =>
      'Ceva nu a funcționat. Te rugăm să încerci din nou.';

  @override
  String get tagsKindPost => 'ETICHETAT ÎNTR-O POSTARE';

  @override
  String get tagsKindComment => 'ETICHETAT ÎNTR-UN COMENTARIU';

  @override
  String get tagsKindThread => 'ETICHETAT ÎNTR-O DISCUȚIE';

  @override
  String get tagsKindReply => 'ETICHETAT ÎNTR-UN RĂSPUNS';

  @override
  String tagsOnPostBy(String author) {
    return 'la postarea lui @$author';
  }

  @override
  String get tagsLoadMore => 'ÎNCARCĂ MAI MULT';

  @override
  String get tagsEmptyOwner => 'Nu ai fost etichetat încă.';

  @override
  String get tagsEmptyVisitor => 'Nicio etichetă încă.';

  @override
  String get tagsRemove => 'Elimină eticheta';

  @override
  String get tagsRemoveTitle => 'Elimini eticheta?';

  @override
  String get tagsRemoveBody =>
      'Vei fi eliminat din acest conținut pentru toată lumea, împreună cu mașinile tale etichetate acolo. Doar autorul te poate eticheta din nou.';

  @override
  String get tagsRemoveConfirm => 'Elimină';

  @override
  String get tagsErrorContentGone => 'Acest conținut nu mai există.';

  @override
  String get tagsErrorGeneric =>
      'Ceva nu a funcționat. Te rugăm să încerci din nou.';

  @override
  String get mapOpenNow => 'Deschis acum';

  @override
  String get mapClosedNow => 'Închis';

  @override
  String get mapNoReviews => 'Nicio recenzie încă';

  @override
  String mapReviewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recenzii',
      one: 'o recenzie',
    );
    return '$_temp0';
  }

  @override
  String mapFollowerCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count urmăritori',
      one: 'un urmăritor',
    );
    return '$_temp0';
  }

  @override
  String get mapHoursTitle => 'PROGRAM';

  @override
  String get mapHoursClosed => 'Închis';

  @override
  String get mapHoursNextDay => '(ziua următoare)';

  @override
  String get mapWeekdayMonday => 'Luni';

  @override
  String get mapWeekdayTuesday => 'Marți';

  @override
  String get mapWeekdayWednesday => 'Miercuri';

  @override
  String get mapWeekdayThursday => 'Joi';

  @override
  String get mapWeekdayFriday => 'Vineri';

  @override
  String get mapWeekdaySaturday => 'Sâmbătă';

  @override
  String get mapWeekdaySunday => 'Duminică';

  @override
  String get mapPopupClose => 'Închide';

  @override
  String get mapRecentre => 'Centrează pe locația mea';

  @override
  String get mapRetry => 'ÎNCEARCĂ DIN NOU';

  @override
  String get mapErrorNetwork =>
      'Fără conexiune la internet. Te rugăm să încerci din nou.';

  @override
  String get mapErrorBusinessNotFound =>
      'Acest business nu mai este disponibil.';

  @override
  String get mapErrorLocationUnavailable =>
      'Nu am putut obține locația ta. Verifică dacă locația este activată pentru Tweakd.';

  @override
  String get mapErrorGeneric =>
      'Ceva nu a funcționat. Te rugăm să încerci din nou.';

  @override
  String get mapNavigate => 'Navighează';

  @override
  String get mapNavigateSheetTitle => 'Alege o aplicație de navigare';

  @override
  String get mapNavigateInstall => 'INSTALEAZĂ';

  @override
  String get mapNavigateFailed => 'Nu am putut deschide acea aplicație.';

  @override
  String get mapEventsErrorNetwork =>
      'Fără conexiune la internet. Te rugăm să încerci din nou.';

  @override
  String get mapEventsErrorNotFound =>
      'Acest eveniment nu mai este disponibil.';

  @override
  String get mapEventsErrorForbidden => 'Doar organizatorii pot face asta.';

  @override
  String get mapEventsErrorConflict =>
      'Momentan acest lucru nu este posibil pentru acest eveniment.';

  @override
  String get mapEventsErrorInvalidInput =>
      'Te rugăm să verifici detaliile și să încerci din nou.';

  @override
  String mapEventsBulkRegisterPartial(int registered, int failed) {
    return '$registered din mașinile tale s-au înscris înainte ca acest eveniment să atingă capacitatea maximă — $failed nu au putut fi adăugate și nu au fost eliminate automat.';
  }

  @override
  String get mapEventsErrorGeneric =>
      'Ceva nu a funcționat. Te rugăm să încerci din nou.';

  @override
  String get mapEventsStatusUpcoming => 'URMEAZĂ';

  @override
  String get mapEventsStatusLive => 'ARE LOC ACUM';

  @override
  String get mapEventsStatusPrevious => 'TRECUT';

  @override
  String get mapEventsStatusHidden => 'ASCUNS';

  @override
  String get mapEventsStatusCanceled => 'ANULAT';

  @override
  String get mapEventsApprovalPending => 'ÎN VERIFICARE';

  @override
  String get mapEventsApprovalAccepted => 'APROBAT';

  @override
  String get mapEventsApprovalRejected => 'RESPINS';

  @override
  String mapEventsRejectionReason(String reason) {
    return 'Motiv: $reason';
  }

  @override
  String get mapEventsClose => 'Închide';

  @override
  String get mapEventsShare => 'Distribuie';

  @override
  String get mapEventsStatAttendees => 'PARTICIPANȚI';

  @override
  String get mapEventsStatCars => 'MAȘINI';

  @override
  String get mapEventsStatStarts => 'ÎNCEPE';

  @override
  String get mapEventsStatStarted => 'A ÎNCEPUT';

  @override
  String mapEventsGoingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count persoane merg',
      one: '1 persoană merge',
    );
    return '$_temp0';
  }

  @override
  String get mapEventsRoleOrganizer => 'organizator';

  @override
  String get mapEventsRoleCreator => 'creator';

  @override
  String get mapEventsChipIndividual => 'PERSOANĂ';

  @override
  String get mapEventsChipBusiness => 'BUSINESS';

  @override
  String get mapEventsAttending => 'PARTICIP';

  @override
  String get mapEventsInterested => 'MĂ INTERESEAZĂ';

  @override
  String get mapEventsWantToParticipate => 'VREI SĂ PARTICIPI?';

  @override
  String get mapEventsParticipateShort => 'PARTICIPI?';

  @override
  String get mapEventsParticipating => 'PARTICIPI';

  @override
  String mapEventsParticipatingCount(int count) {
    return 'PARTICIPI · $count MAȘINI';
  }

  @override
  String get mapEventsParticipationPending => 'ÎN AȘTEPTARE';

  @override
  String get mapEventsWithdrawAction => 'RETRAGE-TE';

  @override
  String get mapEventsViewEvent => 'VEZI EVENIMENTUL';

  @override
  String mapEventsCapacityOf(int capacity) {
    return 'din $capacity';
  }

  @override
  String get mapEventsTabOverview => 'PREZENTARE';

  @override
  String mapEventsTabCars(int count) {
    return 'MAȘINI · $count';
  }

  @override
  String get mapEventsEntryListTitle => 'Pe lista de înscrieri';

  @override
  String mapEventsApprovedCount(int count) {
    return '$count APROBATE';
  }

  @override
  String get mapEventsSectionAbout => 'DESPRE EVENIMENT';

  @override
  String get mapEventsSectionOrganizers => 'ORGANIZATORI';

  @override
  String get mapEventsSectionRules => 'NOTE DE LA ORGANIZATOR';

  @override
  String get mapEventsSectionContests => 'CONCURSURI';

  @override
  String get mapEventsSectionAttendees => 'PARTICIPANȚI';

  @override
  String get mapEventsSoon => 'ÎN CURÂND';

  @override
  String get mapEventsContestsTitle => 'Concursuri';

  @override
  String get mapEventsContestsBody =>
      'Organizatorii vor putea porni voturi în cadrul unei întâlniri — cel mai reușit build, cel mai curat compartiment motor, cea mai zgomotoasă evacuare.';

  @override
  String get mapEventsSeeAll => 'VEZI TOT';

  @override
  String get mapEventsSeeAllAttendees => 'VEZI TOȚI PARTICIPANȚII';

  @override
  String mapEventsSeeAllCars(int count) {
    return 'VEZI TOATE CELE $count MAȘINI';
  }

  @override
  String mapEventsRegisterBefore(String deadline) {
    return 'Înscrie-ți mașina până pe $deadline';
  }

  @override
  String get mapEventsRegistrationClosed =>
      'Înscrierile pentru acest eveniment s-au închis.';

  @override
  String get mapEventsCapacityFull => 'Lista de înscrieri este plină.';

  @override
  String get mapEventsGarageLink => 'GARAJ';

  @override
  String get mapEventsEntryListEmpty =>
      'Încă nu există mașini pe lista de înscrieri.';

  @override
  String get mapEventsAttendeesEmpty => 'Încă nu a confirmat nimeni.';

  @override
  String get mapEventsRetry => 'ÎNCEARCĂ DIN NOU';

  @override
  String get mapEventsStripPendingTitle => 'Cerere în așteptare';

  @override
  String get mapEventsStripPendingBody =>
      'Organizatorii îți vor aproba sau refuza înscrierea.';

  @override
  String get mapEventsStripDeclinedTitle => 'Înscriere refuzată';

  @override
  String get mapEventsStripDeclinedBody =>
      'Organizatorii au refuzat această mașină pentru acest eveniment.';

  @override
  String get mapEventsStripWithdrawnTitle => 'Retragere solicitată';

  @override
  String get mapEventsStripWithdrawnBody =>
      'Organizatorii îți analizează cererea de retragere. Nu o mai poți anula.';

  @override
  String get mapEventsDeclineReasonHeading => 'MOTIVUL';

  @override
  String get mapEventsTryAnotherCar => 'ÎNCEARCĂ ALTĂ MAȘINĂ';

  @override
  String get mapEventsCancelRequest => 'ANULEAZĂ CEREREA';

  @override
  String get mapEventsPickCarTitle => 'Cu ce mașini vii?';

  @override
  String get mapEventsPickCarSubtitle =>
      'Selectează cel puțin o mașină pentru înscriere';

  @override
  String mapEventsPickCarSpotsLeft(int count) {
    return 'Mai sunt $count locuri — poți selecta până la atâtea';
  }

  @override
  String get mapEventsPickCarFull =>
      'Acest eveniment a atins numărul maxim de participanți.';

  @override
  String get mapEventsPickCarAlreadyIn => 'Deja înscrisă';

  @override
  String get mapEventsPickCarSelectAll => 'SELECTEAZĂ TOATE';

  @override
  String get mapEventsPickCarClearAll => 'ȘTERGE';

  @override
  String mapEventsPickCarRegisterCta(int count) {
    return 'ÎNSCRIE ($count)';
  }

  @override
  String get mapEventsPickCarEmptyTitle => 'Garajul tău este gol';

  @override
  String get mapEventsPickCarEmptyBody =>
      'Adaugă întâi o mașină în garaj, apoi înscrie-o la un eveniment.';

  @override
  String get mapEventsPickCarAdd => 'ADAUGĂ O MAȘINĂ';

  @override
  String mapEventsCarYear(String year) {
    return '$year';
  }

  @override
  String get mapEventsWithdrawTitle => 'Te retragi de la acest eveniment?';

  @override
  String get mapEventsWithdrawBody =>
      'Le vei cere organizatorilor să te scoată de pe lista de înscrieri și din orice concurs din cadrul evenimentului. Odată trimisă, cererea nu mai poate fi anulată.';

  @override
  String mapEventsWithdrawAllCars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Toate cele $count de mașini ale tale ies împreună de pe lista de înscrieri — nu poți retrage doar una. Un organizator trebuie să aprobe mai întâi.',
      few:
          'Toate cele $count mașini ale tale ies împreună de pe lista de înscrieri — nu poți retrage doar una. Un organizator trebuie să aprobe mai întâi.',
      one:
          'Mașina ta iese de pe lista de înscrieri — un organizator trebuie să aprobe mai întâi.',
    );
    return '$_temp0';
  }

  @override
  String get mapEventsWithdrawNoteLabel =>
      'NOTĂ PENTRU ORGANIZATORI (OPȚIONAL)';

  @override
  String get mapEventsWithdrawNoteHint => 'Spune-le de ce, dacă vrei…';

  @override
  String get mapEventsCancel => 'ANULEAZĂ';

  @override
  String get mapEventsAttendeesPageTitle => 'Participanți';

  @override
  String get mapEventsFilterAttending => 'PARTICIPĂ';

  @override
  String get mapEventsFilterInterested => 'INTERESAȚI';

  @override
  String get mapEventsCreateTitle => 'EVENIMENT NOU';

  @override
  String get mapEventsEditTitle => 'EDITEAZĂ EVENIMENTUL';

  @override
  String get mapEventsCoverAdd => 'ADAUGĂ O FOTOGRAFIE DE COPERTĂ';

  @override
  String get mapEventsCoverHint => 'recomandat 1600 × 900';

  @override
  String get mapEventsCoverChange => 'SCHIMBĂ COPERTA';

  @override
  String get mapEventsFieldCover => 'FOTOGRAFIE DE COPERTĂ';

  @override
  String get mapEventsFieldTitle => 'TITLUL EVENIMENTULUI';

  @override
  String get mapEventsFieldTitleHint => 'ex. Casino Square Cars & Coffee';

  @override
  String get mapEventsFieldCategory => 'CATEGORIA EVENIMENTULUI';

  @override
  String get mapEventsCategoriesSoonNote => 'Urmează și alte categorii.';

  @override
  String get mapEventsCategoryTrackDay => 'Track Day';

  @override
  String get mapEventsCategoryCarsAndCoffee => 'Cars & Coffee';

  @override
  String get mapEventsCategoryCruise => 'Cruise';

  @override
  String get mapEventsFieldDescription => 'DESCRIERE';

  @override
  String get mapEventsFieldDescriptionHint => 'Despre ce e evenimentul ?';

  @override
  String get mapEventsFieldLocation => 'LOCAȚIE';

  @override
  String get mapEventsFieldVenueHint => 'Numele locației — ex. Place du Casino';

  @override
  String get mapEventsSetLocationOnMap => 'ALEGE LOCAȚIA PE HARTĂ';

  @override
  String get mapEventsLocationSet => 'PIN PLASAT · ATINGE PENTRU A-L MUTA';

  @override
  String get mapEventsFieldDateTime => 'DATĂ ȘI ORĂ';

  @override
  String get mapEventsStartsLabel => 'Începe';

  @override
  String get mapEventsEndsLabel => 'Se termină';

  @override
  String get mapEventsEndBlankHint =>
      'Lasă finalul gol pentru un eveniment fără oră de încheiere.';

  @override
  String get mapEventsClearEnd => 'ȘTERGE FINALUL';

  @override
  String get mapEventsFieldCapacity => 'CAPACITATE MAXIMĂ';

  @override
  String get mapEventsOptional => 'OPȚIONAL';

  @override
  String get mapEventsRequired => 'OBLIGATORIU';

  @override
  String get mapEventsCapacityHint => 'Fără o limită explicită, e nelimitat';

  @override
  String get mapEventsCapacityLockedHint =>
      'Capacitatea poate fi mărită ulterior, dar nu poate fi eliminată.';

  @override
  String get mapEventsApprovalToggleTitle =>
      'Necesită aprobare pentru înscriere';

  @override
  String get mapEventsApprovalToggleBody =>
      'Tu și co-organizatorii tăi analizați fiecare cerere înainte ca un participant să fie adăugat pe lista de înscrieri.';

  @override
  String get mapEventsFieldDeadline => 'TERMEN LIMITĂ DE ÎNSCRIERE';

  @override
  String get mapEventsFieldRules => 'REGULI ȘI RECOMANDĂRI';

  @override
  String get mapEventsAddRule => 'ADAUGĂ O REGULĂ';

  @override
  String get mapEventsRuleHint => 'ex. Fără turat sau derapaje.';

  @override
  String get mapEventsRemoveRule => 'Șterge regula';

  @override
  String get mapEventsFieldOrganizers => 'ORGANIZATORI';

  @override
  String get mapEventsOrganizersHint =>
      'Tu ești creatorul. Adaugă alte conturi de persoane sau de business certificate care să organizeze împreună cu tine.';

  @override
  String get mapEventsYouCreator => 'TU · CREATOR';

  @override
  String get mapEventsAddOrganizer => 'ADAUGĂ ORGANIZATOR';

  @override
  String get mapEventsRemoveOrganizer => 'Șterge organizatorul';

  @override
  String get mapEventsCreateCta => 'CREEAZĂ EVENIMENTUL';

  @override
  String get mapEventsCreateCtaIncomplete =>
      'ADAUGĂ TITLU, LOCAȚIE ȘI ORA DE ÎNCEPERE';

  @override
  String get mapEventsCreateCtaDeadline => 'ADAUGĂ UN TERMEN DE ÎNSCRIERE';

  @override
  String get mapEventsCreateCtaCover => 'ADAUGĂ O FOTOGRAFIE DE COPERTĂ';

  @override
  String get mapEventsSaveCta => 'SALVEAZĂ MODIFICĂRILE';

  @override
  String get mapEventsSubmitting => 'Doar o clipă…';

  @override
  String get mapEventsValidationEndBeforeStart =>
      'Ora de final trebuie să fie după ora de început.';

  @override
  String get mapEventsValidationDeadlineAfterStart =>
      'Termenul de înscriere trebuie să fie înainte de începerea evenimentului.';

  @override
  String get mapEventsValidationCapacity =>
      'Capacitatea trebuie să fie cel puțin 1.';

  @override
  String get mapEventsPendingReviewTitle => 'Trimis spre verificare';

  @override
  String get mapEventsPendingReviewBody =>
      'Echipa noastră verifică fiecare eveniment nou înainte să apară pe hartă. Până atunci îl găsești la Evenimente, pe profilul tău.';

  @override
  String get mapEventsDone => 'GATA';

  @override
  String get mapEventsCoverUploadFailed =>
      'Evenimentul a fost creat, dar fotografia de copertă nu s-a încărcat. O poți adăuga din Evenimentele mele.';

  @override
  String get mapEventsWizardNext => 'MAI DEPARTE';

  @override
  String get mapEventsWizardBack => 'ÎNAPOI';

  @override
  String get mapEventsWizardClose => 'Închide';

  @override
  String get mapEventsWizardDiscardTitle => 'Ieși din ciorna evenimentului?';

  @override
  String get mapEventsWizardDiscardBody =>
      'Progresul e salvat pe telefon, așa că poți relua de unde ai rămas. Sau îl arunci și o iei de la capăt data viitoare.';

  @override
  String get mapEventsWizardKeepDraft => 'SALVEAZĂ & IEȘI';

  @override
  String get mapEventsWizardDiscardDraft => 'ARUNCĂ';

  @override
  String get mapEventsWizardStay => 'CONTINUĂ';

  @override
  String get mapEventsDraftRestored => 'Am reluat de unde ai rămas.';

  @override
  String get mapEventsDraftStartOver => 'IA DE LA CAPĂT';

  @override
  String get mapEventsStepBasicsTitle => 'Datele de bază';

  @override
  String get mapEventsStepBasicsSubtitle =>
      'Cum se numește evenimentul și la ce să se aștepte lumea?';

  @override
  String get mapEventsStepOrganizersTitle => 'Cine îl organizează';

  @override
  String get mapEventsStepOrganizersSubtitle =>
      'Tu ești creatorul. Adaugă conturi individuale sau de business certificate care să organizeze împreună cu tine.';

  @override
  String get mapEventsStepOrganizersEmpty =>
      'Niciun co-organizator încă. Îi poți adăuga și mai târziu.';

  @override
  String get mapEventsStepWhenWhereTitle => 'Când & unde';

  @override
  String get mapEventsStepWhenWhereSubtitle =>
      'Stabilește programul, apoi pune pinul pe hartă.';

  @override
  String get mapEventsLocationPickCta => 'ALEGE LOCAȚIA PE HARTĂ';

  @override
  String get mapEventsLocationChangeCta => 'SCHIMBĂ LOCAȚIA';

  @override
  String get mapEventsLocationCardCity => 'Oraș';

  @override
  String get mapEventsLocationCardStreet => 'Stradă';

  @override
  String get mapEventsLocationCardNumber => 'Număr';

  @override
  String get mapEventsLocationCardPin => 'Pin plasat';

  @override
  String get mapEventsLocationEmptyHint =>
      'Alege o locație și completăm orașul, strada și numărul din adresa căutată.';

  @override
  String get mapEventsDeadlineHint =>
      'Întâlnirile auto au nevoie de una: ultimul moment în care cineva poate înscrie o mașină.';

  @override
  String get mapEventsStepRulesTitle => 'Reguli & înscriere';

  @override
  String get mapEventsStepRulesSubtitle =>
      'Regulile casei, câte mașini încap și dacă verifici fiecare înscriere.';

  @override
  String get mapEventsRulesEmpty =>
      'Nicio regulă încă. Multe întâlniri merg bine și fără.';

  @override
  String get mapEventsCapacityUnlimited => 'Nelimitat';

  @override
  String get mapEventsCapacityUnlimitedHint => 'Lasă gol pentru fără limită.';

  @override
  String get mapEventsStepContestsTitle => 'Concursuri';

  @override
  String get mapEventsStepContestsSubtitle =>
      'Pregătește categoriile la care se votează. Le poți adăuga, edita sau șterge oricând după ce evenimentul e aprobat.';

  @override
  String get mapEventsContestsEmpty => 'Niciun concurs încă.';

  @override
  String get mapEventsAddContest => 'ADAUGĂ UN CONCURS';

  @override
  String get mapEventsEditContest => 'Editează concursul';

  @override
  String get mapEventsRemoveContest => 'Șterge concursul';

  @override
  String get mapEventsContestsUnavailable =>
      'Categoriile de concurs nu au putut fi încărcate. Poți adăuga concursuri din pagina evenimentului după aprobare.';

  @override
  String mapEventsContestsFullHint(int count) {
    return 'Un eveniment poate avea până la $count concursuri.';
  }

  @override
  String mapEventsContestsFailed(int count) {
    return 'Evenimentul a fost creat, dar $count dintre concursurile lui nu. Le poți adăuga din Evenimentele mele.';
  }

  @override
  String get mapEventsContestOpensLabel => 'Votul se deschide';

  @override
  String get mapEventsContestClosesLabel => 'Votul se închide';

  @override
  String get mapEventsContestOpensAtStart => 'Când începe întâlnirea';

  @override
  String get mapEventsContestOpensNow => 'Imediat ce e aprobat';

  @override
  String get mapEventsContestCustomTime => 'Alege o oră';

  @override
  String get mapEventsContestClosesManualNote =>
      'Participanții văd această oră. Tot tu deschizi și închizi votarea, din lista de concursuri după ce evenimentul e aprobat.';

  @override
  String get mapEventsContestTitleLabel => 'TITLUL CONCURSULUI';

  @override
  String get mapEventsContestTitleHint => 'ex. Cel mai bun sistem de evacuare';

  @override
  String get mapEventsContestCriteriaLabel => 'NOTĂ DE JURIZARE';

  @override
  String get mapEventsContestCriteriaHint => 'La ce se votează, mai exact?';

  @override
  String get mapEventsContestCategoryLabel => 'CATEGORIE';

  @override
  String get mapEventsContestSave => 'SALVEAZĂ CONCURSUL';

  @override
  String get mapEventsStepCoverTitle => 'Poza de copertă';

  @override
  String get mapEventsStepCoverSubtitle =>
      'Singura imagine pe care lumea o vede pe hartă, în feed și în capul evenimentului.';

  @override
  String get mapEventsStepReviewTitle => 'Verifică & publică';

  @override
  String get mapEventsStepReviewSubtitle =>
      'Așa îl va vedea lumea. Atinge orice secțiune ca să te întorci și să o modifici.';

  @override
  String get mapEventsReviewEdit => 'MODIFICĂ';

  @override
  String get mapEventsReviewNoDescription => 'Încă fără descriere';

  @override
  String get mapEventsReviewNoRules => 'Fără reguli';

  @override
  String get mapEventsReviewNoContests => 'Fără concursuri';

  @override
  String get mapEventsReviewNoOrganizers => 'Doar tu';

  @override
  String get mapEventsReviewOpenEnded => 'Fără oră de final';

  @override
  String get mapEventsReviewApprovalOn => 'Aprobi fiecare mașină';

  @override
  String get mapEventsReviewApprovalOff => 'Oricine poate înscrie o mașină';

  @override
  String get mapEventsReviewSectionOrganizers => 'ORGANIZATORI';

  @override
  String get mapEventsReviewSectionSchedule => 'PROGRAM';

  @override
  String get mapEventsReviewSectionEntry => 'ÎNSCRIERE';

  @override
  String get mapEventsPublishCta => 'TRIMITE SPRE APROBARE';

  @override
  String get mapEventsValidationTitle => 'Dă-i evenimentului un titlu.';

  @override
  String get mapEventsValidationDescription =>
      'Adaugă o descriere scurtă, ca lumea să știe despre ce e vorba.';

  @override
  String get mapEventsValidationLocation => 'Alege locația pe hartă.';

  @override
  String get mapEventsValidationStart => 'Stabilește când începe evenimentul.';

  @override
  String get mapEventsValidationDeadlineRequired =>
      'O întâlnire auto are nevoie de un termen limită de înscriere.';

  @override
  String get mapEventsValidationCover => 'Adaugă o poză de copertă.';

  @override
  String get mapEventsUseThisLocation => 'FOLOSEȘTE ACEASTĂ LOCAȚIE';

  @override
  String get mapEventsLocationFormTitle => 'Găsește adresa';

  @override
  String get mapEventsLocationFormSubtitle =>
      'Vom muta harta acolo. Tu plasezi pinul exact.';

  @override
  String get mapEventsLocationCity => 'ORAȘ';

  @override
  String get mapEventsLocationCityHint => 'Cluj-Napoca';

  @override
  String get mapEventsLocationStreet => 'STRADA';

  @override
  String get mapEventsLocationStreetHint => 'Strada Memorandumului';

  @override
  String get mapEventsLocationNumber => 'NUMĂR';

  @override
  String get mapEventsLocationNumberHint => '28B';

  @override
  String get mapEventsLocationSearchButton => 'CAUTĂ';

  @override
  String get mapEventsLocationSearchIncomplete =>
      'COMPLETEAZĂ TOATE CELE TREI CÂMPURI';

  @override
  String get mapEventsLocationSearchNoResults =>
      'Nicio potrivire pentru acea adresă. Verifică scrierea sau caută strada fără număr.';

  @override
  String get mapEventsLocationResultsTitle =>
      'Alege cea mai apropiată potrivire';

  @override
  String get mapEventsLocationResultsSubtitle =>
      'Asta doar mută harta — pinul tot tu îl plasezi.';

  @override
  String get mapEventsLocationEditSearch => 'MODIFICĂ';

  @override
  String get mapEventsLocationBackToResults => 'REZULTATE';

  @override
  String get mapEventsLocationDropPinTitle =>
      'Atinge harta pentru a plasa pinul';

  @override
  String get mapEventsLocationDropPinBody =>
      'Atinge locul exact — intrarea, curtea, zona de parcare.';

  @override
  String get mapEventsLocationPinDropped =>
      'Pin plasat. Atinge din nou pentru a-l muta.';

  @override
  String get mapEventsLocationPrecisionExact => 'ADRESĂ EXACTĂ';

  @override
  String get mapEventsLocationPrecisionPoint => 'PUNCT APROPIAT';

  @override
  String get mapEventsLocationPrecisionIntersection => 'INTERSECȚIE';

  @override
  String get mapEventsLocationPrecisionApproximate => 'APROXIMATIV';

  @override
  String get mapEventsLocationPrecisionStreet => 'NIVEL STRADĂ';

  @override
  String get mapEventsLocationPrecisionAddress => 'ADRESĂ';

  @override
  String get mapEventsLocationPrecisionPostcode => 'ZONĂ COD POȘTAL';

  @override
  String get mapEventsLocationPrecisionArea => 'ZONĂ EXTINSĂ';

  @override
  String get mapEventsSearchOrganizersTitle => 'Adaugă un organizator';

  @override
  String get mapEventsSearchOrganizersHint => 'Caută persoane și business-uri';

  @override
  String get mapEventsSearchOrganizersEmpty => 'Nu a fost găsit nimeni.';

  @override
  String get mapEventsSearchOrganizersPrompt =>
      'Începe să scrii un nume pentru a găsi persoane și business-uri certificate.';

  @override
  String get profileTabEvents => 'Evenimente';

  @override
  String get mapEventsMineTitle => 'Evenimentele mele';

  @override
  String get mapEventsMineEmptyTitle => 'Încă niciun eveniment';

  @override
  String get mapEventsMineEmptyBody =>
      'Evenimentele pe care le creezi apar aici — inclusiv cele care așteaptă verificarea.';

  @override
  String get mapEventsMineCreate => 'CREEAZĂ UN EVENIMENT';

  @override
  String get mapEventsManageTitle => 'Gestionează evenimentul';

  @override
  String get mapEventsManageEntries => 'CERERI DE ÎNSCRIERE';

  @override
  String get mapEventsManageWithdrawals => 'CERERI DE RETRAGERE';

  @override
  String get mapEventsManageOrganizers => 'ORGANIZATORI';

  @override
  String get mapEventsManageDanger => 'EVENIMENT';

  @override
  String get mapEventsNoPendingEntries =>
      'Nicio cerere de înscriere în așteptare.';

  @override
  String get mapEventsNoWithdrawals =>
      'Nicio cerere de retragere în așteptare.';

  @override
  String get mapEventsAccept => 'ACCEPTĂ';

  @override
  String get mapEventsDecline => 'REFUZĂ';

  @override
  String get mapEventsDeclineTitle => 'Refuzi această înscriere?';

  @override
  String mapEventsDeclineBody(String car) {
    return '$car nu va fi pe lista de înscrieri. Proprietarul vede motivul tău, așa că scrie ceva ce poate folosi.';
  }

  @override
  String get mapEventsDeclineReasonLabel => 'MOTIV (OBLIGATORIU)';

  @override
  String get mapEventsDeclineReasonHint =>
      'Categorie greșită pentru o întâlnire doar JDM…';

  @override
  String get mapEventsLetThemOut => 'LASĂ-I SĂ PLECE';

  @override
  String get mapEventsKeepThemIn => 'PĂSTREAZĂ-I';

  @override
  String get mapEventsWithdrawalNoteLabel => 'Nota lor';

  @override
  String get mapEventsEditEvent => 'EDITEAZĂ EVENIMENTUL';

  @override
  String get mapEventsCancelEvent => 'ANULEAZĂ EVENIMENTUL';

  @override
  String get mapEventsFinishEvent => 'ÎNCHEIE EVENIMENTUL';

  @override
  String get mapEventsDeleteEvent => 'ȘTERGE EVENIMENTUL';

  @override
  String get mapEventsEditLockedHint =>
      'Un eveniment poate fi editat doar cât timp așteaptă verificarea sau după ce a fost respins.';

  @override
  String get mapEventsConfirmCancelTitle => 'Anulezi acest eveniment?';

  @override
  String get mapEventsConfirmCancelBody =>
      'Rămâne vizibil, dar este marcat ca anulat, iar nimeni nu mai poate înscrie o mașină.';

  @override
  String get mapEventsConfirmFinishTitle => 'Închei acest eveniment?';

  @override
  String get mapEventsConfirmFinishBody =>
      'Se mută la evenimentele tale trecute. Confirmările și lista de înscrieri rămân neschimbate.';

  @override
  String get mapEventsConfirmDeleteTitle => 'Ștergi acest eveniment?';

  @override
  String get mapEventsConfirmDeleteBody =>
      'Această acțiune nu poate fi anulată. Lista de înscrieri și toate confirmările dispar odată cu el.';

  @override
  String get mapEventsConfirm => 'CONFIRMĂ';

  @override
  String get mapEventsDelete => 'ȘTERGE';

  @override
  String mapEventsWithdrawalCarsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mașini',
      one: '1 mașină',
    );
    return '$_temp0';
  }

  @override
  String get mapSearchPlaceholder => 'Caută întâlniri, service-uri, orașe…';

  @override
  String get mapCreateEvent => 'Creează un eveniment';

  @override
  String get mapEventsCopied => 'Detaliile evenimentului au fost copiate.';

  @override
  String get mapEventsDateCardTitle => 'Când';

  @override
  String get feedbackFeedEyebrow => 'COMUNITATE';

  @override
  String get feedbackFeedTitle => 'Feedback';

  @override
  String get feedbackFeedNew => 'NOU';

  @override
  String get feedbackFeedSortNewest => 'CELE NOI';

  @override
  String get feedbackFeedSortPopular => 'POPULARE';

  @override
  String get feedbackFeedSortOldest => 'CELE VECHI';

  @override
  String get feedbackFeedCompletedLink => 'Cereri finalizate';

  @override
  String get feedbackFeedCompletedTitle => 'Cereri finalizate';

  @override
  String get feedbackFeedComposeEyebrow => 'COMUNITATEA DE FEEDBACK';

  @override
  String get feedbackFeedComposeTitle => 'Trimite feedback';

  @override
  String get feedbackFeedComposeSubtitle =>
      'Vizibil pentru toată lumea. Ceilalți șoferi pot vota pentru sau împotrivă.';

  @override
  String get feedbackFeedCategoryLabel => 'CATEGORIE';

  @override
  String get feedbackFeedMessageLabel => 'MESAJUL TĂU';

  @override
  String get feedbackFeedMessageHint =>
      'La ce te gândești — un bug, o idee, o îmbunătățire?';

  @override
  String get feedbackFeedPostAction => 'TRIMITE FEEDBACK';

  @override
  String get feedbackFeedPostSuccess => 'Feedbackul tău este public.';

  @override
  String get feedbackFeedYou => 'tu';

  @override
  String feedbackFeedNetVotes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count voturi nete',
      one: '1 vot net',
    );
    return '$_temp0';
  }

  @override
  String feedbackFeedShippedAgo(String time) {
    return 'livrat acum $time';
  }

  @override
  String feedbackFeedTimeAgo(String time) {
    return 'acum $time';
  }

  @override
  String get feedbackFeedStaffLabel => 'ECHIPA TWEAKD';

  @override
  String get feedbackFeedDelete => 'Șterge';

  @override
  String get feedbackFeedDeleteTitle => 'Ștergi acest feedback?';

  @override
  String get feedbackFeedDeleteBody =>
      'Acțiunea nu poate fi anulată. Voturile strânse dispar odată cu el.';

  @override
  String get feedbackFeedDeleteSuccess => 'Feedback șters.';

  @override
  String get feedbackFeedCancel => 'Anulează';

  @override
  String get feedbackFeedEmptyTitle => 'Încă nu e nimic aici';

  @override
  String get feedbackFeedEmptyBody =>
      'Fii primul care raportează un bug sau propune o idee.';

  @override
  String get feedbackFeedCompletedEmptyTitle => 'Încă nu am livrat nimic';

  @override
  String get feedbackFeedCompletedEmptyBody =>
      'După ce finalizăm o cerere, apare aici.';

  @override
  String get feedbackFeedRetry => 'Încearcă din nou';

  @override
  String get feedbackFeedErrorNetwork =>
      'Nu ai conexiune la internet. Încearcă din nou.';

  @override
  String get feedbackFeedErrorNotFound => 'Acest feedback nu mai există.';

  @override
  String get feedbackFeedErrorLocked =>
      'Ne-am apucat deja de asta, așa că nu mai poate fi șters.';

  @override
  String get feedbackFeedErrorGeneric =>
      'Ceva nu a mers bine. Încearcă din nou.';

  @override
  String get profileBadgesAll => 'TOATE';

  @override
  String get profileBadgesSheetTitle => 'Insigne';

  @override
  String get profileBadgesEmptyVisitor => 'Încă nu are insigne.';

  @override
  String get garageCarStatYear => 'AN';

  @override
  String profileBadgesSheetUnlocked(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString deblocate',
      one: '1 deblocată',
      zero: 'Nicio insignă încă',
    );
    return '$_temp0';
  }

  @override
  String get createPostTitle => 'Postare';

  @override
  String get createPostSubtitle =>
      'Fotografii cu mașina ta, un drum sau un detaliu';

  @override
  String get createThreadTitle => 'Thread pe forum';

  @override
  String get createThreadSubtitle => 'Pune o întrebare sau pornește o discuție';

  @override
  String get createEventTitle => 'Eveniment auto';

  @override
  String get createEventSubtitle =>
      'Organizează o întâlnire, o plimbare sau o zi pe circuit';

  @override
  String get createModTitle => 'Adaugă o modificare';

  @override
  String get createModSubtitle =>
      'Notează o piesă nouă sau un upgrade la una dintre mașinile tale';

  @override
  String get feedSegmentFeed => 'Feed';

  @override
  String get forumsBrowseAction => 'Explorează forumurile';

  @override
  String get forumsSavedAction => 'Thread-uri salvate';

  @override
  String get garageCarStatPower => 'PUTERE';

  @override
  String get garageCarStatTorque => 'CUPLU';

  @override
  String get garageCarUnitPower => 'cp';

  @override
  String get garageCarUnitTorque => 'lb-ft';

  @override
  String get commonContinue => 'Continuă';

  @override
  String get badgeCelebrationHeadline => 'Insignă nouă deblocată!';

  @override
  String get contestsTab => 'CONCURSURI';

  @override
  String get contestsSectionVotingOpen => 'VOTAREA E DESCHISĂ';

  @override
  String get contestsSectionOpensLater => 'SE DESCHID MAI TÂRZIU';

  @override
  String get contestsSectionResults => 'REZULTATE';

  @override
  String contestsStandingEntered(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mașina ta e înscrisă în $count concursuri',
      one: 'Mașina ta e înscrisă într-un concurs',
    );
    return '$_temp0';
  }

  @override
  String get contestsStandingNotEntered => 'Mașina ta nu e înscrisă încă';

  @override
  String contestsVotesOpenToYou(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mai ai $count voturi de dat',
      one: 'Mai ai un vot de dat',
      zero: 'Ai votat în toate concursurile deschise',
    );
    return '$_temp0';
  }

  @override
  String get contestsManage => 'GESTIONEAZĂ';

  @override
  String get contestsEnterCar => 'ÎNSCRIE';

  @override
  String get contestsFooterNote =>
      'Un vot per concurs. Îl poți schimba oricând până când organizatorul închide votarea.';

  @override
  String get contestsEmptyTitle => 'Niciun concurs aici';

  @override
  String get contestsEmptyBody =>
      'Organizatorul nu a deschis niciun vot pentru această întâlnire.';

  @override
  String contestsAllCount(int count) {
    return 'TOATE CELE $count CONCURSURI';
  }

  @override
  String contestsCarsAndVotes(int cars, int votes) {
    String _temp0 = intl.Intl.pluralLogic(
      cars,
      locale: localeName,
      other: '$cars mașini',
      one: '1 mașină',
    );
    String _temp1 = intl.Intl.pluralLogic(
      votes,
      locale: localeName,
      other: '$votes voturi',
      one: '1 vot',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String contestsCarsEnteredCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mașini înscrise',
      one: '1 mașină înscrisă',
    );
    return '$_temp0';
  }

  @override
  String get contestsYoursIsIn => '· a ta e înscrisă';

  @override
  String get contestsCastYourVote => 'VOTEAZĂ';

  @override
  String get contestsVoteBeforeClose => 'VOTEAZĂ ÎNAINTE SĂ SE ÎNCHIDĂ';

  @override
  String get contestsVote => 'VOTEAZĂ';

  @override
  String get contestsVoted => 'VOTAT';

  @override
  String get contestsYourVote => 'VOTUL TĂU';

  @override
  String get contestsChange => 'SCHIMBĂ';

  @override
  String contestsTimeLeftHours(int hours, int minutes) {
    return '${hours}h ${minutes}m rămase';
  }

  @override
  String contestsTimeLeftMinutes(int minutes) {
    return '${minutes}m rămase';
  }

  @override
  String contestsOpensInHours(int hours, int minutes) {
    return 'se deschide în ${hours}h ${minutes}m';
  }

  @override
  String contestsOpensInMinutes(int minutes) {
    return 'se deschide în ${minutes}m';
  }

  @override
  String get contestsOpensSoon => 'așteaptă organizatorul';

  @override
  String get contestsVotingOpenNow => 'votare deschisă';

  @override
  String get contestsClosing => 'se închide';

  @override
  String get contestsResultsIn => 'REZULTATE';

  @override
  String get contestsClosed => 'ÎNCHIS';

  @override
  String get contestsStatVotesCast => 'VOTURI';

  @override
  String get contestsStatCarsIn => 'MAȘINI';

  @override
  String get contestsStatRemaining => 'RĂMAS';

  @override
  String get contestsStatStatus => 'STARE';

  @override
  String get contestsStatVoting => 'VOTARE';

  @override
  String get contestsHowItWorks => 'CUM FUNCȚIONEAZĂ';

  @override
  String get contestsHowItWasJudged => 'CUM S-A JURIZAT';

  @override
  String contestsSetBy(String username) {
    return 'Stabilit de @$username';
  }

  @override
  String get contestsLeaderboard => 'CLASAMENT';

  @override
  String get contestsCarsEntered => 'MAȘINI ÎNSCRISE';

  @override
  String get contestsFinalStandings => 'CLASAMENT FINAL';

  @override
  String get contestsUpdatingLive => 'LIVE';

  @override
  String contestsVotingOpensAt(String time) {
    return 'Planificată să se deschidă la $time — o pornește organizatorul';
  }

  @override
  String get contestsNoEntriesYet => 'Nicio mașină pe buletin încă.';

  @override
  String get contestsWinner => 'CÂȘTIGĂTOR';

  @override
  String contestsVotesOf(int votes, int total) {
    return '$votes din $total voturi';
  }

  @override
  String contestsBadgeAwarded(String category) {
    return 'Insigna $category a fost acordată';
  }

  @override
  String get contestsBadgeAwardedBody =>
      'Apare acum pe mașină și pe profilul proprietarului';

  @override
  String get contestsNoWinner =>
      'Nimeni nu a votat, așa că nu există câștigător de data aceasta.';

  @override
  String get contestsThatsYourCar => 'E mașina ta';

  @override
  String get contestsPostToFeedHint => 'Postează cardul în feed';

  @override
  String get contestsShare => 'DISTRIBUIE';

  @override
  String get contestsShareYourWin => 'DISTRIBUIE VICTORIA';

  @override
  String get contestsShareTheResult => 'DISTRIBUIE REZULTATUL';

  @override
  String get contestsShareSheetTitle => 'Distribuie victoria';

  @override
  String get contestsShareResultSheetTitle => 'Distribuie rezultatul';

  @override
  String get contestsPostToFeed => 'POSTEAZĂ ÎN FEED';

  @override
  String get contestsPostedTitle => 'Postat în feed';

  @override
  String get contestsPostedBody => 'Urmăritorii tăi îl pot vedea acum';

  @override
  String get contestsPostFailed =>
      'Nu s-a putut posta cardul. Încearcă din nou.';

  @override
  String get contestsCaptionHint => 'Spune ceva despre victorie (opțional)';

  @override
  String contestsShareText(
    String car,
    String place,
    String contest,
    String event,
  ) {
    return '$car a luat locul $place la „$contest” la $event, pe Tweakd';
  }

  @override
  String contestsOfVotes(int total) {
    return 'DIN $total VOTURI';
  }

  @override
  String get contestsPickFavourite => 'Alege favorita';

  @override
  String get contestsChangeYourVote => 'Schimbă votul';

  @override
  String get contestsSaveNewVote => 'SALVEAZĂ NOUL VOT';

  @override
  String get contestsCastVote => 'VOTEAZĂ';

  @override
  String get contestsYourCar => 'MAȘINA TA';

  @override
  String get contestsEnterTitle => 'Înscrie-ți mașina';

  @override
  String get contestsApprovedForMeet => 'Aprobată pentru această întâlnire';

  @override
  String get contestsEnterHint =>
      'Alege categoriile în care vrei să fii jurizat. Organizatorul aprobă fiecare înscriere. Te poți retrage până se deschide votarea.';

  @override
  String get contestsEntryLocked => 'Votare deschisă — înscrierea e blocată';

  @override
  String get contestsVotingAlreadyOpen => 'Votarea e deja deschisă';

  @override
  String get contestsEntryPending => 'Așteaptă organizatorul';

  @override
  String get contestsEntryRejected => 'Neacceptată';

  @override
  String get contestsWhy => 'DE CE';

  @override
  String get contestsSaveEntries => 'SALVEAZĂ ÎNSCRIERILE';

  @override
  String get contestsEntriesSaved => 'Înscrierile au fost actualizate';

  @override
  String contestsVoteCounted(String car) {
    return 'Vot înregistrat pentru $car';
  }

  @override
  String get contestsCannotVoteOwnCar => 'Nu poți vota propria mașină';

  @override
  String get contestsVotingClosedHint => 'Votarea s-a închis';

  @override
  String get contestsAttendToVote =>
      'Confirmă participarea pentru a vota în acest concurs';

  @override
  String get contestsOrganizerTitle => 'Concursuri';

  @override
  String contestsOrganizerSubtitle(String event) {
    return '$event · ești organizator';
  }

  @override
  String get contestsNew => 'NOU';

  @override
  String get contestsStatRunning => 'ÎN DESFĂȘURARE';

  @override
  String get contestsStatScheduled => 'PROGRAMATE';

  @override
  String get contestsStatVotesTonight => 'VOTURI PÂNĂ ACUM';

  @override
  String get contestsRunningNow => 'ÎN DESFĂȘURARE';

  @override
  String get contestsScheduled => 'PROGRAMATE';

  @override
  String get contestsFinished => 'ÎNCHEIATE';

  @override
  String get contestsChipOpen => 'DESCHIS';

  @override
  String get contestsChipClosed => 'ÎNCHIS';

  @override
  String get contestsChipScheduled => 'PROGRAMAT';

  @override
  String get contestsFullBoard => 'CLASAMENT COMPLET';

  @override
  String get contestsFinishNow => 'ÎNCHEIE ACUM';

  @override
  String get contestsEdit => 'EDITEAZĂ';

  @override
  String get contestsOpenVotingNow => 'DESCHIDE VOTAREA';

  @override
  String get contestsExtend => 'PRELUNGEȘTE';

  @override
  String get contestsDelete => 'ȘTERGE';

  @override
  String get contestsResultsPublished =>
      'Rezultate publicate · insignă acordată';

  @override
  String get contestsNoVotesResult => 'Închis fără voturi';

  @override
  String get contestsAddAnother => 'ADAUGĂ ALT CONCURS';

  @override
  String get contestsAddFirst => 'CREEAZĂ UN CONCURS';

  @override
  String get contestsOrganizerEmpty =>
      'Niciun concurs încă. Deschide un vot și toți cei de la întâlnire își pot alege favorita.';

  @override
  String contestsClosedAtVotes(String time, int votes) {
    String _temp0 = intl.Intl.pluralLogic(
      votes,
      locale: localeName,
      other: '$votes voturi',
      one: '1 vot',
    );
    return 'Închis la $time · $_temp0';
  }

  @override
  String contestsLeftAndVotes(String left, int votes) {
    String _temp0 = intl.Intl.pluralLogic(
      votes,
      locale: localeName,
      other: '$votes voturi',
      one: '1 vot',
    );
    return '$left · $_temp0';
  }

  @override
  String contestsOpensAndCars(String opens, int cars) {
    String _temp0 = intl.Intl.pluralLogic(
      cars,
      locale: localeName,
      other: '$cars mașini înscrise',
      one: '1 mașină înscrisă',
    );
    return '$opens · $_temp0';
  }

  @override
  String contestsFinishTitle(String title) {
    return 'Închei „$title”?';
  }

  @override
  String contestsFinishBody(String timeLeft) {
    return 'Votarea se închide imediat — cu $timeLeft mai devreme. Clasamentul îngheață așa cum e acum și câștigătorul primește insigna.';
  }

  @override
  String get contestsFinishBodyNoVotes =>
      'Votarea se închide imediat. Nimeni nu a votat încă, așa că nu va exista câștigător.';

  @override
  String get contestsFinishBodyPastPlan =>
      'Votarea se închide imediat. A rulat peste ora pe care ai planificat-o. Clasamentul îngheață așa cum e acum, iar câștigătorul primește insigna.';

  @override
  String get contestsWinsIfFinishNow => 'CÂȘTIGĂ DACĂ ÎNCHEI ACUM';

  @override
  String contestsCloseRace(int gap) {
    String _temp0 = intl.Intl.pluralLogic(
      gap,
      locale: localeName,
      other: 'Doar $gap voturi în fața locului doi — se mai poate schimba.',
      one: 'Doar un vot în fața locului doi — se mai poate schimba.',
    );
    return '$_temp0';
  }

  @override
  String contestsClearLead(int gap) {
    return 'Avans clar — $gap voturi în fața locului doi.';
  }

  @override
  String get contestsKeepOpen => 'LASĂ DESCHIS';

  @override
  String get contestsFinishPublish => 'ÎNCHEIE & PUBLICĂ';

  @override
  String contestsFinishedBanner(String title) {
    return '„$title” s-a încheiat';
  }

  @override
  String get contestsFinishedBannerBody =>
      'Rezultatele sunt publice · toți cei de la întâlnire au fost anunțați';

  @override
  String contestsPendingEntries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count MAȘINI ÎN AȘTEPTARE',
      one: '1 MAȘINĂ ÎN AȘTEPTARE',
    );
    return '$_temp0';
  }

  @override
  String get contestsAccept => 'ACCEPTĂ';

  @override
  String get contestsDecline => 'REFUZĂ';

  @override
  String get contestsDeclineEntryTitle => 'Refuzi această mașină?';

  @override
  String get contestsDeclineEntryHint =>
      'Spune-i proprietarului de ce. Va vedea mesajul.';

  @override
  String get contestsExtendTitle => 'Prelungește votarea';

  @override
  String get contestsExtendBody =>
      'Alege noua oră de închidere pe care o văd participanții. E un plan, nu un termen — votarea merge până când închei concursul.';

  @override
  String contestsExtendClosesAt(String time) {
    return 'Se închide $time';
  }

  @override
  String get contestsExtendConfirm => 'PRELUNGEȘTE VOTAREA';

  @override
  String get contestsDeleteTitle => 'Ștergi acest concurs?';

  @override
  String get contestsDeleteBody =>
      'Nu s-a deschis încă, așa că nu se pierde nimic — mașinile înscrise sunt pur și simplu eliberate.';

  @override
  String get contestsCreateTitle => 'Concurs nou';

  @override
  String get contestsEditTitle => 'Editează concursul';

  @override
  String get contestsCategory => 'CATEGORIE';

  @override
  String get contestsCategoryCustom => 'Personalizat';

  @override
  String get contestsName => 'NUMELE CONCURSULUI';

  @override
  String get contestsNameHint => 'Numele afișat participanților';

  @override
  String get contestsNameHintCustom => 'ex. Cea mai bună mașină de zi cu zi';

  @override
  String get contestsCriteria => 'CUM AR TREBUI JURIZAT?';

  @override
  String get contestsCriteriaHint =>
      'Una sau două rânduri. Participanții văd asta deasupra clasamentului.';

  @override
  String get contestsVotingOpens => 'VOTAREA SE DESCHIDE';

  @override
  String get contestsOpensNow => 'Imediat';

  @override
  String get contestsOpensAtStart => 'La începutul întâlnirii';

  @override
  String get contestsSetATime => 'Setează o oră';

  @override
  String get contestsVotingCloses => 'VOTAREA SE ÎNCHIDE';

  @override
  String get contestsFinishEarlyNote =>
      'Aceste ore sunt ce văd participanții. Tu deschizi votarea și tot tu o închizi, din lista de concursuri.';

  @override
  String get contestsLockedOpenNote =>
      'Votarea e deschisă: acum se pot schimba doar nota de jurizare și ora de închidere.';

  @override
  String get contestsPublish => 'PUBLICĂ CONCURSUL';

  @override
  String get contestsSaveChanges => 'SALVEAZĂ MODIFICĂRILE';

  @override
  String get contestsManageSectionTitle => 'CONCURSURI';

  @override
  String get contestsManageOpen => 'Deschide concursurile';

  @override
  String contestsManageSummary(int running, int scheduled) {
    String _temp0 = intl.Intl.pluralLogic(
      running,
      locale: localeName,
      other: '$running în desfășurare',
      one: '1 în desfășurare',
      zero: 'Niciunul în desfășurare',
    );
    String _temp1 = intl.Intl.pluralLogic(
      scheduled,
      locale: localeName,
      other: '$scheduled programate',
      one: '1 programat',
      zero: 'niciunul programat',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String get contestsErrorNotEligible => 'Nu poți vota în acest concurs.';

  @override
  String get contestsRank1 => '1';

  @override
  String get contestsRank2 => '2';

  @override
  String get contestsRank3 => '3';

  @override
  String contestsRankN(int rank) {
    return '$rank';
  }

  @override
  String participantCardPlace(String rank) {
    return 'Locul $rank';
  }

  @override
  String get participantCardEvent => 'EVENIMENT';

  @override
  String get participantCardContests => 'CONCURSURI';

  @override
  String participantCardContestWithRank(String contest, String rank) {
    return '$contest ($rank)';
  }

  @override
  String participantCardMore(int count) {
    return '+$count altele';
  }

  @override
  String participantCardAttendees(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count persoane au fost la eveniment.',
      one: '1 persoană a fost la eveniment.',
      zero: 'Nimeni nu s-a înregistrat la eveniment.',
    );
    return '$_temp0';
  }

  @override
  String get participantCardContestsSheetTitle =>
      'Concursurile la care a participat';

  @override
  String get participantCardTookPart => 'A participat';

  @override
  String get participantCardShareSheetTitle => 'Distribuie cardul';

  @override
  String participantCardShareText(String car, String event) {
    return '$car a fost la $event pe Tweakd';
  }

  @override
  String participantCardShareTextPlaced(
    String car,
    String place,
    String contest,
    String event,
  ) {
    return '$car a luat $place la \"$contest\" în $event pe Tweakd';
  }

  @override
  String get participantCardShare => 'DISTRIBUIE CARDUL';

  @override
  String participantCardSectionTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'CARDURILE TALE',
      one: 'CARDUL TĂU',
    );
    return '$_temp0';
  }

  @override
  String get participantCardYourCard => 'CARDUL TĂU';

  @override
  String get participantCardNotReady =>
      'Cardul tău va fi gata după ce organizatorul încheie evenimentul.';

  @override
  String participantCardCooldown(String date) {
    return 'Ai distribuit recent acest card. Îl poți distribui din nou pe $date.';
  }

  @override
  String get carEventsContestBadges => 'INSIGNE DIN CONCURSURI';

  @override
  String carEventsBadgesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count INSIGNE DIN CONCURSURI',
      one: '1 INSIGNĂ DIN CONCURSURI',
    );
    return '$_temp0';
  }

  @override
  String get carEventsAttended => 'EVENIMENTE LA CARE A PARTICIPAT';

  @override
  String get carEventsWhereFrom => 'DE UNDE PROVIN';

  @override
  String carEventsPlacement(String rank, String category) {
    return '$rank · $category';
  }
}
