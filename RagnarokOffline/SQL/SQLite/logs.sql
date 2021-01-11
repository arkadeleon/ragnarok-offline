PRAGMA synchronous = OFF;
PRAGMA journal_mode = MEMORY;
BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS `atcommandlog` (
  `atcommand_id` integer  NOT NULL PRIMARY KEY AUTOINCREMENT
,  `atcommand_date` datetime NOT NULL
,  `account_id` integer  NOT NULL default '0'
,  `char_id` integer  NOT NULL default '0'
,  `char_name` varchar(25) NOT NULL default ''
,  `map` varchar(11) NOT NULL default ''
,  `command` varchar(255) NOT NULL default ''
,  INDEX (`account_id`)
,  INDEX (`char_id`)
);
CREATE TABLE IF NOT EXISTS `branchlog` (
  `branch_id` integer  NOT NULL PRIMARY KEY AUTOINCREMENT
,  `branch_date` datetime NOT NULL
,  `account_id` integer NOT NULL default '0'
,  `char_id` integer NOT NULL default '0'
,  `char_name` varchar(25) NOT NULL default ''
,  `map` varchar(11) NOT NULL default ''
,  INDEX (`account_id`)
,  INDEX (`char_id`)
);
CREATE TABLE IF NOT EXISTS `cashlog` (
  `id` integer NOT NULL PRIMARY KEY AUTOINCREMENT
,  `time` datetime NOT NULL
,  `char_id` integer NOT NULL DEFAULT '0'
,  `type` text  NOT NULL DEFAULT 'S'
,  `cash_type` text  NOT NULL DEFAULT 'O'
,  `amount` integer NOT NULL DEFAULT '0'
,  `map` varchar(11) NOT NULL DEFAULT ''
,  INDEX `type` (`type`)
);
CREATE TABLE IF NOT EXISTS `chatlog` (
  `id` integer NOT NULL PRIMARY KEY AUTOINCREMENT
,  `time` datetime NOT NULL
,  `type` text  NOT NULL default 'O'
,  `type_id` integer NOT NULL default '0'
,  `src_charid` integer NOT NULL default '0'
,  `src_accountid` integer NOT NULL default '0'
,  `src_map` varchar(11) NOT NULL default ''
,  `src_map_x` integer NOT NULL default '0'
,  `src_map_y` integer NOT NULL default '0'
,  `dst_charname` varchar(25) NOT NULL default ''
,  `message` varchar(150) NOT NULL default ''
,  INDEX (`src_accountid`)
,  INDEX (`src_charid`)
);
CREATE TABLE IF NOT EXISTS `feedinglog` (
  `id` integer NOT NULL PRIMARY KEY AUTOINCREMENT
,  `time` DATETIME NOT NULL
,  `char_id` integer NOT NULL
,  `target_id` integer NOT NULL
,  `target_class` integer NOT NULL
,  `type` text  NOT NULL, -- P: Pet, H: Homunculus, O: Other
,  `intimacy` integer  NOT NULL
,  `item_id` integer  NOT NULL
,  `map` VARCHAR(11) NOT NULL
,  `x` integer  NOT NULL
,  `y` integer  NOT NULL
);
CREATE TABLE IF NOT EXISTS `loginlog` (
  `time` datetime NOT NULL
,  `ip` varchar(15) NOT NULL default ''
,  `user` varchar(23) NOT NULL default ''
,  `rcode` integer NOT NULL default '0'
,  `log` varchar(255) NOT NULL default ''
,  INDEX (`ip`)
);
CREATE TABLE IF NOT EXISTS `mvplog` (
  `mvp_id` integer  NOT NULL PRIMARY KEY AUTOINCREMENT
,  `mvp_date` datetime NOT NULL
,  `kill_char_id` integer NOT NULL default '0'
,  `monster_id` integer NOT NULL default '0'
,  `prize` integer  NOT NULL default '0'
,  `mvpexp` integer  NOT NULL default '0'
,  `map` varchar(11) NOT NULL default ''
);
CREATE TABLE IF NOT EXISTS `npclog` (
  `npc_id` integer  NOT NULL PRIMARY KEY AUTOINCREMENT
,  `npc_date` datetime NOT NULL
,  `account_id` integer  NOT NULL default '0'
,  `char_id` integer  NOT NULL default '0'
,  `char_name` varchar(25) NOT NULL default ''
,  `map` varchar(11) NOT NULL default ''
,  `mes` varchar(255) NOT NULL default ''
,  INDEX (`account_id`)
,  INDEX (`char_id`)
);
CREATE TABLE IF NOT EXISTS `picklog` (
  `id` integer NOT NULL PRIMARY KEY AUTOINCREMENT
,  `time` datetime NOT NULL
,  `char_id` integer NOT NULL default '0'
,  `type` text  NOT NULL default 'P'
,  `nameid` integer  NOT NULL default '0'
,  `amount` integer NOT NULL default '1'
,  `refine` integer  NOT NULL default '0'
,  `card0` integer  NOT NULL default '0'
,  `card1` integer  NOT NULL default '0'
,  `card2` integer  NOT NULL default '0'
,  `card3` integer  NOT NULL default '0'
,  `option_id0` integer NOT NULL default '0'
,  `option_val0` integer NOT NULL default '0'
,  `option_parm0` integer NOT NULL default '0'
,  `option_id1` integer NOT NULL default '0'
,  `option_val1` integer NOT NULL default '0'
,  `option_parm1` integer NOT NULL default '0'
,  `option_id2` integer NOT NULL default '0'
,  `option_val2` integer NOT NULL default '0'
,  `option_parm2` integer NOT NULL default '0'
,  `option_id3` integer NOT NULL default '0'
,  `option_val3` integer NOT NULL default '0'
,  `option_parm3` integer NOT NULL default '0'
,  `option_id4` integer NOT NULL default '0'
,  `option_val4` integer NOT NULL default '0'
,  `option_parm4` integer NOT NULL default '0'
,  `unique_id` integer  NOT NULL default '0'
,  `map` varchar(11) NOT NULL default ''
,  `bound` integer  NOT NULL default '0'
,  INDEX (`type`)
);
CREATE TABLE IF NOT EXISTS `zenylog` (
  `id` integer NOT NULL PRIMARY KEY AUTOINCREMENT
,  `time` datetime NOT NULL
,  `char_id` integer NOT NULL default '0'
,  `src_id` integer NOT NULL default '0'
,  `type` text  NOT NULL default 'S'
,  `amount` integer NOT NULL default '0'
,  `map` varchar(11) NOT NULL default ''
,  INDEX (`type`)
);
END TRANSACTION;
