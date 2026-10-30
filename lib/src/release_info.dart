/// Details shown on the About & credits screen and used by the store links.
///
/// Every `TODO(owner)` must be filled in before a store release; see
/// docs/RELEASE_CHECKLIST.md, section 1. Until then the About screen shows
/// "to be added" for empty values, and `test/release_info_test.dart` lists
/// what is still missing.
library;

/// Must match `version:` in pubspec.yaml (a test checks this).
const appVersion = '1.0.0';

/// Android application ID; also used for the Google Play link.
const androidAppId = 'io.github.khiruashish.gita_for_everyone';

/// TODO(owner): copyright holder, e.g. "© 2026 Your Name" (checklist 1.1).
const copyrightHolder = '';

/// TODO(owner): licence for the code, e.g. "MIT" (checklist 1.2).
const codeLicence = '';

/// TODO(owner): licence for the translations and other original text,
/// e.g. "CC BY-SA 4.0" (checklist 1.3).
const contentLicence = '';

/// TODO(owner): scholar reviewer(s) as they wish to be credited, with their
/// written permission (checklist 1.4).
const reviewers = <String>[];

/// TODO(owner): other contributors, e.g. "Icon: Name" (checklist 1.5).
const contributors = <String>[];

/// TODO(owner): public contact email for support (checklist 1.6).
const contactEmail = '';

/// TODO(owner): numeric App Store ID, known after creating the app in App Store
/// Connect. While empty, "Rate this app" is hidden on iPhone and iPad.
const appStoreId = '';

const sourceCodeUrl = 'https://github.com/khiruashish/bhagavad-gita-app';

/// Values that still need the owner's input, for the release checklist test.
List<String> get missingReleaseInfo => [
  if (copyrightHolder.isEmpty) 'copyrightHolder',
  if (codeLicence.isEmpty) 'codeLicence',
  if (contentLicence.isEmpty) 'contentLicence',
  if (reviewers.isEmpty) 'reviewers',
  if (contactEmail.isEmpty) 'contactEmail',
  if (appStoreId.isEmpty) 'appStoreId',
];
