SET foreign_key_checks=0;

DROP TABLE IF EXISTS `entries`;

CREATE TABLE `entries` (
  `id` INTEGER unsigned NOT NULL auto_increment,
  `uuid` VARCHAR(191) NOT NULL,
  `title` VARCHAR(120) DEFAULT '',
  `body` TEXT(10000) NOT NULL,
  `created_at` datetime NOT NULL,
  INDEX `uuid` (`uuid`),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8mb4;

SET foreign_key_checks=1;
