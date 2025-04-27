-- Set Pradyumn's last roll to 2
UPDATE Player
SET last_roll = 2
WHERE name = 'Pradyumn';

-- Move Pradyumn to "Suspension" (location_id 8) and set suspension status without awarding Welcome Week credits
UPDATE Player
SET current_location_id = 8, suspension_status = 1
WHERE name = 'Pradyumn';

-- Log Pradyumn's move in the AuditTrail
INSERT INTO AuditTrail (round, player_id, location_id, credits)
VALUES (
    2, -- Round number
    (SELECT player_id FROM Player WHERE name = 'Pradyumn'),
    8, -- Suspension location
    (SELECT credits FROM Player WHERE name = 'Pradyumn')  -- No additional credits awarded
);
