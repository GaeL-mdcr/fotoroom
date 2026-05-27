import '../models/editor_state_model.dart';

class EditorRulesService {
  static const double minAdjustmentValue = -1;
  static const double maxAdjustmentValue = 1;
  static const int maxHistoryLength = 30;
  static const int maxRotationTurns = 4;

  double normalizeAdjustment(double value) {
    return value.clamp(minAdjustmentValue, maxAdjustmentValue);
  }

  int normalizeRotationTurns(int turns) {
    return turns % maxRotationTurns;
  }

  bool shouldSaveToHistory({
    required EditorStateModel currentState,
    required List<EditorStateModel> previousHistory,
  }) {
    if (previousHistory.isEmpty) {
      return true;
    }

    return previousHistory.last != currentState;
  }

  List<EditorStateModel> limitHistory(List<EditorStateModel> history) {
    if (history.length <= maxHistoryLength) {
      return history;
    }

    return history.sublist(history.length - maxHistoryLength);
  }

  bool isDefaultState(EditorStateModel state) {
    return state == const EditorStateModel();
  }
}
