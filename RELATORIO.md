# Sistema de Gerenciamento de Campeonatos de E-sports

**Relatório Técnico – Projeto Final de Banco de Dados**

| | |
|---|---|
| **Instituição** | Afya Centro Universitário |
| **Curso** | Engenharia da Computação |
| **Disciplina** | Banco de Dados |
| **Professor** | Evandro José |
| **Integrantes** | Vitor Alexandre Laboissiere Pereira · George Panayotis |
| **Semestre** | 2/2026 |
| **SGBD** | MariaDB 10.x (XAMPP), compatível com MySQL 8.0.16+ |

---

## Sumário

1. [Resumo executivo](#1-resumo-executivo)
2. [Domínio e regras de negócio](#2-domínio-e-regras-de-negócio)
3. [Diagrama Entidade-Relacionamento](#3-diagrama-entidade-relacionamento)
4. [Dicionário de dados](#4-dicionário-de-dados)
5. [Justificativa da normalização](#5-justificativa-da-normalização)
6. [Catálogo de consultas](#6-catálogo-de-consultas)
7. [Instruções de execução](#7-instruções-de-execução)
8. [Considerações finais](#8-considerações-finais)
9. [Referências](#9-referências)

---

## 1. Resumo executivo

Este projeto modela e implementa, em SQL puro, um banco de dados relacional para gerenciar campeonatos de esportes eletrônicos de três jogos competitivos: **League of Legends** (MOBA), **Valorant** e **Counter-Strike 2** (FPS). O sistema registra times, jogadores, treinadores, campeonatos, mapas, partidas, patrocinadores e o desempenho individual de cada jogador em cada partida.

O esquema tem **12 tabelas** (9 entidades e 3 associativas), **19 chaves estrangeiras**, **3 relacionamentos N:N**, **1 relacionamento 1:1** e está na **Terceira Forma Normal**. A base foi povoada com dados de fontes públicas do cenário competitivo (temporada 2024), totalizando **mais de 15 registros em todas as tabelas**, e é explorada por **14 consultas**, entre simples, com JOIN, com subconsulta e com LEFT JOIN.

## 2. Domínio e regras de negócio

Os e-sports são hoje um mercado profissional, com organizações, atletas contratados, patrocinadores e campeonatos com premiações milionárias. O Brasil tem papel de destaque, com organizações como LOUD, FURIA, paiN Gaming e MIBR. Esse ecossistema gera dados fortemente inter-relacionados: um time disputa vários campeonatos, um jogador participa de várias partidas e uma empresa patrocina vários times.

**Entidades:** País, Jogo, Patrocinador, Time, Treinador, Jogador, Campeonato, Mapa e Partida.
**Associativas:** Inscrição, Estatística da Partida e Patrocínio.

**Regras de negócio**

| # | Regra | Como o banco garante |
|---|---|---|
| RN01 | Cada jogador pertence a no máximo um time por vez e pode estar sem time | FK `jogador.id_time` que aceita NULL |
| RN02 | Cada jogador atua em um único jogo | FK `jogador.id_jogo` NOT NULL |
| RN03 | Cada time tem no máximo um treinador principal | UNIQUE em `treinador.id_time` (1:1) |
| RN04 | Uma partida é disputada entre dois times **diferentes** | CHECK `id_time_a <> id_time_b` |
| RN05 | O vencedor de uma partida é um dos dois times que jogaram | CHECK `id_vencedor IN (id_time_a, id_time_b)` |
| RN06 | Um time não se inscreve duas vezes no mesmo campeonato | PK composta `(id_time, id_campeonato)` |
| RN07 | Um campeonato não termina antes de começar | CHECK `data_fim >= data_inicio` |
| RN08 | Premiações, valores e estatísticas nunca são negativos | CHECKs `>= 0` / `> 0` |
| RN09 | Um mapa não se repete dentro do mesmo jogo | UNIQUE composto `(nome, id_jogo)` |
| RN10 | O histórico de um jogador não pode ser apagado | FK `estatistica_partida.id_jogador` com ON DELETE RESTRICT |

**Simplificação adotada:** cada registro de `partida` representa **um mapa jogado**. Uma série melhor de 3 (MD3) gera até três registros.

## 3. Diagrama Entidade-Relacionamento

![Diagrama Entidade-Relacionamento](img/der.png)

*Figura 1 – DER do sistema. As tabelas `inscricao`, `estatistica_partida` e `patrocinio` resolvem os relacionamentos N:N.*

**Relacionamentos**

| Tipo | Relacionamento | Implementação |
|---|---|---|
| 1:N | País → Time, País → Jogador, País → Treinador | FK `id_pais` |
| 1:N | Jogo → Jogador, Jogo → Campeonato, Jogo → Mapa | FK `id_jogo` |
| 1:N | Time → Jogador | FK `jogador.id_time` (opcional) |
| 1:N | Campeonato → Partida, Mapa → Partida | FKs em `partida` |
| 1:N | Time → Partida (3 papéis: time A, time B e vencedor) | 3 FKs em `partida` |
| 1:1 | Time ↔ Treinador | FK `treinador.id_time` + UNIQUE |
| N:N | Time ↔ Campeonato | Tabela `inscricao` |
| N:N | Jogador ↔ Partida | Tabela `estatistica_partida` |
| N:N | Time ↔ Patrocinador | Tabela `patrocinio` |

## 4. Dicionário de dados


### pais

Países de origem de times, jogadores e treinadores. Criada para a normalização (3FN).

| Atributo | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id` | INT | PK, AUTO_INCREMENT | Identificador do país |
| `nome` | VARCHAR(40) | NOT NULL, UNIQUE | Nome do país (ex.: Brasil) |
| `sigla` | VARCHAR(5) | NOT NULL, UNIQUE | Sigla ISO de 3 letras (ex.: BRA) |

### jogo

Jogos competitivos cobertos pelo sistema.

| Atributo | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id` | INT | PK, AUTO_INCREMENT | Identificador do jogo |
| `nome` | VARCHAR(50) | NOT NULL, UNIQUE | Nome do jogo |
| `desenvolvedora` | VARCHAR(40) | NOT NULL | Empresa que desenvolveu o jogo |
| `genero` | VARCHAR(10) | NOT NULL, CHECK IN ('FPS','MOBA') | Gênero do jogo |
| `ano_lancamento` | SMALLINT | NOT NULL, CHECK BETWEEN 1990 AND 2100 | Ano de lançamento |

### patrocinador

Empresas que patrocinam times.

| Atributo | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id` | INT | PK, AUTO_INCREMENT | Identificador do patrocinador |
| `nome` | VARCHAR(40) | NOT NULL, UNIQUE | Nome da empresa |
| `seguimento` | VARCHAR(40) | NOT NULL | Ramo de atuação (ex.: Bebidas) |

### time

Organizações de e-sports.

| Atributo | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id` | INT | PK, AUTO_INCREMENT | Identificador do time |
| `nome` | VARCHAR(50) | NOT NULL, UNIQUE | Nome da organização |
| `sigla` | VARCHAR(5) | NOT NULL, UNIQUE | Sigla usada nas transmissões (ex.: FUR) |
| `data_fundacao` | DATE | NOT NULL | Data de fundação |
| `id_pais` | INT | NOT NULL, FK → pais(id) | País da organização |

### treinador

Treinador principal de um time (relação 1:1 opcional).

| Atributo | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id` | INT | PK, AUTO_INCREMENT | Identificador do treinador |
| `nome` | VARCHAR(50) | NOT NULL | Nome real |
| `nickname` | VARCHAR(20) | NOT NULL, UNIQUE | Apelido no cenário |
| `id_pais` | INT | NOT NULL, FK → pais(id) | Nacionalidade |
| `id_time` | INT | NULL, UNIQUE, FK → time(id) ON DELETE SET NULL | Time que treina; o UNIQUE garante o 1:1 |

### jogador

Atletas profissionais.

| Atributo | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id` | INT | PK, AUTO_INCREMENT | Identificador do jogador |
| `nickname` | VARCHAR(20) | NOT NULL, UNIQUE | Apelido no jogo |
| `nome` | VARCHAR(50) | NOT NULL | Nome real |
| `data_nascimento` | DATE | NOT NULL | Data de nascimento |
| `funcao` | VARCHAR(40) | NOT NULL | Papel no time (ex.: Mid, AWPer, Duelista) |
| `status` | CHAR(1) | NOT NULL, DEFAULT 'A', CHECK IN ('A','I') | Ativo ou Inativo |
| `id_time` | INT | NULL, FK → time(id) ON DELETE SET NULL | Time atual; NULL = sem time |
| `id_jogo` | INT | NOT NULL, FK → jogo(id) | Jogo em que atua |
| `id_pais` | INT | NOT NULL, FK → pais(id) | Nacionalidade |

### campeonato

Competições de cada jogo.

| Atributo | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id` | INT | PK, AUTO_INCREMENT | Identificador do campeonato |
| `nome` | VARCHAR(100) | NOT NULL, UNIQUE | Nome do campeonato |
| `id_jogo` | INT | NOT NULL, FK → jogo(id) | Jogo disputado |
| `data_inicio` | DATE | NOT NULL | Data de início |
| `data_fim` | DATE | NOT NULL, CHECK data_fim >= data_inicio | Data de término |
| `premiacao` | DECIMAL(12,2) | NOT NULL, DEFAULT 0.00, CHECK >= 0 | Premiação total em dólares |

### mapa

Mapas em que as partidas são jogadas.

| Atributo | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id` | INT | PK, AUTO_INCREMENT | Identificador do mapa |
| `nome` | VARCHAR(40) | NOT NULL, UNIQUE (nome, id_jogo) | Nome do mapa |
| `id_jogo` | INT | NOT NULL, FK → jogo(id) | Jogo ao qual o mapa pertence |

### partida

Cada registro é um mapa jogado entre dois times.

| Atributo | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id` | INT | PK, AUTO_INCREMENT | Identificador da partida |
| `id_campeonato` | INT | NOT NULL, FK → campeonato(id) ON DELETE CASCADE | Campeonato da partida |
| `id_mapa` | INT | NOT NULL, FK → mapa(id) | Mapa jogado |
| `id_time_a` | INT | NOT NULL, FK → time(id), CHECK <> id_time_b | Primeiro time |
| `id_time_b` | INT | NOT NULL, FK → time(id) | Segundo time |
| `id_vencedor` | INT | NULL, FK → time(id), CHECK IN (id_time_a, id_time_b) | Vencedor; NULL = ainda não jogada |
| `data_hora` | DATETIME | NOT NULL | Data e hora do jogo |
| `fase` | VARCHAR(20) | NOT NULL, DEFAULT 'Fase de grupos', CHECK IN (...) | Fase do campeonato |

### inscricao

Associativa N:N entre time e campeonato.

| Atributo | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id_time` | INT | PK, FK → time(id) ON DELETE CASCADE | Time inscrito |
| `id_campeonato` | INT | PK, FK → campeonato(id) ON DELETE CASCADE | Campeonato |
| `data_inscricao` | DATE | NOT NULL, DEFAULT data atual | Data da inscrição |
| `colocacao_final` | SMALLINT | NULL, CHECK > 0 | Colocação final; NULL = em andamento |

### estatistica_partida

Associativa N:N entre jogador e partida: desempenho do jogador naquele mapa.

| Atributo | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id_jogador` | INT | PK, FK → jogador(id) ON DELETE RESTRICT | Jogador |
| `id_partida` | INT | PK, FK → partida(id) ON DELETE CASCADE | Partida |
| `abates` | SMALLINT | NOT NULL, DEFAULT 0, CHECK >= 0 | Abates (kills) |
| `mortes` | SMALLINT | NOT NULL, DEFAULT 0, CHECK >= 0 | Mortes (deaths) |
| `assistencias` | SMALLINT | NOT NULL, DEFAULT 0, CHECK >= 0 | Assistências |

### patrocinio

Associativa N:N entre time e patrocinador.

| Atributo | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id_time` | INT | PK, FK → time(id) ON DELETE CASCADE | Time patrocinado |
| `id_patrocinador` | INT | PK, FK → patrocinador(id) ON DELETE CASCADE | Patrocinador |
| `valor_anual` | DECIMAL(12,2) | NOT NULL, CHECK > 0 | Valor anual do contrato em dólares |
| `data_inicio` | DATE | NOT NULL | Início do contrato |

**Totais do esquema:** 12 tabelas, 19 chaves estrangeiras, 11 restrições CHECK e 7 colunas com DEFAULT.

## 5. Justificativa da normalização

O esquema está na **Terceira Forma Normal (3FN)**:

- **1FN – valores atômicos.** Nenhuma coluna guarda listas. Os patrocinadores de um time, por exemplo, não ficam numa coluna "Red Bull, Nike": cada contrato é uma linha da tabela `patrocinio`.
- **2FN – sem dependência parcial.** Nas tabelas com chave composta, todos os atributos dependem da chave inteira. Em `estatistica_partida`, os abates dependem do par **jogador + partida**, e não só do jogador. Por isso eles não ficam na tabela `jogador`.
- **3FN – sem dependência transitiva.** Nenhum atributo comum depende de outro atributo que não seja a chave.

**Exemplo de decomposição: a tabela `pais`**

Na primeira versão, o país era um texto dentro de `jogador`:

| id | nickname | pais_nome | pais_sigla |
|---|---|---|---|
| 21 | FalleN | Brasil | BRA |
| 22 | KSCERATO | Brasil | BRA |
| 24 | ZywOo | França | FRA |

Aqui existe uma **dependência transitiva**: `id → pais_nome → pais_sigla`, já que a sigla depende do nome do país, e não do jogador. Isso causa anomalias:

- **Atualização:** mudar a sigla do Brasil exigiria alterar todas as linhas de jogadores brasileiros (e de times e treinadores).
- **Inserção:** não seria possível cadastrar um país sem antes ter um jogador dele.
- **Inconsistência:** um erro de digitação ("Brazil") criaria um "país" diferente.

**Decomposição:** o país virou uma tabela própria, e `jogador`, `time` e `treinador` passaram a guardar só a chave estrangeira `id_pais`:

| pais.id | nome | sigla |
|---|---|---|
| 1 | Brasil | BRA |
| 5 | França | FRA |

| jogador.id | nickname | id_pais |
|---|---|---|
| 21 | FalleN | 1 |
| 24 | ZywOo | 5 |

**Decisão consciente:** `jogo.desenvolvedora` foi mantida como texto. Com poucos jogos, a repetição é mínima. Numa evolução com dezenas de jogos, ela viraria uma tabela `desenvolvedora`, seguindo a mesma lógica.

## 6. Catálogo de consultas

Todas as consultas estão em [`sql/03_consultas.sql`](sql/03_consultas.sql). As saídas abaixo foram obtidas executando o script sobre a base povoada (as tabelas longas mostram só as primeiras linhas).

| Nº | Consulta | Categoria |
|---|---|---|
| Q1–Q6 | Seleção, filtro e ordenação | Simples |
| Q7–Q12 | Junções e agregações | JOIN |
| Q13 | Subconsulta | Bônus |
| Q14 | LEFT JOIN | Bônus |


### Q1. Jogadores ativos

Lista os jogadores com status ativo, em ordem alfabética de nickname. Responde: quem está em atividade no cenário cadastrado?

**Recursos:** WHERE, ORDER BY

```sql
SELECT nickname, nome, funcao
FROM jogador
WHERE status = 'A'
ORDER BY nickname ASC;
```

**Saída:**

| nickname | nome | funcao |
|---|---|---|
| apEX | Dan Madesclaire | IGL |
| b1t | Valerii Vakhovskyi | Rifler |
| benjyfishy | Benjy Fish | Sentinela |
| Boaster | Jake Howlett | Controlador |
| Canyon | Kim Geon-bu | Caçador |
| Caps | Rasmus Winther | Mid |

*… mais 26 linhas (32 no total).*


### Q2. Campeonatos entre 1 e 2,5 milhões

Mostra os campeonatos com premiação entre US$ 1.000.000 e US$ 2.500.000, do maior para o menor. Responde: quais são os torneios de grande porte?

**Recursos:** BETWEEN, ORDER BY DESC

```sql
SELECT nome, data_inicio, premiacao
FROM campeonato
WHERE premiacao BETWEEN 1000000 AND 2500000
ORDER BY premiacao DESC;
```

**Saída:**

| nome | data_inicio | premiacao |
|---|---|---|
| Valorant Champions 2024 | 2024-08-01 | 2250000.00 |
| Worlds 2024 | 2024-09-25 | 2225000.00 |
| Mid-Season Invitational 2024 | 2024-05-01 | 2000000.00 |
| PGL Major Copenhagen 2024 | 2024-03-17 | 1250000.00 |
| Perfect World Shanghai Major 2024 | 2024-11-30 | 1250000.00 |
| VCT Masters Shanghai 2024 | 2024-05-23 | 1000000.00 |

*… mais 3 linhas (9 no total).*


### Q3. Times com "Team" no nome

Busca times cujo nome contém a palavra "Team". Demonstra busca por padrão de texto.

**Recursos:** LIKE

```sql
SELECT nome, sigla, data_fundacao
FROM time
WHERE nome LIKE '%Team%';
```

**Saída:**

| nome | sigla | data_fundacao |
|---|---|---|
| Team Vitality | VIT | 2013-08-01 |
| Team Heretics | TH | 2016-01-01 |
| Team Liquid | TL | 2000-01-01 |

*3 linha(s).*


### Q4. AWPers e IGLs

Lista os jogadores que atuam como AWPer (atirador de elite) ou IGL (capitão), agrupados por função. Responde: quem ocupa as funções-chave do CS2?

**Recursos:** IN, ORDER BY com duas colunas

```sql
SELECT nickname, nome, funcao
FROM jogador
WHERE funcao IN ('AWPer', 'IGL')
ORDER BY funcao, nickname;
```

**Saída:**

| nickname | nome | funcao |
|---|---|---|
| FalleN | Gabriel Toledo | AWPer |
| m0NESY | Ilya Osipov | AWPer |
| s1mple | Oleksandr Kostyliev | AWPer |
| ZywOo | Mathieu Herbaut | AWPer |
| apEX | Dan Madesclaire | IGL |
| karrigan | Finn Andersen | IGL |

*6 linha(s).*


### Q5. Funções existentes

Mostra cada função cadastrada uma única vez. Responde: quais papéis existem entre os jogadores dos três jogos?

**Recursos:** DISTINCT

```sql
SELECT DISTINCT funcao
FROM jogador
ORDER BY funcao;
```

**Saída:**

| funcao |
|---|
| Atirador |
| AWPer |
| Caçador |
| Controlador |
| Duelista |
| IGL |

*… mais 5 linhas (11 no total).*


### Q6. 5 maiores premiações

Os cinco campeonatos com maior premiação. Responde: onde está o dinheiro do cenário?

**Recursos:** ORDER BY DESC, LIMIT

```sql
SELECT nome, premiacao
FROM campeonato
ORDER BY premiacao DESC
LIMIT 5;
```

**Saída:**

| nome | premiacao |
|---|---|
| Valorant Champions 2024 | 2250000.00 |
| Worlds 2024 | 2225000.00 |
| Mid-Season Invitational 2024 | 2000000.00 |
| PGL Major Copenhagen 2024 | 1250000.00 |
| Perfect World Shanghai Major 2024 | 1250000.00 |

*5 linha(s).*


### Q7. Jogador e seu time

Relaciona cada jogador ao nome do seu time. Jogadores sem time (id_time NULL) não aparecem, porque o INNER JOIN só traz linhas com correspondência.

**Recursos:** INNER JOIN (2 tabelas)

```sql
SELECT j.nickname, j.funcao, t.nome AS time
FROM jogador j
INNER JOIN time t ON j.id_time = t.id
ORDER BY t.nome, j.nickname;
```

**Saída:**

| nickname | funcao | time |
|---|---|---|
| CHICHOO | Iniciador | EDward Gaming |
| ZmjjKK | Duelista | EDward Gaming |
| karrigan | IGL | FaZe Clan |
| ropz | Rifler | FaZe Clan |
| Boaster | Controlador | Fnatic |
| Derke | Duelista | Fnatic |

*… mais 26 linhas (32 no total).*


### Q8. Times com 3 ou mais jogadores

Conta os jogadores de cada time e mostra apenas os times com 3 ou mais. O filtro fica no HAVING porque atua sobre o resultado do COUNT, depois do agrupamento.

**Recursos:** INNER JOIN (2 tabelas), GROUP BY, COUNT, HAVING

```sql
SELECT t.nome AS time, COUNT(j.id) AS total_jogadores
FROM time t
INNER JOIN jogador j ON j.id_time = t.id
GROUP BY t.nome
HAVING COUNT(j.id) >= 3
ORDER BY total_jogadores DESC;
```

**Saída:**

| time | total_jogadores |
|---|---|
| Gen.G | 4 |
| Sentinels | 3 |
| G2 Esports | 3 |
| FURIA | 3 |
| T1 | 3 |

*5 linha(s).*


### Q9. Premiação por jogo

Para cada jogo, mostra quantos campeonatos existem, o total distribuído e o maior e o menor prêmio. Responde: qual jogo movimenta mais dinheiro?

**Recursos:** INNER JOIN (2 tabelas), GROUP BY, COUNT, SUM, MAX, MIN

```sql
SELECT g.nome AS jogo,
       COUNT(c.id)      AS qtd_campeonatos,
       SUM(c.premiacao) AS premiacao_total,
       MAX(c.premiacao) AS maior_premio,
       MIN(c.premiacao) AS menor_premio
FROM jogo g
INNER JOIN campeonato c ON c.id_jogo = g.id
GROUP BY g.nome
ORDER BY premiacao_total DESC;
```

**Saída:**

| jogo | qtd_campeonatos | premiacao_total | maior_premio | menor_premio |
|---|---|---|---|---|
| Counter-Strike 2 | 5 | 5500000.00 | 1250000.00 | 1000000.00 |
| League of Legends | 5 | 4875000.00 | 2225000.00 | 150000.00 |
| Valorant | 5 | 3750000.00 | 2250000.00 | 0.00 |

*3 linha(s).*


### Q10. Ranking de abates

Média de abates por mapa e relação abates/mortes (K/D) de cada jogador que disputou 2 ou mais mapas, com o nome do time. Responde: quem são os jogadores de maior impacto?

**Recursos:** INNER JOIN (3 tabelas), GROUP BY, AVG, SUM, COUNT, HAVING

```sql
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
```

**Saída:**

| nickname | time | mapas_jogados | media_abates | kd |
|---|---|---|---|---|
| ZywOo | Team Vitality | 2 | 26.5 | 2.04 |
| Derke | Fnatic | 3 | 21.7 | 1.33 |
| jL | Natus Vincere | 3 | 21.7 | 1.67 |
| ZmjjKK | EDward Gaming | 2 | 21.5 | 1.30 |
| MiniBoo | Team Heretics | 4 | 21.0 | 1.27 |
| zekken | Sentinels | 3 | 20.7 | 1.29 |

*… mais 9 linhas (15 no total).*


### Q11. Mapas vencidos por time

Conta quantos mapas cada time venceu, separado por jogo. Usa a FK id_vencedor da partida.

**Recursos:** INNER JOIN (4 tabelas), GROUP BY, COUNT

```sql
SELECT t.nome AS time, g.nome AS jogo, COUNT(p.id) AS mapas_vencidos
FROM partida p
INNER JOIN time t       ON t.id = p.id_vencedor
INNER JOIN campeonato c ON c.id = p.id_campeonato
INNER JOIN jogo g       ON g.id = c.id_jogo
GROUP BY t.nome, g.nome
ORDER BY mapas_vencidos DESC, t.nome;
```

**Saída:**

| time | jogo | mapas_vencidos |
|---|---|---|
| Natus Vincere | Counter-Strike 2 | 3 |
| Gen.G | Valorant | 2 |
| Sentinels | Valorant | 2 |
| Team Heretics | Valorant | 2 |
| Team Vitality | Counter-Strike 2 | 2 |
| EDward Gaming | Valorant | 1 |

*… mais 3 linhas (9 no total).*


### Q12. Campeão de cada campeonato

Mostra o time que terminou em 1º lugar em cada campeonato, passando pela tabela associativa inscricao.

**Recursos:** INNER JOIN (4 tabelas), WHERE

```sql
SELECT c.nome AS campeonato, g.nome AS jogo, t.nome AS campeao, c.premiacao
FROM inscricao i
INNER JOIN time t       ON t.id = i.id_time
INNER JOIN campeonato c ON c.id = i.id_campeonato
INNER JOIN jogo g       ON g.id = c.id_jogo
WHERE i.colocacao_final = 1
ORDER BY c.data_inicio;
```

**Saída:**

| campeonato | jogo | campeao | premiacao |
|---|---|---|---|
| LCK Spring 2024 | League of Legends | Gen.G | 300000.00 |
| VCT Masters Madrid 2024 | Valorant | Sentinels | 500000.00 |
| PGL Major Copenhagen 2024 | Counter-Strike 2 | Natus Vincere | 1250000.00 |
| VCT EMEA Stage 1 2024 | Valorant | Fnatic | 0.00 |
| Mid-Season Invitational 2024 | League of Legends | Gen.G | 2000000.00 |
| VCT Masters Shanghai 2024 | Valorant | Gen.G | 1000000.00 |

*… mais 6 linhas (12 no total).*


### Q13. Jogadores acima da média (bônus)

Mostra os jogadores cuja média de abates é maior que a média geral. A subconsulta calcula a média geral; a consulta externa compara cada jogador com ela.

**Recursos:** Subconsulta, GROUP BY, HAVING, AVG

```sql
SELECT j.nickname, ROUND(AVG(e.abates), 1) AS media_abates
FROM jogador j
INNER JOIN estatistica_partida e ON e.id_jogador = j.id
GROUP BY j.nickname
HAVING AVG(e.abates) > (SELECT AVG(abates) FROM estatistica_partida)
ORDER BY media_abates DESC;
```

**Saída:**

| nickname | media_abates |
|---|---|
| ZywOo | 26.5 |
| Derke | 21.7 |
| jL | 21.7 |
| ZmjjKK | 21.5 |
| NiKo | 21.0 |
| MiniBoo | 21.0 |

*… mais 8 linhas (14 no total).*


### Q14. Patrocinadores por time (bônus)

Conta os patrocinadores de cada time, incluindo quem não tem nenhum. O LEFT JOIN mantém todos os times: a MIBR aparece com 0, e com INNER JOIN ela sumiria.

**Recursos:** LEFT JOIN, GROUP BY, COUNT

```sql
SELECT t.nome AS time, COUNT(pt.id_patrocinador) AS qtd_patrocinadores
FROM time t
LEFT JOIN patrocinio pt ON pt.id_time = t.id
GROUP BY t.nome
ORDER BY qtd_patrocinadores ASC, t.nome;
```

**Saída:**

| time | qtd_patrocinadores |
|---|---|
| MIBR | 0 |
| EDward Gaming | 1 |
| FaZe Clan | 1 |
| Gen.G | 1 |
| paiN Gaming | 1 |
| Sentinels | 1 |

*… mais 9 linhas (15 no total).*


## 7. Instruções de execução

**Pré-requisito:** MariaDB/MySQL instalado. Neste projeto foi usado o **XAMPP** (MariaDB 10.x).

1. Inicie o MySQL no **XAMPP Control Panel** (botão *Start*).
2. Abra o **Shell** do XAMPP e entre no MariaDB com suporte a acentos:
   ```
   mysql -u root --default-character-set=utf8mb4
   ```
3. Rode os scripts **na ordem**, com barras normais no caminho:
   ```sql
   source C:/caminho/do/repositorio/sql/01_criacao_tabelas.sql
   source C:/caminho/do/repositorio/sql/02_povoamento.sql
   ```
4. Confira o resultado:
   ```sql
   SHOW TABLES;                      -- 12 tabelas
   SELECT COUNT(*) FROM jogador;     -- 34
   ```
5. Execute as consultas, uma a uma, a partir de `sql/03_consultas.sql`.

O script `01_criacao_tabelas.sql` começa com `DROP DATABASE IF EXISTS`, então pode ser executado novamente para recriar o banco do zero.

## 8. Considerações finais

**Dificuldades encontradas**

- **Ordem das chaves estrangeiras.** Uma FK só pode apontar para uma tabela que já existe. Durante o desenvolvimento, criamos todas as tabelas primeiro e adicionamos as FKs depois, com `ALTER TABLE`. No script final, as tabelas estão na ordem de dependência, com as FKs dentro do `CREATE TABLE`.
- **UNIQUE em coluna errada.** A coluna `desenvolvedora` foi criada como UNIQUE, o que impediria a Riot Games de ter dois jogos. O erro apareceu no povoamento e foi corrigido com `ALTER TABLE jogo DROP INDEX`. A lição foi usar UNIQUE só em atributos que identificam o registro.
- **CHECK e ações em cascata.** No MySQL, uma coluna usada em CHECK não pode ter `ON DELETE CASCADE` ou `SET NULL` na FK. Por isso, as três FKs de `partida` para `time` usam `RESTRICT`.
- **Execução de scripts no Windows.** O comando `source` não aceita aspas nem barras invertidas no caminho, e os acentos exigem `--default-character-set=utf8mb4`.

**Decisões de projeto**

- Três jogos no mesmo banco, o que enriquece o modelo com vários relacionamentos 1:N a partir da tabela `jogo`.
- `partida` com três FKs para `time`, cada uma com um papel diferente.
- `DECIMAL` em valores monetários, para evitar erros de arredondamento.

**Possíveis evoluções**

- Tabela `serie` para agrupar os mapas de uma MD3 ou MD5.
- Histórico de transferências de jogadores entre times, com datas.
- Tabela `desenvolvedora` e comparação de estatísticas dentro de cada jogo.

**Sobre os dados:** times, jogadores, treinadores, jogos, mapas, patrocinadores e campeonatos são reais (temporada 2024). Datas de nascimento, datas de fundação e premiações são aproximadas. Placares, estatísticas, a maior parte das colocações e os contratos de patrocínio são ilustrativos.

## 9. Referências

- ELMASRI, R.; NAVATHE, S. B. *Sistemas de Banco de Dados*. 7. ed. São Paulo: Pearson, 2018.
- HEUSER, C. A. *Projeto de Banco de Dados*. 6. ed. Porto Alegre: Bookman, 2009.
- MySQL 8.0 Reference Manual. Oracle. Disponível em: https://dev.mysql.com/doc/refman/8.0/en/
- MariaDB Knowledge Base. Disponível em: https://mariadb.com/kb/
- Liquipedia – Esports Wiki. Disponível em: https://liquipedia.net/
- HLTV.org – Counter-Strike. Disponível em: https://www.hltv.org/
- VLR.gg – Valorant. Disponível em: https://www.vlr.gg/
- Leaguepedia – League of Legends. Disponível em: https://lol.fandom.com/

**Ferramentas auxiliares:** XAMPP (MariaDB), [ferramenta usada no DER], e Claude (Anthropic) como assistente de estudo, usado com compreensão integral do código, conforme a seção 10 do enunciado.
