-- Set Pradyumn's first roll to 6
UPDATE Player
SET last_roll = 6
WHERE name = 'Pradyumn';

-- Move Pradyumn to new location (Shopping Precinct - location_id 12)
UPDATE Player
SET current_location_id = 12
WHERE name = 'Pradyumn';

-- Log Pradyumn's move in the AuditTrail (no action on this location)
INSERT INTO AuditTrail (round, player_id, location_id, credits)
VALUES (
    1, -- Round number
    (SELECT player_id FROM Player WHERE name = 'Pradyumn'),
    12, -- Shopping Precinct location
    (SELECT credits FROM Player WHERE name = 'Pradyumn')
);

-- Set Pradyumn's second roll to 4
UPDATE Player
SET last_roll = 4
WHERE name = 'Pradyumn';

-- Move Pradyumn to new location (Sam Alex - location_id 16)
UPDATE Player
SET current_location_id = 16
WHERE name = 'Pradyumn';



