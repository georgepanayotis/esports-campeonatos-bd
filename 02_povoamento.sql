-- =====================================================================
-- PROJETO FINAL - BANCO DE DADOS
-- Sistema de Gerenciamento de Campeonatos de E-sports
-- Arquivo: 02_povoamento.sql  (DML - insercao dos dados)
--
-- FONTE DOS DADOS
--   Times, jogadores, treinadores, jogos, mapas, paises, patrocinadores e
--   campeonatos sao REAIS, com base em fontes publicas (Liquipedia, HLTV,
--   VLR.gg, Leaguepedia), usando a temporada 2024 como recorte.
--   Sao APROXIMADOS: datas de nascimento, datas de fundacao e premiacoes.
--   Sao ILUSTRATIVOS: partidas, placares, estatisticas, colocacoes (exceto
--   os campeoes indicados), pares de patrocinio e valores de contrato.
--
-- ORDEM: tabelas "pai" primeiro, associativas por ultimo.
-- Os ids sao informados explicitamente para as FKs ficarem legiveis.
-- Rode depois do 01_criacao_tabelas.sql, com as tabelas VAZIAS.
-- =====================================================================

USE gerenciadorEsports;

-- ---------------------------------------------------------------------
-- 1. PAIS (20 registros)
-- ---------------------------------------------------------------------
INSERT INTO pais (id, nome, sigla) VALUES
(1,  'Brasil',               'BRA'),
(2,  'Estados Unidos',       'USA'),
(3,  'Coreia do Sul',        'KOR'),
(4,  'China',                'CHN'),
(5,  'França',               'FRA'),
(6,  'Ucrânia',              'UKR'),
(7,  'Dinamarca',            'DNK'),
(8,  'Finlândia',            'FIN'),
(9,  'Reino Unido',          'GBR'),
(10, 'Canadá',               'CAN'),
(11, 'Argentina',            'ARG'),
(12, 'Lituânia',             'LTU'),
(13, 'Estônia',              'EST'),
(14, 'Bósnia e Herzegovina', 'BIH'),
(15, 'Rússia',               'RUS'),
(16, 'Espanha',              'ESP'),
(17, 'Países Baixos',        'NLD'),
(18, 'Suécia',               'SWE'),
(19, 'Alemanha',             'DEU'),
(20, 'Austrália',            'AUS');

-- ---------------------------------------------------------------------
-- 2. JOGO (15 registros) - foco em LoL (1), Valorant (2) e CS2 (3)
-- ---------------------------------------------------------------------
INSERT INTO jogo (id, nome, desenvolvedora, genero, ano_lancamento) VALUES
(1,  'League of Legends',             'Riot Games',            'MOBA', 2009),
(2,  'Valorant',                      'Riot Games',            'FPS',  2020),
(3,  'Counter-Strike 2',              'Valve',                 'FPS',  2023),
(4,  'Dota 2',                        'Valve',                 'MOBA', 2013),
(5,  'Rainbow Six Siege',             'Ubisoft',               'FPS',  2015),
(6,  'Overwatch 2',                   'Blizzard Entertainment','FPS',  2022),
(7,  'Apex Legends',                  'Respawn Entertainment', 'FPS',  2019),
(8,  'Halo Infinite',                 '343 Industries',        'FPS',  2021),
(9,  'PUBG: Battlegrounds',           'PUBG Studios',          'FPS',  2017),
(10, 'Mobile Legends: Bang Bang',     'Moonton',               'MOBA', 2016),
(11, 'League of Legends: Wild Rift',  'Riot Games',            'MOBA', 2020),
(12, 'Arena of Valor',                'TiMi Studio Group',     'MOBA', 2016),
(13, 'Smite',                         'Hi-Rez Studios',        'MOBA', 2014),
(14, 'Heroes of the Storm',           'Blizzard Entertainment','MOBA', 2015),
(15, 'Pokémon Unite',                 'TiMi Studio Group',     'MOBA', 2021);

-- ---------------------------------------------------------------------
-- 3. PATROCINADOR (15 registros)
-- ---------------------------------------------------------------------
INSERT INTO patrocinador (id, nome, seguimento) VALUES
(1,  'Red Bull',       'Bebidas'),
(2,  'Monster Energy', 'Bebidas'),
(3,  'Logitech G',     'Periféricos'),
(4,  'HyperX',         'Periféricos'),
(5,  'Razer',          'Periféricos'),
(6,  'Intel',          'Hardware'),
(7,  'AMD',            'Hardware'),
(8,  'Secretlab',      'Mobiliário'),
(9,  'Mercedes-Benz',  'Automotivo'),
(10, 'BMW',            'Automotivo'),
(11, 'Nike',           'Vestuário'),
(12, 'Santander',      'Banco'),
(13, 'Samsung',        'Eletrônicos'),
(14, 'Puma',           'Vestuário'),
(15, 'Coca-Cola',      'Bebidas');

-- ---------------------------------------------------------------------
-- 4. TIME (15 registros) - depende de PAIS
-- ---------------------------------------------------------------------
INSERT INTO time (id, nome, sigla, data_fundacao, id_pais) VALUES
(1,  'LOUD',            'LLL',  '2019-02-01', 1),
(2,  'FURIA',           'FUR',  '2017-08-01', 1),
(3,  'paiN Gaming',     'PNG',  '2010-11-01', 1),
(4,  'MIBR',            'MIBR', '2003-01-01', 1),
(5,  'Sentinels',       'SEN',  '2016-11-01', 2),
(6,  'T1',              'T1',   '2004-04-01', 3),
(7,  'Gen.G',           'GEN',  '2017-08-01', 3),
(8,  'Fnatic',          'FNC',  '2004-07-01', 9),
(9,  'Team Vitality',   'VIT',  '2013-08-01', 5),
(10, 'Natus Vincere',   'NAVI', '2009-12-01', 6),
(11, 'FaZe Clan',       'FAZE', '2010-05-01', 2),
(12, 'G2 Esports',      'G2',   '2014-02-01', 16),
(13, 'Team Heretics',   'TH',   '2016-01-01', 16),
(14, 'EDward Gaming',   'EDG',  '2013-09-01', 4),
(15, 'Team Liquid',     'TL',   '2000-01-01', 17);

-- ---------------------------------------------------------------------
-- 5. TREINADOR (15 registros) - depende de PAIS e TIME
-- id_time NULL = treinador sem time neste recorte (relacao 1:1 opcional)
-- ---------------------------------------------------------------------
INSERT INTO treinador (id, nome, nickname, id_pais, id_time) VALUES
(1,  'Matheus Tarasconi',   'bzkA',          1,  1),
(2,  'Sid Macedo',          'sidde',         1,  2),
(3,  'Kim Jeong-gyun',      'kkOma',         3,  6),
(4,  'Kim Jeong-soo',       'Kim',           3,  7),
(5,  'Adam Kaplan',         'kaplan',        2,  5),
(6,  'Jacob Harris',        'CoJo',          9,  8),
(7,  'Rémy Quoniam',        'XTQZZZ',        5,  9),
(8,  'Andrii Gorodenskyi',  'B1ad3',         6,  10),
(9,  'Robert Dahlström',    'RobbaN',        18, 11),
(10, 'Dylan Falco',         'DylanFalco',    2,  12),
(11, 'Danny Sørensen',      'zonic',         7,  NULL),
(12, 'Luis Tadeu',          'peacemaker',    1,  NULL),
(13, 'Jakob Mebdi',         'YamatoCannon',  18, NULL),
(14, 'Fabian Lohmann',      'Grabbz',        19, NULL),
(15, 'Kim Sang-soo',        'Ssong',         3,  NULL);

-- ---------------------------------------------------------------------
-- 6. JOGADOR (34 registros) - depende de TIME, JOGO e PAIS
-- funcao: Valorant = Duelista/Iniciador/Controlador/Sentinela
--         LoL = Top/Cacador/Mid/Atirador/Suporte | CS2 = AWPer/Rifler/IGL
-- status 'I' + id_time NULL = jogador inativo/sem time
-- ---------------------------------------------------------------------
INSERT INTO jogador (id, nickname, nome, data_nascimento, funcao, status, id_time, id_jogo, id_pais) VALUES
-- Valorant
(1,  'Saadhak',    'Matias Delipetro',       '1997-07-21', 'Iniciador',   'A', 1,  2, 11),
(2,  'Less',       'Felipe Basso',           '2005-01-18', 'Sentinela',   'A', 1,  2, 1),
(3,  'TenZ',       'Tyson Ngo',              '2001-05-05', 'Duelista',    'A', 5,  2, 10),
(4,  'zekken',     'Zachary Patrone',        '2004-05-23', 'Duelista',    'A', 5,  2, 2),
(5,  'Sacy',       'Gustavo Rossi',          '1997-08-07', 'Iniciador',   'A', 5,  2, 1),
(6,  'Meteor',     'Kim Tae-oh',             '2001-03-18', 'Sentinela',   'A', 7,  2, 3),
(7,  't3xture',    'Kim Na-ra',              '2000-08-12', 'Duelista',    'A', 7,  2, 3),
(8,  'Boaster',    'Jake Howlett',           '1995-05-25', 'Controlador', 'A', 8,  2, 9),
(9,  'Derke',      'Nikita Sirmitev',        '2002-12-06', 'Duelista',    'A', 8,  2, 8),
(10, 'MiniBoo',    'Dominykas Lukaševičius', '2005-07-02', 'Duelista',    'A', 13, 2, 12),
(11, 'benjyfishy', 'Benjy Fish',             '2004-04-09', 'Sentinela',   'A', 13, 2, 9),
(12, 'ZmjjKK',     'Zheng Yongkang',         '2003-10-11', 'Duelista',    'A', 14, 2, 4),
(13, 'CHICHOO',    'Wan Shunzhi',            '2001-02-15', 'Iniciador',   'A', 14, 2, 4),
-- League of Legends
(14, 'Faker',      'Lee Sang-hyeok',         '1996-05-07', 'Mid',         'A', 6,  1, 3),
(15, 'Keria',      'Ryu Min-seok',           '2002-10-14', 'Suporte',     'A', 6,  1, 3),
(16, 'Gumayusi',   'Lee Min-hyeong',         '2002-02-06', 'Atirador',    'A', 6,  1, 3),
(17, 'Chovy',      'Jeong Ji-hoon',          '2001-03-03', 'Mid',         'A', 7,  1, 3),
(18, 'Canyon',     'Kim Geon-bu',            '2001-06-18', 'Caçador',     'A', 7,  1, 3),
(19, 'Caps',       'Rasmus Winther',         '1999-11-17', 'Mid',         'A', 12, 1, 7),
(20, 'brTT',       'Felipe Gonçalves',       '1991-03-28', 'Atirador',    'I', NULL, 1, 1),
-- Counter-Strike 2
(21, 'FalleN',     'Gabriel Toledo',         '1991-05-30', 'AWPer',       'A', 2,  3, 1),
(22, 'KSCERATO',   'Kaike Cerato',           '1999-09-12', 'Rifler',      'A', 2,  3, 1),
(23, 'yuurih',     'Yuri Boian',             '1999-12-22', 'Rifler',      'A', 2,  3, 1),
(24, 'ZywOo',      'Mathieu Herbaut',        '2000-11-09', 'AWPer',       'A', 9,  3, 5),
(25, 'apEX',       'Dan Madesclaire',        '1993-02-22', 'IGL',         'A', 9,  3, 5),
(26, 'b1t',        'Valerii Vakhovskyi',     '2003-01-05', 'Rifler',      'A', 10, 3, 6),
(27, 'jL',         'Justinas Lekavičius',    '1999-09-29', 'Rifler',      'A', 10, 3, 12),
(28, 'karrigan',   'Finn Andersen',          '1990-04-14', 'IGL',         'A', 11, 3, 7),
(29, 'ropz',       'Robin Kool',             '1999-12-22', 'Rifler',      'A', 11, 3, 13),
(30, 'NiKo',       'Nikola Kovač',           '1997-02-16', 'Rifler',      'A', 12, 3, 14),
(31, 'm0NESY',     'Ilya Osipov',            '2005-05-01', 'AWPer',       'A', 12, 3, 15),
(32, 'exit',       'Raphael Lacerda',        '1997-01-29', 'Rifler',      'A', 4,  3, 1),
(33, 'NAF',        'Keith Markovic',         '1997-11-24', 'Rifler',      'A', 15, 3, 10),
(34, 's1mple',     'Oleksandr Kostyliev',    '1997-10-02', 'AWPer',       'I', NULL, 3, 6);

-- ---------------------------------------------------------------------
-- 7. CAMPEONATO (15 registros) - depende de JOGO
-- premiacao em dolares (USD), valores aproximados
-- ---------------------------------------------------------------------
INSERT INTO campeonato (id, nome, id_jogo, data_inicio, data_fim, premiacao) VALUES
-- League of Legends
(1,  'Worlds 2024',                         1, '2024-09-25', '2024-11-02', 2225000.00),
(2,  'Mid-Season Invitational 2024',        1, '2024-05-01', '2024-05-19', 2000000.00),
(3,  'LCK Spring 2024',                     1, '2024-01-17', '2024-04-14', 300000.00),
(4,  'CBLOL 2024 - 2ª Etapa',               1, '2024-06-08', '2024-09-07', 150000.00),
(5,  'LEC Season Finals 2024',              1, '2024-08-24', '2024-09-08', 200000.00),
-- Valorant
(6,  'VCT Masters Madrid 2024',             2, '2024-03-14', '2024-03-24', 500000.00),
(7,  'VCT Masters Shanghai 2024',           2, '2024-05-23', '2024-06-09', 1000000.00),
(8,  'Valorant Champions 2024',             2, '2024-08-01', '2024-08-25', 2250000.00),
-- Counter-Strike 2
(11, 'PGL Major Copenhagen 2024',           3, '2024-03-17', '2024-03-31', 1250000.00),
(12, 'Perfect World Shanghai Major 2024',   3, '2024-11-30', '2024-12-15', 1250000.00),
(13, 'IEM Katowice 2024',                   3, '2024-01-31', '2024-02-11', 1000000.00),
(14, 'IEM Cologne 2024',                    3, '2024-08-07', '2024-08-25', 1000000.00),
(15, 'BLAST Premier World Final 2024',      3, '2024-10-30', '2024-11-03', 1000000.00);

-- Sem premiacao informada: o DEFAULT 0.00 e aplicado automaticamente
INSERT INTO campeonato (id, nome, id_jogo, data_inicio, data_fim) VALUES
(9,  'VCT Americas Kickoff 2024',           2, '2024-02-16', '2024-03-03'),
(10, 'VCT EMEA Stage 1 2024',               2, '2024-04-03', '2024-05-12');

-- ---------------------------------------------------------------------
-- 8. MAPA (16 registros) - depende de JOGO
-- ---------------------------------------------------------------------
INSERT INTO mapa (id, nome, id_jogo) VALUES
(1,  'Summoner''s Rift', 1),
(2,  'Ascent',   2),
(3,  'Haven',    2),
(4,  'Bind',     2),
(5,  'Lotus',    2),
(6,  'Split',    2),
(7,  'Sunset',   2),
(8,  'Icebox',   2),
(9,  'Mirage',   3),
(10, 'Inferno',  3),
(11, 'Nuke',     3),
(12, 'Ancient',  3),
(13, 'Anubis',   3),
(14, 'Dust2',    3),
(15, 'Vertigo',  3),
(16, 'Overpass', 3);

-- ---------------------------------------------------------------------
-- 9. PARTIDA (15 registros) - depende de CAMPEONATO, MAPA e TIME
-- Cada registro = 1 mapa jogado. Resultados ilustrativos.
-- ---------------------------------------------------------------------
INSERT INTO partida (id, id_campeonato, id_mapa, id_time_a, id_time_b, id_vencedor, data_hora, fase) VALUES
-- VCT Masters Madrid 2024 (Valorant)
(1,  6,  2,  5,  7,  5,  '2024-03-24 14:00:00', 'Final'),
(2,  6,  5,  5,  7,  7,  '2024-03-24 15:30:00', 'Final'),
(3,  6,  7,  5,  7,  5,  '2024-03-24 17:00:00', 'Final'),
(4,  6,  4,  8,  13, 8,  '2024-03-15 13:00:00', 'Fase de grupos'),
(5,  6,  6,  7,  8,  7,  '2024-03-20 13:00:00', 'Playoffs'),
-- Valorant Champions 2024
(6,  8,  3,  14, 13, 14, '2024-08-25 14:00:00', 'Final'),
(7,  8,  2,  14, 13, 13, '2024-08-25 15:30:00', 'Final'),
(8,  8,  8,  8,  13, 13, '2024-08-23 15:00:00', 'Semifinal'),
-- PGL Major Copenhagen 2024 (CS2)
(9,  11, 12, 10, 11, 10, '2024-03-31 15:00:00', 'Final'),
(10, 11, 11, 10, 11, 10, '2024-03-31 16:30:00', 'Final'),
(11, 11, 9,  9,  2,  9,  '2024-03-25 12:00:00', 'Fase de grupos'),
(12, 11, 10, 12, 10, 10, '2024-03-30 15:00:00', 'Semifinal'),
-- IEM Cologne 2024 (CS2)
(13, 14, 14, 9,  10, 9,  '2024-08-25 14:00:00', 'Final'),
-- Worlds 2024 (LoL)
(14, 1,  1,  6,  7,  6,  '2024-10-26 09:00:00', 'Semifinal');

-- Sem fase informada: o DEFAULT 'Fase de grupos' e aplicado
INSERT INTO partida (id, id_campeonato, id_mapa, id_time_a, id_time_b, id_vencedor, data_hora) VALUES
(15, 1,  1,  12, 3,  12, '2024-10-05 06:00:00');

-- =====================================================================
-- TABELAS ASSOCIATIVAS (N:N)
-- =====================================================================

-- ---------------------------------------------------------------------
-- 10. INSCRICAO (46 registros) - TIME <-> CAMPEONATO
-- Campeoes reais: T1 (Worlds), Gen.G (MSI e LCK Spring), Sentinels (Madrid),
-- Gen.G (Shanghai), EDG (Champions), NAVI (Copenhagen), Vitality (Cologne).
-- Demais colocacoes sao ilustrativas.
-- ---------------------------------------------------------------------
INSERT INTO inscricao (id_time, id_campeonato, data_inscricao, colocacao_final) VALUES
-- Worlds 2024
(6,  1,  '2024-08-20', 1),
(7,  1,  '2024-08-20', 3),
(12, 1,  '2024-08-25', 9),
(3,  1,  '2024-09-08', 17),
-- MSI 2024
(7,  2,  '2024-04-14', 1),
(6,  2,  '2024-04-14', 3),
(12, 2,  '2024-04-15', 4),
-- LCK Spring 2024
(7,  3,  '2024-01-05', 1),
(6,  3,  '2024-01-05', 2),
-- CBLOL 2024 - 2a Etapa
(3,  4,  '2024-05-20', 1),
(1,  4,  '2024-05-20', 2),
(2,  4,  '2024-05-20', 5),
-- LEC Season Finals 2024
(12, 5,  '2024-08-01', 1),
(8,  5,  '2024-08-01', 2),
-- VCT Masters Madrid 2024
(5,  6,  '2024-02-20', 1),
(7,  6,  '2024-02-20', 2),
(8,  6,  '2024-02-22', 4),
(13, 6,  '2024-02-22', 5),
(14, 6,  '2024-02-25', 7),
-- VCT Masters Shanghai 2024
(7,  7,  '2024-04-25', 1),
(13, 7,  '2024-04-28', 2),
(5,  7,  '2024-04-25', 7),
-- Valorant Champions 2024
(14, 8,  '2024-07-01', 1),
(13, 8,  '2024-07-03', 2),
(8,  8,  '2024-07-03', 4),
-- VCT Americas Kickoff 2024
(5,  9,  '2024-01-20', 3),
(1,  9,  '2024-01-20', 4),
-- VCT EMEA Stage 1 2024
(8,  10, '2024-03-28', 1),
(13, 10, '2024-03-28', 2),
-- PGL Major Copenhagen 2024
(10, 11, '2024-02-15', 1),
(11, 11, '2024-02-15', 2),
(12, 11, '2024-02-16', 3),
(9,  11, '2024-02-16', 5),
(2,  11, '2024-02-20', 12),
-- Perfect World Shanghai Major 2024
(11, 12, '2024-10-15', 2),
(9,  12, '2024-10-15', 5),
(4,  12, '2024-10-20', 9),
-- IEM Katowice 2024
(11, 13, '2024-01-10', 2),
(9,  13, '2024-01-10', 5),
(10, 13, '2024-01-10', 6),
-- IEM Cologne 2024
(9,  14, '2024-07-15', 1),
(10, 14, '2024-07-15', 2),
(12, 14, '2024-07-15', 4),
-- BLAST Premier World Final 2024
(12, 15, '2024-10-01', 1),
(11, 15, '2024-10-01', 3),
(10, 15, '2024-10-01', 4);

-- ---------------------------------------------------------------------
-- 11. ESTATISTICA_PARTIDA (53 registros) - JOGADOR <-> PARTIDA
-- Valores ilustrativos de abates, mortes e assistencias por mapa.
-- ---------------------------------------------------------------------
INSERT INTO estatistica_partida (id_jogador, id_partida, abates, mortes, assistencias) VALUES
-- Partida 1: Sentinels x Gen.G (Ascent)
(3,  1, 24, 15, 4),
(4,  1, 21, 16, 6),
(5,  1, 14, 14, 11),
(6,  1, 15, 18, 5),
(7,  1, 19, 18, 3),
-- Partida 2: Sentinels x Gen.G (Lotus)
(3,  2, 17, 19, 3),
(4,  2, 15, 18, 5),
(6,  2, 20, 13, 7),
(7,  2, 23, 15, 4),
-- Partida 3: Sentinels x Gen.G (Sunset)
(4,  3, 26, 14, 5),
(5,  3, 16, 12, 12),
(7,  3, 18, 20, 2),
-- Partida 4: Fnatic x Team Heretics (Bind)
(8,  4, 12, 15, 10),
(9,  4, 25, 14, 3),
(10, 4, 18, 18, 4),
(11, 4, 13, 17, 6),
-- Partida 5: Gen.G x Fnatic (Split)
(6,  5, 17, 12, 8),
(7,  5, 22, 14, 3),
(9,  5, 19, 17, 2),
-- Partida 6: EDG x Team Heretics (Haven)
(12, 6, 27, 15, 4),
(13, 6, 15, 13, 13),
(10, 6, 20, 19, 3),
-- Partida 7: EDG x Team Heretics (Ascent)
(12, 7, 16, 18, 2),
(10, 7, 24, 14, 5),
(11, 7, 17, 13, 8),
-- Partida 8: Fnatic x Team Heretics (Icebox)
(9,  8, 21, 18, 4),
(8,  8, 9,  17, 9),
(10, 8, 22, 15, 6),
-- Partida 9: NAVI x FaZe (Ancient)
(26, 9, 19, 14, 5),
(27, 9, 22, 13, 4),
(28, 9, 11, 18, 6),
(29, 9, 17, 17, 3),
-- Partida 10: NAVI x FaZe (Nuke)
(26, 10, 16, 15, 4),
(27, 10, 20, 12, 7),
(29, 10, 18, 16, 2),
-- Partida 11: Vitality x FURIA (Mirage)
(24, 11, 28, 12, 5),
(25, 11, 13, 16, 8),
(21, 11, 14, 19, 3),
(22, 11, 19, 17, 4),
(23, 11, 15, 18, 6),
-- Partida 12: G2 x NAVI (Inferno)
(30, 12, 21, 18, 4),
(31, 12, 18, 17, 2),
(26, 12, 20, 15, 6),
(27, 12, 23, 14, 3),
-- Partida 13: Vitality x NAVI (Dust2)
(24, 13, 25, 14, 3),
(25, 13, 14, 15, 9),
(26, 13, 16, 19, 4),
-- Partida 14: T1 x Gen.G (Summoner's Rift)
(14, 14, 5,  1,  8),
(15, 14, 1,  2,  14),
(16, 14, 7,  2,  6),
(17, 14, 3,  4,  5),
(18, 14, 2,  3,  6),
-- Partida 15: G2 x paiN Gaming (Summoner's Rift)
(19, 15, 6,  1,  9);

-- ---------------------------------------------------------------------
-- 12. PATROCINIO (21 registros) - TIME <-> PATROCINADOR
-- Pares e valores ilustrativos (contratos reais nao sao publicos). USD/ano.
-- ---------------------------------------------------------------------
INSERT INTO patrocinio (id_time, id_patrocinador, valor_anual, data_inicio) VALUES
(6,  11, 1500000.00, '2024-01-01'),
(6,  13, 1200000.00, '2023-01-01'),
(6,  1,   800000.00, '2022-06-01'),
(7,  9,   900000.00, '2023-03-01'),
(1,  1,   500000.00, '2023-02-01'),
(1,  12,  700000.00, '2023-05-01'),
(2,  4,   400000.00, '2022-08-01'),
(2,  14,  600000.00, '2023-01-01'),
(9,  1,   650000.00, '2022-01-01'),
(10, 15,  550000.00, '2023-04-01'),
(10, 5,   450000.00, '2022-09-01'),
(8,  10, 1000000.00, '2021-01-01'),
(8,  3,   500000.00, '2023-07-01'),
(11, 6,   750000.00, '2022-03-01'),
(12, 10, 1100000.00, '2021-06-01'),
(12, 3,   600000.00, '2024-01-01'),
(5,  8,   300000.00, '2023-02-01'),
(13, 7,   350000.00, '2024-02-01'),
(14, 13,  400000.00, '2023-01-01'),
(3,  15,  250000.00, '2024-03-01'),
(15, 6,   500000.00, '2022-05-01');
