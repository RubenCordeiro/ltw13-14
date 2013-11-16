/* USER MANAGEMENT */

DROP TABLE IF EXISTS role;
DROP TABLE IF EXISTS user;

CREATE TABLE IF NOT EXISTS role (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name CHAR(50) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS user (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username CHAR(50) NOT NULL UNIQUE,
    password CHAR(256) NOT NULL,
    role_id INTEGER NOT NULL,
    FOREIGN KEY(role_id) REFERENCES role(id)
);

/* INVOICING SYSTEM */

DROP TABLE IF EXISTS customer;
DROP TABLE IF EXISTS invoice;
DROP TABLE IF EXISTS product;
DROP TABLE IF EXISTS city;
DROP TABLE IF EXISTS country;
DROP TABLE IF EXISTS line;
DROP TABLE IF EXISTS tax;

CREATE TABLE IF NOT EXISTS country (
    code CHAR(2) PRIMARY KEY,
    name CHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS city (
    id INTEGER PRIMARY KEY,
    name CHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS customer (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    tax_id INTEGER UNIQUE,
    company_name CHAR(100) NOT NULL,
    email CHAR(60) NOT NULL,
    detail CHAR(50),
    city_id INTEGER,
    postal_code CHAR(8) NOT NULL,
    country_code CHAR(2) NOT NULL,
    FOREIGN KEY(city_id) REFERENCES city(id),
    FOREIGN KEY(country_code) REFERENCES country(code)
);

CREATE TABLE IF NOT EXISTS product (
    id INTEGER PRIMARY KEY,
    description CHAR(50) NOT NULL,
    unit_price INTEGER CHECK (unit_price > 0));

CREATE TABLE IF NOT EXISTS invoice (
    id INTEGER PRIMARY KEY,
    billing_date DATE NOT NULL,
    customer_id INTEGER,
    FOREIGN KEY(customer_id) REFERENCES customer(id)
);

CREATE TABLE IF NOT EXISTS line (
    product_id INTEGER,
    line_number INTEGER,
    invoice_id INTEGER,
    quantity INTEGER CHECK (quantity > 0),
    unit_price REAL CHECK (unit_price >= 0),
    tax_id INTEGER,
    PRIMARY KEY(product_id, line_number, invoice_id),
    FOREIGN KEY(product_id) REFERENCES product(id),
    FOREIGN KEY(invoice_id) REFERENCES invoice(id),
    FOREIGN KEY(tax_id) REFERENCES tax(id)
);

CREATE TABLE IF NOT EXISTS tax (
    id INTEGER PRIMARY KEY,
    type CHAR(50) NOT NULL,
    percentage INTEGER CHECK (percentage > 0)
);

INSERT INTO role (name) VALUES
('Reader'),
('Editor'),
('Administrator');

/* INSERTIONS */

INSERT INTO tax (id, type, percentage) VALUES
(1, 'IVA', 23),
(2, 'VAT', 18);

INSERT INTO product (id, description, unit_price) VALUES
(125, 'MSI nGTX560-ti OC edition GPU', 	229),
(126, 'OCZ Vector4 128Gb SSD', 			100),
(127, 'GSkill 1600Mhz 2x2Gb RAM', 		50),
(128, 'Samsung Pinpoint F3 2TB HDD', 	70),
(129, 'Generic Sata cable', 			2),
(130, 'Samsung 840 EVO 512GB SSD', 		380),
(131, 'Asus nGTX 780ti matrix', 		550),
(132, 'Msi R290x Lightning edition', 	500),
(133, 'Asus P67 Sabertooth motherboard', 130),
(134, 'ASRock Z77 pro3 motherboard', 	100),
(135, 'XFX Pro 550W Bronze PSU', 		80),
(136, 'Corsair 1050i Gold PSU', 		120),
(137, 'Coolermaster HAF-X pc case', 	100),
(138, 'Coolermaster HAF-xb pc case', 					90),
(139, 'Corsair carbide R300 pc case', 					70),
(140, 'LG liteon dvd drive', 							20),
(141, 'Computer hardware for dummies book, 2nd edition', 8),
(142, 'Razer Deathadder 2013 edition mouse', 45),
(143, 'Microsoft Office 1 month trial retail', 13),
(144, 'Windows 7.9 premium retail', 79),
(145, 'Asus N550-CN214H laptop', 1100),
(146, 'Asus n56-S4800 laptop', 900),
(147, 'Intel core i5 3930K CPU', 150),
(148, 'Amd A8 cpu', 100),
(149, 'LG 23 inch widescreen LED monitor (1920x1080)', 140),
(150, '50 shades of grey book, 3rd edition', 22);

INSERT INTO line (product_id, line_number, invoice_id, quantity, unit_price, tax_id) VALUES
(125, 1, 1, 3, 90, 1),
(126, 2, 1, 1, 450, 1),
(125, 1, 2, 4, 90, 1),
(126, 2, 2, 10, 450, 1),
(127, 1, 3, 7, 40, 3),
(129, 2 , 3, 7, 2, 3),
(128, 3 , 3, 7, 380, 3),
(129, 4 , 3, 7, 550, 3),
(130, 5 , 3, 7, 500, 3),
(131, 6 , 3, 7, 130, 3),
(132, 7 , 3, 7, 100, 3),
(133, 8 , 3, 7, 80, 3),
(134, 9 , 3, 7, 120, 3),
(135, 10, 3, 7, 100, 3),
(136, 11, 3, 7, 90, 3),
(137, 12, 3, 7, 70, 3),
(138, 13, 3, 7, 20, 3),
(139, 14, 3, 7, 8, 3),
(140, 15, 3, 7, 45, 3),
(141, 16, 3, 7, 13, 3),
(142, 17, 3, 7, 79, 3),
(143, 18, 3, 7, 1100, 3),
(144, 19, 3, 7, 900, 3),
(145, 20, 3, 7, 150, 3),
(146, 21, 3, 7, 100, 3),
(147, 22, 3, 7, 150, 3),
(148, 23, 3, 7, 100, 3),
(148, 1, 4, 7, 140, 3);

INSERT INTO invoice (id, billing_date, customer_id) VALUES
(1, '2013-09-27', 555560),
(2, '2013-09-27', 555560),
(3, '2013-09-30', 555568),
(4, '2013-10-24', 555565),
(5, '2013-10-21', 555566),
(6, '2013-11-10', 555567),
(8, '2013-07-22', 555568);

INSERT INTO city (id, name) VALUES
(1, 'Porto'),
(2, 'Lisbon'),
(3, 'London');

INSERT INTO customer (id, tax_id, company_name, email, detail, city_id, postal_code, country_code) VALUES
(555560, 123, 'FEUP', 'feup@feup.com', 'Faculdade de Engenharia da Universidade do Porto', 1, '4200-465', 'PT'),
(555561, 124, 'UP', 'up@up.com', 'Universidade do Porto', 1, '3222-222', 'PT'),
(555565, 125, 'WSI', 'comercial@wsi-bg.pt', 'Computer store specialized in laptops and costumer disservice', 1, '3343-433', 'PT'),
(555566, 126, 'Alientech', 'comercial@alientech.pt', 'Electronics store', 1, '1233-333', 'PT'),
(555567, 127, 'Fnac', 'comercial@fnac.pt', 'General technology goods store', 1, '1000-155', 'PT'),
(555568, 128, 'Memory', 'comercial@memory.co', 'General technology goods store', 3, '1000-155', 'GB');


INSERT INTO country (code, name) VALUES
('AF', 'Afghanistan'),
('AX', 'Åland Islands'),
('AL', 'Albania'),
('DZ', 'Algeria'),
('AS', 'American Samoa'),
('AD', 'Andorra'),
('AO', 'Angola'),
('AI', 'Anguilla'),
('AQ', 'Antarctica'),
('AG', 'Antigua And Barbuda'),
('AR', 'Argentina'),
('AM', 'Armenia'),
('AW', 'Aruba'),
('AU', 'Australia'),
('AT', 'Austria'),
('AZ', 'Azerbaijan'),
('BS', 'Bahamas'),
('BH', 'Bahrain'),
('BD', 'Bangladesh'),
('BB', 'Barbados'),
('BY', 'Belarus'),
('BE', 'Belgium'),
('BZ', 'Belize'),
('BJ', 'Benin'),
('BM', 'Bermuda'),
('BT', 'Bhutan'),
('BO', 'Bolivia, Plurinational State Of'),
('BQ', 'Bonaire, Sint Eustatius And Saba'),
('BA', 'Bosnia And Herzegovina'),
('BW', 'Botswana'),
('BV', 'Bouvet Island'),
('BR', 'Brazil'),
('IO', 'British Indian Ocean Territory'),
('BN', 'Brunei Darussalam'),
('BG', 'Bulgaria'),
('BF', 'Burkina Faso'),
('BI', 'Burundi'),
('KH', 'Cambodia'),
('CM', 'Cameroon'),
('CA', 'Canada'),
('CV', 'Cape Verde'),
('KY', 'Cayman Islands'),
('CF', 'Central African Republic'),
('TD', 'Chad'),
('CL', 'Chile'),
('CN', 'China'),
('CX', 'Christmas Island'),
('CC', 'Cocos (Keeling) Islands'),
('CO', 'Colombia'),
('KM', 'Comoros'),
('CG', 'Congo'),
('CD', 'Congo, The Democratic Republic Of The'),
('CK', 'Cook Islands'),
('CR', 'Costa Rica'),
('CI', 'Côte D`Ivoire'),
('HR', 'Croatia'),
('CU', 'Cuba'),
('CW', 'Curaçao'),
('CY', 'Cyprus'),
('CZ', 'Czech Republic'),
('DK', 'Denmark'),
('DJ', 'Djibouti'),
('DM', 'Dominica'),
('DO', 'Dominican Republic'),
('EC', 'Ecuador'),
('EG', 'Egypt'),
('SV', 'El Salvador'),
('GQ', 'Equatorial Guinea'),
('ER', 'Eritrea'),
('EE', 'Estonia'),
('ET', 'Ethiopia'),
('FK', 'Falkland Islands (Malvinas)'),
('FO', 'Faroe Islands'),
('FJ', 'Fiji'),
('FI', 'Finland'),
('FR', 'France'),
('GF', 'French Guiana'),
('PF', 'French Polynesia'),
('TF', 'French Southern Territories'),
('GA', 'Gabon'),
('GM', 'Gambia'),
('GE', 'Georgia'),
('DE', 'Germany'),
('GH', 'Ghana'),
('GI', 'Gibraltar'),
('GR', 'Greece'),
('GL', 'Greenland'),
('GD', 'Grenada'),
('GP', 'Guadeloupe'),
('GU', 'Guam'),
('GT', 'Guatemala'),
('GG', 'Guernsey'),
('GN', 'Guinea'),
('GW', 'Guinea-Bissau'),
('GY', 'Guyana'),
('HT', 'Haiti'),
('HM', 'Heard Island And Mcdonald Islands'),
('VA', 'Holy See (Vatican City State)'),
('HN', 'Honduras'),
('HK', 'Hong Kong'),
('HU', 'Hungary'),
('IS', 'Iceland'),
('IN', 'India'),
('ID', 'Indonesia'),
('IR', 'Iran, Islamic Republic Of'),
('IQ', 'Iraq'),
('IE', 'Ireland'),
('IM', 'Isle Of Man'),
('IL', 'Israel'),
('IT', 'Italy'),
('JM', 'Jamaica'),
('JP', 'Japan'),
('JE', 'Jersey'),
('JO', 'Jordan'),
('KZ', 'Kazakhstan'),
('KE', 'Kenya'),
('KI', 'Kiribati'),
('KP', 'Korea, Democratic People`s Republic Of'),
('KR', 'Korea, Republic Of'),
('KW', 'Kuwait'),
('KG', 'Kyrgyzstan'),
('LA', 'Lao People`S Democratic Republic'),
('LV', 'Latvia'),
('LB', 'Lebanon'),
('LS', 'Lesotho'),
('LR', 'Liberia'),
('LY', 'Libya'),
('LI', 'Liechtenstein'),
('LT', 'Lithuania'),
('LU', 'Luxembourg'),
('MO', 'Macao'),
('MK', 'Macedonia, The Former Yugoslav Republic Of'),
('MG', 'Madagascar'),
('MW', 'Malawi'),
('MY', 'Malaysia'),
('MV', 'Maldives'),
('ML', 'Mali'),
('MT', 'Malta'),
('MH', 'Marshall Islands'),
('MQ', 'Martinique'),
('MR', 'Mauritania'),
('MU', 'Mauritius'),
('YT', 'Mayotte'),
('MX', 'Mexico'),
('FM', 'Micronesia, Federated States Of'),
('MD', 'Moldova, Republic Of'),
('MC', 'Monaco'),
('MN', 'Mongolia'),
('ME', 'Montenegro'),
('MS', 'Montserrat'),
('MA', 'Morocco'),
('MZ', 'Mozambique'),
('MM', 'Myanmar'),
('NA', 'Namibia'),
('NR', 'Nauru'),
('NP', 'Nepal'),
('NL', 'Netherlands'),
('NC', 'New Caledonia'),
('NZ', 'New Zealand'),
('NI', 'Nicaragua'),
('NE', 'Niger'),
('NG', 'Nigeria'),
('NU', 'Niue'),
('NF', 'Norfolk Island'),
('MP', 'Northern Mariana Islands'),
('NO', 'Norway'),
('OM', 'Oman'),
('PK', 'Pakistan'),
('PW', 'Palau'),
('PS', 'Palestine, State Of'),
('PA', 'Panama'),
('PG', 'Papua New Guinea'),
('PY', 'Paraguay'),
('PE', 'Peru'),
('PH', 'Philippines'),
('PN', 'Pitcairn'),
('PL', 'Poland'),
('PT', 'Portugal'),
('PR', 'Puerto Rico'),
('QA', 'Qatar'),
('RE', 'Réunion'),
('RO', 'Romania'),
('RU', 'Russian Federation'),
('RW', 'Rwanda'),
('BL', 'Saint Barthélemy'),
('SH', 'Saint Helena, Ascension And Tristan Da Cunha'),
('KN', 'Saint Kitts And Nevis'),
('LC', 'Saint Lucia'),
('MF', 'Saint Martin (French Part)'),
('PM', 'Saint Pierre And Miquelon'),
('VC', 'Saint Vincent And The Grenadines'),
('WS', 'Samoa'),
('SM', 'San Marino'),
('ST', 'Sao Tome And Principe'),
('SA', 'Saudi Arabia'),
('SN', 'Senegal'),
('RS', 'Serbia'),
('SC', 'Seychelles'),
('SL', 'Sierra Leone'),
('SG', 'Singapore'),
('SX', 'Sint Maarten (Dutch Part)'),
('SK', 'Slovakia'),
('SI', 'Slovenia'),
('SB', 'Solomon Islands'),
('SO', 'Somalia'),
('ZA', 'South Africa'),
('GS', 'South Georgia And The South Sandwich Islands'),
('SS', 'South Sudan'),
('ES', 'Spain'),
('LK', 'Sri Lanka'),
('SD', 'Sudan'),
('SR', 'Suriname'),
('SJ', 'Svalbard And Jan Mayen'),
('SZ', 'Swaziland'),
('SE', 'Sweden'),
('CH', 'Switzerland'),
('SY', 'Syrian Arab Republic'),
('TW', 'Taiwan, Province Of China'),
('TJ', 'Tajikistan'),
('TZ', 'Tanzania, United Republic Of'),
('TH', 'Thailand'),
('TL', 'Timor-Leste'),
('TG', 'Togo'),
('TK', 'Tokelau'),
('TO', 'Tonga'),
('TT', 'Trinidad And Tobago'),
('TN', 'Tunisia'),
('TR', 'Turkey'),
('TM', 'Turkmenistan'),
('TC', 'Turks And Caicos Islands'),
('TV', 'Tuvalu'),
('UG', 'Uganda'),
('UA', 'Ukraine'),
('AE', 'United Arab Emirates'),
('GB', 'United Kingdom'),
('US', 'United States'),
('UM', 'United States Minor Outlying Islands'),
('UY', 'Uruguay'),
('UZ', 'Uzbekistan'),
('VU', 'Vanuatu'),
('VE', 'Venezuela, Bolivarian Republic Of'),
('VN', 'Viet Nam'),
('VG', 'Virgin Islands, British'),
('VI', 'Virgin Islands, U.S.'),
('WF', 'Wallis And Futuna'),
('EH', 'Western Sahara'),
('YE', 'Yemen'),
('ZM', 'Zambia'),
('ZW', 'Zimbabwe');

/* QUERIES */

-- lines_per_invoice
SELECT
    product.id AS "Product code",
    line.line_number AS "Line",
    invoice.billing_date AS "Date",
    customer.company_name AS "Company"
FROM invoice
    JOIN line ON invoice.id = line.invoice_id
    JOIN customer ON customer.id = invoice.id
    JOIN product ON line.product_id = product.id
GROUP BY invoice.id
ORDER BY line.line_number ASC;
