import 'prayer_flow_step.dart';

class RakahFlow {
  final int rakahNumber;
  final List<PrayerFlowStep> steps;
  final bool hasFirstTashahhud;
  final bool hasFinalTashahhud;

  const RakahFlow({
    required this.rakahNumber,
    required this.steps,
    this.hasFirstTashahhud = false,
    this.hasFinalTashahhud = false,
  });
}
