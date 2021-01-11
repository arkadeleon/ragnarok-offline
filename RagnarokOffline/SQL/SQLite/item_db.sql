PRAGMA synchronous = OFF;
PRAGMA journal_mode = MEMORY;
BEGIN TRANSACTION;
CREATE TABLE `item_db` (
  `id` integer  NOT NULL DEFAULT '0'
,  `name_aegis` varchar(50) NOT NULL DEFAULT ''
,  `name_english` varchar(50) NOT NULL DEFAULT ''
,  `type` varchar(20) DEFAULT NULL
,  `subtype` varchar(20) DEFAULT NULL
,  `price_buy` integer  DEFAULT NULL
,  `price_sell` integer  DEFAULT NULL
,  `weight` integer  DEFAULT NULL
,  `attack` integer  DEFAULT NULL
,  `defense` integer  DEFAULT NULL
,  `range` integer  DEFAULT NULL
,  `slots` integer  DEFAULT NULL
,  `job_all` integer  DEFAULT NULL
,  `job_acolyte` integer  DEFAULT NULL
,  `job_alchemist` integer  DEFAULT NULL
,  `job_archer` integer  DEFAULT NULL
,  `job_assassin` integer  DEFAULT NULL
,  `job_barddancer` integer  DEFAULT NULL
,  `job_blacksmith` integer  DEFAULT NULL
,  `job_crusader` integer  DEFAULT NULL
,  `job_gunslinger` integer  DEFAULT NULL
,  `job_hunter` integer  DEFAULT NULL
,  `job_knight` integer  DEFAULT NULL
,  `job_mage` integer  DEFAULT NULL
,  `job_merchant` integer  DEFAULT NULL
,  `job_monk` integer  DEFAULT NULL
,  `job_ninja` integer  DEFAULT NULL
,  `job_novice` integer  DEFAULT NULL
,  `job_priest` integer  DEFAULT NULL
,  `job_rogue` integer  DEFAULT NULL
,  `job_sage` integer  DEFAULT NULL
,  `job_soullinker` integer  DEFAULT NULL
,  `job_stargladiator` integer  DEFAULT NULL
,  `job_supernovice` integer  DEFAULT NULL
,  `job_swordman` integer  DEFAULT NULL
,  `job_taekwon` integer  DEFAULT NULL
,  `job_thief` integer  DEFAULT NULL
,  `job_wizard` integer  DEFAULT NULL
,  `class_all` integer  DEFAULT NULL
,  `class_normal` integer  DEFAULT NULL
,  `class_upper` integer  DEFAULT NULL
,  `class_baby` integer  DEFAULT NULL
,  `gender` varchar(10) DEFAULT NULL
,  `location_head_top` integer  DEFAULT NULL
,  `location_head_mid` integer  DEFAULT NULL
,  `location_head_low` integer  DEFAULT NULL
,  `location_armor` integer  DEFAULT NULL
,  `location_right_hand` integer  DEFAULT NULL
,  `location_left_hand` integer  DEFAULT NULL
,  `location_garment` integer  DEFAULT NULL
,  `location_shoes` integer  DEFAULT NULL
,  `location_right_accessory` integer  DEFAULT NULL
,  `location_left_accessory` integer  DEFAULT NULL
,  `location_costume_head_top` integer  DEFAULT NULL
,  `location_costume_head_mid` integer  DEFAULT NULL
,  `location_costume_head_low` integer  DEFAULT NULL
,  `location_costume_garment` integer  DEFAULT NULL
,  `location_ammo` integer  DEFAULT NULL
,  `location_shadow_armor` integer  DEFAULT NULL
,  `location_shadow_weapon` integer  DEFAULT NULL
,  `location_shadow_shield` integer  DEFAULT NULL
,  `location_shadow_shoes` integer  DEFAULT NULL
,  `location_shadow_right_accessory` integer  DEFAULT NULL
,  `location_shadow_left_accessory` integer  DEFAULT NULL
,  `weapon_level` integer  DEFAULT NULL
,  `equip_level_min` integer  DEFAULT NULL
,  `equip_level_max` integer  DEFAULT NULL
,  `refineable` integer  DEFAULT NULL
,  `view` integer  DEFAULT NULL
,  `alias_name` varchar(50) DEFAULT NULL
,  `flag_buyingstore` integer  DEFAULT NULL
,  `flag_deadbranch` integer  DEFAULT NULL
,  `flag_container` integer  DEFAULT NULL
,  `flag_uniqueid` integer  DEFAULT NULL
,  `flag_bindonequip` integer  DEFAULT NULL
,  `flag_dropannounce` integer  DEFAULT NULL
,  `flag_noconsume` integer  DEFAULT NULL
,  `flag_dropeffect` varchar(20) DEFAULT NULL
,  `delay_duration` integer  DEFAULT NULL
,  `delay_status` varchar(30) DEFAULT NULL
,  `stack_amount` integer  DEFAULT NULL
,  `stack_inventory` integer  DEFAULT NULL
,  `stack_cart` integer  DEFAULT NULL
,  `stack_storage` integer  DEFAULT NULL
,  `stack_guildstorage` integer  DEFAULT NULL
,  `nouse_override` integer  DEFAULT NULL
,  `nouse_sitting` integer  DEFAULT NULL
,  `trade_override` integer  DEFAULT NULL
,  `trade_nodrop` integer  DEFAULT NULL
,  `trade_notrade` integer  DEFAULT NULL
,  `trade_tradepartner` integer  DEFAULT NULL
,  `trade_nosell` integer  DEFAULT NULL
,  `trade_nocart` integer  DEFAULT NULL
,  `trade_nostorage` integer  DEFAULT NULL
,  `trade_noguildstorage` integer  DEFAULT NULL
,  `trade_nomail` integer  DEFAULT NULL
,  `trade_noauction` integer  DEFAULT NULL
,  `script` text
,  `equip_script` text
,  `unequip_script` text
,  PRIMARY KEY (`id`)
,  UNIQUE INDEX `UniqueAegisName` (`name_aegis`)
);
END TRANSACTION;
