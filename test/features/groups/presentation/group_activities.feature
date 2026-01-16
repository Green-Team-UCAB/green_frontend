Feature: Actividades del Grupo
    Como usuario del grupo
    Quiero ver y recibir actividades educativas (Kahoots)
    Para practicar y competir con mis compañeros

    # H8.7: Ver lista (User)
    Scenario: Ver actividades asignadas
        Given que soy miembro del grupo "Matemáticas"
        And el grupo tiene una actividad "Álgebra Básica" pendiente
        When entro a la pantalla de "Detalle del Grupo"
        Then debería ver "Álgebra Básica" en la pestaña de actividades
        And debería ver el estado "PENDIENTE"

    # H8.6: Asignar actividad (Admin)
    Scenario: Asignar un nuevo Kahoot al grupo
        Given que soy administrador del grupo
        And tengo un Kahoot llamado "Examen Final" en mi biblioteca
        When presiono "Asignar Kahoot"
        And selecciono "Examen Final" de la lista
        And selecciono una fecha límite en el calendario
        Then el sistema debería asignar la actividad al grupo
        And debería ver un mensaje de éxito "Actividad asignada correctamente"