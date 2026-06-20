import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_km.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('km')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'PROPERTDIA'**
  String get appName;

  /// No description provided for @actionContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get actionContinue;

  /// No description provided for @actionGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get actionGetStarted;

  /// No description provided for @actionSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get actionSkip;

  /// No description provided for @actionLogIn.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get actionLogIn;

  /// No description provided for @actionSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get actionSeeAll;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navFavorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get navFavorite;

  /// No description provided for @navMedia.
  ///
  /// In en, this message translates to:
  /// **'Media'**
  String get navMedia;

  /// No description provided for @navPartnership.
  ///
  /// In en, this message translates to:
  /// **'Partner'**
  String get navPartnership;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @onbMapTitle.
  ///
  /// In en, this message translates to:
  /// **'Real Prices on the Map'**
  String get onbMapTitle;

  /// No description provided for @onbMapSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Browse live market prices and trends by area.'**
  String get onbMapSubtitle;

  /// No description provided for @onbEstimateTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick Property Estimate'**
  String get onbEstimateTitle;

  /// No description provided for @onbEstimateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get an instant price indication based on type, size, and location.'**
  String get onbEstimateSubtitle;

  /// No description provided for @onbTitleTitle.
  ///
  /// In en, this message translates to:
  /// **'Title Services in Cambodia'**
  String get onbTitleTitle;

  /// No description provided for @onbTitleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Verify property ownership and legal documents with trusted local experts.'**
  String get onbTitleSubtitle;

  /// No description provided for @onbAlreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get onbAlreadyHaveAccount;

  /// No description provided for @homeCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Current Location'**
  String get homeCurrentLocation;

  /// No description provided for @homeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search condo, borey, land...'**
  String get homeSearchHint;

  /// No description provided for @homeBestPrice.
  ///
  /// In en, this message translates to:
  /// **'Best Price'**
  String get homeBestPrice;

  /// No description provided for @moduleMapPrice.
  ///
  /// In en, this message translates to:
  /// **'Map Price'**
  String get moduleMapPrice;

  /// No description provided for @moduleEstimate.
  ///
  /// In en, this message translates to:
  /// **'Estimate'**
  String get moduleEstimate;

  /// No description provided for @moduleTitle.
  ///
  /// In en, this message translates to:
  /// **'Title Services'**
  String get moduleTitle;

  /// No description provided for @moduleForceSale.
  ///
  /// In en, this message translates to:
  /// **'Force Sale'**
  String get moduleForceSale;

  /// No description provided for @moduleInvest.
  ///
  /// In en, this message translates to:
  /// **'Invest'**
  String get moduleInvest;

  /// No description provided for @moduleLoan.
  ///
  /// In en, this message translates to:
  /// **'Loan'**
  String get moduleLoan;

  /// No description provided for @modulePartnership.
  ///
  /// In en, this message translates to:
  /// **'Partnership'**
  String get modulePartnership;

  /// No description provided for @profileGroupAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get profileGroupAccount;

  /// No description provided for @profileGroupActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get profileGroupActivity;

  /// No description provided for @profileGroupPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get profileGroupPreferences;

  /// No description provided for @profileGroupSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get profileGroupSupport;

  /// No description provided for @profilePersonalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get profilePersonalInfo;

  /// No description provided for @profileIdentityVerification.
  ///
  /// In en, this message translates to:
  /// **'Identity Verification'**
  String get profileIdentityVerification;

  /// No description provided for @profileNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Not verified'**
  String get profileNotVerified;

  /// No description provided for @profileSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security Settings'**
  String get profileSecurity;

  /// No description provided for @profileTransactionHistory.
  ///
  /// In en, this message translates to:
  /// **'Transaction History'**
  String get profileTransactionHistory;

  /// No description provided for @profileApplicationHistory.
  ///
  /// In en, this message translates to:
  /// **'Application History'**
  String get profileApplicationHistory;

  /// No description provided for @profileSavedDrafts.
  ///
  /// In en, this message translates to:
  /// **'Saved Drafts'**
  String get profileSavedDrafts;

  /// No description provided for @profileNotificationPrefs.
  ///
  /// In en, this message translates to:
  /// **'Notification Preferences'**
  String get profileNotificationPrefs;

  /// No description provided for @profileLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguage;

  /// No description provided for @profileHelpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get profileHelpSupport;

  /// No description provided for @profileSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get profileSignOut;

  /// No description provided for @profileGuestTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re browsing as a guest'**
  String get profileGuestTitle;

  /// No description provided for @profileGuestSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log in to save favorites, invest in projects and manage your wallet.'**
  String get profileGuestSubtitle;

  /// No description provided for @profileCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get profileCreateAccount;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// No description provided for @aboutHeadline.
  ///
  /// In en, this message translates to:
  /// **'Smarter property decisions in Cambodia'**
  String get aboutHeadline;

  /// No description provided for @aboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get to know the team behind PROPERTDIA and how to reach us.'**
  String get aboutSubtitle;

  /// No description provided for @aboutWhoWeAreLabel.
  ///
  /// In en, this message translates to:
  /// **'Who We Are'**
  String get aboutWhoWeAreLabel;

  /// No description provided for @aboutMissionLabel.
  ///
  /// In en, this message translates to:
  /// **'Our Mission'**
  String get aboutMissionLabel;

  /// No description provided for @aboutTeamLabel.
  ///
  /// In en, this message translates to:
  /// **'Our Team'**
  String get aboutTeamLabel;

  /// No description provided for @aboutOfficeLabel.
  ///
  /// In en, this message translates to:
  /// **'Office'**
  String get aboutOfficeLabel;

  /// No description provided for @aboutContactLabel.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get aboutContactLabel;

  /// No description provided for @aboutFollowLabel.
  ///
  /// In en, this message translates to:
  /// **'Follow Us'**
  String get aboutFollowLabel;

  /// No description provided for @aboutValuePricing.
  ///
  /// In en, this message translates to:
  /// **'Clear, data-backed property pricing.'**
  String get aboutValuePricing;

  /// No description provided for @aboutValueTitles.
  ///
  /// In en, this message translates to:
  /// **'Verified titles and trusted partners.'**
  String get aboutValueTitles;

  /// No description provided for @aboutValueAccess.
  ///
  /// In en, this message translates to:
  /// **'Open access for local and global investors.'**
  String get aboutValueAccess;

  /// No description provided for @aboutChatTelegram.
  ///
  /// In en, this message translates to:
  /// **'Chat on Telegram'**
  String get aboutChatTelegram;

  /// No description provided for @aboutCallSupport.
  ///
  /// In en, this message translates to:
  /// **'Call Support'**
  String get aboutCallSupport;

  /// No description provided for @aboutEmailUs.
  ///
  /// In en, this message translates to:
  /// **'Email Us'**
  String get aboutEmailUs;

  /// No description provided for @aboutGetDirections.
  ///
  /// In en, this message translates to:
  /// **'Get Directions'**
  String get aboutGetDirections;

  /// No description provided for @teamAboutLabel.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get teamAboutLabel;

  /// No description provided for @teamSpecialtiesLabel.
  ///
  /// In en, this message translates to:
  /// **'Specialties'**
  String get teamSpecialtiesLabel;

  /// No description provided for @teamContactLabel.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get teamContactLabel;

  /// No description provided for @teamEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get teamEmail;

  /// No description provided for @teamPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get teamPhone;

  /// No description provided for @teamYearsExperience.
  ///
  /// In en, this message translates to:
  /// **'{years}+ years of experience'**
  String teamYearsExperience(int years);
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
      <String>['en', 'km'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'km':
      return AppLocalizationsKm();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
