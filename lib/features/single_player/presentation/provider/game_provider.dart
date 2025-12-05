import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:green_frontend/features/single_player/application/start_attempt.dart';
import 'package:green_frontend/features/single_player/application/get_attempt.dart';
import 'package:green_frontend/features/single_player/application/submit_answer.dart';
import 'package:green_frontend/features/single_player/application/get_summary.dart';
import 'package:green_frontend/features/single_player/application/get_kahoot_preview.dart';
import 'package:green_frontend/features/single_player/domain/entities/answer.dart';
import 'package:green_frontend/core/error/failures.dart';
import 'package:green_frontend/features/single_player/domain/entities/kahoot.dart';
import 'package:green_frontend/features/single_player/domain/entities/attempt.dart';
import 'package:green_frontend/features/single_player/domain/entities/slide.dart';  // Cambia a Slide si es diferente
import 'package:green_frontend/features/single_player/domain/entities/summary.dart';
import 'package:green_frontend/core/storage/local_storage.dart';
import 'package:green_frontend/features/single_player/presentation/screens/game_page.dart';
import 'package:green_frontend/features/single_player/presentation/screens/summary_page.dart';

class GameController extends ChangeNotifier {
  final StartAttempt startAttempt;
  final GetAttempt getAttempt;
  final SubmitAnswer submitAnswer;
  final GetSummary getSummary;
  final GetKahootPreview getKahootPreview;

  // Estados principales
  Attempt? attempt;
  Slide? currentSlide;  // Cambia a Slide? si nextSlide es Slide
  Summary? summary;
  Kahoot? preview;

  // Estados de UI
  bool isLoading = false;
  bool isSubmitting = false;
  bool showFeedback = false;
  bool wasCorrect = false;
  int pointsEarned = 0;

  // Errores
  Failure? lastFailure;

  GameController({
    required this.startAttempt,
    required this.getAttempt,
    required this.submitAnswer,
    required this.getSummary,
    required this.getKahootPreview,
  });

  Future<void> loadPreview(String kahootId) async {
    isLoading = true;
    lastFailure = null;
    notifyListeners();
    final res = await getKahootPreview.call(kahootId);
    res.match(
      (f) => lastFailure = f,
      (k) => preview = k,
    );
    isLoading = false;
    notifyListeners();
  }

  Future<void> startNewAttempt(String kahootId, BuildContext context) async {
    isLoading = true;
    lastFailure = null;
    notifyListeners();
    final res = await startAttempt.call(kahootId: kahootId);
    res.match(
      (f) => lastFailure = f,
      (a) {
        attempt = a;
        currentSlide = a.nextSlide;  // Asume que startAttempt devuelve nextSlide como primera
        GameStorage.saveAttempt(a.attemptId, kahootId);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => GamePage(attemptId: a.attemptId)));
      },
    );
    isLoading = false;
    notifyListeners();
  }

  Future<void> resumeAttempt(String attemptId, BuildContext context) async {
    isLoading = true;
    lastFailure = null;
    notifyListeners();
    final res = await getAttempt.call(attemptId: attemptId);
    res.match(
      (f) => lastFailure = f,
      (a) {
        attempt = a;
        currentSlide = a.nextSlide;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => GamePage(attemptId: a.attemptId)));
      },
    );
    isLoading = false;
    notifyListeners();
  }

  Future<void> submitAnswerResult(Answer answer, BuildContext context) async {
    if (attempt == null || currentSlide == null) return;
    isSubmitting = true;
    lastFailure = null;
    notifyListeners();

    final res = await submitAnswer.call(attempt!.attemptId, answer);
    res.match(
  (f) {
    lastFailure = f;
    isSubmitting = false;
    notifyListeners();
  },
  (result) {
    showFeedback = true;
    wasCorrect = result.wasCorrect;  // Asume que result tiene wasCorrect
    pointsEarned = result.pointsEarned;  // Asume que result tiene pointsEarned
    attempt = attempt!.copyWith(currentScore: result.updatedScore);
    if (result.attemptState == AttemptState.completed) {
      isSubmitting = false;
      notifyListeners();
      loadSummary(attempt!.attemptId, context);
    } else {
      currentSlide = result.nextSlide ?? currentSlide;
      Future.delayed(const Duration(milliseconds: 900), () {
        showFeedback = false;
        wasCorrect = false;  // Reset
        pointsEarned = 0;    // Reset
        isSubmitting = false;
        notifyListeners();
      });
    }
  },
);
  }

  Future<void> loadSummary(String attemptId, BuildContext context) async {
    isLoading = true;
    lastFailure = null;
    notifyListeners();
    final res = await getSummary.call(attemptId);
    res.match(
      (f) => lastFailure = f,
      (s) {
        summary = s;
        GameStorage.clearAttempt();
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SummaryPage()));
      },
    );
    isLoading = false;
    notifyListeners();
  }

  void reset() {
    attempt = null;
    currentSlide = null;
    summary = null;
    preview = null;
    lastFailure = null;
    isLoading = false;
    isSubmitting = false;
    showFeedback = false;
    notifyListeners();
  }

  // Métodos async para compatibilidad
  Future<Either<Failure, Kahoot>> getKahootPreviewAsync(String kahootId) async {
    return await getKahootPreview.call(kahootId);
  }

  Future<Either<Failure, Attempt>> startAttemptAsync(String kahootId) async {
    return await startAttempt.call(kahootId: kahootId);
  }

  Future<Either<Failure, Attempt>> getAttemptAsync(String attemptId) async {
    return await getAttempt.call(attemptId: attemptId);
  }
}