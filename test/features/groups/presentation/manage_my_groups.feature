Feature: Gestión de Mis Grupos
    Como usuario de la plataforma
    Quiero ver, crear y administrar mis grupos de estudio
    Para organizar mis actividades académicas y mantener la información actualizada

    # H8.1: Ver lista (Caso vacío)
    Scenario: Ver lista de grupos vacía
        Given que no pertenezco a ningún grupo
        When entro a la pantalla "Mis Grupos"
        Then debería ver el mensaje "No perteneces a ningún grupo aún"

    # H8.1: Ver lista (Caso con datos)
    Scenario: Ver lista con grupos existentes
        Given que pertenezco al grupo "Matemáticas 101"
        When entro a la pantalla "Mis Grupos"
        Then debería ver la tarjeta del grupo "Matemáticas 101"

    # H8.2: Crear grupo
    Scenario: Crear un nuevo grupo exitosamente
        Given que estoy en la pantalla "Mis Grupos"
        When presiono el botón "Nuevo"
        And selecciono la opción "Crear Grupo"
        And ingreso el nombre "Física Avanzada"
        And ingreso la descripción "Grupo para el final"
        And confirmo la creación
        Then debería ver un mensaje de éxito "Grupo creado exitosamente"
        And el nuevo grupo debería aparecer en la lista

    # H8.5: Editar grupo (Requiere ser Admin)
    Scenario: Editar la información de un grupo existente
        Given que soy administrador del grupo "Física Avanzada"
        And estoy en la pantalla de "Configuración del Grupo"
        When cambio el nombre a "Física II"
        And cambio la descripción a "Preparación intensiva"
        And guardo los cambios
        Then debería ver un mensaje de "Información actualizada"
        And el título del grupo debería cambiar a "Física II"

    # H8.5: Eliminar grupo (Requiere ser Admin)
    Scenario: Eliminar un grupo permanentemente
        Given que soy administrador del grupo "Física II"
        And estoy en la pantalla de "Configuración del Grupo"
        When presiono el botón "ELIMINAR GRUPO"
        And confirmo la acción en el diálogo de advertencia
        Then debería ser redirigido a la lista de grupos
        And el grupo "Física II" ya no debería aparecer en la lista