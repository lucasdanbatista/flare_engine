import 'package:example/background.dart';
import 'package:example/game_assets.dart';
import 'package:example/menu.dart';
import 'package:example/pipe.dart';
import 'package:example/player.dart';
import 'package:example/score.dart';
import 'package:flare_engine/flare_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'grass.dart';

void main() => runApp(const MainApp());

var score = 0;

enum GameState { idle, running, over }

var gameState = GameState.idle;

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with SingleTickerProviderStateMixin {
  late final engine = FlareEngine(this);
  final frameNotifier = FlareFrameNotifier();
  final _playerKey = GlobalKey();
  final _topPipeKey = GlobalKey();
  final _bottomPipeKey = GlobalKey();
  bool _isLoading = true;
  bool didPlayHit = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _loadAssets();
    engine.run(
      onTick: (delta) {
        frameNotifier.tick(delta);
        if (gameState == GameState.idle) {
          score = 0;
        } else if (gameState == GameState.over) {
          if (!didPlayHit) {
            didPlayHit = true;
            FlareAudio().playSfx('audio/hit.wav');
          }
        }
      },
    );
  }

  Future<void> _loadAssets() async {
    await GameAssets.instance.load();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.black,
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      home: GestureDetector(
        onTap: () {
          switch (gameState) {
            case GameState.idle:
              Player.reset(_playerKey);
              gameState = GameState.running;
              break;
            case GameState.running:
              Player.fly(_playerKey);
              break;
            case GameState.over:
              didPlayHit = false;
              score = 0;
              Player.reset(_playerKey);
              Pipe.reset(_topPipeKey);
              Pipe.reset(_bottomPipeKey);
              gameState = GameState.running;
              break;
          }
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          body: FlareFrameNotifierProvider(
            frameNotifier: frameNotifier,
            child: AnimatedBuilder(
              animation: frameNotifier,
              builder: (context, _) => Stack(
                children: [
                  Background(),
                  Player(key: _playerKey),
                  FlareHitbox(
                    targetKey: _playerKey,
                    mask: GameAssets.instance.pipeMask,
                    targetMask: GameAssets.instance.playerMask,
                    child: Pipe(key: _topPipeKey, direction: AxisDirection.up),
                    onCollision: () => gameState = GameState.over,
                  ),
                  FlareHitbox(
                    targetKey: _playerKey,
                    mask: GameAssets.instance.pipeMask,
                    targetMask: GameAssets.instance.playerMask,
                    child: Pipe(
                      key: _bottomPipeKey,
                      direction: AxisDirection.down,
                    ),
                    onCollision: () => gameState = GameState.over,
                  ),
                  Score(),
                  FlareHitbox(
                    targetKey: _playerKey,
                    mask: GameAssets.instance.grassMask,
                    targetMask: GameAssets.instance.playerMask,
                    onCollision: () => gameState = GameState.over,
                    child: Grass(),
                  ),
                  Menu(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
