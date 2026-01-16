import 'package:flutter/material.dart';
import 'package:green_frontend/features/single_player/application/start_attempt.dart';
import 'package:green_frontend/features/single_player/application/get_attempt.dart';
import 'package:green_frontend/features/single_player/application/submit_answer.dart';
import 'package:green_frontend/features/single_player/application/get_summary.dart';
import 'package:green_frontend/features/single_player/application/get_kahoot_preview.dart';
import 'package:green_frontend/features/single_player/domain/entities/answer.dart';
import 'package:green_frontend/core/error/failures.dart';
import 'package:green_frontend/features/single_player/domain/entities/kahoot.dart';
import 'package:green_frontend/features/single_player/domain/entities/attempt.dart';
import 'package:green_frontend/features/single_player/domain/entities/slide.dart';  
import 'package:green_frontend/features/single_player/domain/entities/summary.dart';
import 'package:green_frontend/core/storage/local_storage.dart';
import 'package:green_frontend/features/single_player/presentation/screens/game_page.dart';
import 'package:green_frontend/features/single_player/presentation/screens/summary_page.dart';
import 'package:fpdart/fpdart.dart';

class GameController extends ChangeNotifier {
  final StartAttempt startAttempt;
  final GetAttempt getAttempt;
  final SubmitAnswer submitAnswer;
  final GetSummary getSummary;
  final GetKahootPreview getKahootPreview;

  // Estados principales
  Attempt? attempt;
  Slide? currentSlide;  
  Summary? summary;
  Kahoot? preview;
  DateTime? startTime;
  String? _lastKahootId;
  String? get lastKahootId => _lastKahootId;
  
  // Variables locales para seguimiento (sin modificar entidades)
  int _answeredQuestions = 0;
  int _estimatedTotalSlides = 10; // Valor por defecto
  int _correctAnswersCount = 0;
  
  // Estados de UI
  bool isLoading = false;
  bool isSubmitting = false;
  bool showFeedback = false;
  bool wasCorrect = false;
  int pointsEarned = 0;

  // Errores
  Failure? lastFailure;

  // NavigatorKey para navegación controlada
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  GameController({
    required this.startAttempt,
    required this.getAttempt,
    required this.submitAnswer,
    required this.getSummary,
    required this.getKahootPreview,
  });

  // GETTERS para el total de slides
  int get totalSlides {
    return _estimatedTotalSlides;
  }

  // GETTER para preguntas respondidas
  int get answeredQuestions {
    return _answeredQuestions;
  }

  // GETTER para slide actual (1-based)
  int get currentSlideNumber {
    return _answeredQuestions + 1; // +1 porque mostramos la siguiente pregunta
  }

  // GETTER para progreso (0.0 a 1.0)
  double get progress {
    if (_estimatedTotalSlides <= 0) return 0.0;
    return currentSlideNumber / _estimatedTotalSlides;
  }

  // Método para actualizar la estimación del total
  void _updateTotalSlidesEstimation() {
    // Opción 1: Valor por defecto ajustable
    _estimatedTotalSlides = 10; // Valor por defecto
    
    // Opción 2: Si el preview tiene alguna información útil
    if (preview != null) {
      if (preview!.title.length > 30) {
        _estimatedTotalSlides = 15;
      }
    }
    
    // Opción 3: Basado en el número de preguntas ya respondidas
    if (_answeredQuestions > 10) {
      _estimatedTotalSlides = _answeredQuestions + 5;
    }
    
    notifyListeners();
  }

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
    _updateTotalSlidesEstimation();
    notifyListeners();
  }

  Future<void> startNewAttempt(String kahootId, BuildContext context) async {
    isLoading = true;
    lastFailure = null;
    notifyListeners();
    
    final res = await startAttempt.call(kahootId: kahootId);
    
    res.match(
      (f) {
        lastFailure = f;
        isLoading = false;
        notifyListeners();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${f.message}')),
        );
      },
      (a) {
        attempt = a;
        currentSlide = a.nextSlide;
        startTime = DateTime.now();
        _answeredQuestions = 0;
        _lastKahootId = kahootId;
        
        isLoading = false;
        _updateTotalSlidesEstimation();
        
        GameStorage.saveAttempt(a.attemptId, kahootId);
        
        // Navegar de manera segura
        _safeNavigate(
          context,
          MaterialPageRoute(builder: (_) => GamePage(attemptId: a.attemptId)),
        );
      },
    );
  }

  Future<void> resumeAttempt(String attemptId, BuildContext context) async {
    isLoading = true;
    lastFailure = null;
    notifyListeners();
    
    final res = await getAttempt.call(attemptId: attemptId);
    
    res.match(
      (f) {
        lastFailure = f;
        isLoading = false;
        notifyListeners();
      },
      (a) {
        attempt = a;
        currentSlide = a.nextSlide;
        _answeredQuestions = _estimateAnsweredFromAttempt(a);
        
        isLoading = false;
        _updateTotalSlidesEstimation();
        
        _safeNavigate(
          context,
          MaterialPageRoute(builder: (_) => GamePage(attemptId: a.attemptId)),
        );
      },
    );
  }

  int _estimateAnsweredFromAttempt(Attempt a) {
    if (a.currentScore > 0) {
      return (a.currentScore ~/ 100).clamp(0, 20);
    }
    return 0;
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
        wasCorrect = result.wasCorrect;  
        pointsEarned = result.pointsEarned; 
         // INCREMENTA EL CONTADOR SI LA RESPUESTA FUE CORRECTA
      if (result.wasCorrect) {
        _correctAnswersCount++;
      }
        attempt = attempt!.copyWith(currentScore: result.updatedScore);
        
        _answeredQuestions++;
        
        if (_answeredQuestions > _estimatedTotalSlides) {
          _estimatedTotalSlides = _answeredQuestions + 2;
        }
        
        if (result.attemptState == AttemptState.completed) {
          isSubmitting = false;
          
          // Cargar summary primero
          WidgetsBinding.instance.addPostFrameCallback((_) {
            loadSummary(attempt!.attemptId, context);
          });
        } else {
          currentSlide = result.nextSlide ?? currentSlide;
          startTime = DateTime.now(); 
          
          Future.delayed(const Duration(milliseconds: 900), () {
            showFeedback = false;
            wasCorrect = false;
            pointsEarned = 0;
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
      (f) {
        lastFailure = f;
        isLoading = false;
        notifyListeners();
      },
      (s) {
        summary = s;
        GameStorage.clearAttempt();
        isLoading = false;
        
        _safeNavigate(
          context,
          MaterialPageRoute(builder: (_) => SummaryPage()),
        );
      },
    );
  }

  // Método seguro para navegación
  void _safeNavigate(BuildContext context, Route route) {
    if (context.mounted) {
      Navigator.pushReplacement(context, route);
    }
    notifyListeners();
  }

  Future<Either<Failure, Kahoot>> getKahootPreviewAsync(String kahootId) async {
    return await getKahootPreview.call(kahootId);
  }

  void adjustTotalSlidesEstimation(int newEstimate) {
    if (newEstimate > 0) {
      _estimatedTotalSlides = newEstimate;
      notifyListeners();
    }
  }

  int get correctAnswersCount => _correctAnswersCount;

  void resetQuestionCounter() {
    _answeredQuestions = 0;
     _correctAnswersCount = 0;
    _estimatedTotalSlides = 10;
    notifyListeners();
  }

  void reset() {
    attempt = null;
    currentSlide = null;
    summary = null;
    startTime = null;
    lastFailure = null;
    isLoading = false;
    isSubmitting = false;
    showFeedback = false;
    resetQuestionCounter();
    notifyListeners();
  }

  void fullReset() {
    attempt = null;
    currentSlide = null;
    summary = null;
    preview = null;
    _lastKahootId = null;
    startTime = null;
    lastFailure = null;
    isLoading = false;
    isSubmitting = false;
    showFeedback = false;
    resetQuestionCounter();
    notifyListeners();
  }
}