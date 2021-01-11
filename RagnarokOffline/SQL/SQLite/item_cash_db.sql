PRAGMA synchronous = OFF;
PRAGMA journal_mode = MEMORY;
BEGIN TRANSACTION;
CREATE TABLE `item_cash_db` (
  `tab` integer NOT NULL
,  `item_id` integer  NOT NULL
,  `price` integer  NOT NULL DEFAULT '0'
,  PRIMARY KEY (`tab`,`item_id`)
);
END TRANSACTION;
