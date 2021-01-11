PRAGMA synchronous = OFF;
PRAGMA journal_mode = MEMORY;
BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS `acc_reg_num` (
  `account_id` integer  NOT NULL default '0'
,  `key` varchar(32) binary NOT NULL default ''
,  `index` integer  NOT NULL default '0'
,  `value` integer NOT NULL default '0'
,  PRIMARY KEY (`account_id`,`key`,`index`)
);
CREATE TABLE IF NOT EXISTS `acc_reg_str` (
  `account_id` integer  NOT NULL default '0'
,  `key` varchar(32) binary NOT NULL default ''
,  `index` integer  NOT NULL default '0'
,  `value` varchar(254) NOT NULL default '0'
,  PRIMARY KEY (`account_id`,`key`,`index`)
);
CREATE TABLE IF NOT EXISTS `achievement` (
  `char_id` integer  NOT NULL default '0'
,  `id` integer  NOT NULL
,  `count1` integer  NOT NULL default '0'
,  `count2` integer  NOT NULL default '0'
,  `count3` integer  NOT NULL default '0'
,  `count4` integer  NOT NULL default '0'
,  `count5` integer  NOT NULL default '0'
,  `count6` integer  NOT NULL default '0'
,  `count7` integer  NOT NULL default '0'
,  `count8` integer  NOT NULL default '0'
,  `count9` integer  NOT NULL default '0'
,  `count10` integer  NOT NULL default '0'
,  `completed` datetime
,  `rewarded` datetime
,  PRIMARY KEY (`char_id`,`id`)
);
CREATE TABLE IF NOT EXISTS `auction` (
  `auction_id` integer  NOT NULL PRIMARY KEY AUTOINCREMENT
,  `seller_id` integer  NOT NULL default '0'
,  `seller_name` varchar(30) NOT NULL default ''
,  `buyer_id` integer  NOT NULL default '0'
,  `buyer_name` varchar(30) NOT NULL default ''
,  `price` integer  NOT NULL default '0'
,  `buynow` integer  NOT NULL default '0'
,  `hours` integer NOT NULL default '0'
,  `timestamp` integer  NOT NULL default '0'
,  `nameid` integer  NOT NULL default '0'
,  `item_name` varchar(50) NOT NULL default ''
,  `type` integer NOT NULL default '0'
,  `refine` integer  NOT NULL default '0'
,  `attribute` integer  NOT NULL default '0'
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
,  `enchantgrade` integer  NOT NULL default '0'
);
CREATE TABLE IF NOT EXISTS `db_roulette` (
  `index` integer NOT NULL default '0'
,  `level` integer  NOT NULL
,  `item_id` integer  NOT NULL
,  `amount` integer  NOT NULL DEFAULT '1'
,  `flag` integer  NOT NULL DEFAULT '1'
,  PRIMARY KEY (`index`)
);
CREATE TABLE IF NOT EXISTS `bonus_script` (
  `char_id` integer  NOT NULL
,  `script` TEXT NOT NULL
,  `tick` integer NOT NULL DEFAULT '0'
,  `flag` integer  NOT NULL DEFAULT '0'
,  `type` integer  NOT NULL DEFAULT '0'
,  `icon` integer NOT NULL DEFAULT '-1'
,  PRIMARY KEY (`char_id`, `type`)
);
CREATE TABLE IF NOT EXISTS `buyingstore_items` (
  `buyingstore_id` integer  NOT NULL
,  `index` integer  NOT NULL
,  `item_id` integer  NOT NULL
,  `amount` integer  NOT NULL
,  `price` integer  NOT NULL
,  PRIMARY KEY (`buyingstore_id`, `index`)
);
CREATE TABLE IF NOT EXISTS `buyingstores` (
  `id` integer  NOT NULL
,  `account_id` integer  NOT NULL
,  `char_id` integer  NOT NULL
,  `sex` text  NOT NULL DEFAULT 'M'
,  `map` varchar(20) NOT NULL
,  `x` integer  NOT NULL
,  `y` integer  NOT NULL
,  `title` varchar(80) NOT NULL
,  `limit` integer  NOT NULL
,  `body_direction` CHAR( 1 ) NOT NULL DEFAULT '4'
,  `head_direction` CHAR( 1 ) NOT NULL DEFAULT '0'
,  `sit` CHAR( 1 ) NOT NULL DEFAULT '1'
,  `autotrade` integer NOT NULL
,  PRIMARY KEY (`id`)
);
CREATE TABLE IF NOT EXISTS `cart_inventory` (
  `id` integer NOT NULL PRIMARY KEY AUTOINCREMENT
,  `char_id` integer NOT NULL default '0'
,  `nameid` integer  NOT NULL default '0'
,  `amount` integer NOT NULL default '0'
,  `equip` integer  NOT NULL default '0'
,  `identify` integer NOT NULL default '0'
,  `refine` integer  NOT NULL default '0'
,  `attribute` integer NOT NULL default '0'
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
,  `expire_time` integer  NOT NULL default '0'
,  `bound` integer  NOT NULL default '0'
,  `unique_id` integer  NOT NULL default '0'
,  `enchantgrade` integer  NOT NULL default '0'
);
CREATE TABLE IF NOT EXISTS `char` (
  `char_id` integer  NOT NULL PRIMARY KEY AUTOINCREMENT
,  `account_id` integer  NOT NULL default '0'
,  `char_num` integer NOT NULL default '0'
,  `name` varchar(30) NOT NULL DEFAULT ''
,  `class` integer  NOT NULL default '0'
,  `base_level` integer  NOT NULL default '1'
,  `job_level` integer  NOT NULL default '1'
,  `base_exp` integer  NOT NULL default '0'
,  `job_exp` integer  NOT NULL default '0'
,  `zeny` integer  NOT NULL default '0'
,  `str` integer  NOT NULL default '0'
,  `agi` integer  NOT NULL default '0'
,  `vit` integer  NOT NULL default '0'
,  `int` integer  NOT NULL default '0'
,  `dex` integer  NOT NULL default '0'
,  `luk` integer  NOT NULL default '0'
,  `max_hp` integer  NOT NULL default '0'
,  `hp` integer  NOT NULL default '0'
,  `max_sp` integer  NOT NULL default '0'
,  `sp` integer  NOT NULL default '0'
,  `status_point` integer  NOT NULL default '0'
,  `skill_point` integer  NOT NULL default '0'
,  `option` integer NOT NULL default '0'
,  `karma` integer NOT NULL default '0'
,  `manner` integer NOT NULL default '0'
,  `party_id` integer  NOT NULL default '0'
,  `guild_id` integer  NOT NULL default '0'
,  `pet_id` integer  NOT NULL default '0'
,  `homun_id` integer  NOT NULL default '0'
,  `elemental_id` integer  NOT NULL default '0'
,  `hair` integer  NOT NULL default '0'
,  `hair_color` integer  NOT NULL default '0'
,  `clothes_color` integer  NOT NULL default '0'
,  `body` integer  NOT NULL default '0'
,  `weapon` integer  NOT NULL default '0'
,  `shield` integer  NOT NULL default '0'
,  `head_top` integer  NOT NULL default '0'
,  `head_mid` integer  NOT NULL default '0'
,  `head_bottom` integer  NOT NULL default '0'
,  `robe` integer  NOT NULL DEFAULT '0'
,  `last_map` varchar(11) NOT NULL default ''
,  `last_x` integer  NOT NULL default '53'
,  `last_y` integer  NOT NULL default '111'
,  `save_map` varchar(11) NOT NULL default ''
,  `save_x` integer  NOT NULL default '53'
,  `save_y` integer  NOT NULL default '111'
,  `partner_id` integer  NOT NULL default '0'
,  `online` integer NOT NULL default '0'
,  `father` integer  NOT NULL default '0'
,  `mother` integer  NOT NULL default '0'
,  `child` integer  NOT NULL default '0'
,  `fame` integer  NOT NULL default '0'
,  `rename` integer  NOT NULL default '0'
,  `delete_date` integer  NOT NULL DEFAULT '0'
,  `moves` integer  NOT NULL DEFAULT '0'
,  `unban_time` integer  NOT NULL default '0'
,  `font` integer  NOT NULL default '0'
,  `uniqueitem_counter` integer  NOT NULL default '0'
,  `sex` text  NOT NULL
,  `hotkey_rowshift` integer  NOT NULL default '0'
,  `hotkey_rowshift2` integer  NOT NULL default '0'
,  `clan_id` integer  NOT NULL default '0'
,  `last_login` datetime DEFAULT NULL
,  `title_id` integer  NOT NULL default '0'
,  `show_equip` integer  NOT NULL default '0'
,  UNIQUE (`name`)
);
CREATE TABLE IF NOT EXISTS `char_reg_num` (
  `char_id` integer  NOT NULL default '0'
,  `key` varchar(32) binary NOT NULL default ''
,  `index` integer  NOT NULL default '0'
,  `value` integer NOT NULL default '0'
,  PRIMARY KEY (`char_id`,`key`,`index`)
);
CREATE TABLE IF NOT EXISTS `char_reg_str` (
  `char_id` integer  NOT NULL default '0'
,  `key` varchar(32) binary NOT NULL default ''
,  `index` integer  NOT NULL default '0'
,  `value` varchar(254) NOT NULL default '0'
,  PRIMARY KEY (`char_id`,`key`,`index`)
);
CREATE TABLE IF NOT EXISTS `charlog` (
  `id` integer  NOT NULL PRIMARY KEY AUTOINCREMENT
,  `time` datetime NOT NULL
,  `char_msg` varchar(255) NOT NULL default 'char select'
,  `account_id` integer NOT NULL default '0'
,  `char_num` integer NOT NULL default '0'
,  `name` varchar(23) NOT NULL default ''
,  `str` integer  NOT NULL default '0'
,  `agi` integer  NOT NULL default '0'
,  `vit` integer  NOT NULL default '0'
,  `int` integer  NOT NULL default '0'
,  `dex` integer  NOT NULL default '0'
,  `luk` integer  NOT NULL default '0'
,  `hair` integer NOT NULL default '0'
,  `hair_color` integer NOT NULL default '0'
);
CREATE TABLE IF NOT EXISTS `clan` (
  `clan_id` integer  NOT NULL PRIMARY KEY AUTOINCREMENT
,  `name` varchar(24) NOT NULL DEFAULT ''
,  `master` varchar(24) NOT NULL DEFAULT ''
,  `mapname` varchar(24) NOT NULL DEFAULT ''
,  `max_member` integer  NOT NULL DEFAULT '0'
);
INSERT INTO `clan` VALUES ('1', 'Swordman Clan', 'Raffam Oranpere', 'prontera', '500');
INSERT INTO `clan` VALUES ('2', 'Arcwand Clan', 'Devon Aire', 'geffen', '500');
INSERT INTO `clan` VALUES ('3', 'Golden Mace Clan', 'Berman Aire', 'prontera', '500');
INSERT INTO `clan` VALUES ('4', 'Crossbow Clan', 'Shaam Rumi', 'payon', '500');
CREATE TABLE IF NOT EXISTS `clan_alliance` (
  `clan_id` integer  NOT NULL DEFAULT '0'
,  `opposition` integer  NOT NULL DEFAULT '0'
,  `alliance_id` integer  NOT NULL DEFAULT '0'
,  `name` varchar(24) NOT NULL DEFAULT ''
,  PRIMARY KEY (`clan_id`,`alliance_id`)
);
INSERT INTO `clan_alliance` VALUES ('1', '0', '3', 'Golden Mace Clan');
INSERT INTO `clan_alliance` VALUES ('2', '0', '3', 'Golden Mace Clan');
INSERT INTO `clan_alliance` VALUES ('2', '1', '4', 'Crossbow Clan');
INSERT INTO `clan_alliance` VALUES ('3', '0', '1', 'Swordman Clan');
INSERT INTO `clan_alliance` VALUES ('3', '0', '2', 'Arcwand Clan');
INSERT INTO `clan_alliance` VALUES ('3', '0', '4', 'Crossbow Clan');
INSERT INTO `clan_alliance` VALUES ('4', '0', '3', 'Golden Mace Clan');
INSERT INTO `clan_alliance` VALUES ('4', '1', '2', 'Arcwand Clan');
CREATE TABLE IF NOT EXISTS `elemental` (
  `ele_id` integer  NOT NULL PRIMARY KEY AUTOINCREMENT
,  `char_id` integer NOT NULL
,  `class` integer  NOT NULL default '0'
,  `mode` integer  NOT NULL default '1'
,  `hp` integer  NOT NULL default '0'
,  `sp` integer  NOT NULL default '0'
,  `max_hp` integer  NOT NULL default '0'
,  `max_sp` integer  NOT NULL default '0'
,  `atk1` integer  NOT NULL default '0'
,  `atk2` integer  NOT NULL default '0'
,  `matk` integer  NOT NULL default '0'
,  `aspd` integer  NOT NULL default '0'
,  `def` integer  NOT NULL default '0'
,  `mdef` integer  NOT NULL default '0'
,  `flee` integer  NOT NULL default '0'
,  `hit` integer  NOT NULL default '0'
,  `life_time` integer NOT NULL default '0'
);
CREATE TABLE IF NOT EXISTS `friends` (
  `char_id` integer NOT NULL default '0'
,  `friend_id` integer NOT NULL default '0'
,  PRIMARY KEY (`char_id`, `friend_id`)
);
CREATE TABLE IF NOT EXISTS `global_acc_reg_num` (
  `account_id` integer  NOT NULL default '0'
,  `key` varchar(32) binary NOT NULL default ''
,  `index` integer  NOT NULL default '0'
,  `value` integer NOT NULL default '0'
,  PRIMARY KEY (`account_id`,`key`,`index`)
);
CREATE TABLE IF NOT EXISTS `global_acc_reg_str` (
  `account_id` integer  NOT NULL default '0'
,  `key` varchar(32) binary NOT NULL default ''
,  `index` integer  NOT NULL default '0'
,  `value` varchar(254) NOT NULL default '0'
,  PRIMARY KEY (`account_id`,`key`,`index`)
);
CREATE TABLE IF NOT EXISTS `guild` (
  `guild_id` integer  NOT NULL PRIMARY KEY AUTOINCREMENT
,  `name` varchar(24) NOT NULL default ''
,  `char_id` integer  NOT NULL default '0'
,  `master` varchar(24) NOT NULL default ''
,  `guild_lv` integer  NOT NULL default '0'
,  `connect_member` integer  NOT NULL default '0'
,  `max_member` integer  NOT NULL default '0'
,  `average_lv` integer  NOT NULL default '1'
,  `exp` integer  NOT NULL default '0'
,  `next_exp` integer  NOT NULL default '0'
,  `skill_point` integer  NOT NULL default '0'
,  `mes1` varchar(60) NOT NULL default ''
,  `mes2` varchar(120) NOT NULL default ''
,  `emblem_len` integer  NOT NULL default '0'
,  `emblem_id` integer  NOT NULL default '0'
,  `emblem_data` blob
,  `last_master_change` datetime
,  UNIQUE (`guild_id`)
);
CREATE TABLE IF NOT EXISTS `guild_alliance` (
  `guild_id` integer  NOT NULL default '0'
,  `opposition` integer  NOT NULL default '0'
,  `alliance_id` integer  NOT NULL default '0'
,  `name` varchar(24) NOT NULL default ''
,  PRIMARY KEY  (`guild_id`,`alliance_id`)
);
CREATE TABLE IF NOT EXISTS `guild_castle` (
  `castle_id` integer  NOT NULL default '0'
,  `guild_id` integer  NOT NULL default '0'
,  `economy` integer  NOT NULL default '0'
,  `defense` integer  NOT NULL default '0'
,  `triggerE` integer  NOT NULL default '0'
,  `triggerD` integer  NOT NULL default '0'
,  `nextTime` integer  NOT NULL default '0'
,  `payTime` integer  NOT NULL default '0'
,  `createTime` integer  NOT NULL default '0'
,  `visibleC` integer  NOT NULL default '0'
,  `visibleG0` integer  NOT NULL default '0'
,  `visibleG1` integer  NOT NULL default '0'
,  `visibleG2` integer  NOT NULL default '0'
,  `visibleG3` integer  NOT NULL default '0'
,  `visibleG4` integer  NOT NULL default '0'
,  `visibleG5` integer  NOT NULL default '0'
,  `visibleG6` integer  NOT NULL default '0'
,  `visibleG7` integer  NOT NULL default '0'
,  PRIMARY KEY  (`castle_id`)
);
CREATE TABLE IF NOT EXISTS `guild_expulsion` (
  `guild_id` integer  NOT NULL default '0'
,  `account_id` integer  NOT NULL default '0'
,  `name` varchar(24) NOT NULL default ''
,  `mes` varchar(40) NOT NULL default ''
,  PRIMARY KEY  (`guild_id`,`name`)
);
CREATE TABLE IF NOT EXISTS `guild_member` (
  `guild_id` integer  NOT NULL default '0'
,  `char_id` integer  NOT NULL default '0'
,  `exp` integer  NOT NULL default '0'
,  `position` integer  NOT NULL default '0'
,  PRIMARY KEY  (`guild_id`,`char_id`)
);
CREATE TABLE IF NOT EXISTS `guild_position` (
  `guild_id` integer  NOT NULL default '0'
,  `position` integer  NOT NULL default '0'
,  `name` varchar(24) NOT NULL default ''
,  `mode` integer  NOT NULL default '0'
,  `exp_mode` integer  NOT NULL default '0'
,  PRIMARY KEY  (`guild_id`,`position`)
);
CREATE TABLE IF NOT EXISTS `guild_skill` (
  `guild_id` integer  NOT NULL default '0'
,  `id` integer  NOT NULL default '0'
,  `lv` integer  NOT NULL default '0'
,  PRIMARY KEY  (`guild_id`,`id`)
);
CREATE TABLE IF NOT EXISTS `guild_storage` (
  `id` integer  NOT NULL PRIMARY KEY AUTOINCREMENT
,  `guild_id` integer  NOT NULL default '0'
,  `nameid` integer  NOT NULL default '0'
,  `amount` integer  NOT NULL default '0'
,  `equip` integer  NOT NULL default '0'
,  `identify` integer  NOT NULL default '0'
,  `refine` integer  NOT NULL default '0'
,  `attribute` integer  NOT NULL default '0'
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
,  `expire_time` integer  NOT NULL default '0'
,  `bound` integer  NOT NULL default '0'
,  `unique_id` integer  NOT NULL default '0'
,  `enchantgrade` integer  NOT NULL default '0'
);
CREATE TABLE IF NOT EXISTS `guild_storage_log` (
  `id` integer NOT NULL PRIMARY KEY AUTOINCREMENT
,  `guild_id` integer  NOT NULL default '0'
,  `time` datetime NOT NULL
,  `char_id` integer NOT NULL default '0'
,  `name` varchar(24) NOT NULL default ''
,  `nameid` integer  NOT NULL default '0'
,  `amount` integer NOT NULL default '1'
,  `identify` integer NOT NULL default '0'
,  `refine` integer  NOT NULL default '0'
,  `attribute` integer  NOT NULL default '0'
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
,  `expire_time` integer  NOT NULL default '0'
,  `unique_id` integer  NOT NULL default '0'
,  `bound` integer  NOT NULL default '0'
,  `enchantgrade` integer  NOT NULL default '0'
,  INDEX (`guild_id`)
);
CREATE TABLE IF NOT EXISTS `homunculus` (
  `homun_id` integer NOT NULL PRIMARY KEY AUTOINCREMENT
,  `char_id` integer NOT NULL
,  `class` integer  NOT NULL default '0'
,  `prev_class` integer NOT NULL default '0'
,  `name` varchar(24) NOT NULL default ''
,  `level` integer NOT NULL default '0'
,  `exp` integer  NOT NULL default '0'
,  `intimacy` integer NOT NULL default '0'
,  `hunger` integer NOT NULL default '0'
,  `str` integer  NOT NULL default '0'
,  `agi` integer  NOT NULL default '0'
,  `vit` integer  NOT NULL default '0'
,  `int` integer  NOT NULL default '0'
,  `dex` integer  NOT NULL default '0'
,  `luk` integer  NOT NULL default '0'
,  `hp` integer  NOT NULL default '0'
,  `max_hp` integer  NOT NULL default '0'
,  `sp` integer NOT NULL default '0'
,  `max_sp` integer NOT NULL default '0'
,  `skill_point` integer  NOT NULL default '0'
,  `alive` integer NOT NULL default '1'
,  `rename_flag` integer NOT NULL default '0'
,  `vaporize` integer NOT NULL default '0'
,  `autofeed` integer NOT NULL default '0'
);
CREATE TABLE IF NOT EXISTS `hotkey` (
  `char_id` integer NOT NULL
,  `hotkey` integer  NOT NULL
,  `type` integer  NOT NULL default '0'
,  `itemskill_id` integer  NOT NULL default '0'
,  `skill_lvl` integer  NOT NULL default '0'
,  PRIMARY KEY (`char_id`,`hotkey`)
);
CREATE TABLE IF NOT EXISTS `interlog` (
  `id` integer NOT NULL PRIMARY KEY AUTOINCREMENT
,  `time` datetime NOT NULL
,  `log` varchar(255) NOT NULL default ''
,  INDEX `time` (`time`)
);
CREATE TABLE IF NOT EXISTS `inventory` (
  `id` integer  NOT NULL PRIMARY KEY AUTOINCREMENT
,  `char_id` integer  NOT NULL default '0'
,  `nameid` integer  NOT NULL default '0'
,  `amount` integer  NOT NULL default '0'
,  `equip` integer  NOT NULL default '0'
,  `identify` integer NOT NULL default '0'
,  `refine` integer  NOT NULL default '0'
,  `attribute` integer  NOT NULL default '0'
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
,  `expire_time` integer  NOT NULL default '0'
,  `favorite` integer  NOT NULL default '0'
,  `bound` integer  NOT NULL default '0'
,  `unique_id` integer  NOT NULL default '0'
,  `equip_switch` integer  NOT NULL default '0'
,  `enchantgrade` integer  NOT NULL default '0'
);
CREATE TABLE IF NOT EXISTS `ipbanlist` (
  `list` varchar(15) NOT NULL default ''
,  `btime` datetime NOT NULL
,  `rtime` datetime NOT NULL
,  `reason` varchar(255) NOT NULL default ''
,  PRIMARY KEY (`list`, `btime`)
);
CREATE TABLE IF NOT EXISTS `login` (
  `account_id` integer  NOT NULL PRIMARY KEY AUTOINCREMENT
,  `userid` varchar(23) NOT NULL default ''
,  `user_pass` varchar(32) NOT NULL default ''
,  `sex` text  NOT NULL default 'M'
,  `email` varchar(39) NOT NULL default ''
,  `group_id` integer NOT NULL default '0'
,  `state` integer  NOT NULL default '0'
,  `unban_time` integer  NOT NULL default '0'
,  `expiration_time` integer  NOT NULL default '0'
,  `logincount` integer  NOT NULL default '0'
,  `lastlogin` datetime
,  `last_ip` varchar(100) NOT NULL default ''
,  `birthdate` DATE
,  `character_slots` integer  NOT NULL default '0'
,  `pincode` varchar(4) NOT NULL DEFAULT ''
,  `pincode_change` integer  NOT NULL DEFAULT '0'
,  `vip_time` integer  NOT NULL default '0'
,  `old_group` integer NOT NULL default '0'
,  `web_auth_token` varchar(17) null
,  `web_auth_token_enabled` integer NOT NULL default '0'
,  UNIQUE (`web_auth_token`)
);
INSERT INTO `login` (`account_id`, `userid`, `user_pass`, `sex`, `email`) VALUES ('1', 's1', 'p1', 'S','athena@athena.com');
CREATE TABLE IF NOT EXISTS `mail` (
  `id` integer  NOT NULL PRIMARY KEY AUTOINCREMENT
,  `send_name` varchar(30) NOT NULL default ''
,  `send_id` integer  NOT NULL default '0'
,  `dest_name` varchar(30) NOT NULL default ''
,  `dest_id` integer  NOT NULL default '0'
,  `title` varchar(45) NOT NULL default ''
,  `message` varchar(500) NOT NULL default ''
,  `time` integer  NOT NULL default '0'
,  `status` integer NOT NULL default '0'
,  `zeny` integer  NOT NULL default '0'
,  `type` integer NOT NULL default '0'
);
CREATE TABLE IF NOT EXISTS `mail_attachments` (
  `id` integer  NOT NULL PRIMARY KEY AUTOINCREMENT
,  `index` integer  NOT NULL DEFAULT '0'
,  `nameid` integer  NOT NULL DEFAULT '0'
,  `amount` integer  NOT NULL DEFAULT '0'
,  `refine` integer  NOT NULL DEFAULT '0'
,  `attribute` integer  NOT NULL DEFAULT '0'
,  `identify` integer NOT NULL DEFAULT '0'
,  `card0` integer  NOT NULL DEFAULT '0'
,  `card1` integer  NOT NULL DEFAULT '0'
,  `card2` integer  NOT NULL DEFAULT '0'
,  `card3` integer  NOT NULL DEFAULT '0'
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
,  `unique_id` integer  NOT NULL DEFAULT '0'
,  `bound` integer  NOT NULL DEFAULT '0'
,  `enchantgrade` integer  NOT NULL default '0'
);
CREATE TABLE IF NOT EXISTS `mapreg` (
  `varname` varchar(32) binary NOT NULL
,  `index` integer  NOT NULL default '0'
,  `value` varchar(255) NOT NULL
,  PRIMARY KEY (`varname`,`index`)
);
CREATE TABLE IF NOT EXISTS `market` (
  `name` varchar(50) NOT NULL DEFAULT ''
,  `nameid` integer  NOT NULL
,  `price` integer  NOT NULL
,  `amount` integer  NOT NULL
,  `flag` integer  NOT NULL DEFAULT '0'
,  PRIMARY KEY  (`name`,`nameid`)
);
CREATE TABLE IF NOT EXISTS `memo` (
  `memo_id` integer  NOT NULL PRIMARY KEY AUTOINCREMENT
,  `char_id` integer  NOT NULL default '0'
,  `map` varchar(11) NOT NULL default ''
,  `x` integer  NOT NULL default '0'
,  `y` integer  NOT NULL default '0'
);
CREATE TABLE IF NOT EXISTS `mercenary` (
  `mer_id` integer  NOT NULL PRIMARY KEY AUTOINCREMENT
,  `char_id` integer NOT NULL
,  `class` integer  NOT NULL default '0'
,  `hp` integer  NOT NULL default '0'
,  `sp` integer  NOT NULL default '0'
,  `kill_counter` integer NOT NULL
,  `life_time` integer NOT NULL default '0'
);
CREATE TABLE IF NOT EXISTS `mercenary_owner` (
  `char_id` integer NOT NULL
,  `merc_id` integer NOT NULL default '0'
,  `arch_calls` integer NOT NULL default '0'
,  `arch_faith` integer NOT NULL default '0'
,  `spear_calls` integer NOT NULL default '0'
,  `spear_faith` integer NOT NULL default '0'
,  `sword_calls` integer NOT NULL default '0'
,  `sword_faith` integer NOT NULL default '0'
,  PRIMARY KEY  (`char_id`)
);
CREATE TABLE IF NOT EXISTS `sales` (
  `nameid` integer  NOT NULL
,  `start` datetime NOT NULL
,  `end` datetime NOT NULL
,  `amount` integer NOT NULL
,  PRIMARY KEY (`nameid`)
);
CREATE TABLE IF NOT EXISTS `sc_data` (
  `account_id` integer  NOT NULL
,  `char_id` integer  NOT NULL
,  `type` integer  NOT NULL
,  `tick` integer NOT NULL
,  `val1` integer NOT NULL default '0'
,  `val2` integer NOT NULL default '0'
,  `val3` integer NOT NULL default '0'
,  `val4` integer NOT NULL default '0'
,  PRIMARY KEY (`char_id`, `type`)
);
CREATE TABLE IF NOT EXISTS `skillcooldown` (
  `account_id` integer  NOT NULL
,  `char_id` integer  NOT NULL
,  `skill` integer  NOT NULL DEFAULT '0'
,  `tick` integer NOT NULL
,  PRIMARY KEY (`char_id`, `skill`)
);
CREATE TABLE IF NOT EXISTS `party` (
  `party_id` integer  NOT NULL PRIMARY KEY AUTOINCREMENT
,  `name` varchar(24) NOT NULL default ''
,  `exp` integer  NOT NULL default '0'
,  `item` integer  NOT NULL default '0'
,  `leader_id` integer  NOT NULL default '0'
,  `leader_char` integer  NOT NULL default '0'
);
CREATE TABLE IF NOT EXISTS `pet` (
  `pet_id` integer  NOT NULL PRIMARY KEY AUTOINCREMENT
,  `class` integer  NOT NULL default '0'
,  `name` varchar(24) NOT NULL default ''
,  `account_id` integer  NOT NULL default '0'
,  `char_id` integer  NOT NULL default '0'
,  `level` integer  NOT NULL default '0'
,  `egg_id` integer  NOT NULL default '0'
,  `equip` integer  NOT NULL default '0'
,  `intimate` integer  NOT NULL default '0'
,  `hungry` integer  NOT NULL default '0'
,  `rename_flag` integer  NOT NULL default '0'
,  `incubate` integer  NOT NULL default '0'
,  `autofeed` integer NOT NULL default '0'
);
CREATE TABLE IF NOT EXISTS `quest` (
  `char_id` integer  NOT NULL default '0'
,  `quest_id` integer  NOT NULL
,  `state` text  NOT NULL default '0'
,  `time` integer  NOT NULL default '0'
,  `count1` integer  NOT NULL default '0'
,  `count2` integer  NOT NULL default '0'
,  `count3` integer  NOT NULL default '0'
,  PRIMARY KEY  (`char_id`,`quest_id`)
);
CREATE TABLE IF NOT EXISTS `skill` (
  `char_id` integer  NOT NULL default '0'
,  `id` integer  NOT NULL default '0'
,  `lv` integer  NOT NULL default '0'
,  `flag` integer  NOT NULL default 0
,  PRIMARY KEY  (`char_id`,`id`)
);
CREATE TABLE IF NOT EXISTS `skill_homunculus` (
  `homun_id` integer NOT NULL
,  `id` integer NOT NULL
,  `lv` integer NOT NULL
,  PRIMARY KEY  (`homun_id`,`id`)
);
CREATE TABLE IF NOT EXISTS `storage` (
  `id` integer  NOT NULL PRIMARY KEY AUTOINCREMENT
,  `account_id` integer  NOT NULL default '0'
,  `nameid` integer  NOT NULL default '0'
,  `amount` integer  NOT NULL default '0'
,  `equip` integer  NOT NULL default '0'
,  `identify` integer  NOT NULL default '0'
,  `refine` integer  NOT NULL default '0'
,  `attribute` integer  NOT NULL default '0'
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
,  `expire_time` integer  NOT NULL default '0'
,  `bound` integer  NOT NULL default '0'
,  `unique_id` integer  NOT NULL default '0'
,  `enchantgrade` integer  NOT NULL default '0'
);
CREATE TABLE IF NOT EXISTS `vending_items` (
  `vending_id` integer  NOT NULL
,  `index` integer  NOT NULL
,  `cartinventory_id` integer  NOT NULL
,  `amount` integer  NOT NULL
,  `price` integer  NOT NULL
,  PRIMARY KEY (`vending_id`, `index`)
);
CREATE TABLE IF NOT EXISTS `vendings` (
  `id` integer  NOT NULL
,  `account_id` integer  NOT NULL
,  `char_id` integer  NOT NULL
,  `sex` text  NOT NULL DEFAULT 'M'
,  `map` varchar(20) NOT NULL
,  `x` integer  NOT NULL
,  `y` integer  NOT NULL
,  `title` varchar(80) NOT NULL
,  `body_direction` CHAR( 1 ) NOT NULL DEFAULT '4'
,  `head_direction` CHAR( 1 ) NOT NULL DEFAULT '0'
,  `sit` CHAR( 1 ) NOT NULL DEFAULT '1'
,  `autotrade` integer NOT NULL
,  PRIMARY KEY (`id`)
);
CREATE INDEX "idx_charlog_account_id" ON "charlog" (`account_id`);
CREATE INDEX "idx_guild_castle_guild_id" ON "guild_castle" (`guild_id`);
CREATE INDEX "idx_clan_alliance_alliance_id" ON "clan_alliance" (`alliance_id`);
CREATE INDEX "idx_cart_inventory_char_id" ON "cart_inventory" (`char_id`);
CREATE INDEX "idx_guild_storage_guild_id" ON "guild_storage" (`guild_id`);
CREATE INDEX "idx_guild_char_id" ON "guild" (`char_id`);
CREATE INDEX "idx_acc_reg_num_account_id" ON "acc_reg_num" (`account_id`);
CREATE INDEX "idx_login_name" ON "login" (`userid`);
CREATE INDEX "idx_char_reg_num_char_id" ON "char_reg_num" (`char_id`);
CREATE INDEX "idx_memo_char_id" ON "memo" (`char_id`);
CREATE INDEX "idx_char_account_id" ON "char" (`account_id`);
CREATE INDEX "idx_char_party_id" ON "char" (`party_id`);
CREATE INDEX "idx_char_guild_id" ON "char" (`guild_id`);
CREATE INDEX "idx_char_online" ON "char" (`online`);
CREATE INDEX "idx_guild_alliance_alliance_id" ON "guild_alliance" (`alliance_id`);
CREATE INDEX "idx_global_acc_reg_str_account_id" ON "global_acc_reg_str" (`account_id`);
CREATE INDEX "idx_achievement_char_id" ON "achievement" (`char_id`);
CREATE INDEX "idx_inventory_char_id" ON "inventory" (`char_id`);
CREATE INDEX "idx_acc_reg_str_account_id" ON "acc_reg_str" (`account_id`);
CREATE INDEX "idx_storage_account_id" ON "storage" (`account_id`);
CREATE INDEX "idx_char_reg_str_char_id" ON "char_reg_str" (`char_id`);
CREATE INDEX "idx_guild_member_char_id" ON "guild_member" (`char_id`);
CREATE INDEX "idx_global_acc_reg_num_account_id" ON "global_acc_reg_num" (`account_id`);
END TRANSACTION;
