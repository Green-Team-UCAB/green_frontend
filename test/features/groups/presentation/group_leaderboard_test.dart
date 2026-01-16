// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/que_pertenezco_al_grupo_matematicas.dart';
import './step/maria_es_la_lider_con1500_puntos.dart';
import './step/pedro_esta_en_segundo_lugar_con1200_puntos.dart';
import './step/entro_a_la_pantalla_de_detalle_del_grupo.dart';
import './step/selecciono_la_pestana_ranking.dart';
import './step/deberia_ver_a_maria_en_la_posicion1.dart';
import './step/deberia_ver_a_pedro_en_la_posicion2.dart';

void main() {
  group('''Ranking del Grupo''', () {
    testWidgets('''Ver el Top 3 del ranking''', (tester) async {
      await quePertenezcoAlGrupoMatematicas(tester);
      await mariaEsLaLiderCon1500Puntos(tester);
      await pedroEstaEnSegundoLugarCon1200Puntos(tester);
      await entroALaPantallaDeDetalleDelGrupo(tester);
      await seleccionoLaPestanaRanking(tester);
      await deberiaVerAMariaEnLaPosicion1(tester);
      await deberiaVerAPedroEnLaPosicion2(tester);
    });
  });
}
