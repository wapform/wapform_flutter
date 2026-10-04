-- example/server/sales.sql
--
-- A real phpMyAdmin export of the `sales` production database, trimmed
-- to the 12 tables the 12 example pages (plus function.wml's menu
-- entry) actually use — checked against every `select ... from` in
-- example/lib/app*.dart:
--
--   Table    Used by
--   cu       app004, app006, app007, app012*, app023
--   em       app005, app006
--   fm       app006, app023, app037
--   login    app901, app902 -- also read by wapform_menu.dart to
--            resolve each user's per-menu-item read/write permission
--   mnu      app901, app902 -- also read by wapform_menu.dart to
--            build the main menu itself
--   num      app006 (queried under the dataset id "ab")
--   pa       app002, app006
--   sh       app006, app012, app023
--   sn       app006
--   sys      app001, app004, app006, app007, app012, app023
--   users    app901, app902 -- also read by wapform_session.dart to
--            validate login
--   ve       app002, app003
--
--   * app012 is the grouped WapReport (Accounts Receivable Statement)
--     used as the example in the main README's "From WML to this API"
--     section — see that section for how <group change="sh.cno">
--     compiles into this table's data.
--
-- `web` (a lookup source for app002's category/group fields in an
-- earlier generator template) is no longer queried by the current
-- app002.dart and isn't included here.
--
-- Unlike earlier versions of this file, every table here has real
-- seed data, not just sys/mnu/login/users — this is an actual data
-- export, not hand-written placeholder rows. That includes a seeded
-- `mnu` row for `function.wml` (id 216, "Function Self-Test") — the
-- self-test report is a permanent, real menu item here, reachable by
-- any account (like the seeded `admin`) with a matching `login`
-- permission row, not only through the `[debug]`-only button
-- `example/lib/main.dart` also wires up separately.
--
-- Usage:
--   mysql -u root -p < sales.sql
-- (adjust the user/password in server.js's pool config to match your
-- own MariaDB/MySQL instance — the 'xyz'/'123' in there are placeholders)

CREATE DATABASE IF NOT EXISTS `sales`
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- MySQL account used by the example (wapform.ini, server.js): simulated sample values
CREATE USER IF NOT EXISTS 'wapform'@'localhost' IDENTIFIED BY 'wapform123';
GRANT ALL PRIVILEGES ON `sales`.* TO 'wapform'@'localhost';
FLUSH PRIVILEGES;
USE `sales`;

-- --------------------------------------------------------

-- Table structure: `cu`

CREATE TABLE IF NOT EXISTS `cu` (
  `Cno` varchar(10) NOT NULL DEFAULT '',
  `Cname` varchar(40) DEFAULT NULL,
  `Cshort` varchar(8) DEFAULT NULL,
  `Addr1` varchar(60) DEFAULT NULL,
  `Addr2` varchar(60) DEFAULT NULL,
  `AC` varchar(10) DEFAULT NULL,
  `Zip` varchar(10) DEFAULT NULL,
  `Phone` varchar(20) DEFAULT NULL,
  `FAX` varchar(15) DEFAULT NULL,
  `GSM` varchar(15) DEFAULT NULL,
  `Email` varchar(40) DEFAULT NULL,
  `Charger` varchar(10) DEFAULT NULL,
  `Contact` varchar(10) DEFAULT NULL,
  `Capital` bigint(20) DEFAULT NULL,
  `Level` char(2) DEFAULT NULL,
  `cdate` date DEFAULT NULL,
  `ID` varchar(20) DEFAULT NULL,
  `Typ` varchar(20) DEFAULT NULL,
  `Pay` varchar(10) DEFAULT NULL,
  `AType` char(1) DEFAULT NULL,
  `Sex` smallint(1) DEFAULT NULL,
  `Ship` smallint(1) DEFAULT NULL,
  `Rem` varchar(50) DEFAULT NULL,
  `Remark` varchar(50) DEFAULT NULL,
  `Password` varchar(40) DEFAULT NULL,
  `Ziq` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Seed data: `cu`

INSERT INTO `cu` (`Cno`, `Cname`, `Cshort`, `Addr1`, `Addr2`, `AC`, `Zip`, `Phone`, `FAX`, `GSM`, `Email`, `Charger`, `Contact`, `Capital`, `Level`, `cdate`, `ID`, `Typ`, `Pay`, `AType`, `Sex`, `Ship`, `Rem`, `Remark`, `Password`, `Ziq`) VALUES
('C001', 'Global Trading Co., Ltd.', 'Global', '100 Commerce Rd', '8F-2', '02', '10048', '02-8765-1000', '02-8765-1001', '0921-000-001', 'sales@globaltrading.example.com', 'Mark Johns', 'Mark Johns', 5000000, 'A1', '2020-01-10', '12345678', 'Wholesale', 'Monthly', '1', 1, 1, '', 'Long-term partner', NULL, NULL),
('C002', 'Sunrise Electronics Inc.', 'Sunrise', '45 Bay St', '3F', '07', '80661', '07-535-2000', '07-535-2001', '0921-000-002', 'orders@sunrise.example.com', 'Linda Wu', 'Linda Wu', 3200000, 'A2', '2020-05-22', '23456789', 'Retail', 'Net30', '1', 2, 1, '', '', NULL, NULL),
('C003', 'Pacific Rim Distributors', 'Pacific', '9 Ocean Blvd', '', '04', '40704', '04-2377-3000', '04-2377-3001', '0921-000-003', 'info@pacificrim.example.com', 'David Chen', 'David Chen', 8000000, 'A1', '2019-11-01', '34567890', 'Wholesale', 'Monthly', '1', 1, 2, '', 'VIP customer', NULL, NULL),
('C004', 'Silver Star Retail Group', 'SilverSt', '77 Union St', '2F', '06', '70041', '06-201-4000', '06-201-4001', '0921-000-004', 'purchasing@silverstar.example.com', 'Grace Lin', 'Grace Lin', 1500000, 'B1', '2021-08-15', '45678901', 'Retail', 'Net15', '1', 2, 1, '', '', NULL, NULL),
('C005', 'Northgate Hardware Supply', 'Northgat', '3 Industrial Park Rd', '', '03', '30075', '03-668-5000', '03-668-5001', '0921-000-005', 'contact@northgate.example.com', 'Peter Ho', 'Peter Ho', 2100000, 'B2', '2022-02-28', '56789012', 'Retail', 'COD', '1', 1, 1, '', 'New account 2022', NULL, NULL);

-- --------------------------------------------------------

-- Table structure: `em`

CREATE TABLE IF NOT EXISTS `em` (
  `ENo` varchar(6) NOT NULL DEFAULT '',
  `EName` varchar(8) DEFAULT NULL,
  `ID` varchar(10) DEFAULT NULL,
  `Birthday` date DEFAULT NULL,
  `City` varchar(10) DEFAULT NULL,
  `Sex` char(1) DEFAULT NULL,
  `Maried` char(1) DEFAULT NULL,
  `Army` char(1) DEFAULT NULL,
  `School` varchar(8) DEFAULT NULL,
  `Start` date DEFAULT NULL,
  `Leave` date DEFAULT NULL,
  `Part` varchar(8) DEFAULT NULL,
  `Position` varchar(8) DEFAULT NULL,
  `Phone1` varchar(14) DEFAULT NULL,
  `Phone2` varchar(14) DEFAULT NULL,
  `Addr1` varchar(40) DEFAULT NULL,
  `Addr2` varchar(40) DEFAULT NULL,
  `Rem` varchar(40) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Seed data: `em`

INSERT INTO `em` (`ENo`, `EName`, `ID`, `Birthday`, `City`, `Sex`, `Maried`, `Army`, `School`, `Start`, `Leave`, `Part`, `Position`, `Phone1`, `Phone2`, `Addr1`, `Addr2`, `Rem`) VALUES
('E1', 'Alice', 'A100000001', '1992-03-14', 'Taipei', 'F', 'N', 'N', 'State U.', '2019-07-01', NULL, 'Sales', 'Sales Re', '02-2700-1111', '0955-111-001', '10 Main St', '', 'Top performer 2025'),
('E2', 'Brian', 'A100000002', '1990-11-02', 'New Taipei', 'M', 'Y', 'Y', 'City Col', '2018-03-15', NULL, 'Sales', 'Sales Re', '02-2700-2222', '0955-111-002', '22 Park Rd', '', ''),
('E3', 'Cathy', 'A100000003', '1987-06-25', 'Taipei', 'F', 'Y', 'N', 'Tech Ins', '2015-09-01', NULL, 'Sales', 'Sales Ma', '02-2700-3333', '0955-111-003', '5 Center Ave', '', 'Team lead');

-- --------------------------------------------------------

-- Table structure: `fm`

CREATE TABLE IF NOT EXISTS `fm` (
  `FNo` varchar(6) NOT NULL DEFAULT '',
  `FName` varchar(8) DEFAULT NULL,
  `ID` varchar(10) DEFAULT NULL,
  `Birthday` date DEFAULT NULL,
  `City` varchar(10) DEFAULT NULL,
  `Sex` char(1) DEFAULT NULL,
  `Maried` char(1) DEFAULT NULL,
  `Army` char(1) DEFAULT NULL,
  `School` varchar(8) DEFAULT NULL,
  `Start` date DEFAULT NULL,
  `Leave` date DEFAULT NULL,
  `Part` varchar(8) DEFAULT NULL,
  `Position` varchar(8) DEFAULT NULL,
  `Phone1` varchar(14) DEFAULT NULL,
  `Phone2` varchar(14) DEFAULT NULL,
  `Addr1` varchar(40) DEFAULT NULL,
  `Addr2` varchar(40) DEFAULT NULL,
  `Rem` varchar(40) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Seed data: `fm`

INSERT INTO `fm` (`FNo`, `FName`, `ID`, `Birthday`, `City`, `Sex`, `Maried`, `Army`, `School`, `Start`, `Leave`, `Part`, `Position`, `Phone1`, `Phone2`, `Addr1`, `Addr2`, `Rem`) VALUES
('F1', 'Speedy', 'A123456789', '1985-04-12', 'Taipei', 'M', 'Y', 'N', 'N/A', '2015-01-05', NULL, 'Logistic', 'Manager', '02-8811-2200', '0933-111-222', '20 Freight Ave', '', 'Freight partner'),
('F2', 'Metro', 'A234567890', '1988-09-01', 'Taichung', 'F', 'Y', 'N', 'N/A', '2017-06-15', NULL, 'Logistic', 'Coordina', '04-2233-4455', '0933-222-333', '31 Cargo Blvd', '', 'Freight partner');

-- --------------------------------------------------------

-- Table structure: `login`

CREATE TABLE IF NOT EXISTS `login` (
  `id` int(6) NOT NULL DEFAULT 0,
  `itm` int(6) NOT NULL DEFAULT 0,
  `uid` varchar(40) DEFAULT NULL,
  `r` smallint(6) DEFAULT NULL,
  `w` smallint(6) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Seed data: `login`

INSERT INTO `login` (`id`, `itm`, `uid`, `r`, `w`) VALUES
(0, 1, 'admin', 1, 1),
(1, 1, 'admin', 1, 1),
(2, 1, 'admin', 1, 1),
(3, 1, 'admin', 1, 1),
(4, 1, 'admin', 1, 1),
(5, 1, 'admin', 1, 1),
(6, 1, 'admin', 1, 1),
(7, 1, 'admin', 1, 1),
(8, 1, 'admin', 1, 1),
(9, 1, 'admin', 1, 1),
(10, 1, 'admin', 1, 1),
(11, 1, 'admin', 1, 1),
(12, 1, 'admin', 1, 1),
(14, 1, 'admin', 1, 1),
(15, 1, 'admin', 1, 1),
(16, 1, 'admin', 1, 1),
(17, 1, 'admin', 1, 1),
(20, 1, 'admin', 1, 1),
(21, 1, 'admin', 1, 1),
(22, 1, 'admin', 1, 1),
(23, 1, 'admin', 1, 1),
(24, 1, 'admin', 1, 1),
(25, 1, 'admin', 1, 1),
(26, 1, 'admin', 1, 1),
(27, 1, 'admin', 1, 1),
(28, 1, 'admin', 1, 1),
(29, 1, 'admin', 1, 1),
(30, 1, 'admin', 1, 1),
(31, 1, 'admin', 1, 1),
(32, 1, 'admin', 1, 1),
(33, 1, 'admin', 1, 1),
(34, 1, 'admin', 1, 1),
(35, 1, 'admin', 1, 1),
(36, 1, 'admin', 1, 1),
(37, 1, 'admin', 1, 1),
(50, 1, 'admin', 1, 1),
(51, 1, 'admin', 1, 1),
(52, 1, 'admin', 1, 1),
(53, 1, 'admin', 1, 1),
(54, 1, 'admin', 1, 1),
(55, 1, 'admin', 1, 1),
(56, 1, 'admin', 1, 1),
(92, 1, 'admin', 1, 1),
(96, 1, 'admin', 1, 1),
(97, 1, 'admin', 1, 1),
(98, 1, 'admin', 1, 1),
(99, 1, 'admin', 1, 1),
(101, 1, 'admin', 1, 1),
(200, 1, 'admin', 1, 1),
(201, 1, 'admin', 1, 1),
(202, 1, 'admin', 1, 1),
(203, 1, 'admin', 1, 1),
(205, 1, 'admin', 1, 1),
(207, 1, 'admin', 1, 1),
(208, 1, 'admin', 1, 1),
(209, 1, 'admin', 1, 1),
(210, 1, 'admin', 1, 1),
(215, 1, 'admin', 1, 1),
(216, 1, 'admin', 1, 1),
(999, 1, 'admin', 1, 1);

-- --------------------------------------------------------

-- Table structure: `mnu`

CREATE TABLE IF NOT EXISTS `mnu` (
  `id` smallint(3) NOT NULL DEFAULT 0,
  `sub` smallint(3) DEFAULT NULL,
  `title` varchar(40) DEFAULT NULL,
  `href` varchar(40) DEFAULT NULL,
  `activate` smallint(1) DEFAULT 1,
  `usr` varchar(60) DEFAULT NULL,
  `http` varchar(40) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Seed data: `mnu`

INSERT INTO `mnu` (`id`, `sub`, `title`, `href`, `activate`, `usr`, `http`) VALUES
(1, -1, 'Sales Management System', '', 1, '', NULL),
(2, 1, 'Create Shipping Order', 'app006.wml', 1, '', NULL),
(3, 1, 'Create Payment Receipt', 'app023.wml', 1, '', NULL),
(4, 999, 'System Parameters Setup', 'app001.wml', 1, '', NULL),
(5, 999, 'Product Data Entry', 'app002.wml', 1, '', NULL),
(6, 999, 'Brand Data Management', 'app003.wml', 1, '', NULL),
(7, 999, 'Customer Data Entry', 'app004.wml', 1, '', NULL),
(11, 999, 'Employee Data Entry', 'app005.wml', 1, '', NULL),
(17, 999, 'Customer Data Printing', 'app007.wml', 1, '', NULL),
(23, 1, 'Accounts Receivable Statement', 'app012.wml', 1, '', NULL),
(55, 999, 'Shipping Company Data Entry', 'app037.wml', 1, '', NULL),
(92, 999, 'Account Management', 'app901.wml', 1, '', NULL),
(98, 999, 'Permission Management', 'app902.wml', 1, '', NULL),
(216, 999, 'Function Self-Test', 'function.wml', 1, '', NULL),
(999, -1, 'Basic Data Management', '', 1, '', NULL);

-- --------------------------------------------------------

-- Table structure: `num`

CREATE TABLE IF NOT EXISTS `num` (
  `Date` varchar(10) NOT NULL DEFAULT '',
  `Sno` int(11) NOT NULL DEFAULT 0,
  `Xno` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

-- Table structure: `pa`

CREATE TABLE IF NOT EXISTS `pa` (
  `Pno` varchar(14) NOT NULL DEFAULT '',
  `Qno` varchar(14) DEFAULT NULL,
  `Barcode` varchar(40) DEFAULT NULL,
  `Sid` varchar(4) DEFAULT NULL,
  `Sub` varchar(16) DEFAULT NULL,
  `Gid` varchar(4) DEFAULT NULL,
  `Grp` varchar(16) DEFAULT NULL,
  `Vno` varchar(6) DEFAULT NULL,
  `Des` varchar(40) DEFAULT NULL,
  `Unit` varchar(4) DEFAULT NULL,
  `Pr` double(6,1) DEFAULT NULL,
  `Pricea` double(6,1) DEFAULT NULL,
  `Priceb` double(6,1) DEFAULT NULL,
  `Pricec` double(6,1) DEFAULT NULL,
  `Price1` double(6,1) DEFAULT NULL,
  `Price2` double(6,1) DEFAULT NULL,
  `Price3` double(6,1) DEFAULT NULL,
  `activate` smallint(6) DEFAULT 1,
  `UDate` varchar(6) DEFAULT NULL,
  `pic` varchar(100) DEFAULT NULL,
  `newa` double(6,1) DEFAULT NULL,
  `new1` double(6,1) DEFAULT NULL,
  `topic` text DEFAULT NULL,
  `mnu` varchar(1) NOT NULL DEFAULT 'n',
  `typ` varchar(1) DEFAULT NULL,
  `ord` varchar(2) DEFAULT NULL,
  `qty` int(6) DEFAULT NULL,
  `icon` varchar(30) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Seed data: `pa`

INSERT INTO `pa` (`Pno`, `Qno`, `Barcode`, `Sid`, `Sub`, `Gid`, `Grp`, `Vno`, `Des`, `Unit`, `Pr`, `Pricea`, `Priceb`, `Pricec`, `Price1`, `Price2`, `Price3`, `activate`, `UDate`, `pic`, `newa`, `new1`, `topic`, `mnu`, `typ`, `ord`, `qty`, `icon`) VALUES
('P0001', NULL, NULL, NULL, NULL, NULL, NULL, 'V001', 'USB-C Fast Charger 65W', 'PCS', 450.0, 450.0, 420.0, 390.0, NULL, NULL, NULL, 1, '202601', NULL, NULL, NULL, NULL, 'n', NULL, NULL, NULL, NULL),
('P0002', NULL, NULL, NULL, NULL, NULL, NULL, 'V001', 'Wireless Mouse M2', 'PCS', 320.0, 320.0, 300.0, 280.0, NULL, NULL, NULL, 1, '202601', NULL, NULL, NULL, NULL, 'n', NULL, NULL, NULL, NULL),
('P0003', NULL, NULL, NULL, NULL, NULL, NULL, 'V002', 'Mechanical Keyboard K88', 'PCS', 1850.0, 1850.0, 1750.0, 1650.0, NULL, NULL, NULL, 1, '202601', NULL, NULL, NULL, NULL, 'n', NULL, NULL, NULL, NULL),
('P0004', NULL, NULL, NULL, NULL, NULL, NULL, 'V002', '27-inch LED Monitor', 'PCS', 4800.0, 4800.0, 4600.0, 4400.0, NULL, NULL, NULL, 1, '202601', NULL, NULL, NULL, NULL, 'n', NULL, NULL, NULL, NULL),
('P0005', NULL, NULL, NULL, NULL, NULL, NULL, 'V002', 'HDMI Cable 2M', 'PCS', 150.0, 150.0, 140.0, 130.0, NULL, NULL, NULL, 1, '202601', NULL, NULL, NULL, NULL, 'n', NULL, NULL, NULL, NULL),
('P0006', NULL, NULL, NULL, NULL, NULL, NULL, 'V003', 'External SSD 1TB', 'PCS', 2600.0, 2600.0, 2500.0, 2400.0, NULL, NULL, NULL, 1, '202601', NULL, NULL, NULL, NULL, 'n', NULL, NULL, NULL, NULL),
('P0007', NULL, NULL, NULL, NULL, NULL, NULL, 'V003', 'Bluetooth Speaker Mini', 'PCS', 980.0, 980.0, 930.0, 880.0, NULL, NULL, NULL, 1, '202601', NULL, NULL, NULL, NULL, 'n', NULL, NULL, NULL, NULL),
('P0008', NULL, NULL, NULL, NULL, NULL, NULL, 'V001', 'Laptop Stand Aluminum', 'PCS', 680.0, 680.0, 650.0, 620.0, NULL, NULL, NULL, 1, '202601', NULL, NULL, NULL, NULL, 'n', NULL, NULL, NULL, NULL),
('P0009', NULL, NULL, NULL, NULL, NULL, NULL, 'V003', 'Webcam 1080P', 'PCS', 1200.0, 1200.0, 1150.0, 1100.0, NULL, NULL, NULL, 1, '202601', NULL, NULL, NULL, NULL, 'n', NULL, NULL, NULL, NULL),
('P0010', NULL, NULL, NULL, NULL, NULL, NULL, 'V002', 'Power Strip 6-Outlet', 'PCS', 390.0, 390.0, 370.0, 350.0, NULL, NULL, NULL, 1, '202601', NULL, NULL, NULL, NULL, 'n', NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

-- Table structure: `sh`

CREATE TABLE IF NOT EXISTS `sh` (
  `sno` varchar(14) NOT NULL DEFAULT '',
  `sdate` date DEFAULT NULL,
  `vno` varchar(10) NOT NULL DEFAULT '001',
  `Cno` varchar(10) DEFAULT NULL,
  `Eno` char(2) DEFAULT NULL,
  `FNo` char(2) DEFAULT NULL,
  `fname` varchar(8) DEFAULT NULL,
  `Gno` varchar(4) DEFAULT NULL,
  `Fty` int(6) DEFAULT NULL,
  `adate` date DEFAULT NULL,
  `AType` char(1) NOT NULL DEFAULT '1',
  `ANo` varchar(10) DEFAULT NULL,
  `Rem` varchar(255) DEFAULT NULL,
  `Remark` varchar(60) DEFAULT NULL,
  `RemPay` varchar(40) DEFAULT NULL,
  `TaxRate` smallint(2) DEFAULT NULL,
  `Amount` int(6) DEFAULT NULL,
  `Tax` int(6) DEFAULT NULL,
  `Paid` int(6) DEFAULT NULL,
  `UnPaid` int(6) DEFAULT NULL,
  `GetDate` date DEFAULT NULL,
  `PayDate` date DEFAULT NULL,
  `ChkNo` varchar(10) DEFAULT NULL,
  `A2010` varchar(14) DEFAULT NULL,
  `cshort` varchar(10) DEFAULT NULL,
  `ac` varchar(10) DEFAULT NULL,
  `pay` varchar(10) DEFAULT NULL,
  `amounttax` int(6) DEFAULT NULL,
  `topic` varchar(255) DEFAULT NULL,
  `sales` varchar(50) DEFAULT NULL,
  `dm` varchar(50) DEFAULT NULL,
  `pc` char(1) DEFAULT NULL,
  `source` char(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Seed data: `sh`

INSERT INTO `sh` (`sno`, `sdate`, `vno`, `Cno`, `Eno`, `FNo`, `fname`, `Gno`, `Fty`, `adate`, `AType`, `ANo`, `Rem`, `Remark`, `RemPay`, `TaxRate`, `Amount`, `Tax`, `Paid`, `UnPaid`, `GetDate`, `PayDate`, `ChkNo`, `A2010`, `cshort`, `ac`, `pay`, `amounttax`, `topic`, `sales`, `dm`, `pc`, `source`) VALUES
('SH26010001', '2026-01-03', '001', 'C002', 'E1', 'F1', 'Speedy', NULL, NULL, NULL, '1', NULL, NULL, NULL, NULL, 5, 3600, 180, 3780, 0, '2026-01-03', NULL, NULL, NULL, NULL, NULL, NULL, 3780, 'Sales Order', NULL, NULL, NULL, NULL),
('SH26010002', '2026-01-07', '001', 'C002', 'E3', 'F1', 'Speedy', NULL, NULL, NULL, '1', NULL, NULL, NULL, NULL, 5, 24300, 1215, 25515, 0, '2026-01-07', NULL, NULL, NULL, NULL, NULL, NULL, 25515, 'Sales Order', NULL, NULL, NULL, NULL),
('SH26010003', '2026-01-08', '001', 'C004', 'E2', 'F2', 'Metro', NULL, NULL, NULL, '1', NULL, NULL, NULL, NULL, 5, 27000, 1350, 28350, 0, '2026-01-11', NULL, NULL, NULL, NULL, NULL, NULL, 28350, 'Sales Order', NULL, NULL, NULL, NULL),
('SH26010004', '2026-01-09', '001', 'C005', 'E2', 'F1', 'Speedy', NULL, NULL, NULL, '1', NULL, NULL, NULL, NULL, 5, 49800, 2490, 52290, 0, '2026-01-16', NULL, NULL, NULL, NULL, NULL, NULL, 52290, 'Sales Order', NULL, NULL, NULL, NULL),
('SH26010005', '2026-01-13', '001', 'C003', 'E1', 'F1', 'Speedy', NULL, NULL, NULL, '1', NULL, NULL, NULL, NULL, 5, 8820, 441, 9261, 0, '2026-01-16', NULL, NULL, NULL, NULL, NULL, NULL, 9261, 'Sales Order', NULL, NULL, NULL, NULL),
('SH26010006', '2026-01-14', '001', 'C003', 'E2', 'F1', 'Speedy', NULL, NULL, NULL, '1', NULL, NULL, NULL, NULL, 5, 92070, 4604, 96674, 0, '2026-01-21', NULL, NULL, NULL, NULL, NULL, NULL, 96674, 'Sales Order', NULL, NULL, NULL, NULL),
('SH26010007', '2026-01-15', '001', 'C003', 'E1', 'F1', 'Speedy', NULL, NULL, NULL, '1', NULL, NULL, NULL, NULL, 5, 33800, 1690, 35490, 0, '2026-01-15', NULL, NULL, NULL, NULL, NULL, NULL, 35490, 'Sales Order', NULL, NULL, NULL, NULL),
('SH26010008', '2026-01-16', '001', 'C002', 'E3', 'F2', 'Metro', NULL, NULL, NULL, '1', NULL, NULL, NULL, NULL, 5, 44320, 2216, 46536, 0, '2026-01-19', NULL, NULL, NULL, NULL, NULL, NULL, 46536, 'Sales Order', NULL, NULL, NULL, NULL),
('SH26010009', '2026-01-17', '001', 'C003', 'E1', 'F1', 'Speedy', NULL, NULL, NULL, '1', NULL, NULL, NULL, NULL, 5, 18060, 903, 18963, 0, '2026-01-24', NULL, NULL, NULL, NULL, NULL, NULL, 18963, 'Sales Order', NULL, NULL, NULL, NULL),
('SH26010010', '2026-01-17', '001', 'C004', 'E3', 'F2', 'Metro', NULL, NULL, NULL, '1', NULL, NULL, NULL, NULL, 5, 5760, 288, 6048, 0, '2026-01-24', NULL, NULL, NULL, NULL, NULL, NULL, 6048, 'Sales Order', NULL, NULL, NULL, NULL),
('SH26010011', '2026-01-19', '001', 'C001', 'E2', 'F2', 'Metro', NULL, NULL, NULL, '1', NULL, NULL, NULL, NULL, 5, 13770, 688, 14458, 0, '2026-01-26', NULL, NULL, NULL, NULL, NULL, NULL, 14458, 'Sales Order', NULL, NULL, NULL, NULL),
('SH26010012', '2026-01-21', '001', 'C005', 'E3', 'F1', 'Speedy', NULL, NULL, NULL, '1', NULL, NULL, NULL, NULL, 5, 78250, 3912, 49297, 32865, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 82162, 'Sales Order', NULL, NULL, NULL, NULL),
('SH26010013', '2026-01-22', '001', 'C004', 'E1', 'F1', 'Speedy', NULL, NULL, NULL, '1', NULL, NULL, NULL, NULL, 5, 93750, 4688, 98438, 0, '2026-01-25', NULL, NULL, NULL, NULL, NULL, NULL, 98438, 'Sales Order', NULL, NULL, NULL, NULL),
('SH26010014', '2026-01-24', '001', 'C002', 'E3', 'F2', 'Metro', NULL, NULL, NULL, '1', NULL, NULL, NULL, NULL, 5, 19800, 990, 12474, 8316, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 20790, 'Sales Order', NULL, NULL, NULL, NULL),
('SH26010015', '2026-01-26', '001', 'C003', 'E2', 'F2', 'Metro', NULL, NULL, NULL, '1', NULL, NULL, NULL, NULL, 5, 15550, 778, 16328, 0, '2026-01-26', NULL, NULL, NULL, NULL, NULL, NULL, 16328, 'Sales Order', NULL, NULL, NULL, NULL),
('SH26010016', '2026-01-27', '001', 'C001', 'E1', 'F1', 'Speedy', NULL, NULL, NULL, '1', NULL, NULL, NULL, NULL, 5, 4870, 244, 5114, 0, '2026-01-30', NULL, NULL, NULL, NULL, NULL, NULL, 5114, 'Sales Order', NULL, NULL, NULL, NULL),
('SH26010017', '2026-01-28', '001', 'C002', 'E3', 'F1', 'Speedy', NULL, NULL, NULL, '1', NULL, NULL, NULL, NULL, 5, 39480, 1974, 41454, 0, '2026-01-31', NULL, NULL, NULL, NULL, NULL, NULL, 41454, 'Sales Order', NULL, NULL, NULL, NULL),
('SH26010018', '2026-01-28', '001', 'C001', 'E3', 'F1', 'Speedy', NULL, NULL, NULL, '1', NULL, NULL, NULL, NULL, 5, 10780, 539, 3396, 7923, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 11319, 'Sales Order', NULL, NULL, NULL, NULL),
('SH26010019', '2026-01-29', '001', 'C002', 'E1', 'F2', 'Metro', NULL, NULL, NULL, '1', NULL, NULL, NULL, NULL, 5, 36570, 1828, 38398, 0, '2026-01-29', NULL, NULL, NULL, NULL, NULL, NULL, 38398, 'Sales Order', NULL, NULL, NULL, NULL),
('SH26010020', '2026-01-30', '001', 'C005', 'E1', 'F1', 'Speedy', NULL, NULL, NULL, '1', NULL, NULL, NULL, NULL, 5, 2560, 128, 2688, 0, '2026-02-02', NULL, NULL, NULL, NULL, NULL, NULL, 2688, 'Sales Order', NULL, NULL, NULL, NULL),
('SH26010021', '2026-01-30', '001', 'C004', 'E1', 'F2', 'Metro', NULL, NULL, NULL, '1', NULL, NULL, NULL, NULL, 5, 24050, 1202, 25252, 0, '2026-02-02', NULL, NULL, NULL, NULL, NULL, NULL, 25252, 'Sales Order', NULL, NULL, NULL, NULL),
('SH26010022', '2026-01-31', '001', 'C004', 'E2', 'F2', 'Metro', NULL, NULL, NULL, '1', NULL, NULL, NULL, NULL, 5, 98240, 4912, 103152, 0, '2026-01-31', NULL, NULL, NULL, NULL, NULL, NULL, 103152, 'Sales Order', NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

-- Table structure: `sn`

CREATE TABLE IF NOT EXISTS `sn` (
  `sno` varchar(14) NOT NULL DEFAULT '',
  `Itm` smallint(2) NOT NULL DEFAULT 0,
  `sdate` date DEFAULT NULL,
  `vno` varchar(10) NOT NULL DEFAULT '001',
  `Cno` varchar(10) DEFAULT NULL,
  `Eno` char(2) DEFAULT NULL,
  `Pno` varchar(14) DEFAULT NULL,
  `Qty` int(6) DEFAULT NULL,
  `Price` double(8,2) DEFAULT NULL,
  `ord` varchar(14) DEFAULT NULL,
  `Rem` varchar(40) DEFAULT NULL,
  `Remark` varchar(40) DEFAULT NULL,
  `A2010` varchar(14) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Seed data: `sn`

INSERT INTO `sn` (`sno`, `Itm`, `sdate`, `vno`, `Cno`, `Eno`, `Pno`, `Qty`, `Price`, `ord`, `Rem`, `Remark`, `A2010`) VALUES
('SH26010001', 1, '2026-01-03', '001', 'C002', 'E1', 'P0009', 3, 1200.00, NULL, NULL, NULL, NULL),
('SH26010002', 1, '2026-01-07', '001', 'C002', 'E3', 'P0009', 8, 1200.00, NULL, NULL, NULL, NULL),
('SH26010002', 2, '2026-01-07', '001', 'C002', 'E3', 'P0007', 15, 980.00, NULL, NULL, NULL, NULL),
('SH26010003', 1, '2026-01-08', '001', 'C004', 'E2', 'P0004', 4, 4800.00, NULL, NULL, NULL, NULL),
('SH26010003', 2, '2026-01-08', '001', 'C004', 'E2', 'P0006', 3, 2600.00, NULL, NULL, NULL, NULL),
('SH26010004', 1, '2026-01-09', '001', 'C005', 'E2', 'P0009', 18, 1200.00, NULL, NULL, NULL, NULL),
('SH26010004', 2, '2026-01-09', '001', 'C005', 'E2', 'P0002', 10, 320.00, NULL, NULL, NULL, NULL),
('SH26010004', 3, '2026-01-09', '001', 'C005', 'E2', 'P0007', 20, 980.00, NULL, NULL, NULL, NULL),
('SH26010004', 4, '2026-01-09', '001', 'C005', 'E2', 'P0001', 12, 450.00, NULL, NULL, NULL, NULL),
('SH26010005', 1, '2026-01-13', '001', 'C003', 'E1', 'P0007', 9, 980.00, NULL, NULL, NULL, NULL),
('SH26010006', 1, '2026-01-14', '001', 'C003', 'E2', 'P0002', 6, 320.00, NULL, NULL, NULL, NULL),
('SH26010006', 2, '2026-01-14', '001', 'C003', 'E2', 'P0003', 15, 1850.00, NULL, NULL, NULL, NULL),
('SH26010006', 3, '2026-01-14', '001', 'C003', 'E2', 'P0004', 13, 4800.00, NULL, NULL, NULL, NULL),
('SH26010007', 1, '2026-01-15', '001', 'C003', 'E1', 'P0006', 13, 2600.00, NULL, NULL, NULL, NULL),
('SH26010008', 1, '2026-01-16', '001', 'C002', 'E3', 'P0008', 8, 680.00, NULL, NULL, NULL, NULL),
('SH26010008', 2, '2026-01-16', '001', 'C002', 'E3', 'P0003', 18, 1850.00, NULL, NULL, NULL, NULL),
('SH26010008', 3, '2026-01-16', '001', 'C002', 'E3', 'P0005', 18, 150.00, NULL, NULL, NULL, NULL),
('SH26010008', 4, '2026-01-16', '001', 'C002', 'E3', 'P0002', 9, 320.00, NULL, NULL, NULL, NULL),
('SH26010009', 1, '2026-01-17', '001', 'C003', 'E1', 'P0002', 6, 320.00, NULL, NULL, NULL, NULL),
('SH26010009', 2, '2026-01-17', '001', 'C003', 'E1', 'P0001', 14, 450.00, NULL, NULL, NULL, NULL),
('SH26010009', 3, '2026-01-17', '001', 'C003', 'E1', 'P0010', 20, 390.00, NULL, NULL, NULL, NULL),
('SH26010009', 4, '2026-01-17', '001', 'C003', 'E1', 'P0008', 3, 680.00, NULL, NULL, NULL, NULL),
('SH26010010', 1, '2026-01-17', '001', 'C004', 'E3', 'P0002', 18, 320.00, NULL, NULL, NULL, NULL),
('SH26010011', 1, '2026-01-19', '001', 'C001', 'E2', 'P0008', 9, 680.00, NULL, NULL, NULL, NULL),
('SH26010011', 2, '2026-01-19', '001', 'C001', 'E2', 'P0001', 17, 450.00, NULL, NULL, NULL, NULL),
('SH26010012', 1, '2026-01-21', '001', 'C005', 'E3', 'P0006', 18, 2600.00, NULL, NULL, NULL, NULL),
('SH26010012', 2, '2026-01-21', '001', 'C005', 'E3', 'P0003', 17, 1850.00, NULL, NULL, NULL, NULL),
('SH26010013', 1, '2026-01-22', '001', 'C004', 'E1', 'P0005', 8, 150.00, NULL, NULL, NULL, NULL),
('SH26010013', 2, '2026-01-22', '001', 'C004', 'E1', 'P0004', 19, 4800.00, NULL, NULL, NULL, NULL),
('SH26010013', 3, '2026-01-22', '001', 'C004', 'E1', 'P0001', 3, 450.00, NULL, NULL, NULL, NULL),
('SH26010014', 1, '2026-01-24', '001', 'C002', 'E3', 'P0005', 20, 150.00, NULL, NULL, NULL, NULL),
('SH26010014', 2, '2026-01-24', '001', 'C002', 'E3', 'P0009', 14, 1200.00, NULL, NULL, NULL, NULL),
('SH26010015', 1, '2026-01-26', '001', 'C003', 'E2', 'P0009', 8, 1200.00, NULL, NULL, NULL, NULL),
('SH26010015', 2, '2026-01-26', '001', 'C003', 'E2', 'P0008', 3, 680.00, NULL, NULL, NULL, NULL),
('SH26010015', 3, '2026-01-26', '001', 'C003', 'E2', 'P0002', 11, 320.00, NULL, NULL, NULL, NULL),
('SH26010015', 4, '2026-01-26', '001', 'C003', 'E2', 'P0010', 1, 390.00, NULL, NULL, NULL, NULL),
('SH26010016', 1, '2026-01-27', '001', 'C001', 'E1', 'P0002', 11, 320.00, NULL, NULL, NULL, NULL),
('SH26010016', 2, '2026-01-27', '001', 'C001', 'E1', 'P0001', 3, 450.00, NULL, NULL, NULL, NULL),
('SH26010017', 1, '2026-01-28', '001', 'C002', 'E3', 'P0004', 4, 4800.00, NULL, NULL, NULL, NULL),
('SH26010017', 2, '2026-01-28', '001', 'C002', 'E3', 'P0008', 4, 680.00, NULL, NULL, NULL, NULL),
('SH26010017', 3, '2026-01-28', '001', 'C002', 'E3', 'P0007', 14, 980.00, NULL, NULL, NULL, NULL),
('SH26010017', 4, '2026-01-28', '001', 'C002', 'E3', 'P0002', 12, 320.00, NULL, NULL, NULL, NULL),
('SH26010018', 1, '2026-01-28', '001', 'C001', 'E3', 'P0007', 11, 980.00, NULL, NULL, NULL, NULL),
('SH26010019', 1, '2026-01-29', '001', 'C002', 'E1', 'P0007', 9, 980.00, NULL, NULL, NULL, NULL),
('SH26010019', 2, '2026-01-29', '001', 'C002', 'E1', 'P0003', 15, 1850.00, NULL, NULL, NULL, NULL),
('SH26010020', 1, '2026-01-30', '001', 'C005', 'E1', 'P0002', 8, 320.00, NULL, NULL, NULL, NULL),
('SH26010021', 1, '2026-01-30', '001', 'C004', 'E1', 'P0003', 13, 1850.00, NULL, NULL, NULL, NULL),
('SH26010022', 1, '2026-01-31', '001', 'C004', 'E2', 'P0003', 2, 1850.00, NULL, NULL, NULL, NULL),
('SH26010022', 2, '2026-01-31', '001', 'C004', 'E2', 'P0004', 19, 4800.00, NULL, NULL, NULL, NULL),
('SH26010022', 3, '2026-01-31', '001', 'C004', 'E2', 'P0005', 18, 150.00, NULL, NULL, NULL, NULL),
('SH26010022', 4, '2026-01-31', '001', 'C004', 'E2', 'P0002', 2, 320.00, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

-- Table structure: `sys`

CREATE TABLE IF NOT EXISTS `sys` (
  `No` smallint(1) NOT NULL DEFAULT 0,
  `Company` varchar(30) DEFAULT NULL,
  `Addr` varchar(40) DEFAULT NULL,
  `AC` varchar(10) DEFAULT NULL,
  `Zip` varchar(10) DEFAULT NULL,
  `Phone` varchar(15) DEFAULT NULL,
  `FAX` varchar(15) DEFAULT NULL,
  `TaxRate` smallint(2) DEFAULT NULL,
  `Printer1` varchar(30) DEFAULT NULL,
  `Printer2` varchar(30) DEFAULT NULL,
  `Printer3` varchar(30) DEFAULT NULL,
  `Design` varchar(30) DEFAULT NULL,
  `Cno` int(11) DEFAULT NULL,
  `AcBeg` varchar(6) DEFAULT NULL,
  `AcEnd` varchar(6) DEFAULT NULL,
  `Rem` text DEFAULT NULL,
  `New` text DEFAULT NULL,
  `ipevo` text DEFAULT NULL,
  `sales` text DEFAULT NULL,
  `a2500` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Seed data: `sys`

INSERT INTO `sys` (`No`, `Company`, `Addr`, `AC`, `Zip`, `Phone`, `FAX`, `TaxRate`, `Printer1`, `Printer2`, `Printer3`, `Design`, `Cno`, `AcBeg`, `AcEnd`, `Rem`, `New`, `ipevo`, `sales`, `a2500`) VALUES
(1, 'Global Trading Co., Ltd.', '100 Commerce Rd, 8F-2, Taipei', '02', '10048', '02-8765-1000', '02-8765-1001', 5, 'HP LaserJet Pro', 'Epson L3210', 'Zebra ZD421', 'Default', 1, '202601', '202612', 'Main system configuration for demo/testing.', 'v1.0 dummy dataset', '', 'Sales module enabled', '');

-- --------------------------------------------------------

-- Table structure: `users`

CREATE TABLE IF NOT EXISTS `users` (
  `USERID` varchar(20) NOT NULL DEFAULT '',
  `USERNAME` varchar(30) DEFAULT NULL,
  `PWD` varchar(10) DEFAULT NULL,
  `DESCRIPTION` varchar(100) DEFAULT NULL,
  `EMAIL` varchar(40) DEFAULT NULL,
  `LASTTIME` varchar(8) DEFAULT NULL,
  `AUTOLOGIN` char(1) DEFAULT NULL,
  `LASTDATE` varchar(8) DEFAULT NULL,
  `GSBH` varchar(20) DEFAULT NULL,
  `GSJZ` varchar(30) DEFAULT NULL,
  `BZ` varchar(50) DEFAULT NULL,
  `QZBH` varchar(30) DEFAULT NULL,
  `QZMC` varchar(50) DEFAULT NULL,
  `GRP` char(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Seed data: `users`

INSERT INTO `users` (`USERID`, `USERNAME`, `PWD`, `DESCRIPTION`, `EMAIL`, `LASTTIME`, `AUTOLOGIN`, `LASTDATE`, `GSBH`, `GSJZ`, `BZ`, `QZBH`, `QZMC`, `GRP`) VALUES
('admin', 'admin', '123', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

-- Table structure: `ve`

CREATE TABLE IF NOT EXISTS `ve` (
  `Vno` varchar(10) NOT NULL DEFAULT '',
  `Vname` varchar(30) DEFAULT NULL,
  `Vshort` varchar(8) DEFAULT NULL,
  `Addr1` varchar(40) DEFAULT NULL,
  `Addr2` varchar(40) DEFAULT NULL,
  `AC` varchar(10) DEFAULT NULL,
  `Zip` varchar(10) DEFAULT NULL,
  `Phone` varchar(15) DEFAULT NULL,
  `FAX` varchar(15) DEFAULT NULL,
  `GSM` varchar(15) DEFAULT NULL,
  `Charger` varchar(10) DEFAULT NULL,
  `Contact` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Seed data: `ve`

INSERT INTO `ve` (`Vno`, `Vname`, `Vshort`, `Addr1`, `Addr2`, `AC`, `Zip`, `Phone`, `FAX`, `GSM`, `Charger`, `Contact`) VALUES
('V001', 'Apex Manufacturing Co., Ltd.', 'Apex', '88 Industrial Rd, Zone 3', 'Building A, 5F', '02', '10001', '02-2711-8800', '02-2711-8801', '0912-345-001', 'Kevin Huan', 'Kevin Huan'),
('V002', 'BlueSky Components Inc.', 'BlueSky', '12 Harbor Ave', 'Suite 210', '07', '80001', '07-231-4400', '07-231-4401', '0912-345-002', 'Nina Su', 'Nina Su'),
('V003', 'Northern Supplies Ltd.', 'Northern', '56 Riverside St', '', '04', '40001', '04-2222-3300', '04-2222-3301', '0912-345-003', 'Tom Lin', 'Tom Lin');

--
-- Indexes for the dumped tables
--

-- Index: `cu`
ALTER TABLE `cu`
  ADD PRIMARY KEY (`Cno`),
  ADD KEY `ByName` (`Cname`);

-- Index: `em`
ALTER TABLE `em`
  ADD PRIMARY KEY (`ENo`),
  ADD KEY `ByName` (`EName`),
  ADD KEY `ByXYZ` (`Sex`,`ENo`);

-- Index: `fm`
ALTER TABLE `fm`
  ADD PRIMARY KEY (`FNo`),
  ADD KEY `ByName` (`FName`);

-- Index: `login`
ALTER TABLE `login`
  ADD PRIMARY KEY (`id`,`itm`);

-- Index: `mnu`
ALTER TABLE `mnu`
  ADD PRIMARY KEY (`id`),
  ADD KEY `BySub` (`sub`);

-- Index: `num`
ALTER TABLE `num`
  ADD PRIMARY KEY (`Date`);

-- Index: `pa`
ALTER TABLE `pa`
  ADD PRIMARY KEY (`Pno`);

-- Index: `sh`
ALTER TABLE `sh`
  ADD PRIMARY KEY (`sno`);

-- Index: `sn`
ALTER TABLE `sn`
  ADD PRIMARY KEY (`sno`,`Itm`);

-- Index: `sys`
ALTER TABLE `sys`
  ADD PRIMARY KEY (`No`);

-- Index: `users`
ALTER TABLE `users`
  ADD PRIMARY KEY (`USERID`);

-- Index: `ve`
ALTER TABLE `ve`
  ADD PRIMARY KEY (`Vno`),
  ADD KEY `ByName` (`Vname`);
COMMIT;
