UPDATE Player
SET last_roll = 6
WHERE name = 'Ruth';

-- Move Ruth to new location (Library - location_id 15)
UPDATE Player
SET current_location_id = 15
WHERE name = 'Ruth';

-- Log Ruth's first move in the AuditTrail (no action due to roll of 6)
INSERT INTO AuditTrail (round, player_id, location_id, credits)
VALUES (
    2, -- Round number
    (SELECT player_id FROM Player WHERE name = 'Ruth'),
    15, -- Library location
    (SELECT credits FROM Player WHERE name = 'Ruth')
);


UPDATE Player
SET last_roll = 1
WHERE name = 'Ruth';

-- Move Ruth to new location (Sam Alex - location_id 16) without any further action
UPDATE Player
SET current_location_id = 16
WHERE name = 'Ruth';

