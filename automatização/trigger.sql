--------------------TRIGGER---------------------
--trigger que gera um novo registro em uma nova tabela, sempre que o nível de satisfação de uma compra for menor ou igual a 2
CREATE TABLE alerta_insatisfacao (
    alerta_id SERIAL PRIMARY KEY,
    usuario_id INT NOT NULL,
    nivel_satisfacao INT,
    data_alerta TIMESTAMP DEFAULT NOW(),
    CONSTRAINT fk_alerta_usuario FOREIGN KEY (usuario_id) REFERENCES usuario(usuario_id) ON DELETE CASCADE
);

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

--Trigger que gera registro em uma nova tabela sempre que um usuário for inserido 
--no sistema para acompanhamento de usuários criados.
CREATE TABLE log_usuario (
    log_id SERIAL PRIMARY KEY,
    usuario_id INT REFERENCES usuario (usuario_id),
    data_log TIMESTAMP DEFAULT NOW(),
    acao TEXT
);

CREATE OR REPLACE FUNCTION trg_log_usuario()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO log_usuario(usuario_id, acao)
    VALUES (NEW.usuario_id, 'Usuário cadastrado');
    RETURN NEW;
END;
$$;

CREATE TRIGGER usuario_audit_trigger
AFTER INSERT ON usuario
FOR EACH ROW
EXECUTE PROCEDURE trg_log_usuario();

--Trigger que impede cadastro de usuário com idade inválida.
CREATE OR REPLACE FUNCTION trg_valida_idade_usuario()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.idade < 0 OR NEW.idade > 120 THEN
        RAISE EXCEPTION 'Idade inválida: %', NEW.idade;
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER valida_idade_trigger
BEFORE INSERT OR UPDATE ON usuario
FOR EACH ROW
EXECUTE PROCEDURE trg_valida_idade_usuario();