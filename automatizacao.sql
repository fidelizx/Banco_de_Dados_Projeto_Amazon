
--------------------VIEWS---------------------
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

--------------------PROCEDURE---------------------
--procedure para criar uma nova categoria na tabela caso ainda não exista
CREATE OR REPLACE PROCEDURE prc_cadastrar_categoria(input_nome TEXT)
LANGUAGE plpgsql
AS $$
BEGIN

    IF NOT EXISTS (SELECT 1 FROM categoria WHERE LOWER(nome) = LOWER(input_nome)) 
    THEN
        INSERT INTO categoria (nome)
        VALUES (input_nome);
        RAISE NOTICE 'Categoria "%" cadastrada!', input_nome;
    ELSE
        RAISE NOTICE 'Categoria já existe.';
    END IF;

END;
$$;

--------------------TRIGGER---------------------
--trigger que gera um novo registro em uma nova tabela, sempre que o nível de satisfação de uma compra for menor ou igual a 2

CREATE TABLE alerta_insatisfacao (
    alerta_id SERIAL PRIMARY KEY,
    usuario_id INT NOT NULL,
    nivel_satisfacao INT,
    data_alerta TIMESTAMP DEFAULT NOW(),
    CONSTRAINT fk_alerta_usuario FOREIGN KEY (usuario_id) REFERENCES usuario(usuario_id) ON DELETE CASCADE
);

SELECT * FROM alerta_insatisfacao;

CREATE OR REPLACE FUNCTION trg_insatisfacao()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.shopping_satisfaction IS NOT NULL 
       AND NEW.shopping_satisfaction <= 2 THEN
       
    INSERT INTO alerta_usuario(usuario_id, nivel_satisfacao, mensagem)
    VALUES (NEW.usuario_id, NEW.shopping_satisfaction);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER insatisfacao_trigger
AFTER INSERT ON comportamento_compra
FOR EACH ROW
EXECUTE PROCEDURE trg_insatisfacao();



