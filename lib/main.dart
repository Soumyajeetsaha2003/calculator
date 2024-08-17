import 'package:flutter/material.dart';
import 'theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator App',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _themeMode,
      home: CalculatorScreen(changeTheme: _changeTheme),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  final Function(ThemeMode) changeTheme;

  const CalculatorScreen({super.key, required this.changeTheme});

  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _display = "0";

  void _onButtonPressed(String value) {
    setState(() {
      if (_display == "0" || _display == "Error") {
        _display = value;
      } else {
        _display += value;
      }
    });
  }

  void _calculateResult() {
    try {
      final result = _evaluateExpression(_display);
      setState(() {
        _display = result.toString();
      });
    } catch (e) {
      setState(() {
        _display = "Error";
      });
    }
  }

  double _evaluateExpression(String expression) {
    expression = expression.replaceAll(' ', '');

    final operators = RegExp(r'[\+\-\*/]');
    final values = expression.split(operators);
    final ops = operators.allMatches(expression).map((e) => e.group(0)!).toList();

    double result = double.parse(values[0]);
    for (int i = 0; i < ops.length; i++) {
      final op = ops[i];
      final value = double.parse(values[i + 1]);

      switch (op) {
        case '+':
          result += value;
          break;
        case '-':
          result -= value;
          break;
        case '*':
          result *= value;
          break;
        case '/':
          result /= value;
          break;
      }
    }
    return result;
  }

  void _clear() {
    setState(() {
      _display = "0";
    });
  }

  void _backspace() {
    setState(() {
      if (_display == "Error" || _display == "Infinity") {
        _display = "0";
      } else if (_display.length > 1) {
        _display = _display.substring(0, _display.length - 1);
      } else {
        _display = "0";
      }
    });
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Select Theme"),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              widget.changeTheme(ThemeMode.light);
              Navigator.of(context).pop();
            },
            child: Text("Light Theme"),
          ),
          TextButton(
            onPressed: () {
              widget.changeTheme(ThemeMode.dark);
              Navigator.of(context).pop();
            },
            child: Text("Dark Theme"),
          ),
          TextButton(
            onPressed: () {
              widget.changeTheme(ThemeMode.system);
              Navigator.of(context).pop();
            },
            child: Text("System Default"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculator'),
        actions: [
          IconButton(
            icon: Icon(Icons.palette),
            onPressed: _showThemeDialog,
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                _display,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ),
          const Expanded(
            child: Divider(),
          ),
          _buildButtonRow(["7", "8", "9", "/"]),
          _buildButtonRow(["4", "5", "6", "*"]),
          _buildButtonRow(["1", "2", "3", "-"]),
          _buildButtonRow(["0", ".", "C", "+"]),
          _buildButtonRow(["backspace","="]), // Moved '=' and backspace buttons to the same row
        ],
      ),
    );
  }

  Widget _buildButtonRow(List<String> labels) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: labels.map((label) {
        if (label == "backspace") {
          return _buildBackspaceButton();
        } else {
          return _buildButton(label);
        }
      }).toList(),
    );
  }

  Widget _buildButton(String label) {
    final isEqualsButton = label == "="; // Check if the button is '='

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(12.0), // Increased padding for larger buttons
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: Size(double.infinity, 80), // Increased button height
            backgroundColor: isEqualsButton
                ? const Color.fromARGB(255, 201, 6, 6) // Red color for equals button
                : null,
            textStyle: TextStyle(fontSize: 30), // Larger font size
          ),
          onPressed: () {
            if (label == "=") {
              _calculateResult();
            } else if (label == "C") {
              _clear();
            } else {
              _onButtonPressed(label);
            }
          },
          child: Text(
            label,
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(12.0), // Increased padding for larger buttons
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: Size(double.infinity, 80), // Increased button height
            backgroundColor: const Color.fromARGB(255, 68, 63, 63), // Grey color for backspace button
            textStyle: TextStyle(fontSize: 30), // Larger font size
          ),
          onPressed: _backspace,
          child: Icon(
            Icons.backspace_outlined,
            size: 30, // Adjust size of the icon
          ),
        ),
      ),
    );
  }
}