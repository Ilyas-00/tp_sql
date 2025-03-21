CREATE TRIGGER trg_complete_turn
ON turns
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF UPDATE(end_time)
    BEGIN
        DECLARE @id_turn INT, @id_party INT;
        
        SELECT @id_turn = id_turn, @id_party = id_party
        FROM inserted
        WHERE end_time IS NOT NULL;
        
        IF @id_turn IS NOT NULL
        BEGIN
            EXEC COMPLETE_TOUR @TOUR_ID = @id_turn, @PARTY_ID = @id_party;
        END
    END
END;
GO
CREATE TRIGGER trg_username_to_lower
ON players
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    EXEC USERNAME_TO_LOWER;
END;
