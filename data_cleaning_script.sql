-- Automated Data Cleaning --

-- Identify duplicates (check before deciding whether to delete)
SELECT row_id, id, row_num
FROM (
	SELECT row_id, id,
		ROW_NUMBER() OVER (
			PARTITION BY id
			ORDER BY id) AS row_num
	FROM ushouseholdincome
) duplicates
WHERE row_num > 1;

-- Fixing some data quality issues by fixing typos and general standardization
UPDATE ushouseholdincome
SET State_Name = 'Georgia'
WHERE State_Name = 'georia';

UPDATE ushouseholdincome
SET County = UPPER(County);

UPDATE ushouseholdincome
SET City = UPPER(City);

UPDATE ushouseholdincome
SET Place = UPPER(Place);

UPDATE ushouseholdincome
SET State_Name = UPPER(State_Name);

UPDATE ushouseholdincome
SET `Type` = 'CDP'
WHERE `Type` = 'CPD';

UPDATE ushouseholdincome
SET `Type` = 'Borough'
WHERE `Type` = 'Boroughs';

DELIMITER $$
CREATE PROCEDURE Copy_and_clean_Data()
BEGIN
	CREATE TABLE IF NOT EXISTS `ushouseholdincome_cleaned` (
	  `row_id` int DEFAULT NULL,
	  `id` int DEFAULT NULL,
	  `State_Code` int DEFAULT NULL,
	  `State_Name` text,
	  `State_ab` text,
	  `County` text,
	  `City` text,
	  `Place` text,
	  `Type` text,
	  `Primary` text,
	  `Zip_Code` int DEFAULT NULL,
	  `Area_Code` int DEFAULT NULL,
	  `ALand` int DEFAULT NULL,
	  `AWater` int DEFAULT NULL,
	  `Lat` double DEFAULT NULL,
	  `Lon` double DEFAULT NULL,
	  `TimeStamp` TIMESTAMP DEFAULT NULL
	) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

	-- Copy data to new table
	INSERT INTO ushouseholdincome_cleaned
	SELECT *, CURRENT_TIMESTAMP
	FROM ushouseholdincome;
END $$
DELIMITER ;

CALL Copy_and_clean_Data();

SELECT COUNT(row_id)
FROM ushouseholdincome;

SELECT state_name, COUNT(state_name)
FROM ushouseholdincome
GROUP BY State_Name;

-- CREATE EVENT
CREATE EVENT run_data_cleaning
	ON SCHEDULE EVERY 1 YEAR
	DO CALL Copy_and_clean_Data();

-- CREATE TRIGGER
DELIMITER $$
CREATE TRIGGER Transfer_clean_data
	AFTER INSERT ON ushouseholdincome
	FOR EACH ROW
BEGIN
	CALL Copy_and_clean_Data();
END $$
DELIMITER ;