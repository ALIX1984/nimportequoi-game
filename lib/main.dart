import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const NimporteQuoiGame());
}

class NimporteQuoiGame extends StatelessWidget {
  const NimporteQuoiGame({super.key});

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
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final Random _random = Random();
  List<Map<String, double>> fallingItems = []; // Liste des objets tombants
  List<Map<String, double>> bullets = []; // Liste des tirs
  double playerX = 0.5; // Position du joueur
  int score = 0;
  String displayedPhrase = ""; // Phrase affichée lors d'une collision

  final List<String> phrases = [
    "Le temps c'est beaucoup de bruit pour N'importe Quoi®",
    "Montre leur N'importe Quoi®",
    "N'importe quoi®",
    "N'importe Quoi® depuis 2002",
    "N'importe quoi jeu vidéo®",
  ];

  @override
  void initState() {
    super.initState();

    // Générer des objets tombants toutes les 2 secondes
    Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {
        fallingItems.add({
          "x": _random.nextDouble(),
          "y": 0.0,
        });
      });
    });

    // Mise à jour régulière pour les mouvements
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        // Mettre à jour la position des objets tombants
        for (var item in fallingItems) {
          item["y"] = item["y"]! + 0.01; // Descend plus lentement
        }

        // Supprimer les objets tombants qui atteignent le bas
        fallingItems.removeWhere((item) => item["y"]! > 1);

        // Mettre à jour la position des tirs
        for (var bullet in bullets) {
          bullet["y"] = bullet["y"]! - 0.04; // Monte progressivement
        }

        // Supprimer les tirs qui sortent de l'écran
        bullets.removeWhere((bullet) => bullet["y"]! < 0);

        // Détecter les collisions entre tirs et objets tombants
        List<Map<String, double>> itemsToRemove = [];
        List<Map<String, double>> bulletsToRemove = [];

        for (var bullet in bullets) {
          for (var item in fallingItems) {
            if ((bullet["x"]! - item["x"]!).abs() < 0.05 &&
                (bullet["y"]! - item["y"]!).abs() < 0.05) {
              score += 1; // Augmenter le score
              displayedPhrase = phrases[_random.nextInt(phrases.length)];
              itemsToRemove.add(item);
              bulletsToRemove.add(bullet);
              break;
            }
          }
        }

        // Appliquer les suppressions après l'itération
        fallingItems.removeWhere((item) => itemsToRemove.contains(item));
        bullets.removeWhere((bullet) => bulletsToRemove.contains(bullet));
      });
    });
  }

  void _fireBullet() {
    setState(() {
      bullets.add({
        "x": playerX,
        "y": 0.9,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(color: Colors.black), // Arrière-plan

          // Objets tombants
          for (var item in fallingItems)
            Positioned(
              top: MediaQuery.of(context).size.height * item["y"]!,
              left: MediaQuery.of(context).size.width * item["x"]!,
              child: Container(
                width: 50,
                height: 50,
                color: Colors.red,
                child: const Center(
                  child: Text(
                    "N'importe quoi®",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),

          // Tirs
          for (var bullet in bullets)
            Positioned(
              top: MediaQuery.of(context).size.height * bullet["y"]!,
              left: MediaQuery.of(context).size.width * bullet["x"]!,
              child: Container(
                width: 10,
                height: 20,
                color: Colors.yellow,
              ),
            ),

          // Joueur
          Positioned(
            bottom: 20,
            left: MediaQuery.of(context).size.width * playerX - 25,
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

          // Phrase affichée
          Positioned(
            top: 50,
            left: MediaQuery.of(context).size.width * 0.5 - 150,
            child: SizedBox(
              width: 300,
              child: Text(
                displayedPhrase,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.yellow,
                  fontSize: 16,
                ),
              ),
            ),
          ),

          // Boutons tactiles
          Positioned(
            bottom: 100,
            left: 20,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  playerX = max(0, playerX - 0.05); // Déplacer à gauche
                });
              },
              child: const Text("←"),
            ),
          ),
          Positioned(
            bottom: 100,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  playerX = min(1, playerX + 0.05); // Déplacer à droite
                });
              },
              child: const Text("→"),
            ),
          ),
          Positioned(
            bottom: 50,
            left: MediaQuery.of(context).size.width * 0.5 - 50,
            child: ElevatedButton(
              onPressed: _fireBullet, // Tirer
              child: const Text("Tirer"),
            ),
          ),
        ],
      ),
    );
  }
}
