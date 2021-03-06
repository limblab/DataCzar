-- SQL commands to create  the LLSessionsDB --

CREATEDB LLSessionsDB;
CREATE TABLE sessions (
	monkey		text,	-- monkey name
	date		date,
	time		time,
implantID	text,
	task		text,
	sourceFile	text,
	cdsVersion	int,
	duration	interval,
	labNum		smallint,
	hasEMG		bool,
	hasLFP		bool,
	hasKin		bool,
	hasForce	bool,
	hasAnalog	bool,
	hasUnits	bool,
	isSorted	bool,
	numUnits	smallint,
	numSorted	smallint,
	numDualUnits	smallint,
	hasTriggers	bool,
	hasChaoticLoad	bool,
	hasBumps	bool,
	numTrials	smallint,
	numReward	smallint,
	numAbort	smallint,
	numFail		smallint,
	numIncomplete	smallint,
	sha256		varchar(64)
);


CREATE TABLE kin (
	monkey		text,
	date		date,
	time		time,
	label		text,
	nevSha256	varchar(64)
);


CREATE TABLE force (
	monkey		text,
	date		date,	
	time		time,
	label		text,
	nevSha256	varchar(64)
);


CREATE TABLE emg (
	monkey		text,
	date		date	
	time		time,
	label		text,
	nevSha256	varchar(64)
);



CREATE TABLE lfp (
	monkey		text,
	date		date	
	time		time,
	label		text,
	nevSha256	varchar(64)
);


CREATE TABLE units (
	monkey		text,
	date		date	
	time		time,
	label		text,
	nevSha256	varchar(64)
);



CREATE TABLE trials (
	monkey		text,
	date		date	
	time		time,
	label		text,
	nevSha256	varchar(64)
);


CREATE TABLE words (
	monkey		text,
	date		date	
	time		time,
	label		text,
	nevSha256	varchar(64)
);


CREATE TABLE databursts (
	monkey		text,
	date		date	
	time		time,
	label		text,
	nevSha256	varchar(64)
);



