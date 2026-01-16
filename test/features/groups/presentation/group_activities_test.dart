// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/que_soy_miembro_del_grupo_matematicas.dart';
import './step/el_grupo_tiene_una_actividad_algebra_basica_pendiente.dart';
import './step/entro_a_la_pantalla_de_detalle_del_grupo.dart';
import './step/deberia_ver_algebra_basica_en_la_pestana_de_actividades.dart';
import './step/deberia_ver_el_estado_pendiente.dart';
import './step/que_soy_administrador_del_grupo.dart';
import './step/tengo_un_kahoot_llamado_examen_final_en_mi_biblioteca.dart';
import './step/presiono_asignar_kahoot.dart';
import './step/selecciono_examen_final_de_la_lista.dart';
import './step/selecciono_una_fecha_limite_en_el_calendario.dart';
import './step/el_sistema_deberia_asignar_la_actividad_al_grupo.dart';
import './step/deberia_ver_un_mensaje_de_exito_actividad_asignada_correctamente.dart';

void main() {
  group('''Actividades del Grupo''', () {
    testWidgets('''Ver actividades asignadas''', (tester) async {
      await queSoyMiembroDelGrupoMatematicas(tester);
      await elGrupoTieneUnaActividadAlgebraBasicaPendiente(tester);
      await entroALaPantallaDeDetalleDelGrupo(tester);
      await deberiaVerAlgebraBasicaEnLaPestanaDeActividades(tester);
      await deberiaVerElEstadoPendiente(tester);
    });
    testWidgets('''Asignar un nuevo Kahoot al grupo''', (tester) async {
      await queSoyAdministradorDelGrupo(tester);
      await tengoUnKahootLlamadoExamenFinalEnMiBiblioteca(tester);
      await presionoAsignarKahoot(tester);
      await seleccionoExamenFinalDeLaLista(tester);
      await seleccionoUnaFechaLimiteEnElCalendario(tester);
      await elSistemaDeberiaAsignarLaActividadAlGrupo(tester);
      await deberiaVerUnMensajeDeExitoActividadAsignadaCorrectamente(tester);
    });
  });
}
