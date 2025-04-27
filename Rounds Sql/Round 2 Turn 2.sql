-- Set Uli's last roll to 4
UPDATE Player
SET last_roll = 4
WHERE name = 'Uli';

-- Move Uli to new location (Ali G - location_id 11)
UPDATE Player
SET current_location_id = 11
WHERE name = 'Uli';

-- Log Uli's move in the AuditTrail
INSERT INTO AuditTrail (round, player_id, location_id, credits)
VALUES (
    2, -- Round number
    (SELECT player_id FROM Player WHERE name = 'Uli'),
    11, -- Ali G location
    (SELECT credits FROM Player WHERE name = 'Uli')
);
