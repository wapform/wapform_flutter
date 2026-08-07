-- example/server/schema.sql
--
-- Matches server.js's pool config (database: 'ag') and the single `sys`
-- table that agp001.dart's "系統參數建檔" screen reads/writes. Every
-- field in agp001.dart's dbquery define block was declared with _fld()
-- (no type=), which builds a TStringField on the Dart side regardless
-- of the underlying SQL column type — so plain VARCHAR/TEXT is enough
-- here; there's no need to match Dart field classes to SQL types.
--
-- Usage:
--   mysql -u root -p < schema.sql
-- (adjust the user/password in server.js's pool config to match your
-- own MariaDB/MySQL instance — the 'xyz'/'123' in there are placeholders)

CREATE DATABASE IF NOT EXISTS `ag`
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE `ag`;

CREATE TABLE IF NOT EXISTS `sys` (
  `No`       VARCHAR(10)  NOT NULL,
  `Company`  VARCHAR(60)  DEFAULT NULL,
  `Addr`     VARCHAR(120) DEFAULT NULL,
  `AC`       VARCHAR(20)  DEFAULT NULL,
  `Zip`      VARCHAR(10)  DEFAULT NULL,
  `Phone`    VARCHAR(30)  DEFAULT NULL,
  `FAX`      VARCHAR(30)  DEFAULT NULL,
  `TaxRate`  VARCHAR(5)   DEFAULT NULL,
  `Printer1` VARCHAR(40)  DEFAULT NULL,
  `Printer2` VARCHAR(40)  DEFAULT NULL,
  `Printer3` VARCHAR(40)  DEFAULT NULL,
  `Design`   VARCHAR(120) DEFAULT NULL,
  `AcBeg`    VARCHAR(8)   DEFAULT NULL,
  `AcEnd`    VARCHAR(8)   DEFAULT NULL,
  `Rem`      VARCHAR(255) DEFAULT NULL,
  `New`      VARCHAR(255) DEFAULT NULL,
  `sales`    VARCHAR(255) DEFAULT NULL,
  `a2500`    VARCHAR(255) DEFAULT NULL,
  PRIMARY KEY (`No`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- A single seed row, so the screen has something to load and edit on
-- first run (agp001.dart's screen edits one existing row rather than
-- inserting — there's no "new" button visible, only Save/Cancel/Close).
INSERT INTO `sys` (`No`, `Company`, `Addr`, `AC`, `Zip`, `Phone`, `FAX`, `TaxRate`)
VALUES ('1', 'Demo Company Ltd.', '1 Example Road', '12345678', '100', '02-1234-5678', '02-1234-5679', '5')
ON DUPLICATE KEY UPDATE `No` = `No`;
