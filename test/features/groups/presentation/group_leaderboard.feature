Feature: Ranking del Grupo
    Como miembro competitivo del grupo
    Quiero ver la tabla de posiciones
    Para saber quién ha obtenido más puntos en los Kahoots

    # H8.9
    Scenario: Ver el Top 3 del ranking
        Given que pertenezco al grupo "Matemáticas"
        And "María" es la líder con 1500 puntos
        And "Pedro" está en segundo lugar con 1200 puntos
        When entro a la pantalla de "Detalle del Grupo"
        And selecciono la pestaña "Ranking"
        Then debería ver a "María" en la posición 1
        And debería ver a "Pedro" en la posición 2