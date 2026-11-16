-- =====================================================================
-- PROJETO FINAL - BANCO DE DADOS
-- Sistema de Gerenciamento de Campeonatos de E-sports
-- Arquivo: 03_consultas.sql  (catalogo de consultas)
--
-- Q1 a Q6   -> consultas simples (WHERE, ORDER BY, BETWEEN, LIKE, IN,
--              DISTINCT, LIMIT)
-- Q7 a Q12  -> consultas com INNER JOIN, GROUP BY, HAVING e agregacao
-- Q13       -> bonus: subconsulta
-- Q14       -> bonus: LEFT JOIN
-- =====================================================================

USE gerenciadorEsports;

-- =====================================================================
-- CONSULTAS SIMPLES
-- =====================================================================

-- Q1. Quais jogadores estao ativos? (lista em ordem alfabetica)
-- Recursos: WHERE, ORDER BY
SELECT nickname, nome, funcao
FROM jogador
WHERE status = 'A'
ORDER BY nickname ASC;

-- Q2. Quais campeonatos pagaram entre 1 e 2,5 milhoes de dolares?
-- Recursos: BETWEEN, ORDER BY DESC
SELECT nome, data_inicio, premiacao
FROM campeonato
WHERE premiacao BETWEEN 1000000 AND 2500000
ORDER BY premiacao DESC;

-- Q3. Quais times tem "Team" no nome?
-- Recursos: LIKE (o % significa "qualquer texto antes ou depois")
SELECT nome, sigla, data_fundacao
FROM time
WHERE nome LIKE '%Team%';

-- Q4. Quem sao os AWPers e os IGLs (capitaes) cadastrados?
-- Recursos: IN, ORDER BY com duas colunas
SELECT nickname, nome, funcao
FROM jogador
WHERE funcao IN ('AWPer', 'IGL')
ORDER BY funcao, nickname;

-- Q5. Quais funcoes diferentes existem entre os jogadores?
-- Recursos: DISTINCT (mostra cada funcao uma unica vez)
SELECT DISTINCT funcao
FROM jogador
ORDER BY funcao;

-- Q6. Quais sao os 5 campeonatos com a maior premiacao?
-- Recursos: ORDER BY DESC + LIMIT
SELECT nome, premiacao
FROM campeonato
ORDER BY premiacao DESC
LIMIT 5;

-- =====================================================================
-- CONSULTAS COM JOIN
-- =====================================================================

-- Q7. Em qual time joga cada jogador?
-- Recursos: INNER JOIN com 2 tabelas (jogador + time)
-- Obs.: jogadores sem time (id_time NULL) nao aparecem no INNER JOIN.
SELECT j.nickname, j.funcao, t.nome AS time
FROM jogador j
INNER JOIN time t ON j.id_time = t.id
ORDER BY t.nome, j.nickname;

-- Q8. Quais times tem 3 ou mais jogadores cadastrados?
-- Recursos: INNER JOIN (2 tabelas), GROUP BY, COUNT, HAVING
SELECT t.nome AS time, COUNT(j.id) AS total_jogadores
FROM time t
INNER JOIN jogador j ON j.id_time = t.id
GROUP BY t.nome
HAVING COUNT(j.id) >= 3
ORDER BY total_jogadores DESC;

-- Q9. Quanto cada jogo distribuiu em premiacoes, e qual o maior e o menor
--     premio entre seus campeonatos?
-- Recursos: INNER JOIN (2 tabelas), GROUP BY, COUNT, SUM, MAX, MIN
SELECT g.nome AS jogo,
       COUNT(c.id)      AS qtd_campeonatos,
       SUM(c.premiacao) AS premiacao_total,
       MAX(c.premiacao) AS maior_premio,
       MIN(c.premiacao) AS menor_premio
FROM jogo g
INNER JOIN campeonato c ON c.id_jogo = g.id
GROUP BY g.nome
ORDER BY premiacao_total DESC;

-- Q10. Ranking de jogadores pela media de abates por mapa
--      (so quem jogou 2 ou mais mapas, com o time de cada um)
-- Recursos: INNER JOIN com 3 tabelas, GROUP BY, AVG, SUM, HAVING
SELECT j.nickname,
       t.nome                        AS time,
       COUNT(e.id_partida)           AS mapas_jogados,
       ROUND(AVG(e.abates), 1)       AS media_abates,
       ROUND(SUM(e.abates) / SUM(e.mortes), 2) AS kd
FROM jogador j
INNER JOIN estatistica_partida e ON e.id_jogador = j.id
INNER JOIN time t                ON t.id = j.id_time
GROUP BY j.nickname, t.nome
HAVING COUNT(e.id_partida) >= 2
ORDER BY media_abates DESC;

-- Q11. Quantos mapas cada time venceu, em cada jogo?
-- Recursos: INNER JOIN com 4 tabelas, GROUP BY, COUNT
SELECT t.nome AS time, g.nome AS jogo, COUNT(p.id) AS mapas_vencidos
FROM partida p
INNER JOIN time t       ON t.id = p.id_vencedor
INNER JOIN campeonato c ON c.id = p.id_campeonato
INNER JOIN jogo g       ON g.id = c.id_jogo
GROUP BY t.nome, g.nome
ORDER BY mapas_vencidos DESC, t.nome;

-- Q12. Quem foi o campeao de cada campeonato?
-- Recursos: INNER JOIN com 4 tabelas (passando pela associativa inscricao)
SELECT c.nome AS campeonato, g.nome AS jogo, t.nome AS campeao, c.premiacao
FROM inscricao i
INNER JOIN time t       ON t.id = i.id_time
INNER JOIN campeonato c ON c.id = i.id_campeonato
INNER JOIN jogo g       ON g.id = c.id_jogo
WHERE i.colocacao_final = 1
ORDER BY c.data_inicio;

-- =====================================================================
-- BONUS
-- =====================================================================

-- Q13. Quais jogadores tem media de abates ACIMA da media geral?
-- Recursos: SUBCONSULTA. A consulta interna calcula a media geral de
-- abates; a externa compara a media de cada jogador com esse valor.
SELECT j.nickname, ROUND(AVG(e.abates), 1) AS media_abates
FROM jogador j
INNER JOIN estatistica_partida e ON e.id_jogador = j.id
GROUP BY j.nickname
HAVING AVG(e.abates) > (SELECT AVG(abates) FROM estatistica_partida)
ORDER BY media_abates DESC;

-- Q14. Quantos patrocinadores tem cada time, incluindo quem nao tem nenhum?
-- Recursos: LEFT JOIN. Ele mantem TODOS os times, mesmo sem patrocinio
-- (o INNER JOIN esconderia esses times). Quem nao tem aparece com 0.
SELECT t.nome AS time, COUNT(pt.id_patrocinador) AS qtd_patrocinadores
FROM time t
LEFT JOIN patrocinio pt ON pt.id_time = t.id
GROUP BY t.nome
ORDER BY qtd_patrocinadores ASC, t.nome;
