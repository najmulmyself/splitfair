/// All user-visible strings. Never hardcode UI text in widgets.
/// Always use AppStrings.X
abstract class AppStrings {
  // ── App ─────────────────────────────────────────────────────
  static const appName = 'DivvyBill';
  static const appTagline = 'Split Bills Free. No Signup.';

  // ── Onboarding ──────────────────────────────────────────────
  static const onboardingSkip = 'Skip';
  static const onboardingGetStarted = 'Start Splitting';
  static const onboardingPage1Title = 'Split Any Bill Instantly';
  static const onboardingPage1Body =
      'Enter the total, add people, and get everyone\'s share in seconds. No account needed.';
  static const onboardingPage2Title = 'Tip the Way You Want';
  static const onboardingPage2Body =
      'Tip on subtotal or total. Custom percentages. Never argue about the tip again.';
  static const onboardingPage3Title = 'Share & Settle Up';
  static const onboardingPage3Body =
      'Send payment links via Venmo, Cash App, or PayPal. Or just share a screenshot.';

  // ── Calculator ──────────────────────────────────────────────
  static const calculatorTitle = 'DivvyBill';
  static const subtotalLabel = 'Subtotal';
  static const taxLabel = 'Tax';
  static const tipLabel = 'Tip';
  static const totalLabel = 'Total';
  static const perPersonLabel = 'per person';
  static const addPersonLabel = 'Add Person';
  static const enterNameHint = 'Enter name';
  static const nameTooLongError = 'Name must be 20 characters or less';
  static const minOnePerson = 'At least one person is required';
  static const maxPeopleReached = 'Maximum 20 people reached';
  static const deletePerson = 'Remove';
  static const confirmDeletePerson = 'Remove this person?';
  static const confirmDeletePersonBody =
      'Their share will be redistributed to the remaining people.';

  // ── Tip selector ────────────────────────────────────────────
  static const tipOnSubtotal = 'On subtotal';
  static const tipOnTotal = 'On total';
  static const customTipLabel = 'Custom';
  static const tipDifferenceHint = 'Difference: ';
  static const serviceChargeLabel = 'Service Charge';
  static const coverChargeLabel = 'Cover Charge';
  static const customFeeLabel = 'Custom Fee';

  // ── Split modes ─────────────────────────────────────────────
  static const splitModeEqual = 'Equal';
  static const splitModeCustom = 'Custom';
  static const splitModePercentage = 'Percentage';
  static const splitModeItemized = 'Itemized';
  static const customAmountsUnbalanced =
      'Amounts don\'t add up to the subtotal';
  static const percentagesOver100 = 'Percentages exceed 100%';
  static const percentagesUnder100 = 'Percentages don\'t add up to 100%';

  // ── Birthday free diner ─────────────────────────────────────
  static const birthdayFreeToggle = 'Birthday person eats free 🎂';
  static const birthdayFreeBadge = '🎂 Free!';
  static const birthdayFreeSelectPerson = 'Select the birthday person';

  // ── Rounding ────────────────────────────────────────────────
  static const roundingNone = 'Exact';
  static const roundingUp50c = 'Round up 50¢';
  static const roundingUp1 = 'Round up \$1';

  // ── Result zone ─────────────────────────────────────────────
  static const highestBadge = 'Most';
  static const lowestBadge = 'Least';
  static const subtotalBreakdown = 'Subtotal';
  static const taxBreakdown = 'Tax';
  static const tipBreakdown = 'Tip';

  // ── Share sheet ─────────────────────────────────────────────
  static const shareTitle = 'Share Results';
  static const shareWhatsApp = 'WhatsApp';
  static const shareMessage = 'Message';
  static const shareCopyText = 'Copy Text';
  static const shareSaveImage = 'Save Image';
  static const payVenmo = 'Venmo';
  static const payCashApp = 'Cash App';
  static const payPayPal = 'PayPal';
  static const payBkash = 'bKash';
  static const payNagad = 'Nagad';
  static const bkashNumberPromptTitle = 'Enter bKash Number';
  static const nagadNumberPromptTitle = 'Enter Nagad Number';
  static const mobileNumberHint = '01XXXXXXXXX';
  static const shareFooter = 'Sent via DivvyBill';
  static const shareLabel = 'Split';
  static const imageSavedSuccess = 'Image saved to Photos';
  static const textCopiedSuccess = 'Copied to clipboard';

  // ── Currency selector ────────────────────────────────────────
  static const currencyTitle = 'Select Currency';
  static const currencySearchHint = 'Search by name or code';
  static const recentCurrenciesTitle = 'Recent';
  static const allCurrenciesTitle = 'All Currencies';

  // ── Settings ─────────────────────────────────────────────────
  static const settingsTitle = 'Settings';
  static const settingsDefaultTip = 'Default Tip';
  static const settingsDefaultCurrency = 'Default Currency';
  static const settingsTipCalculation = 'Tip Calculation';
  static const settingsRememberNames = 'Remember Recent Names';
  static const settingsClearNames = 'Clear Recent Names';
  static const settingsClearNamesConfirm = 'Clear all saved names?';
  static const settingsTheme = 'Theme';
  static const settingsThemeDark = 'Dark';
  static const settingsThemeLight = 'Light';
  static const settingsThemeSystem = 'System';
  static const settingsRateApp = 'Rate DivvyBill';
  static const settingsShareApp = 'Share DivvyBill';
  static const settingsPrivacyPolicy = 'Privacy Policy';
  static const settingsBuyACoffee = 'Buy us a coffee ☕';
  static const settingsBuyACoffeePrice = '\$0.99';
  static const settingsVersion = 'Version';
  static const settingsProBadge = 'PRO';

  // ── History ─────────────────────────────────────────────────
  static const historyTitle = 'History';
  static const historyEmpty = 'No splits yet';
  static const historyEmptyBody = 'Your past splits will appear here.';
  static const historyDeleteConfirm = 'Delete this split?';
  static const historyClear = 'Clear History';
  static const historyClearConfirm = 'Clear all split history?';
  static const historyDuplicate = 'Duplicate';
  static const historyProRequired = 'History requires DivvyBill Pro';

  // ── Receipt scanner ──────────────────────────────────────────
  static const scannerTitle = 'Scan Receipt';
  static const scannerCamera = 'Take Photo';
  static const scannerGallery = 'Choose from Library';
  static const scannerProcessing = 'Reading receipt…';
  static const scannerNoItemsFound = 'No items found';
  static const scannerProRequired = 'Receipt Scanner requires DivvyBill Pro';

  // ── Pro unlock ──────────────────────────────────────────────
  static const proTitle = 'DivvyBill Pro';
  static const proSubtitle = 'Unlock everything. One time.';
  static const proPriceLabel = '\$2.99';
  static const proFeature1 = 'Split history — last 20 sessions';
  static const proFeature2 = 'Receipt scanner with auto item detection';
  static const proFeature3 = 'History export';
  static const proFeature4 = 'No ads, ever';
  static const proBuyButton = 'Unlock Pro — \$2.99';
  static const proRestoreButton = 'Restore Purchase';
  static const proAlreadyOwned = 'You already own DivvyBill Pro';
  static const proRestoreSuccess = 'Purchase restored';
  static const proRestoreFailed = 'No purchase found to restore';
  static const proPurchaseFailed = 'Purchase failed. Please try again.';
  static const proPurchaseSuccess = 'Welcome to DivvyBill Pro!';

  // ── Errors / validation ─────────────────────────────────────
  static const invalidAmount = 'Please enter a valid amount';
  static const amountTooLarge = 'Amount cannot exceed \$999,999.99';
  static const invalidTipPercentage = 'Tip must be between 0% and 100%';
  static const enterSubtotalFirst = 'Enter subtotal first';
  static const shareResultsButton = 'Share Results';

  // ── Common ──────────────────────────────────────────────────
  static const cancel = 'Cancel';
  static const confirm = 'Confirm';
  static const done = 'Done';
  static const save = 'Save';
  static const delete = 'Delete';
  static const clear = 'Clear';
  static const reset = 'Reset';
  static const add = 'Add';
  static const edit = 'Edit';
  static const ok = 'OK';
}
