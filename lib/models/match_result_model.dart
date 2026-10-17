import 'item_model.dart';

class MatchResultModel {
  final ItemModel targetItem;
  final ItemModel candidateItem;
  final double score; // 0.0 to 100.0%
  final double categoryScore;
  final double keywordScore;
  final double locationScore;
  final double timeScore;
  final List<String> matchReasons;

  const MatchResultModel({
    required this.targetItem,
    required this.candidateItem,
    required this.score,
    required this.categoryScore,
    required this.keywordScore,
    required this.locationScore,
    required this.timeScore,
    required this.matchReasons,
  });

  bool get isConfidentMatch => score >= 60.0;

  String get scorePercentageText => '${score.toStringAsFixed(0)}% Match';
}
