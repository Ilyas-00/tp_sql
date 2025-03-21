CREATE INDEX idx_players_pseudo ON players(pseudo);
CREATE INDEX idx_players_registration_date ON players(registration_date);

CREATE INDEX idx_parties_status ON parties(game_status);
CREATE INDEX idx_parties_start_time ON parties(game_start_time);

CREATE INDEX idx_players_in_parties_alive ON players_in_parties(is_alive);

CREATE INDEX idx_turns_party ON turns(id_party);
CREATE INDEX idx_turns_status ON turns(turn_status);

CREATE INDEX idx_players_play_turn ON players_play(id_turn);
CREATE INDEX idx_players_play_action ON players_play(action);
CREATE INDEX idx_players_play_status ON players_play(action_status);
