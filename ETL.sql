-- Popula dimensão tempo
INSERT INTO dim_tempo (id_tempo, dia, mes, ano, nome_mes, periodo_dias)
SELECT DISTINCT
    EXTRACT(DOY FROM c.data_compra)::INT AS id_tempo,
    EXTRACT(DAY FROM c.data_compra)::INT AS dia,
    EXTRACT(MONTH FROM c.data_compra)::INT AS mes,
    EXTRACT(YEAR FROM c.data_compra)::INT AS ano,
    TO_CHAR(c.data_compra, 'Month') AS nome_mes,
    EXTRACT(DOY FROM c.data_compra)::INT AS periodo_dias
FROM comportamento_compra c
ON CONFLICT (id_tempo) DO NOTHING;

-- Popula dimensão usuário
INSERT INTO dim_usuario (id_usuario, faixa_etaria)
SELECT DISTINCT
    u.usuario_id,
    CASE
        WHEN u.idade BETWEEN 0 AND 17 THEN '0-17'
        WHEN u.idade BETWEEN 18 AND 25 THEN '18-25'
        WHEN u.idade BETWEEN 26 AND 40 THEN '26-40'
        WHEN u.idade BETWEEN 41 AND 60 THEN '41-60'
        ELSE '60+'
    END AS faixa_etaria
FROM usuario u
ON CONFLICT (id_usuario) DO NOTHING;

-- Popula dimensão motivo de abandono
INSERT INTO dim_abandono_motivo (motivo)
SELECT DISTINCT c.cart_abandonment_factors
FROM comportamento_compra c
WHERE c.cart_abandonment_factors IS NOT NULL
ON CONFLICT DO NOTHING;

-- Popula fato abandono
INSERT INTO fato_abandono (id_usuario, id_motivo, id_tempo, quantidade)
SELECT
    c.usuario_id,
    m.id_motivo,
    EXTRACT(DOY FROM c.data_compra)::INT AS id_tempo,
    1
FROM comportamento_compra c
JOIN dim_abandono_motivo m
  ON m.motivo = c.cart_abandonment_factors;
