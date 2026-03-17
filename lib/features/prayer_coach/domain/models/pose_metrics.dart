class PoseMetrics {
  final double? shoulderAngle;
  final double? hipAngle;
  final double? kneeAngle;
  final double? spineAngle;
  final double? torsoAngleFromHorizontal;
  final double? hipBendAngle;
  final double? leftKneeAngle;
  final double? rightKneeAngle;
  final double? bodyHeightRatio;
  final double? shoulderHeightRatio;
  final double? hipHeightRatio;
  final double? noseHeightRatio;
  final double? torsoDropRatio;

  const PoseMetrics({
    required this.shoulderAngle,
    required this.hipAngle,
    required this.kneeAngle,
    required this.spineAngle,
    required this.torsoAngleFromHorizontal,
    required this.hipBendAngle,
    required this.leftKneeAngle,
    required this.rightKneeAngle,
    required this.bodyHeightRatio,
    required this.shoulderHeightRatio,
    required this.hipHeightRatio,
    required this.noseHeightRatio,
    required this.torsoDropRatio,
  });
}