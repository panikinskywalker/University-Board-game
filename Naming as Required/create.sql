--Creating the Tables

--Creating Tables
--This is probably the boring bit

CREATE TABLE Token (
    token_id INTEGER PRIMARY KEY,
    token_name TEXT UNIQUE NOT NULL
);


CREATE TABLE Player (
    player_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    token_name TEXT NOT NULL,
    credits INTEGER DEFAULT 500 CHECK(credits >= 0),
    current_location_id INTEGER,
    suspension_status BOOLEAN DEFAULT 0,
    FOREIGN KEY (token_name) REFERENCES Token (token_name),
    FOREIGN KEY (current_location_id) REFERENCES Location (location_id)
);

-- Add last_roll column to store the last dice roll for each player
--I added this later as I coded because I realized how this could be used to my advantage
ALTER TABLE Player
ADD COLUMN last_roll INTEGER DEFAULT 0;


CREATE TABLE Location (
    location_id INTEGER PRIMARY KEY,
    location_name TEXT NOT NULL,
    location_type TEXT CHECK(location_type IN ('Corner', 'Building', 'Hearing', 'RAG'))
);

CREATE TABLE Building (
    building_id INTEGER PRIMARY KEY,
    building_name TEXT NOT NULL,
    tuition_fee INTEGER NOT NULL CHECK(tuition_fee > 0),
    color TEXT NOT NULL,
    owner_id INTEGER,
    location_id INTEGER UNIQUE,
    FOREIGN KEY (owner_id) REFERENCES Player (player_id),
    FOREIGN KEY (location_id) REFERENCES Location (location_id)
);

CREATE TABLE Specials (
    special_id INTEGER PRIMARY KEY,
    special_name TEXT NOT NULL,
    description TEXT NOT NULL,
    credits_change INTEGER DEFAULT 0,
    location_id INTEGER UNIQUE,
    FOREIGN KEY (location_id) REFERENCES Location (location_id)
);

CREATE TABLE AuditTrail (
    audit_id INTEGER PRIMARY KEY,
    round INTEGER NOT NULL,
    player_id INTEGER,
    location_id INTEGER,
    credits INTEGER,
    FOREIGN KEY (player_id) REFERENCES Player (player_id),
    FOREIGN KEY (location_id) REFERENCES Location (location_id)
);



-----------------------------------------
-----------Space for Triggers------------
-----------------------------------------

--Unowned Building Buy Trigger
--Trigger which makes it an obligation for a player to buy a building in case it does not have any owner
CREATE TRIGGER buy_unowned_building
AFTER UPDATE OF current_location_id ON Player
WHEN 
    (SELECT location_type FROM Location WHERE location_id = NEW.current_location_id) = 'Building' --if the player lands on a "Building" type location
    AND (SELECT owner_id FROM Building WHERE location_id = NEW.current_location_id) IS NULL -- Check if this building is unowned. If it's already claimed, no touching!
    AND NEW.last_roll != 6  -- Skip buying action if the last roll was 6
BEGIN
    --Basically to pay the amount, Deduct double the tuition fee from the player's credits
    UPDATE Player
    SET credits = credits - (2 * (SELECT tuition_fee FROM Building WHERE location_id = NEW.current_location_id))
    WHERE player_id = NEW.player_id;

     -- Now, to make it official – the player is the proud new owner of this building
    UPDATE Building
    SET owner_id = NEW.player_id
    WHERE location_id = NEW.current_location_id;

    -- Log the purchase in the AuditTrail, we are keeping tabs after all this is a bored game. Sorry board game.
    INSERT INTO AuditTrail (round, player_id, location_id, credits)
    VALUES (
        (SELECT IFNULL(MAX(round), 0) + 1 FROM AuditTrail),
        NEW.player_id,
        NEW.current_location_id,
        (SELECT credits FROM Player WHERE player_id = NEW.player_id)
    );
END;

-----------------------------------Trigger 2
-- Trigger: pay_tuition_fee
--The payment of tuition fee if there is a Owner on the Location on which the player has landed and it isn't themself

CREATE TRIGGER pay_tuition_fee
AFTER UPDATE OF current_location_id ON Player
WHEN 
    (SELECT location_type FROM Location WHERE location_id = NEW.current_location_id) = 'Building'
    AND (SELECT owner_id FROM Building WHERE location_id = NEW.current_location_id) IS NOT NULL -- Check that the building has an owner – we don't want to charge for an unowned building!
    AND (SELECT owner_id FROM Building WHERE location_id = NEW.current_location_id) != NEW.player_id  -- Make sure the player isn't the building's owner (no charging yourself, that’s just stupid?)
    AND NEW.last_roll != 6  -- Skip this whole tuition process if the last roll was a 6 – translation: Lucky.
BEGIN
    -- Calculate the standard tuition fee
    UPDATE Player
    SET credits = credits - (
        CASE
        -- Check if the owner holds all buildings of this color; if yes, double the tuition fee!
            WHEN (
                SELECT COUNT(*) FROM Building 
                WHERE color = (SELECT color FROM Building WHERE location_id = NEW.current_location_id)
                AND owner_id = (SELECT owner_id FROM Building WHERE location_id = NEW.current_location_id)
            ) = (
                SELECT COUNT(*) FROM Building 
                WHERE color = (SELECT color FROM Building WHERE location_id = NEW.current_location_id)
            )
            THEN 2 * (SELECT tuition_fee FROM Building WHERE location_id = NEW.current_location_id) --Double if all buildings with same colours are owned
            ELSE (SELECT tuition_fee FROM Building WHERE location_id = NEW.current_location_id) --single if not all buildings of the colour are owned
        END
    )
    WHERE player_id = NEW.player_id;

    -- Credit the building owner with the correct tuition amount
    UPDATE Player
    SET credits = credits + (
        CASE
            WHEN (
                SELECT COUNT(*) FROM Building 
                WHERE color = (SELECT color FROM Building WHERE location_id = NEW.current_location_id)
                AND owner_id = (SELECT owner_id FROM Building WHERE location_id = NEW.current_location_id)
            ) = (
                SELECT COUNT(*) FROM Building 
                WHERE color = (SELECT color FROM Building WHERE location_id = NEW.current_location_id)
            )
            THEN 2 * (SELECT tuition_fee FROM Building WHERE location_id = NEW.current_location_id)
            ELSE (SELECT tuition_fee FROM Building WHERE location_id = NEW.current_location_id)
        END
    )
    WHERE player_id = (SELECT owner_id FROM Building WHERE location_id = NEW.current_location_id);

    -- Log the payment in the AuditTrail, because I am a fan of keeping account of all transactions
    INSERT INTO AuditTrail (round, player_id, location_id, credits)
    VALUES (
        (SELECT IFNULL(MAX(round), 0) + 1 FROM AuditTrail),
        NEW.player_id,
        NEW.current_location_id,
        (SELECT credits FROM Player WHERE player_id = NEW.player_id)
    );
END;



-----------------------------------Trigger 3
-- Trigger: handle_special_location
-- Purpose: Adjust a player’s credits when they land on a special location like RAG or Hearing.
-- RAG locations give the player a bit of extra cash (just RAG1 though), while Hearings might dock a few credits.


CREATE TRIGGER handle_special_location
AFTER UPDATE OF current_location_id ON Player
WHEN 
    -- Trigger only if the player lands on a RAG or Hearing location
    (SELECT location_type FROM Location WHERE location_id = NEW.current_location_id) IN ('RAG', 'Hearing')
BEGIN
    -- Change the player's credits based on the effect at this special location
    UPDATE Player
    SET credits = credits + (
        -- Pull the effect (credits_change) from the Specials table for this location
        SELECT credits_change
        FROM Specials
        WHERE location_id = NEW.current_location_id
    )
    WHERE player_id = NEW.player_id;

    -- Log this special moment in the AuditTrail – because who doesn’t want credit for landing on RAG or surviving a Hearing?
    INSERT INTO AuditTrail (round, player_id, location_id, credits)
    VALUES (
        (SELECT IFNULL(MAX(round), 0) + 1 FROM AuditTrail),  -- Move to the next round in the log
        NEW.player_id,                                       -- The player who just hit the special location
        NEW.current_location_id,                             -- Location of the special spot
        (SELECT credits FROM Player WHERE player_id = NEW.player_id) -- Updated credit balance after the change
    );
END;




-----------------------------------Trigger 4
-- Trigger: youre_suspended
-- Purpose: When a player lands on “You’re Suspended!”, they’re sent directly to Suspension (location 8).
--          They won’t pass “Go” and certainly won’t collect 100 credits! (This is super important)

CREATE TRIGGER youre_suspended
AFTER UPDATE OF current_location_id ON Player
WHEN NEW.current_location_id = 18 -- Location 18 is the dreaded "You're Suspended!"
BEGIN
    -- Send the player straight to the Suspension location (Location 8)
    UPDATE Player
    SET current_location_id = 8,  -- Set location to Suspension (no detours allowed!)
        suspension_status = 1     -- Flag the player as suspended
    WHERE player_id = NEW.player_id;

    -- Record this unfortunate event in the AuditTrail (so we don’t forget their brush with suspension)
    INSERT INTO AuditTrail (round, player_id, location_id, credits)
    VALUES (
        (SELECT IFNULL(MAX(round), 0) + 1 FROM AuditTrail),  -- Increment to the next round in the log
        NEW.player_id,                                       -- Suspended player’s ID
        8,                                                  -- Location ID for Suspension
        (SELECT credits FROM Player WHERE player_id = NEW.player_id) -- Current credits (unchanged here)
    );
END;






-----------------------------------Trigger 4
-- Trigger: pass_welcome_week
-- Purpose: Give players a 100-credit boost every time they pass or land on "Welcome Week" (unless they’re in Suspension – no freebies there!).

CREATE TRIGGER pass_welcome_week
AFTER UPDATE OF current_location_id ON Player
WHEN 
    -- Trigger this only if the player reaches Location 1 (Welcome Week) or crosses it
    (NEW.current_location_id = 1 OR NEW.current_location_id < OLD.current_location_id)
    AND NEW.suspension_status = 0 -- No bonus if the player is suspended (they need to learn their lesson)
BEGIN
    -- Sweet! Player gets 100 credits for their journey around the board
    UPDATE Player
    SET credits = credits + 100
    WHERE player_id = NEW.player_id;

    -- Log this delightful event in the AuditTrail – everyone likes to see a bonus!
    INSERT INTO AuditTrail (round, player_id, location_id, credits)
    VALUES (
        (SELECT IFNULL(MAX(round), 0) + 1 FROM AuditTrail),  -- Increment to the next round
        NEW.player_id,                                       -- The lucky player’s ID
        NEW.current_location_id,                             -- The location (Welcome Week)
        (SELECT credits FROM Player WHERE player_id = NEW.player_id) -- Updated credit balance after the bonus
    );
END;
