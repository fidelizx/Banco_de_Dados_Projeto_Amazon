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

--Procedure para cadastrar manualmente usuário através de um genero e idade fornecidos
CREATE OR REPLACE PROCEDURE prc_cadastrar_usuario(input_genero TEXT, input_idade TEXT)
LANGUAGE plpgsql
AS $$
BEGIN
        INSERT INTO usuario (genero, idade)
        VALUES (input_genero, input_idade);
END;
$$;

--Atualiza o nível de satisfação de um usuário na tabela comportamentocompra.
CREATE OR REPLACE PROCEDURE prc_atualizar_satisfacao_usuario(
    p_usuario_id INT,
    p_nova_satisfacao INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE comportamento_compra
    SET shopping_satisfaction = p_nova_satisfacao
    WHERE usuario_id = p_usuario_id;

    RAISE NOTICE 'Satisfação do usuário % atualizada para %', p_usuario_id, p_nova_satisfacao;
END;
$$;