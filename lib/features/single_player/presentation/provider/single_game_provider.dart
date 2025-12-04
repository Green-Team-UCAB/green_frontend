import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/entities/attempt.dart';
import '../../domain/entities/answer.dart';
import '../../application/start_attempt.dart';
import '../../application/submit_answer.dart';
import '../../application/get_summary.dart';
import '../../application/get_attempt.dart';
import 'package:green_frontend/features/single_player/domain/entities/slide.dart';
import 'package:green_frontend/features/single_player/domain/entities/summary.dart';


class QuizProvider with ChangeNotifier {
  //Se inyectan los casos de uso
  final StartAttempt startAttemptUseCase;
  final GetAttempt getAttemptUseCase;
  final SubmitAnswer submitAnswerUseCase;
  final GetSummary getSummaryUseCase;

  QuizProvider({
    required this.startAttemptUseCase,
    required this.getAttemptUseCase,
    required this.submitAnswerUseCase,
    required this.getSummaryUseCase,
  });

//atributos de estado

  Attempt? _attempt;
  Slide? _currentSlide;  // Slide actual
  bool _isLoading = false;
  String? _errorMessage;
  int _remainingTime = 0;  // Temporizador 
  Timer? _timer;
  List<int> _selectedOptions = []; // Para multiple choice 
  Summary? _summary;  // Para el resumen final del rendimiento del usuario

  // Getters para la UI
  Attempt? get attempt => _attempt;
  Slide? get currentSlide => _currentSlide;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get remainingTime => _remainingTime;
  List<int> get selectedOptions => _selectedOptions;
  Summary? get summary => _summary;
  bool get isQuizCompleted => _attempt?.state == AttemptState.completed;

  // Método para iniciar el attempt 
  Future<void> startAttempt(String kahootId) async {
    _setLoading(true);
    final result = await startAttemptUseCase(kahootId: kahootId);
    result.fold(
      (failure) => _setError(failure.message),
      (attempt) {
        _attempt = attempt;
        _setCurrentSlide(attempt.nextSlide);  
      },
    );
    _setLoading(false);
  }

  // Método para obtener attempt actualizado 
  Future<void> getAttempt(String attemptId) async {
    _setLoading(true);
    final result = await getAttemptUseCase(attemptId: attemptId);
    result.fold(
      (failure) => _setError(failure.message),
      (attempt) {
        _attempt = attempt;
        _setCurrentSlide(attempt.nextSlide);
      },
    );
    _setLoading(false);
  }

  // Método para enviar respuesta 
  Future<void> submitAnswer() async {
    if (_attempt == null || _currentSlide == null) return;
    _setLoading(true);
    final userAnswer = Answer(
      slideId: _currentSlide!.slideId,
      answerIndex: _selectedOptions.isNotEmpty ? _selectedOptions : null,
      timeElapsedSeconds: _currentSlide!.timeLimitSeconds - _remainingTime,
    );
    final result = await submitAnswerUseCase(_attempt!.attemptId, userAnswer);
    result.fold(
      (failure) => _setError(failure.message),
      (answerResult) {
        _timer?.cancel();
        if (answerResult.attemptState == AttemptState.completed) {
          // Quiz terminado, obtener summary
          getSummary(_attempt!.attemptId);
        } else {
          // Pasar al siguiente slide
          _setCurrentSlide(answerResult.nextSlide);
        }
      },
    );
    _setLoading(false);
  }

  // Método para obtener resumen (llama a GetSummary)
  Future<void> getSummary(String attemptId) async {
    _setLoading(true);
    final result = await getSummaryUseCase(attemptId);
    result.fold(
      (failure) => _setError(failure.message),
      (summary) => _summary = summary,
    );
    _setLoading(false);
  }


  // Seleccionar opción (maneja single/multiple choice)
 void selectOption(int index) {
    if (_currentSlide == null || _remainingTime <= 0) return;
    if (_currentSlide!.questionType == QuestionType.multipleChoice) {
      if (_selectedOptions.contains(index)) {
        _selectedOptions.remove(index);
      } else {
        _selectedOptions.add(index);
      }
    } else {
      _selectedOptions = [index];  // Single choice
    }
    notifyListeners();  
  }

  // establecer slide y temporizador
  void _setCurrentSlide(Slide? slide) {
    _currentSlide = slide;
    _selectedOptions = [];
    if (slide != null) {
      _remainingTime = slide.timeLimitSeconds;
      _startTimer();
    }
    notifyListeners();
  }

  // Temporizador 
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        _remainingTime--;
        notifyListeners();
      } else {
        _timer?.cancel();
        // Auto-enviar respuesta si se acaba el tiempo
        submitAnswer();
      }
    });
  }

  // Helpers
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

