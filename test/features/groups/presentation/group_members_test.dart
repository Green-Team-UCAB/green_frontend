// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/que_soy_administrador_del_grupo_matematicas.dart';
import './step/estoy_en_la_pantalla_de_detalle_del_grupo.dart';
import './step/presiono_el_boton_de_invitar_miembro.dart';
import './step/deberia_ver_un_dialogo_con_el_enlace_de_invitacion.dart';
import './step/deberia_poder_copiar_el_enlace.dart';
import './step/que_estoy_en_la_pantalla_de_configuracion_del_grupo.dart';
import './step/deberia_ver_la_lista_de_todos_los_miembros_del_grupo.dart';
import './step/deberia_ver_sus_roles_o_indicadores_visuales.dart';
import './step/que_soy_administrador_y_estoy_en_configuracion.dart';
import './step/presiono_el_boton_de_expulsar_a_juan_perez.dart';
import './step/confirmo_la_accion.dart';
import './step/juan_perez_deberia_ser_removido_de_la_lista.dart';

void main() {
  group('''Gestión de Miembros del Grupo''', () {
    testWidgets('''Generar enlace de invitación''', (tester) async {
      await queSoyAdministradorDelGrupoMatematicas(tester);
      await estoyEnLaPantallaDeDetalleDelGrupo(tester);
      await presionoElBotonDeInvitarMiembro(tester);
      await deberiaVerUnDialogoConElEnlaceDeInvitacion(tester);
      await deberiaPoderCopiarElEnlace(tester);
    });
    testWidgets('''Ver lista de integrantes''', (tester) async {
      await queEstoyEnLaPantallaDeConfiguracionDelGrupo(tester);
      await deberiaVerLaListaDeTodosLosMiembrosDelGrupo(tester);
      await deberiaVerSusRolesOIndicadoresVisuales(tester);
    });
    testWidgets('''Expulsar a un miembro (Admin)''', (tester) async {
      await queSoyAdministradorYEstoyEnConfiguracion(tester);
      await presionoElBotonDeExpulsarAJuanPerez(tester);
      await confirmoLaAccion(tester);
      await juanPerezDeberiaSerRemovidoDeLaLista(tester);
    });
  });
}
