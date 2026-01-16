// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/que_no_pertenezco_a_ningun_grupo.dart';
import './step/entro_a_la_pantalla_mis_grupos.dart';
import './step/deberia_ver_el_mensaje_no_perteneces_a_ningun_grupo_aun.dart';
import './step/que_pertenezco_al_grupo_matematicas101.dart';
import './step/deberia_ver_la_tarjeta_del_grupo_matematicas101.dart';
import './step/que_estoy_en_la_pantalla_mis_grupos.dart';
import './step/presiono_el_boton_nuevo.dart';
import './step/selecciono_la_opcion_crear_grupo.dart';
import './step/ingreso_el_nombre_fisica_avanzada.dart';
import './step/ingreso_la_descripcion_grupo_para_el_final.dart';
import './step/confirmo_la_creacion.dart';
import './step/deberia_ver_un_mensaje_de_exito_grupo_creado_exitosamente.dart';
import './step/el_nuevo_grupo_deberia_aparecer_en_la_lista.dart';
import './step/que_soy_administrador_del_grupo_fisica_avanzada.dart';
import './step/estoy_en_la_pantalla_de_configuracion_del_grupo.dart';
import './step/cambio_el_nombre_a_fisica_ii.dart';
import './step/cambio_la_descripcion_a_preparacion_intensiva.dart';
import './step/guardo_los_cambios.dart';
import './step/deberia_ver_un_mensaje_de_informacion_actualizada.dart';
import './step/el_titulo_del_grupo_deberia_cambiar_a_fisica_ii.dart';
import './step/que_soy_administrador_del_grupo_fisica_ii.dart';
import './step/presiono_el_boton_eliminar_grupo.dart';
import './step/confirmo_la_accion_en_el_dialogo_de_advertencia.dart';
import './step/deberia_ser_redirigido_a_la_lista_de_grupos.dart';
import './step/el_grupo_fisica_ii_ya_no_deberia_aparecer_en_la_lista.dart';

void main() {
  group('''Gestión de Mis Grupos''', () {
    testWidgets('''Ver lista de grupos vacía''', (tester) async {
      await queNoPertenezcoANingunGrupo(tester);
      await entroALaPantallaMisGrupos(tester);
      await deberiaVerElMensajeNoPertenecesANingunGrupoAun(tester);
    });
    testWidgets('''Ver lista con grupos existentes''', (tester) async {
      await quePertenezcoAlGrupoMatematicas101(tester);
      await entroALaPantallaMisGrupos(tester);
      await deberiaVerLaTarjetaDelGrupoMatematicas101(tester);
    });
    testWidgets('''Crear un nuevo grupo exitosamente''', (tester) async {
      await queEstoyEnLaPantallaMisGrupos(tester);
      await presionoElBotonNuevo(tester);
      await seleccionoLaOpcionCrearGrupo(tester);
      await ingresoElNombreFisicaAvanzada(tester);
      await ingresoLaDescripcionGrupoParaElFinal(tester);
      await confirmoLaCreacion(tester);
      await deberiaVerUnMensajeDeExitoGrupoCreadoExitosamente(tester);
      await elNuevoGrupoDeberiaAparecerEnLaLista(tester);
    });
    testWidgets('''Editar la información de un grupo existente''',
        (tester) async {
      await queSoyAdministradorDelGrupoFisicaAvanzada(tester);
      await estoyEnLaPantallaDeConfiguracionDelGrupo(tester);
      await cambioElNombreAFisicaIi(tester);
      await cambioLaDescripcionAPreparacionIntensiva(tester);
      await guardoLosCambios(tester);
      await deberiaVerUnMensajeDeInformacionActualizada(tester);
      await elTituloDelGrupoDeberiaCambiarAFisicaIi(tester);
    });
    testWidgets('''Eliminar un grupo permanentemente''', (tester) async {
      await queSoyAdministradorDelGrupoFisicaIi(tester);
      await estoyEnLaPantallaDeConfiguracionDelGrupo(tester);
      await presionoElBotonEliminarGrupo(tester);
      await confirmoLaAccionEnElDialogoDeAdvertencia(tester);
      await deberiaSerRedirigidoALaListaDeGrupos(tester);
      await elGrupoFisicaIiYaNoDeberiaAparecerEnLaLista(tester);
    });
  });
}
