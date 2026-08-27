import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_ms.dart';
import 'app_localizations_th.dart';
import 'app_localizations_zh.dart';

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
    Locale('ja'),
    Locale('ko'),
    Locale('ms'),
    Locale('th'),
    Locale('zh'),
    Locale('zh', 'CN'),
    Locale('zh', 'TW'),
  ];

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navLive.
  ///
  /// In en, this message translates to:
  /// **'Live Shopping'**
  String get navLive;

  /// No description provided for @navShop.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get navShop;

  /// No description provided for @navCart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get navCart;

  /// No description provided for @navMe.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get navMe;

  /// No description provided for @navFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get navFavorites;

  /// No description provided for @navNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get navNotifications;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search for products'**
  String get searchHint;

  /// No description provided for @homeHeroTagline.
  ///
  /// In en, this message translates to:
  /// **'Live Commerce · All In One'**
  String get homeHeroTagline;

  /// No description provided for @homeHeroBrand.
  ///
  /// In en, this message translates to:
  /// **'Live Butler'**
  String get homeHeroBrand;

  /// No description provided for @homeSearchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search products'**
  String get homeSearchPlaceholder;

  /// No description provided for @homeSearchGo.
  ///
  /// In en, this message translates to:
  /// **'GO'**
  String get homeSearchGo;

  /// No description provided for @homeSectionReplays.
  ///
  /// In en, this message translates to:
  /// **'Replays · Short Videos'**
  String get homeSectionReplays;

  /// No description provided for @homeSectionCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get homeSectionCategories;

  /// No description provided for @homeSectionLiveAnnouncement.
  ///
  /// In en, this message translates to:
  /// **'Live Announcement'**
  String get homeSectionLiveAnnouncement;

  /// No description provided for @homeSectionWeeklySchedule.
  ///
  /// In en, this message translates to:
  /// **'This Week\'s Live Sessions'**
  String get homeSectionWeeklySchedule;

  /// No description provided for @homeViewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get homeViewAll;

  /// No description provided for @homeFloatingCS.
  ///
  /// In en, this message translates to:
  /// **'Customer Support'**
  String get homeFloatingCS;

  /// No description provided for @homeFloatingLivePreview.
  ///
  /// In en, this message translates to:
  /// **'Live Now'**
  String get homeFloatingLivePreview;

  /// No description provided for @supportTitle.
  ///
  /// In en, this message translates to:
  /// **'Coco Assistant'**
  String get supportTitle;

  /// No description provided for @supportStatus.
  ///
  /// In en, this message translates to:
  /// **'Online · ~1 min reply'**
  String get supportStatus;

  /// No description provided for @supportInputHint.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get supportInputHint;

  /// No description provided for @supportQuickShipping.
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get supportQuickShipping;

  /// No description provided for @supportQuickReturn.
  ///
  /// In en, this message translates to:
  /// **'Return'**
  String get supportQuickReturn;

  /// No description provided for @supportQuickSize.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get supportQuickSize;

  /// No description provided for @supportQuickHuman.
  ///
  /// In en, this message translates to:
  /// **'Live agent'**
  String get supportQuickHuman;

  /// No description provided for @supportGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hi! I\'m Coco, your shopping assistant. How can I help you today?'**
  String get supportGreeting;

  /// No description provided for @supportAutoReplyShipping.
  ///
  /// In en, this message translates to:
  /// **'Standard shipping takes 3–5 business days. You can track your order in My Orders.'**
  String get supportAutoReplyShipping;

  /// No description provided for @supportAutoReplyReturn.
  ///
  /// In en, this message translates to:
  /// **'We accept returns within 7 days of delivery. Tap My Orders to start a return.'**
  String get supportAutoReplyReturn;

  /// No description provided for @supportAutoReplySize.
  ///
  /// In en, this message translates to:
  /// **'Sizes vary by product — check the size chart on the product detail page.'**
  String get supportAutoReplySize;

  /// No description provided for @supportAutoReplyHuman.
  ///
  /// In en, this message translates to:
  /// **'Connecting you to a live agent. Average wait: 1 minute.'**
  String get supportAutoReplyHuman;

  /// No description provided for @supportAutoReplyDefault.
  ///
  /// In en, this message translates to:
  /// **'Thanks for your message — we\'ll get back to you shortly.'**
  String get supportAutoReplyDefault;

  /// No description provided for @profilePoints.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get profilePoints;

  /// No description provided for @profileCoupons.
  ///
  /// In en, this message translates to:
  /// **'Coupons'**
  String get profileCoupons;

  /// No description provided for @profileTopup.
  ///
  /// In en, this message translates to:
  /// **'Top-up'**
  String get profileTopup;

  /// No description provided for @profileMyOrders.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get profileMyOrders;

  /// No description provided for @profileViewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get profileViewAll;

  /// No description provided for @profilePendingPayment.
  ///
  /// In en, this message translates to:
  /// **'Pending Payment'**
  String get profilePendingPayment;

  /// No description provided for @profilePendingShipment.
  ///
  /// In en, this message translates to:
  /// **'Pending Shipment'**
  String get profilePendingShipment;

  /// No description provided for @profilePendingDelivery.
  ///
  /// In en, this message translates to:
  /// **'Pending Delivery'**
  String get profilePendingDelivery;

  /// No description provided for @profileCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get profileCompleted;

  /// No description provided for @profileUnboundMobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile not bound'**
  String get profileUnboundMobile;

  /// No description provided for @menuMyOrders.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get menuMyOrders;

  /// No description provided for @menuFavorites.
  ///
  /// In en, this message translates to:
  /// **'My Favorites'**
  String get menuFavorites;

  /// No description provided for @menuHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get menuHistory;

  /// No description provided for @menuCoupons.
  ///
  /// In en, this message translates to:
  /// **'Coupons'**
  String get menuCoupons;

  /// No description provided for @menuAddress.
  ///
  /// In en, this message translates to:
  /// **'Delivery Address'**
  String get menuAddress;

  /// No description provided for @menuSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get menuSettings;

  /// No description provided for @menuHelp.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get menuHelp;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSectionLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsSectionLanguage;

  /// No description provided for @settingsSectionAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsSectionAbout;

  /// No description provided for @settingsAppVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get settingsAppVersion;

  /// No description provided for @sessionExpiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Session Expired'**
  String get sessionExpiredTitle;

  /// No description provided for @sessionExpiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please log in again.'**
  String get sessionExpiredMessage;

  /// No description provided for @relogin.
  ///
  /// In en, this message translates to:
  /// **'Log In Again'**
  String get relogin;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get confirm;

  /// No description provided for @validationRequired.
  ///
  /// In en, this message translates to:
  /// **'required'**
  String get validationRequired;

  /// No description provided for @labelCountryCode.
  ///
  /// In en, this message translates to:
  /// **'country code'**
  String get labelCountryCode;

  /// No description provided for @labelPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'phone number'**
  String get labelPhoneNumber;

  /// No description provided for @hintPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter phone number'**
  String get hintPhoneNumber;

  /// No description provided for @labelPassword.
  ///
  /// In en, this message translates to:
  /// **'password'**
  String get labelPassword;

  /// No description provided for @hintPassword.
  ///
  /// In en, this message translates to:
  /// **'8-20 alphanumeric characters'**
  String get hintPassword;

  /// No description provided for @forgotPasswordLink.
  ///
  /// In en, this message translates to:
  /// **'forget password'**
  String get forgotPasswordLink;

  /// No description provided for @labelCaptcha.
  ///
  /// In en, this message translates to:
  /// **'Captcha'**
  String get labelCaptcha;

  /// No description provided for @hintCaptcha.
  ///
  /// In en, this message translates to:
  /// **'Enter captcha'**
  String get hintCaptcha;

  /// No description provided for @termsAgreePrefix.
  ///
  /// In en, this message translates to:
  /// **'I agree XSmartlive '**
  String get termsAgreePrefix;

  /// No description provided for @termsLink.
  ///
  /// In en, this message translates to:
  /// **'Terms and condition'**
  String get termsLink;

  /// No description provided for @termsAnd.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get termsAnd;

  /// No description provided for @privacyLink.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyLink;

  /// No description provided for @termsError.
  ///
  /// In en, this message translates to:
  /// **'To protect your rights, please agree to the terms and privacy policy first'**
  String get termsError;

  /// No description provided for @termsDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Notice'**
  String get termsDialogTitle;

  /// No description provided for @termsDialogContent.
  ///
  /// In en, this message translates to:
  /// **'You have not agreed to the Terms of Service. Tapping \"Confirm and Login\" means you have read and agree to the Terms of Service and Privacy Policy.'**
  String get termsDialogContent;

  /// No description provided for @termsDialogConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm and Login'**
  String get termsDialogConfirm;

  /// No description provided for @termsDialogCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get termsDialogCancel;

  /// No description provided for @orLoginWith.
  ///
  /// In en, this message translates to:
  /// **'or login with'**
  String get orLoginWith;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'login'**
  String get loginTitle;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'login with phone number'**
  String get loginButton;

  /// No description provided for @loginFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginFailedTitle;

  /// No description provided for @captchaPending.
  ///
  /// In en, this message translates to:
  /// **'Please complete the captcha first'**
  String get captchaPending;

  /// No description provided for @noAccountText.
  ///
  /// In en, this message translates to:
  /// **'no account, immediately '**
  String get noAccountText;

  /// No description provided for @registerLink.
  ///
  /// In en, this message translates to:
  /// **'register'**
  String get registerLink;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot password'**
  String get forgotPasswordTitle;

  /// No description provided for @stepPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get stepPhone;

  /// No description provided for @stepVerifyOtp.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get stepVerifyOtp;

  /// No description provided for @stepNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get stepNewPassword;

  /// No description provided for @labelCountryCodePhone.
  ///
  /// In en, this message translates to:
  /// **'Country code / Phone'**
  String get labelCountryCodePhone;

  /// No description provided for @validationPhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'please enter phone number'**
  String get validationPhoneRequired;

  /// No description provided for @otpWillSend.
  ///
  /// In en, this message translates to:
  /// **'OTP will be sent to your phone'**
  String get otpWillSend;

  /// No description provided for @otpSentTo.
  ///
  /// In en, this message translates to:
  /// **'OTP sent to'**
  String get otpSentTo;

  /// No description provided for @labelOtp.
  ///
  /// In en, this message translates to:
  /// **'OTP code'**
  String get labelOtp;

  /// No description provided for @hintOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter 6-digit OTP'**
  String get hintOtp;

  /// No description provided for @validationOtpRequired.
  ///
  /// In en, this message translates to:
  /// **'please enter OTP'**
  String get validationOtpRequired;

  /// No description provided for @resendOtp.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resendOtp;

  /// No description provided for @resendOtpCountdown.
  ///
  /// In en, this message translates to:
  /// **'Resend ({seconds} s)'**
  String resendOtpCountdown(int seconds);

  /// No description provided for @labelNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get labelNewPassword;

  /// No description provided for @hintNewPassword.
  ///
  /// In en, this message translates to:
  /// **'8-20 alphanumeric characters'**
  String get hintNewPassword;

  /// No description provided for @validationNewPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'please enter new password'**
  String get validationNewPasswordRequired;

  /// No description provided for @validationPasswordMinLength.
  ///
  /// In en, this message translates to:
  /// **'minimum 8 characters'**
  String get validationPasswordMinLength;

  /// No description provided for @labelConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get labelConfirmPassword;

  /// No description provided for @hintConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Please re-enter password'**
  String get hintConfirmPassword;

  /// No description provided for @validationConfirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'please confirm password'**
  String get validationConfirmPasswordRequired;

  /// No description provided for @validationPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'passwords do not match'**
  String get validationPasswordMismatch;

  /// No description provided for @sendOtpButton.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOtpButton;

  /// No description provided for @verifyButton.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verifyButton;

  /// No description provided for @resetPasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPasswordButton;

  /// No description provided for @passwordResetSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Password reset'**
  String get passwordResetSuccessTitle;

  /// No description provided for @passwordResetSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Please log in with your new password.'**
  String get passwordResetSuccessMessage;

  /// No description provided for @goToLogin.
  ///
  /// In en, this message translates to:
  /// **'Go to login'**
  String get goToLogin;

  /// No description provided for @forgotPasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter the phone number you used to register. We\'ll send you a verification code.'**
  String get forgotPasswordDescription;

  /// No description provided for @otpVerifyTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your identity'**
  String get otpVerifyTitle;

  /// No description provided for @otpVerifyDescription.
  ///
  /// In en, this message translates to:
  /// **'Verification code sent to {mobile}'**
  String otpVerifyDescription(String mobile);

  /// No description provided for @newPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Set a new password'**
  String get newPasswordTitle;

  /// No description provided for @newPasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'For your account security, please set a strong password with letters and numbers.'**
  String get newPasswordDescription;

  /// No description provided for @resetSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Password reset successful!'**
  String get resetSuccessTitle;

  /// No description provided for @resetSuccessDescription.
  ///
  /// In en, this message translates to:
  /// **'Your password has been updated. You can now log in with your new password.'**
  String get resetSuccessDescription;

  /// No description provided for @otpResendPrompt.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the code?'**
  String get otpResendPrompt;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Register account'**
  String get registerTitle;

  /// No description provided for @labelName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get labelName;

  /// No description provided for @hintName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get hintName;

  /// No description provided for @labelVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get labelVerificationCode;

  /// No description provided for @hintVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter 6-digit verification code'**
  String get hintVerificationCode;

  /// No description provided for @labelSetPassword.
  ///
  /// In en, this message translates to:
  /// **'Set password'**
  String get labelSetPassword;

  /// No description provided for @hintSetPassword.
  ///
  /// In en, this message translates to:
  /// **'8-20 chars, A-Z / a-z / special symbol'**
  String get hintSetPassword;

  /// No description provided for @validationPasswordLength.
  ///
  /// In en, this message translates to:
  /// **'8-20 characters required'**
  String get validationPasswordLength;

  /// No description provided for @validationPasswordUppercase.
  ///
  /// In en, this message translates to:
  /// **'must contain at least 1 uppercase letter'**
  String get validationPasswordUppercase;

  /// No description provided for @validationPasswordLowercase.
  ///
  /// In en, this message translates to:
  /// **'must contain at least 1 lowercase letter'**
  String get validationPasswordLowercase;

  /// No description provided for @validationPasswordSpecial.
  ///
  /// In en, this message translates to:
  /// **'must contain at least 1 special character'**
  String get validationPasswordSpecial;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Complete registration and log in'**
  String get registerButton;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @loginNow.
  ///
  /// In en, this message translates to:
  /// **'Log in now'**
  String get loginNow;

  /// No description provided for @registrationFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Registration failed'**
  String get registrationFailedTitle;

  /// No description provided for @validationPhoneFirst.
  ///
  /// In en, this message translates to:
  /// **'please enter phone number first'**
  String get validationPhoneFirst;

  /// No description provided for @registrationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Registration successful. Please log in.'**
  String get registrationSuccess;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get sendCode;

  /// No description provided for @registerNeedHelp.
  ///
  /// In en, this message translates to:
  /// **'Need help?'**
  String get registerNeedHelp;

  /// No description provided for @liveTabCurrent.
  ///
  /// In en, this message translates to:
  /// **'Live Now'**
  String get liveTabCurrent;

  /// No description provided for @liveTabHistory.
  ///
  /// In en, this message translates to:
  /// **'Past Lives'**
  String get liveTabHistory;

  /// No description provided for @liveLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load: {error}'**
  String liveLoadError(String error);

  /// No description provided for @liveNoStream.
  ///
  /// In en, this message translates to:
  /// **'No live stream at the moment'**
  String get liveNoStream;

  /// No description provided for @liveStreamer.
  ///
  /// In en, this message translates to:
  /// **'Streamer {name}'**
  String liveStreamer(String name);

  /// No description provided for @liveCommentHeader.
  ///
  /// In en, this message translates to:
  /// **'Live Comments'**
  String get liveCommentHeader;

  /// No description provided for @liveCommentHint.
  ///
  /// In en, this message translates to:
  /// **'Type a comment...'**
  String get liveCommentHint;

  /// No description provided for @liveNoHistory.
  ///
  /// In en, this message translates to:
  /// **'No past live streams'**
  String get liveNoHistory;

  /// No description provided for @liveOrientLandscapeTitle.
  ///
  /// In en, this message translates to:
  /// **'Switch to Landscape?'**
  String get liveOrientLandscapeTitle;

  /// No description provided for @liveOrientPortraitTitle.
  ///
  /// In en, this message translates to:
  /// **'Switch to Portrait?'**
  String get liveOrientPortraitTitle;

  /// No description provided for @liveOrientLandscapeMessage.
  ///
  /// In en, this message translates to:
  /// **'Device rotated to landscape.\nSwitch to landscape view?'**
  String get liveOrientLandscapeMessage;

  /// No description provided for @liveOrientPortraitMessage.
  ///
  /// In en, this message translates to:
  /// **'Device rotated to portrait.\nSwitch back to portrait?'**
  String get liveOrientPortraitMessage;

  /// No description provided for @liveOrientConfirmLandscape.
  ///
  /// In en, this message translates to:
  /// **'Go Landscape'**
  String get liveOrientConfirmLandscape;

  /// No description provided for @liveOrientConfirmPortrait.
  ///
  /// In en, this message translates to:
  /// **'Go Portrait'**
  String get liveOrientConfirmPortrait;

  /// No description provided for @liveOrientCancelPortrait.
  ///
  /// In en, this message translates to:
  /// **'Stay Portrait'**
  String get liveOrientCancelPortrait;

  /// No description provided for @liveOrientCancelLandscape.
  ///
  /// In en, this message translates to:
  /// **'Stay Landscape'**
  String get liveOrientCancelLandscape;

  /// No description provided for @liveCommentHintFS.
  ///
  /// In en, this message translates to:
  /// **'Say something...'**
  String get liveCommentHintFS;

  /// No description provided for @ordersTitle.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get ordersTitle;

  /// No description provided for @orderFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get orderFilterAll;

  /// No description provided for @orderFilterPending.
  ///
  /// In en, this message translates to:
  /// **'Pending Payment'**
  String get orderFilterPending;

  /// No description provided for @orderFilterPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get orderFilterPaid;

  /// No description provided for @orderFilterShipped.
  ///
  /// In en, this message translates to:
  /// **'Shipped'**
  String get orderFilterShipped;

  /// No description provided for @orderFilterCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get orderFilterCompleted;

  /// No description provided for @orderNumber.
  ///
  /// In en, this message translates to:
  /// **'Order #{id}'**
  String orderNumber(String id);

  /// No description provided for @orderCreatedAt.
  ///
  /// In en, this message translates to:
  /// **'Created: {date}'**
  String orderCreatedAt(String date);

  /// No description provided for @orderSubtotalShipping.
  ///
  /// In en, this message translates to:
  /// **'Subtotal: \${subtotal}  Shipping: \${fee}'**
  String orderSubtotalShipping(String subtotal, String fee);

  /// No description provided for @orderTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get orderTotal;

  /// No description provided for @orderEmpty.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get orderEmpty;

  /// No description provided for @orderLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load orders'**
  String get orderLoadFailed;

  /// No description provided for @orderRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get orderRefresh;

  /// No description provided for @ordersFilterHintAll.
  ///
  /// In en, this message translates to:
  /// **'All orders'**
  String get ordersFilterHintAll;

  /// No description provided for @ordersDateRangeSummary.
  ///
  /// In en, this message translates to:
  /// **'Showing results from {start} to {end}'**
  String ordersDateRangeSummary(String start, String end);

  /// No description provided for @ordersFieldDate.
  ///
  /// In en, this message translates to:
  /// **'Order date'**
  String get ordersFieldDate;

  /// No description provided for @ordersFieldNumber.
  ///
  /// In en, this message translates to:
  /// **'Order no.'**
  String get ordersFieldNumber;

  /// No description provided for @ordersFieldItemCount.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get ordersFieldItemCount;

  /// No description provided for @ordersFieldTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get ordersFieldTotal;

  /// No description provided for @ordersFieldPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get ordersFieldPayment;

  /// No description provided for @ordersFieldShipping.
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get ordersFieldShipping;

  /// No description provided for @ordersFieldInvoice.
  ///
  /// In en, this message translates to:
  /// **'Invoice'**
  String get ordersFieldInvoice;

  /// No description provided for @ordersFieldStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get ordersFieldStatus;

  /// No description provided for @ordersFieldMissing.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get ordersFieldMissing;

  /// No description provided for @ordersDetailToggle.
  ///
  /// In en, this message translates to:
  /// **'Shipping progress / items'**
  String get ordersDetailToggle;

  /// No description provided for @ordersPendingPackage.
  ///
  /// In en, this message translates to:
  /// **'Pending package'**
  String get ordersPendingPackage;

  /// No description provided for @ordersPackagePieces.
  ///
  /// In en, this message translates to:
  /// **'{count} pcs'**
  String ordersPackagePieces(int count);

  /// No description provided for @ordersItemSpec.
  ///
  /// In en, this message translates to:
  /// **'Spec: {spec}'**
  String ordersItemSpec(String spec);

  /// No description provided for @ordersItemQtySuffix.
  ///
  /// In en, this message translates to:
  /// **'/ {count} pcs'**
  String ordersItemQtySuffix(int count);

  /// No description provided for @ordersTimelinePending.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get ordersTimelinePending;

  /// No description provided for @ordersTimelineToShip.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get ordersTimelineToShip;

  /// No description provided for @ordersTimelineShipped.
  ///
  /// In en, this message translates to:
  /// **'Shipped'**
  String get ordersTimelineShipped;

  /// No description provided for @ordersTimelineDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get ordersTimelineDelivered;

  /// No description provided for @ordersTimelineCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get ordersTimelineCompleted;

  /// No description provided for @ordersDetailLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load order details'**
  String get ordersDetailLoadFailed;

  /// No description provided for @ordersSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search orders'**
  String get ordersSearchTitle;

  /// No description provided for @ordersSearchDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Order date'**
  String get ordersSearchDateLabel;

  /// No description provided for @ordersSearchDatePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'YYYY/MM/DD - YYYY/MM/DD'**
  String get ordersSearchDatePlaceholder;

  /// No description provided for @ordersSearchDateHelper.
  ///
  /// In en, this message translates to:
  /// **'Pick a date range of up to 6 months, within the last 2 years.'**
  String get ordersSearchDateHelper;

  /// No description provided for @ordersSearchKeywordPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter order ID or product name'**
  String get ordersSearchKeywordPlaceholder;

  /// No description provided for @ordersSearchSubmit.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get ordersSearchSubmit;

  /// No description provided for @ordersSearchReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get ordersSearchReset;

  /// No description provided for @ordersSearchErrorRangeTooLong.
  ///
  /// In en, this message translates to:
  /// **'Range cannot exceed 6 months'**
  String get ordersSearchErrorRangeTooLong;

  /// No description provided for @ordersSearchErrorOutOfWindow.
  ///
  /// In en, this message translates to:
  /// **'Only orders within the last 2 years are searchable'**
  String get ordersSearchErrorOutOfWindow;

  /// No description provided for @ordersInfoPanelTitle.
  ///
  /// In en, this message translates to:
  /// **'Purchase rights & after-sales info'**
  String get ordersInfoPanelTitle;

  /// No description provided for @ordersInfoRightsItem1.
  ///
  /// In en, this message translates to:
  /// **'Every product is covered by a 10-day cooling-off period (note: this is NOT a trial period). Returning or exchanging goods that are not in brand-new condition or without complete packaging will affect your rights and may incur restoration fees.\n*Under the Consumer Protection Act, 5 categories are excluded from the 10-day window — see the Return Notice for details.'**
  String get ordersInfoRightsItem1;

  /// No description provided for @ordersInfoRightsItem2.
  ///
  /// In en, this message translates to:
  /// **'Some items are excluded from the 10-day cooling-off rule — e.g. perishable goods (freshly prepared meals, fruits, vegetables, cakes, milk) that spoil quickly or may expire during the process. Please understand before purchasing.'**
  String get ordersInfoRightsItem2;

  /// No description provided for @ordersInfoRightsItem3.
  ///
  /// In en, this message translates to:
  /// **'Downloadable serial keys, jewellery, gold, and appliances requiring installation are not eligible for online return/exchange. 3C products cannot be exchanged. Other items are limited to one exchange per order.'**
  String get ordersInfoRightsItem3;

  /// No description provided for @ordersInfoRightsItem4.
  ///
  /// In en, this message translates to:
  /// **'If you cannot operate online, please use Contact Support and a representative will assist you.'**
  String get ordersInfoRightsItem4;

  /// No description provided for @ordersInfoRightsItem5.
  ///
  /// In en, this message translates to:
  /// **'From the day after delivery, you have 20 days to review the product. Eligible reviews earn bonus points.\n*Gifts, add-ons, vehicle test drives, e-vouchers, bonus credit, software keys, and travel products are not eligible for review.'**
  String get ordersInfoRightsItem5;

  /// No description provided for @ordersInfoReturnTitle.
  ///
  /// In en, this message translates to:
  /// **'Return / exchange policy:'**
  String get ordersInfoReturnTitle;

  /// No description provided for @ordersInfoReturnRule1.
  ///
  /// In en, this message translates to:
  /// **'Group-promotion items (e.g. mix-and-match, bulk, minimum-spend bundles) are treated as a single product; they must be cancelled or returned together with the rest of the order.'**
  String get ordersInfoReturnRule1;

  /// No description provided for @ordersInfoReturnRule2Prefix.
  ///
  /// In en, this message translates to:
  /// **'Only items with shipment status '**
  String get ordersInfoReturnRule2Prefix;

  /// No description provided for @ordersInfoReturnRule2Suffix.
  ///
  /// In en, this message translates to:
  /// **' and matching product codes are eligible for exchange.'**
  String get ordersInfoReturnRule2Suffix;

  /// No description provided for @couponTitle.
  ///
  /// In en, this message translates to:
  /// **'My Coupons'**
  String get couponTitle;

  /// No description provided for @couponTabAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get couponTabAll;

  /// No description provided for @couponTabUnused.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get couponTabUnused;

  /// No description provided for @couponTabUsed.
  ///
  /// In en, this message translates to:
  /// **'Used'**
  String get couponTabUsed;

  /// No description provided for @couponTabExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get couponTabExpired;

  /// No description provided for @couponLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load'**
  String get couponLoadFailed;

  /// No description provided for @couponRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get couponRetry;

  /// No description provided for @couponEmptyAll.
  ///
  /// In en, this message translates to:
  /// **'No coupons available'**
  String get couponEmptyAll;

  /// No description provided for @couponEmptyUnused.
  ///
  /// In en, this message translates to:
  /// **'No available coupons'**
  String get couponEmptyUnused;

  /// No description provided for @couponEmptyUsed.
  ///
  /// In en, this message translates to:
  /// **'No used coupons'**
  String get couponEmptyUsed;

  /// No description provided for @couponEmptyExpired.
  ///
  /// In en, this message translates to:
  /// **'No expired coupons'**
  String get couponEmptyExpired;

  /// No description provided for @couponDiscount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get couponDiscount;

  /// No description provided for @couponExpiry.
  ///
  /// In en, this message translates to:
  /// **'Valid until {date}'**
  String couponExpiry(String date);

  /// No description provided for @couponUsedAt.
  ///
  /// In en, this message translates to:
  /// **'Used on: {date}'**
  String couponUsedAt(String date);

  /// No description provided for @couponUsedStamp.
  ///
  /// In en, this message translates to:
  /// **'USED'**
  String get couponUsedStamp;

  /// No description provided for @couponUseNow.
  ///
  /// In en, this message translates to:
  /// **'Use Now'**
  String get couponUseNow;

  /// No description provided for @couponClaimMore.
  ///
  /// In en, this message translates to:
  /// **'Claim More'**
  String get couponClaimMore;

  /// No description provided for @couponValidUntil.
  ///
  /// In en, this message translates to:
  /// **'Valid until {date}'**
  String couponValidUntil(String date);

  /// No description provided for @couponQuotaLeft.
  ///
  /// In en, this message translates to:
  /// **'{count} left'**
  String couponQuotaLeft(int count);

  /// No description provided for @couponClaimed.
  ///
  /// In en, this message translates to:
  /// **'Claimed'**
  String get couponClaimed;

  /// No description provided for @couponClaim.
  ///
  /// In en, this message translates to:
  /// **'Claim'**
  String get couponClaim;

  /// No description provided for @couponClaimFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to claim. Please try again.'**
  String get couponClaimFailed;

  /// No description provided for @couponUsableTitle.
  ///
  /// In en, this message translates to:
  /// **'Available Coupons'**
  String get couponUsableTitle;

  /// No description provided for @couponEmptyUsable.
  ///
  /// In en, this message translates to:
  /// **'No available coupons'**
  String get couponEmptyUsable;

  /// No description provided for @productQuantity.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get productQuantity;

  /// No description provided for @productStockLeft.
  ///
  /// In en, this message translates to:
  /// **'{count} left'**
  String productStockLeft(int count);

  /// No description provided for @shopLoadCategoryError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load categories: {error}'**
  String shopLoadCategoryError(String error);

  /// No description provided for @shopCategoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get shopCategoryAll;

  /// No description provided for @shopSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search products...'**
  String get shopSearchHint;

  /// No description provided for @shopSearchError.
  ///
  /// In en, this message translates to:
  /// **'Search failed: {error}'**
  String shopSearchError(String error);

  /// No description provided for @shopSearchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results for \"{query}\"'**
  String shopSearchNoResults(String query);

  /// No description provided for @shopLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load: {error}'**
  String shopLoadError(String error);

  /// No description provided for @shopNoProducts.
  ///
  /// In en, this message translates to:
  /// **'No products available'**
  String get shopNoProducts;

  /// No description provided for @shopLiveAnnouncementTitle.
  ///
  /// In en, this message translates to:
  /// **'Live Announcement'**
  String get shopLiveAnnouncementTitle;

  /// No description provided for @shopLiveAnnouncementHeadline.
  ///
  /// In en, this message translates to:
  /// **'✨ This week\'s live schedule'**
  String get shopLiveAnnouncementHeadline;

  /// No description provided for @shopLiveAnnouncementFallback.
  ///
  /// In en, this message translates to:
  /// **'Autumn–winter kids\' apparel marathon is here 😎\n\nWed 10:00 AM ✨ Special show ✨\n 🍂 Supplier warehouse overstock sale 🤎\n\nThu 2:00 PM ✨ Special show ✨\n🍂 Supplier warehouse overstock sale 🤎\n\nThu 7:00 PM ✨ Special show ✨\n\nFri 2:00 PM\nStudio accessories clearance — grab the deals ⚡️🤩'**
  String get shopLiveAnnouncementFallback;

  /// No description provided for @shopCategoryExpand.
  ///
  /// In en, this message translates to:
  /// **'Expand categories'**
  String get shopCategoryExpand;

  /// No description provided for @shopCategoryCollapse.
  ///
  /// In en, this message translates to:
  /// **'Collapse categories'**
  String get shopCategoryCollapse;

  /// No description provided for @shopCategoryViewMore.
  ///
  /// In en, this message translates to:
  /// **'View more'**
  String get shopCategoryViewMore;

  /// No description provided for @cartLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load cart'**
  String get cartLoadFailed;

  /// No description provided for @cartRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get cartRetry;

  /// No description provided for @cartTitle.
  ///
  /// In en, this message translates to:
  /// **'Cart ({count})'**
  String cartTitle(int count);

  /// No description provided for @cartProductFallback.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get cartProductFallback;

  /// No description provided for @cartItemPrice.
  ///
  /// In en, this message translates to:
  /// **'NTD \${price}'**
  String cartItemPrice(String price);

  /// No description provided for @cartSubtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get cartSubtotal;

  /// No description provided for @cartDiscount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get cartDiscount;

  /// No description provided for @cartTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get cartTotal;

  /// No description provided for @cartCheckout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get cartCheckout;

  /// No description provided for @cartEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get cartEmpty;

  /// No description provided for @searchScreenHint.
  ///
  /// In en, this message translates to:
  /// **'Search products, streamers...'**
  String get searchScreenHint;

  /// No description provided for @searchHotTitle.
  ///
  /// In en, this message translates to:
  /// **'Trending Searches'**
  String get searchHotTitle;

  /// No description provided for @searchHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Search History'**
  String get searchHistoryTitle;

  /// No description provided for @searchHistoryClear.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get searchHistoryClear;

  /// No description provided for @checkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Order'**
  String get checkoutTitle;

  /// No description provided for @checkoutOrderSuccess.
  ///
  /// In en, this message translates to:
  /// **'Order placed successfully!'**
  String get checkoutOrderSuccess;

  /// No description provided for @checkoutOrderFailed.
  ///
  /// In en, this message translates to:
  /// **'Order failed: {error}'**
  String checkoutOrderFailed(String error);

  /// No description provided for @checkoutCartEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get checkoutCartEmpty;

  /// No description provided for @checkoutRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get checkoutRetry;

  /// No description provided for @checkoutSectionItems.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get checkoutSectionItems;

  /// No description provided for @checkoutItemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} item(s)'**
  String checkoutItemsCount(int count);

  /// No description provided for @checkoutSectionShipping.
  ///
  /// In en, this message translates to:
  /// **'Shipping Method'**
  String get checkoutSectionShipping;

  /// No description provided for @checkoutSectionPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get checkoutSectionPayment;

  /// No description provided for @checkoutSectionPrice.
  ///
  /// In en, this message translates to:
  /// **'Price Details'**
  String get checkoutSectionPrice;

  /// No description provided for @checkoutShippingNormal.
  ///
  /// In en, this message translates to:
  /// **'Standard Shipping'**
  String get checkoutShippingNormal;

  /// No description provided for @checkoutShippingNormalDesc.
  ///
  /// In en, this message translates to:
  /// **'3–5 business days'**
  String get checkoutShippingNormalDesc;

  /// No description provided for @checkoutShippingCold.
  ///
  /// In en, this message translates to:
  /// **'Cold-Chain Shipping'**
  String get checkoutShippingCold;

  /// No description provided for @checkoutShippingColdDesc.
  ///
  /// In en, this message translates to:
  /// **'Temperature-controlled delivery'**
  String get checkoutShippingColdDesc;

  /// No description provided for @checkoutPaymentCard.
  ///
  /// In en, this message translates to:
  /// **'Credit Card'**
  String get checkoutPaymentCard;

  /// No description provided for @checkoutPaymentCardDesc.
  ///
  /// In en, this message translates to:
  /// **'Visa / Mastercard / JCB'**
  String get checkoutPaymentCardDesc;

  /// No description provided for @checkoutPaymentBank.
  ///
  /// In en, this message translates to:
  /// **'Bank Transfer'**
  String get checkoutPaymentBank;

  /// No description provided for @checkoutPaymentBankDesc.
  ///
  /// In en, this message translates to:
  /// **'ATM transfer'**
  String get checkoutPaymentBankDesc;

  /// No description provided for @checkoutPaymentCod.
  ///
  /// In en, this message translates to:
  /// **'Cash on Delivery'**
  String get checkoutPaymentCod;

  /// No description provided for @checkoutPaymentCodDesc.
  ///
  /// In en, this message translates to:
  /// **'Pay in cash on delivery'**
  String get checkoutPaymentCodDesc;

  /// No description provided for @checkoutPriceSubtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get checkoutPriceSubtotal;

  /// No description provided for @checkoutPriceDiscount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get checkoutPriceDiscount;

  /// No description provided for @checkoutPriceShipping.
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get checkoutPriceShipping;

  /// No description provided for @checkoutPriceFreeShipping.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get checkoutPriceFreeShipping;

  /// No description provided for @checkoutPriceTotal.
  ///
  /// In en, this message translates to:
  /// **'Order Total'**
  String get checkoutPriceTotal;

  /// No description provided for @checkoutAmountDue.
  ///
  /// In en, this message translates to:
  /// **'Amount Due'**
  String get checkoutAmountDue;

  /// No description provided for @checkoutConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Place Order'**
  String get checkoutConfirmButton;

  /// No description provided for @productBundleTitle.
  ///
  /// In en, this message translates to:
  /// **'Bundle Contents'**
  String get productBundleTitle;

  /// No description provided for @productSpec.
  ///
  /// In en, this message translates to:
  /// **'Spec'**
  String get productSpec;

  /// No description provided for @menuTheme.
  ///
  /// In en, this message translates to:
  /// **'App Theme'**
  String get menuTheme;

  /// No description provided for @themePickerTitle.
  ///
  /// In en, this message translates to:
  /// **'App Theme'**
  String get themePickerTitle;

  /// No description provided for @themePickerDescription.
  ///
  /// In en, this message translates to:
  /// **'Pick a visual style for the entire app. Switch any time.'**
  String get themePickerDescription;

  /// No description provided for @themePickerSectionPresets.
  ///
  /// In en, this message translates to:
  /// **'Presets'**
  String get themePickerSectionPresets;

  /// No description provided for @themePickerSectionDefault.
  ///
  /// In en, this message translates to:
  /// **'Use merchant default'**
  String get themePickerSectionDefault;

  /// No description provided for @themePickerOptionMerchant.
  ///
  /// In en, this message translates to:
  /// **'Merchant default'**
  String get themePickerOptionMerchant;

  /// No description provided for @themePickerOptionMerchantDesc.
  ///
  /// In en, this message translates to:
  /// **'Use the theme provided by the merchant.'**
  String get themePickerOptionMerchantDesc;

  /// No description provided for @themeWarm.
  ///
  /// In en, this message translates to:
  /// **'Warm'**
  String get themeWarm;

  /// No description provided for @themeMinimal.
  ///
  /// In en, this message translates to:
  /// **'Minimal'**
  String get themeMinimal;

  /// No description provided for @themeVibrant.
  ///
  /// In en, this message translates to:
  /// **'Vibrant'**
  String get themeVibrant;

  /// No description provided for @themeEcom.
  ///
  /// In en, this message translates to:
  /// **'Commerce'**
  String get themeEcom;

  /// No description provided for @themeNight.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get themeNight;

  /// No description provided for @themeDiva.
  ///
  /// In en, this message translates to:
  /// **'Diva Boss'**
  String get themeDiva;

  /// No description provided for @themeCurrentlyApplied.
  ///
  /// In en, this message translates to:
  /// **'Currently applied'**
  String get themeCurrentlyApplied;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'en',
    'ja',
    'ko',
    'ms',
    'th',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.countryCode) {
          case 'CN':
            return AppLocalizationsZhCn();
          case 'TW':
            return AppLocalizationsZhTw();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'ms':
      return AppLocalizationsMs();
    case 'th':
      return AppLocalizationsTh();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
