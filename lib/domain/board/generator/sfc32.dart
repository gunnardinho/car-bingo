/// Deterministic PRNG: sfc32 seeded via cyrb128 (ARCHITECTURE.md §8).
///
/// Chosen over Random()/mulberry32/`% n`: 128-bit state, top statistical
/// quality, ~10 lines so it can be reimplemented byte-identically in Node for
/// later server-side anti-cheat. Integers are drawn by rejection sampling
/// (never modulo bias, never from a float).
///
/// Dart determinism rules applied throughout: every op masked with
/// `& 0xFFFFFFFF`, unsigned shift `>>>`, `imul` as `(x*y) & 0xFFFFFFFF`, seed
/// strings iterated by UTF-16 code unit. This is byte-reproducible on the Dart
/// VM (where golden tests run) and on AOT mobile; web ints are not the target.
library;

const int _mask = 0xFFFFFFFF;

int _imul(int a, int b) => (a * b) & _mask;

/// cyrb128 string hash → four 32-bit seed words.
List<int> cyrb128(String str) {
  int h1 = 1779033703, h2 = 3144134277, h3 = 1013904242, h4 = 2773480762;
  for (var i = 0; i < str.length; i++) {
    final k = str.codeUnitAt(i);
    h1 = h2 ^ _imul(h1 ^ k, 597399067);
    h2 = h3 ^ _imul(h2 ^ k, 2869860233);
    h3 = h4 ^ _imul(h3 ^ k, 951274213);
    h4 = h1 ^ _imul(h4 ^ k, 2716044179);
  }
  h1 = _imul(h3 ^ (h1 >>> 18), 597399067);
  h2 = _imul(h4 ^ (h2 >>> 22), 2869860233);
  h3 = _imul(h1 ^ (h3 >>> 17), 951274213);
  h4 = _imul(h2 ^ (h4 >>> 19), 2716044179);
  // Canonical cyrb128 fold: words 1-3 XOR the NEW h1 (= h1^h2^h3^h4), not the
  // pre-fold h1. This makes a Node reimplementation byte-identical, which the
  // later server-side anti-cheat depends on.
  final s0 = (h1 ^ h2 ^ h3 ^ h4) & _mask;
  return [s0, (h2 ^ s0) & _mask, (h3 ^ s0) & _mask, (h4 ^ s0) & _mask];
}

class Sfc32 {
  int _a, _b, _c, _d;

  Sfc32(this._a, this._b, this._c, this._d);

  /// Seed from a string and warm the state so early outputs are well mixed.
  factory Sfc32.fromSeed(String seed) {
    final h = cyrb128(seed);
    final rng = Sfc32(h[0], h[1], h[2], h[3]);
    for (var i = 0; i < 16; i++) {
      rng.nextU32();
    }
    return rng;
  }

  /// Next raw 32-bit unsigned value.
  int nextU32() {
    _a &= _mask;
    _b &= _mask;
    _c &= _mask;
    _d &= _mask;
    final t = (((_a + _b) & _mask) + _d) & _mask;
    _d = (_d + 1) & _mask;
    _a = _b ^ (_b >>> 9);
    _b = (_c + ((_c << 3) & _mask)) & _mask;
    _c = (((_c << 21) & _mask) | (_c >>> 11)) & _mask;
    _c = (_c + t) & _mask;
    return t;
  }

  /// Unbiased integer in [0, n) via rejection sampling. Never `nextU32() % n`
  /// (which biases toward small values).
  int nextInt(int n) {
    if (n <= 0) throw ArgumentError.value(n, 'n', 'must be > 0');
    if (n == 1) return 0;
    const two32 = 0x100000000; // 2^32
    final rem = two32 % n;
    final limit = two32 - rem; // largest multiple of n that is <= 2^32
    while (true) {
      final r = nextU32();
      if (r < limit) return r % n;
    }
  }
}
