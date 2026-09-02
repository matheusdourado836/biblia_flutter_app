import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

/// Estado compartilhado pelo tutorial da tela de devocionais.
///
/// As três seções (jornada, comunidade e planos) vivem em arquivos separados,
/// mas o coach mark precisa apontar para os widgets de todas elas — por isso as
/// chaves ficam aqui em vez de dentro de uma das seções.
final GlobalKey journeyKey = GlobalKey();
final GlobalKey communityKey = GlobalKey();
final GlobalKey plansKey = GlobalKey();

/// Libera o fundo depois que o conteúdo termina de carregar.
final ValueNotifier<bool> removeTutorialBackground = ValueNotifier(false);

List<TargetFocus> devocionaisTargets = [];
