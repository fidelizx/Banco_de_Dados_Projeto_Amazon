--------------------FUNÇÕES---------------------
--Function para identificar o que mais agrada e a sugestão de melhoria com base na idade e genero apontado
CREATE OR REPLACE FUNCTION func_gosto_e_melhoria(input_genero TEXT, input_idade INT)
RETURNS TABLE(genero TEXT, idade INT, servico_apreciado TEXT, sugestao_melhoria TEXT)
LANGUAGE plpgsql
AS $$
DECLARE
    var_servico TEXT;
    var_sugestao TEXT;
BEGIN
    SELECT c.service_appreciation
    INTO var_servico
    FROM comportamento_compra c
    JOIN usuario u ON c.usuario_id = u.usuario_id
    WHERE LOWER(u.gender) = LOWER(input_genero)
        AND u.age = input_idade
        AND c.service_appreciation IS NOT NULL
    GROUP BY c.service_appreciation
    ORDER BY COUNT(*) DESC
    LIMIT 1;

    SELECT c.improvement_area
    INTO var_sugestao
    FROM comportamento_compra c
    JOIN usuario u ON c.usuario_id = u.usuario_id
    WHERE LOWER(u.gender) = LOWER(input_genero)
        AND u.age = input_idade
        AND c.improvement_area IS NOT NULL
    GROUP BY c.improvement_area
    ORDER BY COUNT(*) DESC
    LIMIT 1;

    servico_apreciado := var_servico;
    sugestao_melhoria := var_sugestao;
    idade := input_idade;
    genero := input_genero;

   RETURN NEXT;
END;
$$;

SELECT * FROM func_gosto_e_melhoria('female', 24);

--Função que retorna a média de satisfação em uma determinada categoria escrita pelo usuário. 
--A função permite análise sobre quais categorias tem melhor/pior média de aproveitamento do 
--cliente, permitindo demais análises encima dos resultados fornecidos por esta função.
CREATE OR REPLACE FUNCTION func_media_satisfacao_categoria(categoriaNome TEXT)
RETURNS REAL
LANGUAGE plpgsql
AS $$
DECLARE
        media REAL;
BEGIN
        SELECT AVG(cc.shopping_satisfaction) 
        INTO media
        FROM comportamento_compra cc
        INNER JOIN usuario_categoria uc
        ON uc.usuario_id = cc.usuario_id
        INNER JOIN categoria c
        ON c.categoria_id = uc.categoria_id
        WHERE LOWER(c.nome) = LOWER(categoriaNome);
   
        RETURN media;
END;
$$

select * from func_media_satisfacao_categoria('beauty and personal care');

--Função que retorna percentual de abandono de carrinho levando em conta o 
--numero total de comportamentos registrados.
CREATE OR REPLACE FUNCTION func_percentual_abandono_carrinho()
RETURNS REAL
LANGUAGE plpgsql
AS $$
DECLARE
    total INT;
    abandonos INT;
    percentual REAL;
BEGIN
    SELECT COUNT(*) INTO total FROM comportamento_compra;
    SELECT COUNT(*) INTO abandonos
    FROM comportamento_compra
    WHERE cart_abandonment_factors IS NOT NULL;

    IF total = 0 THEN
        RETURN 0;
    END IF;

    percentual := (abandonos::REAL / total::REAL) * 100;
    RETURN percentual;
END;
$$;

SELECT * from func_percentual_abandono_carrinho();