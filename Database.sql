CREATE Database Milestone2

GO


CREATE PROC createAllTables 
AS

CREATE TABLE SystemUser(
username Varchar(20) PRIMARY KEY ,
Password Varchar(20),
);


CREATE TABLE Stadium(
ID int PRIMARY KEY IDENTITY,
Capacity int,
Status bit,
Name Varchar(20),
Location Varchar(20),
);

CREATE TABLE StadiumManager(
ID int PRIMARY KEY IDENTITY,
Name Varchar(20),
username Varchar(20) FOREIGN KEY REFERENCES SystemUser(username),
Manager_ID int FOREIGN KEY REFERENCES Stadium(ID),
);


CREATE TABLE Club(
ID int PRIMARY KEY IDENTITY,
Name Varchar(20),
Location Varchar(20),
);

CREATE TABLE ClubRepresentative(
ID int PRIMARY KEY IDENTITY,
Name Varchar(20),
username Varchar(20) FOREIGN KEY REFERENCES SystemUser(username),
Club_ID int FOREIGN KEY REFERENCES Club(ID),
);

CREATE TABLE Match(
ID int PRIMARY KEY IDENTITY,
StartTime datetime,
Stadium_ID int FOREIGN KEY REFERENCES Stadium(ID),
HostClub_ID int FOREIGN KEY REFERENCES Club(ID),
GuestClub_ID int FOREIGN KEY REFERENCES Club(ID),
);


CREATE TABLE HostRequest(
ID int PRIMARY KEY IDENTITY,
Match_ID Varchar(20),
Status Varchar,
StadiumManager_ID int FOREIGN KEY REFERENCES StadiumManager(ID),
ClubRepresentative_ID int FOREIGN KEY REFERENCES ClubRepresentative(ID),
);

CREATE TABLE Fan(
NationalID int PRIMARY KEY,
BirthDate datetime,
Status bit,
Address Varchar(20),
Name Varchar(20),
PhoneNo Varchar(20), 
username Varchar(20) FOREIGN KEY REFERENCES SystemUser(username),
);

CREATE TABLE Ticket(
ID int PRIMARY KEY IDENTITY,
Status bit,
Fan_ID int FOREIGN KEY REFERENCES Fan(NationalID),
Match_ID int FOREIGN KEY REFERENCES Match(ID),
);

CREATE TABLE SystemAdmin(
ID int PRIMARY KEY IDENTITY, 
Name Varchar(20),
username Varchar(20) FOREIGN KEY REFERENCES SystemUser(username),
);

CREATE TABLE SportsAssociationManager(
ID int PRIMARY KEY IDENTITY,
Name Varchar(20),
username Varchar(20) FOREIGN KEY REFERENCES SystemUser(username),
Password varchar(20),
);
GO
EXEC createAllTables
GO


CREATE PROC dropAllTables

AS

DROP TABLE SportsAssociationManager

DROP TABLE SystemAdmin

DROP TABLE Ticket

DROP TABLE Fan

DROP TABLE HostRequest

DROP TABLE Match

DROP TABLE ClubRepresentative

DROP TABLE Club

DROP TABLE StadiumManager

DROP TABLE Stadium

DROP TABLE SystemUser
GO
EXEC dropAllTables
GO


CREATE PROC clearAllTables

AS

TRUNCATE TABLE SystemUser

TRUNCATE TABLE StadiumManager

TRUNCATE TABLE ClubRepresentative

TRUNCATE TABLE Fan

TRUNCATE TABLE SportsAssociationManager

TRUNCATE TABLE SystemAdmin

TRUNCATE TABLE Stadium

TRUNCATE TABLE HostRequest

TRUNCATE TABLE Club

TRUNCATE TABLE Match

TRUNCATE TABLE Ticket
GO
EXEC clearAllTables
GO


CREATE PROC dropAllProceduresFunctionsViews

AS

DROP PROCEDURE createAllTables

DROP PROCEDURE dropAllTables

DROP PROCEDURE clearAllTables

DROP VIEW allAssocManagers

DROP VIEW allClubRepresentatives

DROP VIEW allStadiumManagers

DROP VIEW allFans

DROP VIEW allMatches

DROP VIEW allTickets

DROP VIEW allCLubs

DROP VIEW allStadiums

DROP VIEW allRequests

DROP PROCEDURE addAssociationManager

DROP PROCEDURE addNewMatch

DROP VIEW clubsWithNoMatches

DROP PROCEDURE deleteMatch

DROP PROCEDURE deleteMatchesOnStadium

DROP PROCEDURE addClub

DROP PROCEDURE addTicket

DROP PROCEDURE deleteClub

DROP PROCEDURE addStadium

DROP PROCEDURE deleteStadium

DROP PROCEDURE blockFan

DROP PROCEDURE unblockFan

DROP PROCEDURE addRepresentative

DROP FUNCTION viewAvailableStadiumsOn

DROP PROCEDURE addHostRequest

DROP FUNCTION allUnassignedMatches

DROP PROCEDURE addStadiumManager

DROP FUNCTION allPendingRequests

DROP PROCEDURE acceptRequest

DROP PROCEDURE rejectRequest

DROP PROCEDURE addFan

DROP FUNCTION upcomingMatchesOfClub

DROP FUNCTION availableMatchesToAttend

DROP PROCEDURE purchaseTicket

DROP PROCEDURE updateMatchHost

DROP PROCEDURE deleteMatchesOnStadium

DROP VIEW matchesPerTeam

DROP VIEW clubsNeverMatched

DROP FUNCTION clubsNeverPlayed

DROP FUNCTION matchWithHighestAttendance

DROP FUNCTION matchesRankedByAttendance

DROP FUNCTION requestsFromClub
GO
EXEC dropAllProceduresFunctionsViews
GO

CREATE PROC addAssociationManager
@AssociationManager varchar(20),
@username varchar(20),
@password varchar(20)
AS
INSERT INTO SportsAssociationManager
VALUES(@AssociationManager,@username,@password);
GO

CREATE FUNCTION [getclub_stadiumID]
(@clubname VARCHAR(20))
Returns VARCHAR(20)
AS
BEGIN
DECLARE @stadiumID VARCHAR(20)
SELECT @stadiumID = S.ID
FROM Stadium s, Club c
WHERE c.name = @clubname AND s.Location = c.Location
Return @stadiumID
END
GO

CREATE PROC addNewMatch
@club1 varchar(20),
@club2 varchar(20),
@hostname varchar(20),
@time datetime
AS 
IF @hostname = @club1
BEGIN
INSERT INTO Match
VALUES(@time,dbo.getclub_stadiumID(@hostname),@club1,@club2);
END
ELSE 
BEGIN 
INSERT INTO Match
VALUES(@time,dbo.club_stadiumID(@hostname),@club2,@club1);
END
GO

CREATE VIEW clubsWithNoMatches AS
SELECT c.name 
FROM Club c
WHERE c.name NOT IN (SELECT c1.name
					 FROM Club c1, Match m
					 WHERE c1.ID = m.HostClub_Id OR c1.ID = m.GuestClub_ID);
GO

CREATE FUNCTION [getclub_ID]
(@club VARCHAR(20))
Returns int
AS
BEGIN
DECLARE @clubid int
SELECT @clubid = ID
FROM Club
WHERE @club = name
RETURN @clubid
END
GO


CREATE PROC deleteMatch
@club1 varchar(20),
@club2 varchar(20),
@hostclub VARCHAR(20)
AS
IF @hostname = @club1
BEGIN
DELETE FROM Match
WHERE HostClub_ID = dbo.getclub_ID(@club1) AND GuestClub_ID = dbo.getclub_ID(@club2)
END
ELSE 
BEGIN 
DELETE FROM Match
WHERE HostClub_ID = dbo.getclub_ID(@club1) AND GuestClub_ID = dbo.getclub_ID(@club2)
END
GO

CREATE PROC deleteMatchesOnStadium
@stadium VARCHAR(20)
AS 
DELEtE FROM Match 
WHERE Stadium_ID = (SELECT ID FROM Stadium WHERE @stadium = name) AND GETDATE() < StartTime;
GO

CREATE PROC addClub
@club VARCHAR(20),
@clublocation VARCHAR(20)
AS
INSERT INTO Club
Values(@club,@clublocation)
Go

CREATE FUNCTION [getmatch_ID]
(@hostclub varchar(20),
@guestclub varchar(20),
@datetime datetime)
Returns int
AS
BEGIN
DECLARE @matchid int
SELECT @matchid = ID 
FROM Match 
WHERE HostClub_ID = dbo.getclub_ID(@hostclub) AND GuestClub_ID = dbo.getclub_ID(@guestclub) AND StartTime = @datetime
RETURN @matchid
END
Go

CREATE PROC addTicket
@hostclub varchar(20),
@guestclub varchar(20),
@datetime datetime
AS
INSERT INTO Ticket(Match_ID)
VALUES(dbo.getmatch_ID(@hostclub,@guestclub,@datetime))
GO

CREATE PROC deleteClub
@club VARCHAR(20)
AS
DELETE FROM Club
WHERE name = @club
GO

CREATE PROC addStadium
@stadium VARCHAR(20),
@location VARCHAR(20),
@capacity int
AS
INSERT INTO Stadium(Capacity,Name,Location)
VALUES(@capacity,@stadium,@location)
GO

CREATE PROC deleteStadium
@stadium VARCHAR(20)
AS
DELETE FROM Stadium
WHERE name = @stadium
GO

