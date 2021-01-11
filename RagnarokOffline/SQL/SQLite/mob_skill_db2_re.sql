PRAGMA synchronous = OFF;
PRAGMA journal_mode = MEMORY;
BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS `mob_skill_db2_re` (
  `MOB_ID` integer NOT NULL
,  `INFO` text NOT NULL
,  `STATE` text NOT NULL
,  `SKILL_ID` integer NOT NULL
,  `SKILL_LV` integer NOT NULL
,  `RATE` integer NOT NULL
,  `CASTTIME` integer NOT NULL
,  `DELAY` integer NOT NULL
,  `CANCELABLE` text NOT NULL
,  `TARGET` text NOT NULL
,  `CONDITION` text NOT NULL
,  `CONDITION_VALUE` text
,  `VAL1` integer DEFAULT NULL
,  `VAL2` integer DEFAULT NULL
,  `VAL3` integer DEFAULT NULL
,  `VAL4` integer DEFAULT NULL
,  `VAL5` integer DEFAULT NULL
,  `EMOTION` text
,  `CHAT` text
);
END TRANSACTION;
