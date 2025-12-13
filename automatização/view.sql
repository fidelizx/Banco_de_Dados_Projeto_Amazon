
--------------------VIEWS---------------------
--View para relacionar categorias com frequência de compra, 
--permitindo análise sobre as categorias de produto mais compradas, 
--assim como frequência em que usuários finalizam o carrinho de compras 
--com estes produtos e os fatores de abandono de carrinho.
CREATE OR REPLACE VIEW relacao_compra_categoria AS
SELECT c.nome, cp.purchase_frequency, cp.cart_completion_frequency, cp.cart_abandonment_factors
FROM comportamento_compra cp
INNER JOIN usuario_categoria uc
ON uc.usuario_id = cp.usuario_id
INNER JOIN categoria c
ON c.categoria_id = uc.categoria_id
ORDER BY c.nome;

SELECT * FROM relacao_compra_categoria;

--CONSULTA PARA IDENTIFICAR OS MAIORES MOTIVOS DE DESISTÊNCIA DE COMPRAR PRO GENERO
CREATE OR REPLACE VIEW view_abandono_por_genero AS
SELECT
    u.gender as genero,
    c.Cart_Abandonment_Factors as motivo_abandono,
    COUNT(*) AS ocorrencia_total
FROM comportamento_compra c
JOIN usuario u ON c.usuario_id = u.usuario_id
WHERE c.cart_abandonment_factors IS NOT NULL
GROUP BY u.gender, c.cart_abandonment_factors
ORDER BY u.gender, ocorrencia_total DESC;

SELECT * FROM view_abandono_por_genero;

--Consultar efetividade das recomendações de produto feitas para os clientes. 
--Divide colunas em quantos "Yes", "No" e "Sometimes" aparece no comportamento de compras dos usuarios.
CREATE OR REPLACE VIEW view_busca_por_produto AS
SELECT 
    SUM(CASE WHEN Personalized_Recommendation_Frequency = 'Yes' THEN 1 ELSE 0 END) AS total_yes,
    SUM(CASE WHEN Personalized_Recommendation_Frequency = 'No' THEN 1 ELSE 0 END) AS total_no,
    SUM(CASE WHEN Personalized_Recommendation_Frequency = 'Sometimes' THEN 1 ELSE 0 END) AS total_sometimes
FROM comportamento_compra
WHERE Personalized_Recommendation_Frequency IS NOT NULL;

SELECT * FROM view_busca_por_produto;

