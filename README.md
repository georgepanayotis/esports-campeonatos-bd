# Sistema de Gerenciamento de Campeonatos de E-sports

Banco de dados relacional em **SQL puro (MariaDB/MySQL)** para gerenciar campeonatos de **League of Legends**, **Valorant** e **Counter-Strike 2**: times, jogadores, treinadores, campeonatos, partidas, mapas, patrocínios e estatísticas individuais por partida.

Projeto final da disciplina de **Banco de Dados**, curso de Engenharia da Computação, Afya Centro Universitário.

## Integrantes

- Vitor Alexandre Laboissiere Pereira
- George Panayotis

**Professor:** Evandro José

## Números do projeto

| Item | Exigido | Entregue |
|---|---|---|
| Tabelas | 8 | **12** (9 entidades + 3 associativas) |
| Relacionamentos N:N | 2 | **3** |
| Relacionamentos 1:N | 4 | **12** (+ 1 relacionamento 1:1) |
| Normalização | 3FN | **3FN** |
| CHECK | 3 colunas | **11 restrições** |
| DEFAULT | 2 colunas | **7 colunas** |
| Registros por tabela | 15 | **15 a 53** |
| Consultas | 10 | **14** (6 simples, 6 com JOIN, 1 subconsulta, 1 LEFT JOIN) |

## Estrutura do repositório

```
├── README.md                    → esta página
├── RELATORIO.md                 → relatório técnico completo (regras de negócio,
│                                  dicionário de dados, normalização, consultas)
├── img/
│   └── der.png                  → Diagrama Entidade-Relacionamento
└── sql/
    ├── 01_criacao_tabelas.sql   → CREATE DATABASE + CREATE TABLE (DDL)
    ├── 02_povoamento.sql        → INSERT INTO com os dados (DML)
    └── 03_consultas.sql         → 14 consultas comentadas
```

## Como executar

1. Inicie o MySQL no **XAMPP** (ou use qualquer MariaDB 10.x / MySQL 8.0.16+).
2. Abra o terminal e entre no banco:
   ```
   mysql -u root --default-character-set=utf8mb4
   ```
3. Rode os scripts na ordem:
   ```sql
   source C:/caminho/do/repositorio/sql/01_criacao_tabelas.sql
   source C:/caminho/do/repositorio/sql/02_povoamento.sql
   ```
4. Execute as consultas de `sql/03_consultas.sql`, uma a uma.

O passo a passo completo e as saídas esperadas de cada consulta estão no [relatório técnico](RELATORIO.md).

## Diagrama

![DER](img/der.png)

## Fonte dos dados

Times, jogadores, treinadores, campeonatos e mapas são reais, da temporada 2024, consultados na [Liquipedia](https://liquipedia.net/), na [HLTV](https://www.hltv.org/), no [VLR.gg](https://www.vlr.gg/) e na [Leaguepedia](https://lol.fandom.com/). Placares, estatísticas e contratos de patrocínio são ilustrativos.
