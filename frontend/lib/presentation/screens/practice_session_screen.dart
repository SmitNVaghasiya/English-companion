import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/practice_model.dart';
import '../../data/services/practice_service.dart';
import '../widgets/loading_indicator.dart';

class PracticeSessionScreen extends StatefulWidget {
  final String sessionId;

  const PracticeSessionScreen({
    super.key,
    required this.sessionId,
  });

  @override
  State<PracticeSessionScreen> createState() => _PracticeSessionScreenState();
}

class _PracticeSessionScreenState extends State<PracticeSessionScreen> {
  late Future<PracticeSession> _sessionFuture;
  final PracticeService _practiceService = PracticeService();
  
  // Practice state
  int _currentQuestionIndex = 0;
  Map<String, String> _userAnswers = {};
  Map<String, bool> _questionResults = {};
  bool _showResults = false;
  bool _showExplanation = false;
  
  // Timer variables
  Timer? _timer;
  int _timeSpent = 0;
  
  @override
  void initState() {
    super.initState();
    _sessionFuture = _practiceService.getPracticeSession(widget.sessionId);
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timeSpent++;
      });
    });
  }
  
  void _stopTimer() {
    _timer?.cancel();
  }
  
  void _submitAnswer(String answer) {
    _sessionFuture.then((session) {
      final question = session.questions[_currentQuestionIndex];
      setState(() {
        _userAnswers[question.id] = answer;
        _questionResults[question.id] = answer.trim().toLowerCase() == 
            question.correctAnswer.trim().toLowerCase();
        _showExplanation = true;
      });
    });
  }
  
  void _nextQuestion(PracticeSession session) {
    setState(() {
      _showExplanation = false;
      if (_currentQuestionIndex < session.questions.length - 1) {
        _currentQuestionIndex++;
      } else {
        _showResults = true;
        _stopTimer();
        _submitResults(session);
      }
    });
  }
  
  void _submitResults(PracticeSession session) {
    final correctAnswers = _questionResults.values.where((v) => v).length;
    
    final result = PracticeResult(
      sessionId: session.id,
      totalQuestions: session.questions.length,
      correctAnswers: correctAnswers,
      timeSpent: _timeSpent,
      completedAt: DateTime.now(),
      questionResults: _questionResults,
    );
    
    _practiceService.submitPracticeResult(result);
  }
  
  void _restartPractice() {
    setState(() {
      _currentQuestionIndex = 0;
      _userAnswers = {};
      _questionResults = {};
      _showResults = false;
      _showExplanation = false;
      _timeSpent = 0;
      _startTimer();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Practice Session',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        elevation: 0,
        backgroundColor: isDark ? Colors.black : Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF1A1A1A), const Color(0xFF0D0D0D)]
                : [Colors.white, const Color(0xFFF5F5F5)],
          ),
        ),
        child: FutureBuilder<PracticeSession>(
          future: _sessionFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: LoadingIndicator());
            }
            
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[300], size: 60),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading practice session',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _sessionFuture = _practiceService
                              .getPracticeSession(widget.sessionId);
                        });
                      },
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              );
            }
            
            final session = snapshot.data!;
            
            // Start timer on first load
            if (_timeSpent == 0 && !_showResults) {
              _startTimer();
            }
            
            if (_showResults) {
              return _buildResultsView(session);
            }
            
            return _buildQuestionView(session);
          },
        ),
      ),
    );
  }
  
  Widget _buildQuestionView(PracticeSession session) {
    final question = session.questions[_currentQuestionIndex];
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Session info
          Text(
            session.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Question ${_currentQuestionIndex + 1} of ${session.questions.length}',
            style: theme.textTheme.titleMedium?.copyWith(
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          
          // Progress indicator
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / session.questions.length,
            backgroundColor: isDark ? Colors.white24 : Colors.black12,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
          ),
          
          // Question card
          const SizedBox(height: 16),
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: isDark ? AppColors.lightBlack : Colors.white,
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question.question,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: isDark ? Colors.white : Colors.black87,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Question type specific UI
                  _buildQuestionTypeUI(question),
                  
                  // Explanation (if answer submitted)
                  if (_showExplanation) ...[
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _questionResults[question.id] == true
                            ? AppColors.successGreen.withValues(alpha: 0.1)
                            : AppColors.errorRed.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _questionResults[question.id] == true
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                color: _questionResults[question.id] == true
                                    ? AppColors.successGreen
                                    : AppColors.errorRed,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _questionResults[question.id] == true
                                    ? 'Correct!'
                                    : 'Incorrect',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: _questionResults[question.id] == true
                                      ? AppColors.successGreen
                                      : AppColors.errorRed,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Correct answer: ${question.correctAnswer}',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            question.explanation,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDark ? Colors.white70 : Colors.black87,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: () => _nextQuestion(session),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _currentQuestionIndex < session.questions.length - 1
                              ? 'Next Question'
                              : 'See Results',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          // Hint button
          if (!_showExplanation) ...[
            const SizedBox(height: 12),
            Center(
              child: TextButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(question.hint ?? 'Think carefully about the question.'),
                      backgroundColor: AppColors.primaryColor,
                      duration: const Duration(seconds: 5),
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.lightbulb_outline),
                label: const Text('Show Hint'),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildQuestionTypeUI(PracticeQuestion question) {
    switch (question.type) {
      case PracticeQuestionType.multipleChoice:
        return _buildMultipleChoiceQuestion(question);
      case PracticeQuestionType.trueFalse:
        return _buildTrueFalseQuestion(question);
      case PracticeQuestionType.fillInTheBlank:
        return _buildFillInTheBlankQuestion(question);
      case PracticeQuestionType.reorder:
        return _buildReorderQuestion(question);
    }
  }
  
  Widget _buildMultipleChoiceQuestion(PracticeQuestion question) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final userAnswer = _userAnswers[question.id];
    
    return Column(
      children: question.options.map((option) {
        final isSelected = userAnswer == option;
        final isCorrect = question.correctAnswer == option;
        
        // Determine colors based on selection and correctness
        Color? backgroundColor;
        Color? textColor;
        
        if (_showExplanation) {
          if (isCorrect) {
            backgroundColor = AppColors.successGreen.withValues(alpha: 0.2);
            textColor = AppColors.successGreen;
          } else if (isSelected && !isCorrect) {
            backgroundColor = AppColors.errorRed.withValues(alpha: 0.2);
            textColor = AppColors.errorRed;
          }
        } else if (isSelected) {
          backgroundColor = AppColors.primaryColor.withValues(alpha: 0.2);
          textColor = AppColors.primaryColor;
        }
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: _showExplanation
                ? null
                : () {
                    _submitAnswer(option);
                  },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: backgroundColor ??
                    (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03)),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? (textColor ?? AppColors.primaryColor)
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      option,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: textColor ??
                            (isDark ? Colors.white : Colors.black87),
                      ),
                    ),
                  ),
                  if (_showExplanation && isCorrect)
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.successGreen,
                    )
                  else if (_showExplanation && isSelected && !isCorrect)
                    const Icon(
                      Icons.cancel,
                      color: AppColors.errorRed,
                    )
                  else if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: textColor ?? AppColors.primaryColor,
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildTrueFalseQuestion(PracticeQuestion question) {
    // True/False questions are just a special case of multiple choice
    return _buildMultipleChoiceQuestion(question);
  }
  
  Widget _buildFillInTheBlankQuestion(PracticeQuestion question) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final userAnswer = _userAnswers[question.id] ?? '';
    final textController = TextEditingController(text: userAnswer);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: textController,
          enabled: !_showExplanation,
          decoration: InputDecoration(
            hintText: 'Type your answer here...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primaryColor,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.03),
          ),
          style: theme.textTheme.titleMedium,
          onChanged: (value) {
            _userAnswers[question.id] = value;
          },
        ),
        if (!_showExplanation) ...[
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: () => _submitAnswer(textController.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Submit Answer',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
  
  Widget _buildReorderQuestion(PracticeQuestion question) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Create a list of words to reorder
    List<String> currentOrder = [];
    
    if (_userAnswers.containsKey(question.id)) {
      // If user has already attempted to answer, show their current order
      currentOrder = _userAnswers[question.id]!.split(' ');
    } else {
      // Initialize with shuffled options
      currentOrder = List.from(question.options);
      currentOrder.shuffle();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Drag to reorder the words:',
          style: theme.textTheme.titleMedium?.copyWith(
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        // Reorderable list
        ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          onReorder: (oldIndex, newIndex) {
            setState(() {
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }
              final item = currentOrder.removeAt(oldIndex);
              currentOrder.insert(newIndex, item);
              
              // Update user answer
              _userAnswers[question.id] = currentOrder.join(' ');
            });
          },
          children: currentOrder.asMap().entries.map((entry) {
            final index = entry.key;
            final word = entry.value;
            
            return Card(
              key: ValueKey(index),
              margin: const EdgeInsets.only(bottom: 8),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: ReorderableDragStartListener(
                index: index,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: const Icon(
                      Icons.drag_indicator,
                      color: AppColors.primaryColor,
                    ),
                    title: Text(
                      word,
                      style: theme.textTheme.titleMedium,
                    ),
                    trailing: Icon(
                      Icons.drag_handle,
                      color: AppColors.primaryColor.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton(
            onPressed: () => _submitAnswer(currentOrder.join(' ')),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Submit Answer',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildResultsView(PracticeSession session) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final correctAnswers = _questionResults.values.where((v) => v).length;
    final totalQuestions = session.questions.length;
    final score = (correctAnswers / totalQuestions) * 100;
    
    // Determine performance message
    String performanceMessage;
    Color performanceColor;
    
    if (score >= 90) {
      performanceMessage = 'Excellent!';
      performanceColor = AppColors.successGreen;
    } else if (score >= 70) {
      performanceMessage = 'Good job!';
      performanceColor = Colors.amber;
    } else if (score >= 50) {
      performanceMessage = 'Keep practicing!';
      performanceColor = Colors.orange;
    } else {
      performanceMessage = 'Need more practice';
      performanceColor = AppColors.errorRed;
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Score summary
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: isDark ? AppColors.lightBlack : Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    'Practice Complete!',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    session.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  
                  // Score circle
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: performanceColor.withValues(alpha: 0.1),
                      border: Border.all(
                        color: performanceColor,
                        width: 4,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${score.toInt()}%',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: performanceColor,
                            ),
                          ),
                          Text(
                            '$correctAnswers/$totalQuestions',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: performanceColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  Text(
                    performanceMessage,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: performanceColor,
                    ),
                  ),
                  
                  // Time spent
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.timer,
                        color: AppColors.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Time: ${_formatDuration(_timeSpent)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Question review
          Text(
            'Question Review',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          
          // List of questions with results
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: session.questions.length,
            itemBuilder: (context, index) {
              final question = session.questions[index];
              final isCorrect = _questionResults[question.id] ?? false;
              
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: isDark
                    ? AppColors.lightBlack
                    : Colors.white,
                child: ExpansionTile(
                  leading: Icon(
                    isCorrect ? Icons.check_circle : Icons.cancel,
                    color: isCorrect
                        ? AppColors.successGreen
                        : AppColors.errorRed,
                  ),
                  title: Text(
                    'Question ${index + 1}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    question.question,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            question.question,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Your answer: ${_userAnswers[question.id] ?? "Not answered"}',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Correct answer: ${question.correctAnswer}',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            question.explanation,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDark ? Colors.white70 : Colors.black87,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to Sessions'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _restartPractice,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
