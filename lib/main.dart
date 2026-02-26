import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui';

void main() {
  runApp(const PremiumCalculatorApp());
}

class PremiumCalculatorApp extends StatelessWidget {
  const PremiumCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, 
      title: 'Neon Calc',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        fontFamily: 'Roboto', // Default system font that looks clean
      ),
      home: const FlashyCalculator(),
    );
  }
}

class FlashyCalculator extends StatefulWidget {
  const FlashyCalculator({super.key});

  @override
  State<FlashyCalculator> createState() => _FlashyCalculatorState();
}

class _FlashyCalculatorState extends State<FlashyCalculator>
    with SingleTickerProviderStateMixin {
  String _expression = "";
  String _result = "0";
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onPressed(String text) {
    setState(() {
      if (text == "AC") {
        _expression = "";
        _result = "0";
      } else if (text == "C") {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
        }
      } else if (text == "=") {
        _calculate();
      } else {
        // Prevent multiple operators in a row
        if (_expression.isNotEmpty &&
            _isOperator(text) &&
            _isOperator(_expression[_expression.length - 1])) {
          _expression = _expression.substring(0, _expression.length - 1) + text;
        } else {
          _expression += text;
        }
        _calculateIncremental();
      }
    });
  }

  bool _isOperator(String char) {
    return ["+", "-", "×", "÷"].contains(char);
  }

  void _calculateIncremental() {
    if (_expression.isEmpty) {
      _result = "0";
      return;
    }
    try {
      String evalExpr = _expression.replaceAll('×', '*').replaceAll('÷', '/');
      // Basic parser for incremental result
      _result = _evaluate(evalExpr);
    } catch (e) {
      // Don't update result on error during typing
    }
  }

  void _calculate() {
    try {
      String evalExpr = _expression.replaceAll('×', '*').replaceAll('÷', '/');
      setState(() {
        _result = _evaluate(evalExpr);
        _expression = _result;
      });
    } catch (e) {
      setState(() {
        _result = "Error";
      });
    }
  }

  // Simple custom math parser for Basic Arithmetic
  String _evaluate(String expression) {
    try {
      // This is a naive implementation. For a real app we might use 'expressions_parser'
      // But we'll build a simple one here.
      final parts = expression.split(RegExp(r'(?=[+\-*/])|(?<=[+\-*/])'));
      if (parts.isEmpty) return "0";

      double total = double.tryParse(parts[0]) ?? 0;
      for (int i = 1; i < parts.length; i += 2) {
        if (i + 1 >= parts.length) break;
        String op = parts[i];
        double val = double.tryParse(parts[i + 1]) ?? 0;

        if (op == "+") total += val;
        if (op == "-") total -= val;
        if (op == "*") total *= val;
        if (op == "/") {
          if (val == 0) return "∞";
          total /= val;
        }
      }

      if (total == total.toInt()) return total.toInt().toString();
      return total.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
    } catch (e) {
      return "0";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated Background Gradient
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF0F172A),
                      HSLColor.fromAHSL(
                        1.0,
                        (_animationController.value * 360),
                        0.5,
                        0.1,
                      ).toColor(),
                      const Color(0xFF1E1B4B),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              );
            },
          ),

          SafeArea(
            child: Column(
              children: [
                // Display Area
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    alignment: Alignment.bottomRight,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _expression,
                          style: TextStyle(
                            fontSize: 28,
                            color: Colors.white.withOpacity(0.5),
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFF818CF8), Color(0xFFF472B6)],
                          ).createShader(bounds),
                          child: Text(
                            _result,
                            style: const TextStyle(
                              fontSize: 72,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Keypad Area
                Expanded(
                  flex: 5,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(40),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 30,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(40),
                          ),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildRow(["AC", "C", "%", "÷"], isTop: true),
                            _buildRow(["7", "8", "9", "×"]),
                            _buildRow(["4", "5", "6", "-"]),
                            _buildRow(["1", "2", "3", "+"]),
                            _buildRow(["00", "0", ".", "="], isBottom: true),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(
    List<String> keys, {
    bool isTop = false,
    bool isBottom = false,
  }) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: keys.map((key) => _buildKey(key)).toList(),
      ),
    );
  }

  Widget _buildKey(String text) {
    bool isOperator = _isOperator(text) || text == "=";
    bool isSpecial = ["AC", "C", "%"].contains(text);

    Color textColor = Colors.white;
    if (isOperator) textColor = const Color(0xFF818CF8);
    if (isSpecial) textColor = const Color(0xFFF472B6);
    if (text == "=") textColor = Colors.white;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _onPressed(text),
            borderRadius: BorderRadius.circular(24),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: text == "="
                    ? const Color(0xFF6366F1)
                    : Colors.white.withOpacity(0.05),
                border: Border.all(
                  color: text == "="
                      ? Colors.transparent
                      : Colors.white.withOpacity(0.05),
                ),
                boxShadow: text == "="
                    ? [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: isOperator ? FontWeight.bold : FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
