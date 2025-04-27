DROP VIEW IF EXISTS leaderboard;

CREATE VIEW leaderboard AS
SELECT 
    p.name AS name,
    
    -- Show "suspension" if suspension_status is 1, otherwise display the location in snake_case
    CASE 
        WHEN p.suspension_status = 1 THEN 'suspension'
        ELSE LOWER(REPLACE(REPLACE(REPLACE(REPLACE(l.location_name, ' ', '_'), "'", ''), '&', 'and'), ',', ''))
    END AS location,
    
    -- Player's credits
    p.credits AS credits,
    
    -- Concatenate buildings owned by the player in snake_case, in clockwise order from Welcome Week
    (
        SELECT GROUP_CONCAT(
            LOWER(REPLACE(REPLACE(REPLACE(REPLACE(b.building_name, ' ', '_'), "'", ''), '&', 'and'), ',', '')), ', ') 
        FROM Building b
        JOIN Location loc ON b.location_id = loc.location_id
        WHERE b.owner_id = p.player_id
        ORDER BY loc.location_id
    ) AS buildings,
    
    -- Calculate net worth as credits + total purchase price of owned properties
    p.credits + COALESCE((SELECT SUM(2 * b.tuition_fee) FROM Building b WHERE b.owner_id = p.player_id), 0) AS net_worth

FROM Player p
JOIN Location l ON p.current_location_id = l.location_id

-- Order by net worth and credits as a secondary sort
ORDER BY net_worth DESC, credits DESC;
