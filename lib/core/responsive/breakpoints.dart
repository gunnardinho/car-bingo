/// Material 3 width breakpoints. Governing rule: branch on available
/// width/space, never on "is this a tablet" (ARCHITECTURE.md §3).
library;

enum WindowSize { compact, medium, expanded, large }

class Breakpoints {
  static const double medium = 600;
  static const double expanded = 840;
  static const double large = 1200;

  static WindowSize of(double width) {
    if (width < medium) return WindowSize.compact;
    if (width < expanded) return WindowSize.medium;
    if (width < large) return WindowSize.expanded;
    return WindowSize.large;
  }
}
