-- =====================================================================
-- PROJETO FINAL - BANCO DE DADOS
-- Sistema de Gerenciamento de Campeonatos de E-sports
-- Arquivo: 03_consultas.sql  (catalogo de consultas)
--
-- Q1 a Q5  -> consultas simples (uma tabela so)
-- Q6 a Q10 -> consultas com INNER JOIN (duas ou mais tabelas)
-- Q11      -> extra (bonus): LEFT JOIN
--
-- Nas consultas com JOIN, as colunas sao escritas como tabela.coluna
-- (ex.: time.nome), porque varias tabelas tem colunas com o mesmo
-- nome, como "id" e "nome".
-- O AS da um nome mais claro a coluna no resultado
-- (ex.: time.nome AS time).
-- =====================================================================

USE gerenciadorEsports;

-- =====================================================================
-- CONSULTAS SIMPLES
-- =====================================================================

-- Q1. Quais jogadores sao AWPer ou IGL (capitao)? Em ordem alfabetica.
-- Recursos: WHERE, IN, ORDER BY
SELECT nickname, nome, funcao
FROM jogador
WHERE funcao IN ('AWPer', 'IGL')
ORDER BY nickname;

-- Q2. Quais campeonatos pagaram entre 1 e 2,5 milhoes de dolares?
-- Recursos: WHERE, BETWEEN, ORDER BY DESC (do maior para o menor)
SELECT nome, premiacao
FROM campeonato
WHERE premiacao BETWEEN 1000000 AND 2500000
ORDER BY premiacao DESC;

-- Q3. Quais times tem a palavra "Team" no nome?
-- Recursos: LIKE (o % significa "qualquer texto antes ou depois")
SELECT nome, sigla
FROM time
WHERE nome LIKE '%Team%';

-- Q4. Quais funcoes diferentes existem entre os jogadores?
-- Recursos: DISTINCT (mostra cada funcao uma unica vez)
SELECT DISTINCT funcao
FROM jogador
ORDER BY funcao;

-- Q5. Quais sao os 3 campeonatos com a maior premiacao?
-- Recursos: ORDER BY DESC + LIMIT (mostra so as 3 primeiras linhas)
SELECT nome, premiacao
FROM campeonato
ORDER BY premiacao DESC
LIMIT 3;

-- =====================================================================
-- CONSULTAS COM JOIN
-- =====================================================================

-- Q6. Em qual time joga cada jogador?
-- Recursos: INNER JOIN com 2 tabelas (jogador + time)
-- Obs.: jogadores sem time (id_time vazio) nao aparecem.
SELECT jogador.nickname, time.nome AS time
FROM jogador
INNER JOIN time ON jogador.id_time = time.id
ORDER BY time.nome;

-- Q7. Quantos jogadores tem cada pais?
-- Recursos: INNER JOIN com 2 tabelas, GROUP BY, COUNT
SELECT pais.nome, COUNT(jogador.id) AS total_jogadores
FROM pais
INNER JOIN jogador ON jogador.id_pais = pais.id
GROUP BY pais.nome
ORDER BY total_jogadores DESC;

-- Q8. Quanto cada jogo distribuiu em premiacoes, e qual foi o maior
--     e o menor premio?
-- Recursos: INNER JOIN com 2 tabelas, GROUP BY, SUM, MAX, MIN
SELECT jogo.nome,
       SUM(campeonato.premiacao) AS premiacao_total,
       MAX(campeonato.premiacao) AS maior_premio,
       MIN(campeonato.premiacao) AS menor_premio
FROM jogo
INNER JOIN campeonato ON campeonato.id_jogo = jogo.id
GROUP BY jogo.nome;

-- Q9. Quais jogadores fazem, em media, mais de 20 abates por mapa?
-- Recursos: INNER JOIN com 3 tabelas, GROUP BY, AVG, HAVING
-- (ROUND arredonda a media para 1 casa decimal)
SELECT jogador.nickname, time.nome AS time,
       ROUND(AVG(estatistica_partida.abates), 1) AS media_abates
FROM jogador
INNER JOIN estatistica_partida ON estatistica_partida.id_jogador = jogador.id
INNER JOIN time ON jogador.id_time = time.id
GROUP BY jogador.nickname, time.nome
HAVING AVG(estatistica_partida.abates) > 20
ORDER BY media_abates DESC;

-- Q10. Quem foi o campeao de cada campeonato?
-- Recursos: INNER JOIN com 3 tabelas, passando pela tabela
-- associativa inscricao, e WHERE
SELECT campeonato.nome AS campeonato, time.nome AS campeao
FROM inscricao
INNER JOIN campeonato ON inscricao.id_campeonato = campeonato.id
INNER JOIN time ON inscricao.id_time = time.id
WHERE inscricao.colocacao_final = 1
ORDER BY campeonato.data_inicio;

-- =====================================================================
-- CONSULTA EXTRA (BONUS): LEFT JOIN
-- =====================================================================

-- Q11. Quantos patrocinadores tem cada time, incluindo quem nao tem nenhum?
-- Recursos: LEFT JOIN. Ele mantem TODOS os times, mesmo sem patrocinio.
-- Quem nao tem patrocinador aparece com 0 (a MIBR).
-- Para comparar: troque LEFT por INNER e a MIBR some do resultado.
SELECT time.nome AS time, COUNT(patrocinio.id_patrocinador) AS qtd_patrocinadores
FROM time
LEFT JOIN patrocinio ON patrocinio.id_time = time.id
GROUP BY time.nome
ORDER BY qtd_patrocinadores, time.nome;
