-- =====================================================================
-- PROJETO FINAL - BANCO DE DADOS
-- Sistema de Gerenciamento de Campeonatos de E-sports
-- Arquivo: 01_criacao_tabelas.sql  (DDL - criacao do banco e das tabelas)
-- SGBD: MariaDB 10.x (XAMPP) / compativel com MySQL 8.0.16+
--
-- Ordem de criacao: primeiro as tabelas que nao dependem de ninguem,
-- depois as que tem chave estrangeira, e por ultimo as associativas (N:N).
-- =====================================================================

DROP DATABASE IF EXISTS gerenciadorEsports;
CREATE DATABASE gerenciadorEsports
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_general_ci;
USE gerenciadorEsports;

-- ---------------------------------------------------------------------
-- 1. PAIS
-- Criada para a normalizacao (3FN): o nome do pais e guardado uma unica
-- vez e as outras tabelas apenas apontam para ele pelo id.
-- ---------------------------------------------------------------------
CREATE TABLE pais (
  id     INT PRIMARY KEY AUTO_INCREMENT,
  nome   VARCHAR(40) NOT NULL UNIQUE,
  sigla  VARCHAR(5)  NOT NULL UNIQUE          -- ex.: BRA, KOR, USA
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 2. JOGO
-- Jogos competitivos cobertos pelo sistema.
-- desenvolvedora NAO e UNIQUE: uma empresa pode ter varios jogos.
-- ---------------------------------------------------------------------
CREATE TABLE jogo (
  id              INT PRIMARY KEY AUTO_INCREMENT,
  nome            VARCHAR(50) NOT NULL UNIQUE,
  desenvolvedora  VARCHAR(40) NOT NULL,
  genero          VARCHAR(10) NOT NULL,
  ano_lancamento  SMALLINT    NOT NULL,
  CONSTRAINT ck_jogo_genero CHECK (genero IN ('FPS', 'MOBA')),
  CONSTRAINT ck_jogo_ano    CHECK (ano_lancamento BETWEEN 1990 AND 2100)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 3. PATROCINADOR
-- ---------------------------------------------------------------------
CREATE TABLE patrocinador (
  id          INT PRIMARY KEY AUTO_INCREMENT,
  nome        VARCHAR(40) NOT NULL UNIQUE,
  seguimento  VARCHAR(40) NOT NULL              -- ex.: Bebidas, Hardware
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 4. TIME  (1 pais -> N times)
-- ---------------------------------------------------------------------
CREATE TABLE time (
  id             INT PRIMARY KEY AUTO_INCREMENT,
  nome           VARCHAR(50) NOT NULL UNIQUE,
  sigla          VARCHAR(5)  NOT NULL UNIQUE,
  data_fundacao  DATE        NOT NULL,
  id_pais        INT         NOT NULL,
  FOREIGN KEY (id_pais) REFERENCES pais(id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 5. TREINADOR  (1 pais -> N treinadores | TIME 1:1 TREINADOR)
-- O UNIQUE em id_time garante no maximo 1 treinador por time (1:1).
-- id_time aceita NULL: treinador sem time. Se o time for apagado,
-- o treinador continua cadastrado, so que sem time (SET NULL).
-- ---------------------------------------------------------------------
CREATE TABLE treinador (
  id        INT PRIMARY KEY AUTO_INCREMENT,
  nome      VARCHAR(50) NOT NULL,
  nickname  VARCHAR(20) NOT NULL UNIQUE,
  id_pais   INT         NOT NULL,
  id_time   INT         NULL UNIQUE,
  FOREIGN KEY (id_pais) REFERENCES pais(id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  FOREIGN KEY (id_time) REFERENCES time(id)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 6. JOGADOR  (1 time / 1 jogo / 1 pais -> N jogadores)
-- id_time aceita NULL: jogador sem time ("free agent").
-- ---------------------------------------------------------------------
CREATE TABLE jogador (
  id               INT PRIMARY KEY AUTO_INCREMENT,
  nickname         VARCHAR(20) NOT NULL UNIQUE,
  nome             VARCHAR(50) NOT NULL,
  data_nascimento  DATE        NOT NULL,
  funcao           VARCHAR(40) NOT NULL,          -- ex.: Mid, AWPer, Duelista
  status           CHAR(1)     NOT NULL DEFAULT 'A',
  id_time          INT         NULL,
  id_jogo          INT         NOT NULL,
  id_pais          INT         NOT NULL,
  CONSTRAINT ck_jogador_status CHECK (status IN ('A', 'I')),   -- Ativo / Inativo
  FOREIGN KEY (id_time) REFERENCES time(id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  FOREIGN KEY (id_jogo) REFERENCES jogo(id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  FOREIGN KEY (id_pais) REFERENCES pais(id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 7. CAMPEONATO  (1 jogo -> N campeonatos)
-- premiacao em dolares; DECIMAL para guardar dinheiro sem arredondamento.
-- ---------------------------------------------------------------------
CREATE TABLE campeonato (
  id           INT PRIMARY KEY AUTO_INCREMENT,
  nome         VARCHAR(100)  NOT NULL UNIQUE,
  id_jogo      INT           NOT NULL,
  data_inicio  DATE          NOT NULL,
  data_fim     DATE          NOT NULL,
  premiacao    DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  CONSTRAINT ck_campeonato_premiacao CHECK (premiacao >= 0),
  CONSTRAINT ck_campeonato_datas     CHECK (data_fim >= data_inicio),
  FOREIGN KEY (id_jogo) REFERENCES jogo(id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 8. MAPA  (1 jogo -> N mapas)
-- UNIQUE composto: o mesmo nome nao se repete DENTRO do mesmo jogo.
-- ---------------------------------------------------------------------
CREATE TABLE mapa (
  id       INT PRIMARY KEY AUTO_INCREMENT,
  nome     VARCHAR(40) NOT NULL,
  id_jogo  INT         NOT NULL,
  CONSTRAINT uq_mapa_nome_jogo UNIQUE (nome, id_jogo),
  FOREIGN KEY (id_jogo) REFERENCES jogo(id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 9. PARTIDA  (1 campeonato -> N partidas | 1 mapa -> N partidas)
-- Cada registro = 1 mapa jogado entre dois times (uma MD3 gera ate 3).
-- Tem 3 FKs para TIME: time A, time B e vencedor.
-- id_vencedor NULL = partida ainda nao jogada.
-- As FKs de time usam RESTRICT porque essas colunas aparecem nos CHECKs
-- (no MySQL, coluna de CHECK nao pode ter CASCADE/SET NULL na FK).
-- ---------------------------------------------------------------------
CREATE TABLE partida (
  id             INT PRIMARY KEY AUTO_INCREMENT,
  id_campeonato  INT         NOT NULL,
  id_mapa        INT         NOT NULL,
  id_time_a      INT         NOT NULL,
  id_time_b      INT         NOT NULL,
  id_vencedor    INT         NULL,
  data_hora      DATETIME    NOT NULL,
  fase           VARCHAR(20) NOT NULL DEFAULT 'Fase de grupos',
  CONSTRAINT ck_partida_times    CHECK (id_time_a <> id_time_b),
  CONSTRAINT ck_partida_vencedor CHECK (id_vencedor IS NULL
                                        OR id_vencedor IN (id_time_a, id_time_b)),
  CONSTRAINT ck_partida_fase     CHECK (fase IN ('Fase de grupos', 'Playoffs',
                                                 'Semifinal', 'Final')),
  FOREIGN KEY (id_campeonato) REFERENCES campeonato(id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (id_mapa) REFERENCES mapa(id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  FOREIGN KEY (id_time_a) REFERENCES time(id)
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  FOREIGN KEY (id_time_b) REFERENCES time(id)
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  FOREIGN KEY (id_vencedor) REFERENCES time(id)
    ON UPDATE RESTRICT ON DELETE RESTRICT
) ENGINE=InnoDB;

-- =====================================================================
-- TABELAS ASSOCIATIVAS (resolvem os relacionamentos N:N)
-- A chave primaria e composta pelas duas FKs: o mesmo par nao se repete.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 10. INSCRICAO  (N:N  TIME <-> CAMPEONATO)
-- ---------------------------------------------------------------------
CREATE TABLE inscricao (
  id_time          INT      NOT NULL,
  id_campeonato    INT      NOT NULL,
  data_inscricao   DATE     NOT NULL DEFAULT (CURRENT_DATE),
  colocacao_final  SMALLINT NULL,                  -- NULL = em andamento
  PRIMARY KEY (id_time, id_campeonato),
  CONSTRAINT ck_inscricao_colocacao CHECK (colocacao_final IS NULL
                                           OR colocacao_final > 0),
  FOREIGN KEY (id_time) REFERENCES time(id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (id_campeonato) REFERENCES campeonato(id)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 11. ESTATISTICA_PARTIDA  (N:N  JOGADOR <-> PARTIDA)
-- Desempenho do jogador NAQUELA partida.
-- RESTRICT no jogador: nao se apaga um jogador que tem historico.
-- ---------------------------------------------------------------------
CREATE TABLE estatistica_partida (
  id_jogador    INT      NOT NULL,
  id_partida    INT      NOT NULL,
  abates        SMALLINT NOT NULL DEFAULT 0,
  mortes        SMALLINT NOT NULL DEFAULT 0,
  assistencias  SMALLINT NOT NULL DEFAULT 0,
  PRIMARY KEY (id_jogador, id_partida),
  CONSTRAINT ck_estatistica_valores CHECK (abates >= 0 AND mortes >= 0
                                           AND assistencias >= 0),
  FOREIGN KEY (id_jogador) REFERENCES jogador(id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  FOREIGN KEY (id_partida) REFERENCES partida(id)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 12. PATROCINIO  (N:N  TIME <-> PATROCINADOR)
-- ---------------------------------------------------------------------
CREATE TABLE patrocinio (
  id_time          INT           NOT NULL,
  id_patrocinador  INT           NOT NULL,
  valor_anual      DECIMAL(12,2) NOT NULL,
  data_inicio      DATE          NOT NULL,
  PRIMARY KEY (id_time, id_patrocinador),
  CONSTRAINT ck_patrocinio_valor CHECK (valor_anual > 0),
  FOREIGN KEY (id_time) REFERENCES time(id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (id_patrocinador) REFERENCES patrocinador(id)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;
