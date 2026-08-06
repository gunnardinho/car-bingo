// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Norwegian Bokmål (`nb`).
class AppLocalizationsNb extends AppLocalizations {
  AppLocalizationsNb([String locale = 'nb']) : super(locale);

  @override
  String get appTitle => 'Bilbingo';

  @override
  String get homeHeadline => 'Klar for biltur?';

  @override
  String homeSubtitle(int count) {
    return '$count ting å speide etter. Velg brettstørrelse og kjør.';
  }

  @override
  String boardSize(int size) {
    return '$size × $size';
  }

  @override
  String get newGame => 'Nytt spill';

  @override
  String get playAgain => 'Spill igjen';

  @override
  String get backHome => 'Hjem';

  @override
  String get youWon => 'Bingo! Du fant alle 🎉';

  @override
  String get freeSpace => 'Gratisrute';

  @override
  String progress(int done, int total) {
    return '$done av $total krysset av';
  }

  @override
  String get tapToMark => 'Trykk på en rute når du ser den';

  @override
  String get cellMarked => 'krysset av';

  @override
  String get cellNotMarked => 'ikke krysset av';

  @override
  String get loadingCatalog => 'Laster …';

  @override
  String loadFailed(String error) {
    return 'Klarte ikke å laste katalogen: $error';
  }

  @override
  String get detailEmpty => 'Trykk på en rute for å se hva du skal se etter.';

  @override
  String get markIt => 'Kryss av';

  @override
  String get unmarkIt => 'Fjern kryss';

  @override
  String get difficultyEasy => 'Lett';

  @override
  String get difficultyMedium => 'Middels';

  @override
  String get difficultyHard => 'Vanskelig';
}
