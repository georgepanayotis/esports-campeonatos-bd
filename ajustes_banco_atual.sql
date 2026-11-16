-- Ajustes para o banco que ja existe no XAMPP ficar IGUAL ao
-- 01_criacao_tabelas.sql da entrega. Rodar uma unica vez.
USE gerenciadorEsports;

-- 1) Nome do jogo nao pode repetir
ALTER TABLE jogo ADD CONSTRAINT uq_jogo_nome UNIQUE (nome);

-- 2) Mapa: o nome so nao pode repetir DENTRO do mesmo jogo
ALTER TABLE mapa DROP INDEX nome,
  ADD CONSTRAINT uq_mapa_nome_jogo UNIQUE (nome, id_jogo);

-- 3) Vencedor pode ficar vazio (partida ainda nao jogada)
ALTER TABLE partida MODIFY id_vencedor INT NULL;

-- 4) Padroniza 'playoffs' -> 'Playoffs' no CHECK da fase
ALTER TABLE partida DROP CONSTRAINT CONSTRAINT_3,
  ADD CONSTRAINT ck_partida_fase CHECK (fase IN ('Fase de grupos', 'Playoffs', 'Semifinal', 'Final'));
