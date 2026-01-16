Feature: Gestión de Miembros del Grupo
    Como administrador o miembro del grupo
    Quiero gestionar quién pertenece a mi grupo
    Para colaborar con las personas correctas

    # H8.3: Invitar (Solo Admin)
    Scenario: Generar enlace de invitación
        Given que soy administrador del grupo "Matemáticas"
        And estoy en la pantalla de "Detalle del Grupo"
        When presiono el botón de "Invitar Miembro"
        Then debería ver un diálogo con el enlace de invitación
        And debería poder copiar el enlace

    # H8.8: Ver miembros (En Settings)
    Scenario: Ver lista de integrantes
        Given que estoy en la pantalla de "Configuración del Grupo"
        Then debería ver la lista de todos los miembros del grupo
        And debería ver sus roles o indicadores visuales

    # H8.4: Expulsar (Solo Admin)
    Scenario: Expulsar a un miembro (Admin)
        Given que soy administrador y estoy en "Configuración"
        When presiono el botón de expulsar a "Juan Perez"
        And confirmo la acción
        Then "Juan Perez" debería ser removido de la lista