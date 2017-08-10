/*
Steven Han - steven.han@nbcuni.com
Final Project – Building Energy

1. Using MySQL Workbench, create a new database called BuildingEnergy. All of the work below should be completed 
in the BuildingEnergy database. The SQL script should be self-contained, such that if it runs again it will re-create the database.
*/

DROP SCHEMA IF EXISTS BuildingEnergy;

CREATE SCHEMA IF NOT EXISTS BuildingEnergy;

USE BuildingEnergy;

/*
2. You should first create two tables, EnergyCategories and EnergyTypes. Each energy category can have many energy types.
-- Populate the EnergyCategories table with rows for Fossil and Renewable.
-- Populate the EnergyTypes table with rows for Electricity, Gas, Steam, Fuel Oil, Solar, and Wind.
-- In the EnergyTypes table, you should indicate that Electricity, Gas, Steam, and Fuel Oil are Fossil 
energy sources, while Solar and Wind are renewable energy sources.
*/

DROP TABLE IF EXISTS EnergyCategories;
DROP TABLE IF EXISTS EnergyTypes;
DROP TABLE IF EXISTS Buildings;
DROP TABLE IF EXISTS BuildingInfo;
DROP VIEW IF EXISTS BuildingEnergy;

# Create EnergyCategories table

CREATE TABLE IF NOT EXISTS EnergyCategories
(
	category_id VARCHAR(30) NOT NULL,
    category_name VARCHAR(100) NOT NULL,
    PRIMARY KEY (category_id)
);

INSERT INTO EnergyCategories
(category_id, category_name)
VALUES
('426164', 'Fossil'),
('476f6f64', 'Renewable');

SELECT * FROM EnergyCategories;

# Create EnergyTypes table

CREATE TABLE IF NOT EXISTS EnergyTypes
(
	type_id VARCHAR(30) NOT NULL,
    type_name VARCHAR(100) NOT NULL,
    category_id VARCHAR(30),
    PRIMARY KEY (type_id),
    CONSTRAINT FOREIGN KEY (category_id)
    REFERENCES EnergyCategories(category_id)
    ON DELETE SET NULL
    ON UPDATE CASCADE
);

INSERT INTO EnergyTypes
(type_id, type_name, category_id)
VALUES
('456c63747263', 'Electricity', '426164'),
('476173', 'Gas', '426164'),
('537465616d', 'Steam', '426164'),
('4f696c', 'Fuel Oil', '426164'),
('536f6c6172', 'Solar', '476f6f64'),
('57696e64', 'Wind', '476f6f64');

SELECT * FROM EnergyTypes;

/*
3. Write a JOIN statement that shows the energy categories and associated energy types that you entered
*/ 
 
SELECT
Categories.category_name AS `Energy Category`,
IFNULL(type_name, 'No energy type assigned') AS `Energy Type`

FROM EnergyCategories AS Categories
LEFT JOIN EnergyTypes AS Energy
ON Categories.category_id = Energy.category_id

ORDER BY `Energy Type`;

/*
4. You should add a table called Buildings. There should be a many-to-many relationship between Buildings
and EnergyTypes. Here is the information that should be included about buildings in the database:
-- Empire State Building; Energy Types: Electricity, Gas, Steam
-- Chrysler Building; Energy Types: Electricity, Steam
-- Borough of Manhattan Community College; Energy Types: Electricity, Steam, Solar
*/

CREATE TABLE IF NOT EXISTS Buildings
(
	building_id VARCHAR(30) NOT NULL,
    building_name VARCHAR(100) NOT NULL,
    PRIMARY KEY (building_id)
);

INSERT INTO Buildings
(building_id, building_name)
VALUES
('456d70697265', 'Empire State Building'),
('43687279736c6572', 'Chrysler Building'),
('424d4343', 'Borough of Manhattan Community College');

SELECT * FROM Buildings;

CREATE TABLE IF NOT EXISTS BuildingInfo
(
	building_id VARCHAR(30) NOT NULL,
    type_id VARCHAR(30) NOT NULL,
    CONSTRAINT FOREIGN KEY (building_id)
    REFERENCES Buildings(building_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
    CONSTRAINT FOREIGN KEY (type_id)
    REFERENCES EnergyTypes(type_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

INSERT INTO BuildingInfo
(building_id, type_id)
VALUES
('456d70697265', '456c63747263'),
('456d70697265', '476173'),
('456d70697265', '537465616d'),
('43687279736c6572', '456c63747263'),
('43687279736c6572', '537465616d'),
('424d4343', '456c63747263'),
('424d4343', '537465616d'),
('424d4343', '536f6c6172');

SELECT * FROM BuildingInfo;

/*
5. Write a JOIN statement that shows the buildings and associated energy types for each building.
*/

SELECT
Buildings.building_name AS `Buildings`,
Energy.type_name AS `Energy Type`

FROM Buildings AS Buildings
INNER JOIN BuildingInfo AS Bridge
ON Buildings.building_id = Bridge.building_id
INNER JOIN EnergyTypes AS Energy
ON Bridge.type_id = Energy.type_id

ORDER BY `Buildings`;

/*
6. Please add this information to the BuildingEnergy database, inserting rows as needed in various tables.
Building: Bronx Lion House; Energy Types: Geothermal
Brooklyn Childrens Museum: Energy Types: Electricity, Geothermal
*/

INSERT INTO Buildings
(building_id, building_name)
VALUES
('4c696f6e', 'Bronx Lion House'),
('4d757365756d', 'Brooklyn Childrens Museum');

SELECT * FROM Buildings;

INSERT INTO EnergyTypes
(type_id, type_name, category_id)
VALUES
('475448524d4c', 'Geothermal', '476f6f64');

SELECT * FROM EnergyTypes;

INSERT INTO  BuildingInfo
(building_id, type_id)
VALUES
('4c696f6e', '475448524d4c'),
('4d757365756d', '456c63747263'),
('4d757365756d', '475448524d4c');

SELECT * FROM BuildingInfo;

/*
7. Write a SQL query that displays all of the buildings that use Renewable Energies.
*/

CREATE VIEW BuildingEnergy AS
(
SELECT 
Buildings.building_name AS `Buildings`,
Energy.type_name AS `Energy Type`,
Category.category_name AS `Energy Category`

FROM Buildings AS Buildings
INNER JOIN BuildingInfo AS Bridge
ON Buildings.building_id = Bridge.building_ID
INNER JOIN EnergyTypes AS Energy
ON Bridge.type_id = Energy.type_id
INNER JOIN EnergyCategories AS Category
ON Energy.category_id = Category.category_id
);

SELECT *
FROM BuildingEnergy
WHERE `Energy Category` = 'Renewable'
ORDER BY `Buildings`;

/*
8. Write a SQL query that shows the frequency with which energy types are used in various buildings
*/

SELECT
`Energy Type`,
COUNT(*) AS `Usage`

FROM BuildingEnergy

GROUP BY `Energy Type`

ORDER BY `Usage` DESC, `Energy Type`;

/*
9a. Create the appropriate foreign key constraints.

FOREIGN KEY CONSTRAINTS added to the EnergyTypes and BuildingInfo tables.

If a category is deleted from the EnergyCategories table, then the corresponding category ID in the EnergyTypes table is set as NULL. If
the category ID is updated in the EnergyCategories table, it is also updated witin the EnergyTypes table. 

If a building ID or energy type ID is deleted from the Buildings and EnergyTypes tables, respectively, then the row where that ID
is found in the BuildingInfo table is deleted. Likewise, if these IDs are updated, they are likewise updated within the BuildingInfo table.

9b. Create an entity relationship (ER) diagram for the tables in the database. You can sketch this by hand and
include a photo or scan if you wish.

9c. Suppose you wanted to design a set of HTML pages to manage (add, edit, and delete) the information in the
various database tables; create a mockup of the user interface (on paper or using a package like Balsamiq
Mockups).

9d. Suppose you want to track changes over time in energy type preferences in New York City buildings. What
information should you add to each table? What might a report that shows the trends over time look like?



*/