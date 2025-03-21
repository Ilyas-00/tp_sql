-- Vue ALL_PLAYERS
CREATE VIEW ALL_PLAYERS AS
SELECT 
    p.pseudo AS nom_du_joueur,
    COUNT(DISTINCT pip.id_party) AS nombre_de_parties_jouees,
    COUNT(pp.id_turn) AS nombre_de_tours_joues,
    MIN(pp.start_time) AS premiere_participation,
    MAX(pp.end_time) AS derniere_action
FROM 
    players p
LEFT JOIN players_in_parties pip ON p.id_player = pip.id_player
LEFT JOIN players_play pp ON p.id_player = pp.id_player
GROUP BY 
    p.pseudo
ORDER BY 
    nombre_de_parties_jouees DESC, 
    premiere_participation, 
    derniere_action, 
    nom_du_joueur;

-- Vue ALL_PLAYERS_ELAPSED_GAME
CREATE VIEW ALL_PLAYERS_ELAPSED_GAME AS
SELECT 
    p.pseudo AS nom_du_joueur,
    pr.title_party AS nom_de_la_partie,
    (SELECT COUNT(DISTINCT id_player) FROM players_in_parties WHERE id_party = pr.id_party) AS nombre_de_participants,
    MIN(pp.start_time) AS premiere_action,
    MAX(pp.end_time) AS derniere_action,
    DATEDIFF(SECOND, MIN(pp.start_time), MAX(pp.end_time)) AS secondes_dans_la_partie
FROM 
    players p
JOIN players_in_parties pip ON p.id_player = pip.id_player
JOIN parties pr ON pip.id_party = pr.id_party
JOIN players_play pp ON p.id_player = pp.id_player AND pr.id_party = (SELECT id_party FROM turns WHERE id_turn = pp.id_turn)
GROUP BY 
    p.pseudo, 
    pr.title_party;

-- Vue ALL_PLAYERS_ELAPSED_TOUR
CREATE VIEW ALL_PLAYERS_ELAPSED_TOUR AS
SELECT 
    p.pseudo AS nom_du_joueur,
    pr.title_party AS nom_de_la_partie,
    t.turn_number AS numero_du_tour,
    t.start_time AS debut_du_tour,
    pp.end_time AS prise_de_decision,
    DATEDIFF(SECOND, t.start_time, pp.end_time) AS secondes_dans_le_tour
FROM 
    players p
JOIN players_play pp ON p.id_player = pp.id_player
JOIN turns t ON pp.id_turn = t.id_turn
JOIN parties pr ON t.id_party = pr.id_party;

-- Vue ALL_PLAYERS_STATS
CREATE VIEW ALL_PLAYERS_STATS AS
SELECT 
    p.pseudo AS nom_du_joueur,
    CASE 
        WHEN pip.id_role = 1 THEN 'Loup'
        WHEN pip.id_role = 2 THEN 'Villageois'
        ELSE 'Inconnu'
    END AS role,
    pr.title_party AS nom_de_la_partie,
    COUNT(DISTINCT t.id_turn) AS nombre_de_tours_joues,
    MAX(t.turn_number) AS nombre_total_de_tours,
    CASE 
        WHEN pip.id_role = 1 AND pr.game_status = 'completed' THEN 'Loup'
        WHEN pip.id_role = 2 AND pr.game_status = 'completed' THEN 'Villageois'
        ELSE 'En cours'
    END AS vainqueur,
    AVG(DATEDIFF(SECOND, pp.start_time, pp.end_time)) AS temps_moyen_decision
FROM 
    players p
JOIN players_in_parties pip ON p.id_player = pip.id_player
JOIN parties pr ON pip.id_party = pr.id_party
JOIN turns t ON pr.id_party = t.id_party
JOIN players_play pp ON p.id_player = pp.id_player AND t.id_turn = pp.id_turn
GROUP BY 
    p.pseudo, 
    pip.id_role, 
    pr.title_party, 
    pr.game_status;
