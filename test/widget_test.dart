import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Pour gérer les entrées clavier

void main() {
  runApp(const NimporteQuoiGame());
}

class NimporteQuoiGame extends StatelessWidget {
  const NimporteQuoiGame({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'N\'importe Quoi Game',
      theme: ThemeData.dark(),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final Random _random = Random();
  List<FallingItem> fallingItems = [];
  List<Bullet> bullets = [];
  List<FlyingDuck> flyingDucks = [];
  bool showUFO = false;
  double ufoX = 0;
  double playerX = 0.5; // Position du joueur (au centre)
  int score = 0;

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        // Ajouter un objet tombant
        fallingItems.add(
          FallingItem(
            xPosition: _random.nextDouble(),
            onHit: () {
              setState(() {
                score++;
              });
            },
          ),
        );

        // Ajouter un canard volant
        if (_random.nextDouble() < 0.3) {
          flyingDucks.add(
            FlyingDuck(
              xPosition: _random.nextDouble(),
              yPosition: _random.nextDouble() * 0.5,
              onHit: () {
                setState(() {
                  flyingDucks.removeWhere((duck) => duck.xPosition == duck.xPosition);
                  score += 10;
                });
              },
            ),
          );
        }

        // Ajouter un OVNI de manière aléatoire
        if (_random.nextDouble() < 0.2) {
          showUFO = true;
          ufoX = _random.nextDouble();
        }
      });
    });
  }

  void _fireBullet() {
    setState(() {
      bullets.add(
        Bullet(
          xPosition: playerX,
          onImpact: () {
            // Vérifiez les collisions avec les objets tombants
            fallingItems.removeWhere((item) {
              if ((item.xPosition - playerX).abs() < 0.1) {
                score += 5;
                return true;
              }
              return false;
            });

            // Vérifiez la collision avec l'OVNI
            if (showUFO && (ufoX - playerX).abs() < 0.1) {
              showUFO = false;
              score += 15;
            }

            // Vérifiez la collision avec les canards volants
            flyingDucks.removeWhere((duck) {
              if ((duck.xPosition - playerX).abs() < 0.1) {
                score += 10;
                return true;
              }
              return false;
            });
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
              setState(() {
                playerX = max(0, playerX - 0.05);
              });
            } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
              setState(() {
                playerX = min(1, playerX + 0.05);
              });
            } else if (event.logicalKey == LogicalKeyboardKey.space) {
              _fireBullet();
            }
          }
          return KeyEventResult.handled;
        },
        child: Stack(
          children: [
            // Arrière-plan
            Container(color: Colors.black),

            // OVNI
            if (showUFO)
              Positioned(
                top: 50,
                left: ufoX * MediaQuery.of(context).size.width,
                child: Icon(Icons.flight, color: Colors.green, size: 50),
              ),

            // Canards volants
            ...flyingDucks.map((duck) => duck.build(context)),

            // Objets tombants
            ...fallingItems.map((item) => item.build(context)),

            // Tirs
            ...bullets.map((bullet) => bullet.build(context)),

            // Joueur
            Positioned(
              bottom: 20,
              left: playerX * MediaQuery.of(context).size.width - 25,
              child: Container(
                width: 50,
                height: 50,
                color: Colors.blue,
              ),
            ),

            // Score
            Positioned(
              top: 20,
              left: 20,
              child: Text(
                'Score: $score',
                style: const TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FallingItem {
  final double xPosition;
  final VoidCallback onHit;

  FallingItem({required this.xPosition, required this.onHit});

  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: xPosition * MediaQuery.of(context).size.width,
      child: Container(
        width: 50,
        height: 50,
        color: Colors.red,
      ),
    );
  }
}

class Bullet {
  final double xPosition;
  final VoidCallback onImpact;

  Bullet({required this.xPosition, required this.onImpact});

  Widget build(BuildContext context) {
    return Positioned(
      bottom: 50,
      left: xPosition * MediaQuery.of(context).size.width,
      child: Container(
        width: 10,
        height: 20,
        color: Colors.yellow,
      ),
    );
  }
}

class FlyingDuck {
  final double xPosition;
  final double yPosition;
  final VoidCallback onHit;

  FlyingDuck({required this.xPosition, required this.yPosition, required this.onHit});

  Widget build(BuildContext context) {
    return Positioned(
      top: yPosition * MediaQuery.of(context).size.height,
      left: xPosition * MediaQuery.of(context).size.width,
      child: GestureDetector(
        onTap: onHit,
        child: Icon(Icons.airplane_ticket, size: 40, color: Colors.orange),
      ),
    );
  }
}
