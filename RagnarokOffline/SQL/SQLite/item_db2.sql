PRAGMA synchronous = OFF;
PRAGMA journal_mode = MEMORY;
BEGIN TRANSACTION;
CREATE TABLE `item_db2` (
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
REPLACE INTO `item_db2` (`id`,`name_aegis`,`name_english`,`type`,`price_sell`,`weight`,`alias_name`) VALUES (1998,'Jeramiah''s_Jur','Jeramiah''s Jur','Etc',10,10,'Jur');
REPLACE INTO `item_db2` (`id`,`name_aegis`,`name_english`,`type`,`price_sell`,`weight`,`alias_name`) VALUES (1999,'Zed''s_Staff','Zed''s Staff','Etc',10,10,'Staff_Of_Soul');
REPLACE INTO `item_db2` (`id`,`name_aegis`,`name_english`,`type`,`price_sell`,`weight`,`alias_name`) VALUES (7950,'THG_Membership','THG Membership','Etc',10,10,'Foolishness_Of_Blind');
REPLACE INTO `item_db2` (`id`,`name_aegis`,`name_english`,`type`,`price_sell`,`weight`,`alias_name`) VALUES (7951,'Token_Bag','Token Bag','Etc',10,10,'Leather_Bag_Of_Infinity');
REPLACE INTO `item_db2` (`id`,`name_aegis`,`name_english`,`type`,`price_buy`,`weight`,`script`) VALUES (585,'Wurst','Brusti','Delayconsume',2,40,'itemheal rand(15,20),0; itemskill "PR_MAGNIFICAT",3;');
REPLACE INTO `item_db2` (`id`,`name_aegis`,`name_english`,`type`,`price_buy`,`weight`,`script`) VALUES (679,'Gold_Pill','Pilule','Healing',5000,300,'percentheal 50,50;');
REPLACE INTO `item_db2` (`id`,`name_aegis`,`name_english`,`type`,`price_buy`,`weight`,`location_right_accessory`,`location_left_accessory`,`script`) VALUES (2681,'Republic_Ring','Republic Anniversary Ring','Armor',20,100,true,true,'bonus bAllStats,3;');
REPLACE INTO `item_db2` (`id`,`name_aegis`,`name_english`,`type`,`price_buy`,`weight`,`defense`,`location_head_top`,`refineable`,`view`,`script`) VALUES (5134,'Pumpkin_Hat','Pumpkin-Head','Armor',20,200,2,true,true,206,'bonus2 bSubRace,RC_Demon,5;');
REPLACE INTO `item_db2` (`id`,`name_aegis`,`name_english`,`type`,`price_buy`,`weight`,`defense`,`location_head_top`,`refineable`,`view`,`script`) VALUES (5136,'Santa''s_Hat_','Louise''s Santa Hat','Armor',20,100,3,true,true,20,'bonus bMdef,1; bonus bLuk,1; bonus3 bAutoSpellWhenHit,"AL_HEAL",3,50; bonus3 bAutoSpellWhenHit,"AL_BLESSING",10,50;');
REPLACE INTO `item_db2` (`id`,`name_aegis`,`name_english`,`type`,`price_buy`,`weight`,`location_head_top`,`refineable`,`view`,`script`) VALUES (5145,'Carnival_Joker_Jester','Carnival Jester','Armor',10,100,true,true,89,'bonus bAllStats,3;');
REPLACE INTO `item_db2` (`id`,`name_aegis`,`name_english`,`type`,`weight`,`defense`,`location_head_top`,`refineable`,`view`,`script`) VALUES (5147,'Baseball_Cap','Baseball Cap','Armor',200,3,true,true,216,'bonus2 bExpAddRace,RC_Boss,50; bonus2 bExpAddRace,RC_NonBoss,50;');
REPLACE INTO `item_db2` (`id`,`name_aegis`,`name_english`,`type`,`price_buy`,`weight`,`defense`,`location_head_top`,`refineable`,`view`,`script`) VALUES (5201,'Party_Hat_B','2nd Anniversary Party Hat','Armor',20,300,3,true,true,144,'bonus bAllStats,3;');
REPLACE INTO `item_db2` (`id`,`name_aegis`,`name_english`,`type`,`price_buy`,`weight`,`defense`,`location_head_top`,`refineable`,`view`,`script`) VALUES (5202,'Pumpkin_Hat_','Pumpkin Hat','Armor',20,200,2,true,true,206,'bonus bAllStats,2; bonus2 bSubRace,RC_Demon,5; bonus3 bAddMonsterDropItem,529,RC_DemiHuman,1500;');
REPLACE INTO `item_db2` (`id`,`name_aegis`,`name_english`,`type`,`price_buy`,`weight`,`location_head_low`,`view`,`script`) VALUES (5204,'Event_Pierrot_Nose','Rudolf''s Red Nose','Armor',20,100,true,49,'bonus2 bResEff,Eff_Blind,3000; bonus2 bAddMonsterDropItem,12130,30;');
REPLACE INTO `item_db2` (`id`,`name_aegis`,`name_english`,`type`,`price_buy`,`weight`,`defense`,`location_head_top`,`refineable`,`view`,`script`) VALUES (5264,'Aussie_Flag_Hat','Australian Flag Hat','Armor',20,500,4,true,true,304,'bonus bAllStats,2;');
REPLACE INTO `item_db2` (`id`,`name_aegis`,`name_english`,`type`,`price_buy`,`weight`,`defense`,`location_head_top`,`refineable`,`view`,`script`) VALUES (5356,'Pumpkin_Hat_H','Pumpkin Hat','Armor',20,200,2,true,true,206,'bonus bAllStats,2; bonus2 bSubRace,RC_Demon,5; bonus2 bMagicAddRace,RC_Demon,5;');
REPLACE INTO `item_db2` (`id`,`name_aegis`,`name_english`,`type`,`price_buy`,`weight`,`defense`,`slots`,`location_head_top`,`equip_level_min`,`refineable`,`view`,`script`) VALUES (5384,'Santa_Hat_1','Twin Pompom By JB','Armor',20,200,2,1,true,20,true,390,'bonus bLuk,3; bonus2 bResEff,Eff_Curse,2000; bonus bVariableCastrate,-2; bonus bAspdRate,4; bonus2 bAddMonsterDropItem,539,100; bonus2 bAddMonsterDropItem,529,200; bonus2 bAddMonsterDropItem,530,200; autobonus "{ bonus bCritical,10; }",10,5000;');
REPLACE INTO `item_db2` (`id`,`name_aegis`,`name_english`,`type`,`price_buy`,`weight`,`defense`,`location_head_low`,`view`,`script`) VALUES (5811,'Santa_Beard','Santa Beard','Armor',20,100,5,true,25,'bonus2 bSubRace,RC_Brute,5; bonus2 bSubRace,RC_Player_Doram,5;');
REPLACE INTO `item_db2` (`id`,`name_aegis`,`name_english`,`type`,`weight`,`script`) VALUES (11702,'Moon_Cookie','Moon Cookie','Delayconsume',10,'sc_end SC_POISON; sc_end SC_SILENCE; sc_end SC_BLIND; sc_end SC_CONFUSION; sc_end SC_CURSE; sc_end SC_HALLUCINATION; itemskill "AL_BLESSING",7;');
REPLACE INTO `item_db2` (`id`,`name_aegis`,`name_english`,`type`,`price_buy`,`weight`,`script`) VALUES (12131,'Lucky_Potion','Lucky Potion','Healing',2,100,'sc_start SC_LUKFOOD,180000,15;');
REPLACE INTO `item_db2` (`id`,`name_aegis`,`name_english`,`type`,`price_buy`,`weight`,`script`) VALUES (12143,'Red_Can','Red Can','Usable',50000,300,'percentheal 25,25;');
REPLACE INTO `item_db2` (`id`,`name_aegis`,`name_english`,`type`) VALUES (12199,'Rice_Scroll','Rice Scroll','Usable');
REPLACE INTO `item_db2` (`id`,`name_aegis`,`name_english`,`type`,`price_buy`,`weight`,`script`) VALUES (12200,'Event_Cake','Event Cake','Usable',20,50,'itemskill "PR_MAGNIFICAT",3;');
REPLACE INTO `item_db2` (`id`,`name_aegis`,`name_english`,`type`,`price_buy`,`weight`,`script`) VALUES (12238,'New_Year_Rice_Cake_1','New Year Rice Cake','Healing',20,100,'percentheal 20,15; sc_start SC_STRFOOD,1200000,3; sc_start SC_INTFOOD,1200000,3; sc_start SC_LUKFOOD,1200000,3; sc_start SC_SPEEDUP1,5000,0;');
REPLACE INTO `item_db2` (`id`,`name_aegis`,`name_english`,`type`,`price_buy`,`weight`,`script`) VALUES (12239,'New_Year_Rice_Cake_2','New Year Rice Cake','Healing',20,100,'percentheal 20,15; sc_start SC_DEXFOOD,1200000,3; sc_start SC_AGIFOOD,1200000,3; sc_start SC_VITFOOD,1200000,3; sc_start SC_SPEEDUP1,5000,0;');
REPLACE INTO `item_db2` (`id`,`name_aegis`,`name_english`,`type`,`weight`,`alias_name`) VALUES (7915,'Copper_Coin_','Bronze Coin','Etc',10,'Copper_Coin');
REPLACE INTO `item_db2` (`id`,`name_aegis`,`name_english`,`type`,`weight`,`alias_name`) VALUES (7916,'Silver_Coin_','Silver Coin','Etc',10,'Silver_Coin');
REPLACE INTO `item_db2` (`id`,`name_aegis`,`name_english`,`type`,`weight`,`alias_name`,`script`) VALUES (12715,'Black_Treasure_Chest','Black Treasure Chest','Usable',200,'Treasure_Box_','callfunc "F_08stpattyseventbox";');
REPLACE INTO `item_db2` (`id`,`name_aegis`,`name_english`,`type`,`price_buy`,`defense`,`location_right_accessory`,`location_left_accessory`,`script`) VALUES (5817,'Valentine''s_Emblem','Valentine''s Emblem','Armor',10,3,true,true,'bonus bAtkRate,3; bonus bMatkRate,3; bonus bAllStats,2; bonus bFlee,10; bonus bAspd,1; bonus bMdef,3; bonus2 bSkillAtk,"AL_HEAL",10; bonus2 bSkillHeal,"AL_HEAL",10; bonus2 bSkillHeal,"AM_POTIONPITCHER",10; bonus2 bAddItemGroupHealRate,IG_Potion,10;');
REPLACE INTO `item_db2` (`id`,`name_aegis`,`name_english`,`type`,`price_buy`) VALUES (7946,'Gold_Ring_Of_Valentine','Gold Ring Of Valentine','Etc',10);
REPLACE INTO `item_db2` (`id`,`name_aegis`,`name_english`,`type`,`price_buy`) VALUES (7947,'Silver_Ring_Of_Valentine','Silver Ring Of Valentine','Etc',10);
REPLACE INTO `item_db2` (`id`,`name_aegis`,`name_english`,`type`,`price_buy`,`weight`) VALUES (7948,'Box','Box','Etc',10,10);
REPLACE INTO `item_db2` (`id`,`name_aegis`,`name_english`,`type`,`price_buy`,`script`) VALUES (12742,'Valentine_Gift_Box_M','Valentine Gift Box','Usable',10,'getitem 7946,1;');
REPLACE INTO `item_db2` (`id`,`name_aegis`,`name_english`,`type`,`price_buy`,`script`) VALUES (12743,'Valentine_Gift_Box_F','Valentine Gift Box','Usable',10,'getitem 7947,1;');
REPLACE INTO `item_db2` (`id`,`name_aegis`,`name_english`,`type`,`price_buy`,`script`) VALUES (12744,'Chocolate_Box','Chocolate Box','Usable',10,'getitem 558,1;');
REPLACE INTO `item_db2` (`id`,`name_aegis`,`name_english`,`type`,`price_buy`,`script`) VALUES (14466,'Valentine''s_Emblem_Box','Valentine''s Emblem Box','Usable',10,'getitem 5817,1;');
REPLACE INTO `item_db2` (`id`,`name_aegis`,`name_english`,`type`,`price_buy`,`defense`,`location_head_top`,`refineable`,`view`,`script`) VALUES (5668,'Weird_Pumpkin_Hat','Weird Pumpkin Hat','Armor',20,5,true,true,206,'bonus bMdef,5; bonus2 bAddMonsterDropItem,12192,2500;');
REPLACE INTO `item_db2` (`id`,`name_aegis`,`name_english`,`type`) VALUES (6298,'Crushed_Pumpkin','Crushed Pumpkin','Etc');
REPLACE INTO `item_db2` (`id`,`name_aegis`,`name_english`,`type`) VALUES (6299,'Worn_Fabric','Worn Fabric','Etc');
REPLACE INTO `item_db2` (`id`,`name_aegis`,`name_english`,`type`,`price_buy`,`weight`,`job_all`,`job_novice`,`location_armor`,`refineable`,`equip_script`,`unequip_script`) VALUES (2338,'Wedding_Dress','Wedding Dress','Armor',43000,500,true,false,true,true,'sc_start SC_WEDDING,INFINITE_TICK,0;','sc_end SC_WEDDING;');
REPLACE INTO `item_db2` (`id`,`name_aegis`,`name_english`,`type`,`price_buy`,`weight`,`job_all`,`job_novice`,`gender`,`location_armor`,`refineable`,`equip_script`,`unequip_script`) VALUES (7170,'Tuxedo','Tuxedo','Armor',43000,10,true,false,'Male',true,true,'sc_start SC_WEDDING,INFINITE_TICK,0;','sc_end SC_WEDDING;');
REPLACE INTO `item_db2` (`id`,`name_aegis`,`name_english`,`type`,`script`) VALUES (22508,'Para_Team_Mark_','Eden Group Mark','Delayconsume','unitskilluseid getcharid(3),"AL_TELEPORT",3;');
END TRANSACTION;
