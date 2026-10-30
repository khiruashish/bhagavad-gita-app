import '../settings/settings_controller.dart';

/// All interface text, in English and Hindi. Verse content is not here; it comes
/// from the content file.
class Strings {
  const Strings._(this.lang);

  final AppLanguage lang;

  static const english = Strings._(AppLanguage.english);
  static const hindi = Strings._(AppLanguage.hindi);
  static Strings of(AppLanguage l) => l == AppLanguage.hindi ? hindi : english;

  bool get _hi => lang == AppLanguage.hindi;
  String _t(String en, String hi) => _hi ? hi : en;

  String get appTitle => _t('Gita for Everyone', 'सबके लिए गीता');
  String get today => _t('Today', 'आज');
  String get chapters => _t('Chapters', 'अध्याय');
  String get learn => _t('Start here', 'शुरुआत');
  String get settings => _t('Settings', 'सेटिंग्स');
  String day(int n) => _t('Day $n', 'दिन $n');
  String verseOf(int chapter, int verse) =>
      _t('Chapter $chapter · Verse $verse', 'अध्याय $chapter · श्लोक $verse');
  String chapterN(int n) => _t('Chapter $n', 'अध्याय $n');
  String verseCount(int n) => _t('$n verses', '$n श्लोक');
  String get previousDay => _t('Previous day', 'पिछला दिन');
  String get backToToday => _t('Back to today', 'आज पर लौटें');
  String get sanskrit => _t('Sanskrit', 'संस्कृत');
  String get transliteration => _t('Pronunciation', 'उच्चारण');
  String get hindiLabel => _t('Hindi', 'हिन्दी');
  String get englishLabel => _t('English', 'अंग्रेज़ी');
  String get simpleMeaning => _t('In simple words', 'सरल शब्दों में');
  String get listen => _t('Listen', 'सुनें');
  String get stop => _t('Stop', 'रोकें');
  String get noVoice => _t(
    'No voice for this language is installed on your phone. You can add one in your phone\'s text-to-speech settings.',
    'आपके फ़ोन में इस भाषा की आवाज़ नहीं है। आप इसे फ़ोन की टेक्स्ट-टू-स्पीच सेटिंग्स में जोड़ सकते हैं।',
  );
  String get draftNotice =>
      _t('Draft translation, awaiting review', 'प्रारूप अनुवाद, समीक्षा बाकी');
  String get comingSoon => _t(
    'Translation coming in a future update.',
    'अनुवाद आगे के अपडेट में आएगा।',
  );
  String get copy => _t('Copy', 'कॉपी करें');
  String get copied => _t('Verse copied', 'श्लोक कॉपी हो गया');
  String get previous => _t('Previous', 'पिछला');
  String get next => _t('Next', 'अगला');
  String get previousChapter => _t('Previous chapter', 'पिछला अध्याय');
  String get nextChapter => _t('Next chapter', 'अगला अध्याय');
  String get startReading => _t('Start reading', 'पढ़ना शुरू करें');
  String get continueReading => _t('Continue reading', 'पढ़ना जारी रखें');
  String get readChapter => _t('Read this chapter', 'यह अध्याय पढ़ें');
  String get verses => _t('Verses', 'श्लोक');
  String verseProgress(int n, int total) =>
      _t('Verse $n of $total', 'श्लोक $n / $total');
  String get endOfGita => _t('End of the Gita', 'गीता समाप्त');
  String get summary => _t('About this chapter', 'इस अध्याय के बारे में');
  String get glossary => _t('Key words', 'मुख्य शब्द');
  String get appLanguage => _t('App language', 'ऐप की भाषा');
  String get theme => _t('Theme', 'थीम');
  String get themeSystem => _t('Auto', 'अपने-आप');
  String get themeLight => _t('Light', 'हल्की');
  String get themeDark => _t('Dark', 'गहरी');
  String get textSize => _t('Text size', 'अक्षरों का आकार');
  String get showPronunciation => _t(
    'Show pronunciation (Roman letters)',
    'उच्चारण दिखाएँ (रोमन अक्षरों में)',
  );
  String get slowAudio => _t('Read aloud slowly', 'धीरे-धीरे पढ़कर सुनाएँ');
  String get restart =>
      _t('Start again from Day 1', 'फिर से दिन 1 से शुरू करें');
  String get restartConfirm => _t(
    'Today will become Day 1 and the daily verse will start from the beginning.',
    'आज दिन 1 बन जाएगा और रोज़ का श्लोक फिर शुरू से आएगा।',
  );
  String get cancel => _t('Cancel', 'रद्द करें');
  String get confirm => _t('Start again', 'फिर शुरू करें');
  String get about => _t('About this app', 'इस ऐप के बारे में');
  String get aboutBody => _t(
    'Free for everyone, with no ads, no account and no tracking. The app works fully offline and stores your settings only on this phone. '
        'The Sanskrit text is in the public domain. Translations and explanations are original to this project.',
    'सबके लिए मुफ़्त, बिना विज्ञापन, बिना खाते और बिना ट्रैकिंग। ऐप पूरी तरह ऑफ़लाइन चलता है और आपकी सेटिंग्स केवल इसी फ़ोन में रखता है। '
        'संस्कृत पाठ सार्वजनिक है। अनुवाद और व्याख्याएँ इसी परियोजना द्वारा मौलिक रूप से लिखी गई हैं।',
  );
  String get licenses => _t('Open-source licences', 'ओपन-सोर्स लाइसेंस');
}
