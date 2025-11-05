import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:math' as math;
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/image_composition.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:puzzle/src/level_selection/jigsaw_info.dart';

import '../collision/puzzle_collision_detection.dart';
import '../shape_type.dart';
import 'image_utils.dart';
import 'piece_component.dart';

class JigsawGame extends FlameGame with HasCollisionDetection {
  int gridSize = 6;
  List<List<PieceComponent>> pieces = [[]];
  List<Vector2> positions = [];
  double pieceSize = 0;
  JigsawInfo jigsawInfo;
  double _scale = 1.0;
  bool isMusicOn;
  Function win;

  JigsawGame(this.jigsawInfo, this.isMusicOn, this.win);

  @override
  Future<void> onLoad() async {
    collisionDetection = PuzzleCollisionDetection();
    // add(FpsTextComponent(position: Vector2(0, 50)));
    Image image;
    if (jigsawInfo.image.startsWith('assets/')) {
      image = await getAssetImage(jigsawInfo.image);
    } else if (jigsawInfo.image.startsWith('data:image/')) {
      // data URI
      final base64Part = jigsawInfo.image.split(',').last;
      final bytes = base64Decode(base64Part);
      image = await getBytesImage(bytes);
    } else if (jigsawInfo.image.startsWith('file://') ||
        jigsawInfo.image.startsWith('/')) {
      // local file path
      final path = jigsawInfo.image.startsWith('file://')
          ? jigsawInfo.image.replaceFirst('file://', '')
          : jigsawInfo.image;
      final file = File(path);
      image = await getFileImage(file);
    } else {
      var file = await DefaultCacheManager().getSingleFile(jigsawInfo.image);
      image = await getFileImage(file);
    }
    _scale = ImageUtils.calculateScale(
      size.x / 3.0 * 2.0,
      size.y / 3.0 * 2.0,
      image.width.toDouble(),
      image.height.toDouble(),
    );
    gridSize = jigsawInfo.gridSize;
    final double widthPerBlock = image.width / gridSize;
    final double heightPerBlock = image.height / gridSize;
    pieceSize = min(widthPerBlock, heightPerBlock) / 4;
    for (var y = 0; y < gridSize; y++) {
      final tmpPieces = <PieceComponent>[];
      pieces.add(tmpPieces);
      for (var x = 0; x < gridSize; x++) {
        PieceComponent player = getPiece(
          widthPerBlock,
          heightPerBlock,
          x,
          y,
          image,
        );
        pieces[y].add(player);
      }
    }
    positions.shuffle();
    for (var y = 0; y < pieces.length; y++) {
      for (var x = 0; x < pieces[y].length; x++) {
        Vector2 position = positions[y * gridSize + x];
        var piece = pieces[y][x];
        if (piece.shape.topTab == 0) {
          position.y = position.y + pieceSize * _scale;
        }
        if (piece.shape.leftTab == 0) {
          position.x = position.x + pieceSize * _scale;
        }
        position.x = position.x + positionOffsetX;
        piece.position = position;
        add(piece);
      }
    }
  }

  getResult(int num, bool added) async {
    if (num == gridSize * gridSize) {
      print("getResult win:$num");
      win();
      if (isMusicOn) {
        FlameAudio.play('won.wav');
      }
    } else {
      print("getResult isMusicOn:$isMusicOn");
      if (added && isMusicOn) {
        FlameAudio.play('click.wav');
      }
    }
  }

  Future<Image> getFileImage(File filePath) async {
    var minHeight = (size.y / 3.0 * 2.0).toInt();
    var minWidth = (size.x / 3.0 * 2.0).toInt();
    print("minHeight:$minHeight minWidth:$minWidth");
    // var list = await FlutterImageCompress.compressWithFile(
    //   filePath,
    //   minHeight: minHeight,
    //   minWidth: minWidth,
    //   quality: 99,
    //   rotate: 0,
    // );

    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(filePath.readAsBytesSync(), (ui.Image img) {
      print("image width:${img.width} image height:${img.height}:");
      return completer.complete(img);
    });
    return completer.future;
  }

  Future<Image> getAssetImage(String assetPath) async {
    final Completer<ui.Image> completer = Completer();
    final data = await rootBundle.load(assetPath);
    ui.decodeImageFromList(data.buffer.asUint8List(), (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }

  Future<Image> getBytesImage(Uint8List bytes) async {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(bytes, (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    print("onGameResize:$size");
  }

  PieceComponent getPiece(
    double widthPerBlock,
    double heightPerBlock,
    int x,
    int y,
    Image image,
  ) {
    Shape shape = _getShape(gridSize, x, y);
    double xAxis = widthPerBlock * x;
    double yAxis = heightPerBlock * y;
    //相对于扩大后图片的起点
    xAxis -= shape.leftTab != 0 ? pieceSize : 0;
    yAxis -= shape.topTab != 0 ? pieceSize : 0;
    final double widthPerBlockTemp = widthPerBlock +
        (shape.leftTab != 0 ? pieceSize : 0) +
        (shape.rightTab != 0 ? pieceSize : 0);
    final double heightPerBlockTemp = heightPerBlock +
        (shape.topTab != 0 ? pieceSize : 0) +
        (shape.bottomTab != 0 ? pieceSize : 0);

    final piece = PieceComponent(
      SpriteComponent(
        sprite: Sprite(
          image,
          srcPosition: Vector2(xAxis, yAxis),
          srcSize: Vector2(widthPerBlockTemp, heightPerBlockTemp),
        ),
        size: Vector2(widthPerBlockTemp * _scale, heightPerBlockTemp * _scale),
      ),
      shape,
      pieceSize * _scale,
      x,
      y,
    );
    generatePositionBottom(widthPerBlock * _scale, heightPerBlock * _scale);
    return piece;
  }

  ///
  /// 随机 1 凸起 2凹进去，0 平的
  Shape _getShape(int gridSize, int x, int y) {
    final int randomPosRow = math.Random().nextInt(2).isEven ? 1 : -1;
    final int randomPosCol = math.Random().nextInt(2).isEven ? 1 : -1;
    Shape shape = Shape();
    shape.bottomTab = y == gridSize - 1 ? 0 : randomPosCol;
    shape.leftTab = x == 0 ? 0 : -pieces[y][x - 1].shape.rightTab;
    shape.rightTab = x == gridSize - 1 ? 0 : randomPosRow;
    shape.topTab = y == 0 ? 0 : -pieces[y - 1][x].shape.bottomTab;
    return shape;
  }

  double pieceX = 0;
  double pieceY = 0;
  bool left = true;
  double positionOffsetX = -1;

  void generatePositionLeftRight(double widthPerBlock, double heightPerBlock) {
    int width = (widthPerBlock.toInt() + pieceSize * _scale * 2).toInt();
    int height = (heightPerBlock.toInt() + pieceSize * _scale * 2).toInt();
    pieceY = pieceY + height;
    if (positions.length == 0) {
      pieceY = 0;
    }
    if (pieceY + height > size.y) {
      if (left) {
        pieceX = size.x - pieceX - width;
        left = false;
      } else {
        pieceX = size.x - pieceX;
        left = true;
      }
      pieceY = 0;
    }
    // print(" pieceX:$pieceX pieceY:$pieceY");
    positions.add(Vector2(pieceX, pieceY));
  }

  void generatePositionBottom(double widthPerBlock, double heightPerBlock) {
    int width = (widthPerBlock.toInt() + pieceSize * _scale * 2).toInt();
    int height = (heightPerBlock.toInt() + pieceSize * _scale * 2).toInt();
    pieceX = pieceX - width;
    if (positions.length == 0) {
      pieceX = size.x - width;
      pieceY = size.y - height;
    }

    if (pieceX < 0) {
      if (positionOffsetX == -1) {
        positionOffsetX = -((pieceX + width) / 2.0);
      }
      pieceX = size.x - width;
      pieceY = pieceY - height;
    }
    // print(" pieceX:$pieceX pieceY:$pieceY");
    positions.add(Vector2(pieceX, pieceY));
  }
}
