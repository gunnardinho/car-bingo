// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Car Bingo';

  @override
  String get homeHeadline => 'Ready for a road trip?';

  @override
  String homeSubtitle(int count) {
    return '$count things to spot. Pick a board size and go.';
  }

  @override
  String boardSize(int size) {
    return '$size × $size';
  }

  @override
  String get newGame => 'New game';

  @override
  String get resumeGame => 'Resume game';

  @override
  String get startNewGame => 'Or start a new game';

  @override
  String get playAgain => 'Play again';

  @override
  String get backHome => 'Home';

  @override
  String get youWon => 'Bingo! You spotted them all 🎉';

  @override
  String get freeSpace => 'Free space';

  @override
  String progress(int done, int total) {
    return '$done of $total marked';
  }

  @override
  String get tapToMark => 'Tap a square when you spot it';

  @override
  String get cellMarked => 'marked';

  @override
  String get cellNotMarked => 'not marked';

  @override
  String get loadingCatalog => 'Loading…';

  @override
  String loadFailed(String error) {
    return 'Couldn\'\'t load the catalog: $error';
  }

  @override
  String get detailEmpty => 'Tap a square to see what to look for.';

  @override
  String get markIt => 'Mark it';

  @override
  String get unmarkIt => 'Unmark';

  @override
  String get difficultyEasy => 'Easy';

  @override
  String get difficultyMedium => 'Medium';

  @override
  String get difficultyHard => 'Hard';
}
