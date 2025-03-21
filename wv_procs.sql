CREATE PROCEDURE SEED_DATA
    @NB_PLAYERS INT,
    @PARTY_ID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @current_turn INT = 1;
    DECLARE @max_turns INT = 10; 
    DECLARE @start_time DATETIME = GETDATE();
    
    WHILE @current_turn <= @max_turns
    BEGIN
        INSERT INTO turns (id_turn, id_party, start_time, end_time)
        VALUES (
            @current_turn, 
            @PARTY_ID, 
            DATEADD(MINUTE, (@current_turn - 1) * 5, @start_time),
            DATEADD(MINUTE, @current_turn * 5, @start_time)
        );
        
        SET @current_turn = @current_turn + 1;
    END
END;
GO
CREATE PROCEDURE COMPLETE_TOUR
    @TOUR_ID INT,
    @PARTY_ID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    WITH move_conflicts AS (
        SELECT 
            pp1.id_player AS player1,
            pp2.id_player AS player2,
            pp1.target_position_col,
            pp1.target_position_row
        FROM 
            players_play pp1
        JOIN 
            players_play pp2 ON 
                pp1.id_turn = pp2.id_turn AND 
                pp1.id_player <> pp2.id_player AND
                pp1.target_position_col = pp2.target_position_col AND
                pp1.target_position_row = pp2.target_position_row
        WHERE 
            pp1.id_turn = @TOUR_ID
    )
    UPDATE pp
    SET action = 'invalid'
    FROM players_play pp
    JOIN move_conflicts mc ON 
        pp.id_player IN (mc.player1, mc.player2) AND
        pp.id_turn = @TOUR_ID;
    
    UPDATE pip
    SET is_alive = 'N'
    FROM players_in_parties pip
    JOIN players p ON pip.id_player = p.id_player
    JOIN (
        SELECT id_player 
        FROM players_play
        WHERE 
            id_turn = @TOUR_ID AND 
            EXISTS (
                SELECT 1 
                FROM players_play pp2 
                WHERE 
                    pp2.id_turn = @TOUR_ID AND 
                    pp2.id_player <> players_play.id_player AND
                    pp2.target_position_col = players_play.target_position_col AND
                    pp2.target_position_row = players_play.target_position_row
            )
    ) elimination_candidates ON pip.id_player = elimination_candidates.id_player
    WHERE pip.id_party = @PARTY_ID;
 
    UPDATE turns 
    SET end_time = GETDATE()
    WHERE id_turn = @TOUR_ID AND id_party = @PARTY_ID;
END;
GO
CREATE PROCEDURE USERNAME_TO_LOWER
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE players
    SET pseudo = LOWER(pseudo);
END;
