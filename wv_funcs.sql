CREATE FUNCTION random_position(@max_lines INT, @max_cols INT, @party_id INT)
RETURNS TABLE
AS
RETURN (
    WITH used_positions AS (
        SELECT DISTINCT 
            origin_position_col AS col, 
            origin_position_row AS row 
        FROM players_play pp
        JOIN turns t ON pp.id_turn = t.id_turn
        WHERE t.id_party = @party_id
    )
    SELECT TOP 1 
        CHAR(ASCII('A') + FLOOR(RAND() * @max_cols)) AS col,
        CAST(FLOOR(1 + RAND() * @max_lines) AS VARCHAR(2)) AS row
    FROM sys.all_objects a1
    CROSS JOIN sys.all_objects a2
    WHERE NOT EXISTS (
        SELECT 1
        FROM used_positions
        WHERE col = CHAR(ASCII('A') + FLOOR(RAND() * @max_cols))
          AND row = CAST(FLOOR(1 + RAND() * @max_lines) AS VARCHAR(2))
    )
);
GO
CREATE FUNCTION random_role(@party_id INT)
RETURNS INT
AS
BEGIN
    DECLARE @wolf_count INT, @max_players INT, @current_wolves INT;

    SET @max_players = 10;

    SELECT @current_wolves = COUNT(*) 
    FROM players_in_parties 
    WHERE id_party = @party_id AND id_role = 1;

    IF @current_wolves < FLOOR(@max_players * 0.2)
        RETURN 1;
    
    RETURN 2;
END;
GO
CREATE FUNCTION get_the_winner(@party_id INT)
RETURNS TABLE
AS
RETURN (
    SELECT TOP 1
        p.pseudo AS nom_du_joueur,
        r.description_role AS role,
        pr.title_party AS nom_de_la_partie,
        COUNT(DISTINCT t.id_turn) AS nombre_de_tours_joues,
        MAX(t.id_turn) AS nombre_total_de_tours,
        AVG(DATEDIFF(SECOND, pp.start_time, pp.end_time)) AS temps_moyen_decision
    FROM 
        players p
    JOIN players_in_parties pip ON p.id_player = pip.id_player
    JOIN roles r ON pip.id_role = r.id_role
    JOIN parties pr ON pip.id_party = pr.id_party
    JOIN turns t ON pr.id_party = t.id_party
    JOIN players_play pp ON p.id_player = pp.id_player AND t.id_turn = pp.id_turn
    WHERE 
        pr.id_party = @party_id
        AND pip.is_alive = 'Y'
    GROUP BY 
        p.pseudo, 
        r.description_role, 
        pr.title_party
);
