/// Pure Dart: a local, user-entered tariff and the cost estimate it gives. It is an ESTIMATE from numbers the
/// owner typed, never an official bill.
library;

class TariffTier {
  const TariffTier({this.upTo, required this.price});

  /// Cumulative upper bound of this tier in meter units (for example 100, then 300), or null for "the rest".
  final double? upTo;

  /// Price per unit inside this tier.
  final double price;

  Map<String, Object?> toJson() => {'upTo': upTo, 'price': price};

  factory TariffTier.fromJson(Map<String, Object?> json) => TariffTier(
        upTo: (json['upTo'] as num?)?.toDouble(),
        price: (json['price'] as num).toDouble(),
      );
}

enum TariffProblem { noTiers, invalidPrice, invalidLimit, limitsNotIncreasing, lastTierMustBeOpen, invalidFee }

class Tariff {
  const Tariff({required this.currency, this.fixedFee = 0, required this.tiers});

  /// Label shown after amounts (for example EGP).
  final String currency;

  /// Added once per billing period, whatever the consumption.
  final double fixedFee;

  /// Progressive tiers in order. Only the last tier may be open ("the rest").
  final List<TariffTier> tiers;

  TariffProblem? validate() {
    if (tiers.isEmpty) return TariffProblem.noTiers;
    if (fixedFee.isNaN || fixedFee.isInfinite || fixedFee < 0) return TariffProblem.invalidFee;
    var previous = 0.0;
    for (var i = 0; i < tiers.length; i++) {
      final t = tiers[i];
      if (t.price.isNaN || t.price.isInfinite || t.price < 0) return TariffProblem.invalidPrice;
      final isLast = i == tiers.length - 1;
      if (isLast) {
        if (t.upTo != null) return TariffProblem.lastTierMustBeOpen;
      } else {
        final limit = t.upTo;
        if (limit == null || limit.isNaN || limit.isInfinite || limit <= 0) return TariffProblem.invalidLimit;
        if (limit <= previous) return TariffProblem.limitsNotIncreasing;
        previous = limit;
      }
    }
    return null;
  }

  /// Estimated cost of [consumption] units in one billing period: the fixed fee plus the progressive tiers.
  double estimate(double consumption) {
    var remaining = consumption < 0 ? 0.0 : consumption;
    var previousLimit = 0.0;
    var cost = fixedFee;
    for (final tier in tiers) {
      if (remaining <= 0) break;
      final limit = tier.upTo;
      final span = limit == null ? remaining : (limit - previousLimit < remaining ? limit - previousLimit : remaining);
      cost += span * tier.price;
      remaining -= span;
      if (limit != null) previousLimit = limit;
    }
    return cost;
  }

  Map<String, Object?> toJson() => {
        'currency': currency,
        'fixedFee': fixedFee,
        'tiers': tiers.map((t) => t.toJson()).toList(),
      };

  factory Tariff.fromJson(Map<String, Object?> json) => Tariff(
        currency: (json['currency'] as String?) ?? '',
        fixedFee: (json['fixedFee'] as num?)?.toDouble() ?? 0,
        tiers: ((json['tiers'] as List?) ?? const [])
            .map((e) => TariffTier.fromJson((e as Map).cast<String, Object?>()))
            .toList(),
      );
}
