begin;

------------------criando tabelas normalizadas-------------

create TABLE usuario(
    usuario_id serial primary key,
    data_criacao timestamptz,
    age int,
    gender varchar(25)
);


create table categoria(
    categoria_id serial primary key,
    nome varchar(100) unique
);

--tabela de relação entre usuário e categoria, 
--visto que um usuário pode se referir a mais de uma categoria
--relação N:N
CREATE TABLE usuario_categoria(
    usuario_id int not null,
    categoria_id int not null,
    primary key(usuario_id, categoria_id),
    constraint fk_usuario_id foreign key(usuario_id) references usuario(usuario_id) on delete cascade,
    constraint fk_categoria_id foreign key(categoria_id) references categoria(categoria_id) on delete cascade
);

--tabela com referencia ao comportamento de compra

CREATE TABLE comportamento_compra( 
  Comport_compra_id SERIAL PRIMARY KEY,
  usuario_id INT,
  Purchase_Frequency Varchar(100), 
  Personalized_Recommendation_Frequency Varchar(100), 
  Browsing_Frequency Varchar(100),
  Product_Search_Method Varchar(100), 
  Search_Result_Exploration Varchar(100), 
  Customer_Reviews_Importance Integer, 
  Add_to_Cart_Browsing Varchar(100), 
  Cart_Completion_Frequency Varchar(100), 
  Cart_Abandonment_Factors Varchar(100), 
  Saveforlater_Frequency Varchar(100), 
  Review_Left Varchar(100), 
  Review_Reliability Varchar(100), 
  Review_Helpfulness Varchar(100), 
  Personalized_Recommendation_Frequency_Score Integer, 
  Recommendation_Helpfulness Varchar(100), 
  Rating_Accuracy Integer, 
  Shopping_Satisfaction Integer, 
  Service_Appreciation Varchar(100),
  Improvement_Area VARCHAR(200) 
  constraint fk_usuario_id foreign key(usuario_id) references usuario (usuario_id) ON DELETE CASCADE
);

--MIGRNAOD OS DADOS DA TABELA ORIGINAL PARA AS NOEMALIZADAS------------------
--preenchendo a tabela usuário
INSERT INTO usuario (data_criacao, age, gender)
SELECT
  to_timestamp("timestamp", 'YYYY/MM/DD HH12:MI:SS AM "GMT"TZH:TZM'), 
  age,
  gender
FROM tabela_original;

-------CONFERINDO MIGRAÇÃO PELA CONTAGEM DE LINHAS-------
SELECT 
    (SELECT COUNT(*) FROM tabela_original) AS registros_originais,
    (SELECT COUNT(*) FROM usuario) AS usuarios_importados;

--preenchendo a tabela categoria com os valores únicos, considerando 
--que a separação das  mesmas para o mesmo usuário é dada pelo ';'
INSERT INTO categoria (nome)
SELECT DISTINCT unnest(string_to_array(Purchase_Categories, ';')) AS categoria
FROM tabela_original
WHERE Purchase_Categories IS NOT NULL AND Purchase_Categories <> '';

-----COFERINDO SE TODAS AS CATEGORIAS FORAM REGISTRADAS-------
SELECT DISTINCT unnest(string_to_array(Purchase_Categories, ';')) AS categoria
FROM tabela_original
EXCEPT
SELECT nome FROM categoria;


-------------PREENCHENDO A TABELA RELACIONAL--------------
--COMO NÃO EXISTE UMA COLUNA DE IDENTIFICAÇÃO ESPECÍFICA NA TABELA ORIGINAL
--E COMO NA TABELA USUÁRIO, CADA USUARIO_ID CORRESPONDE A UMA LINHA DA TABELA ORIGINAL
--PARA GARANTIR O PREENCHIMENTO CORRETO DA TABELA RELACIONAL, NO INSERT FOI 
--USADO O ROW_NUMBER PARA "CRIAR" UM ID PARA CADA LINHA DA TABELA ORIGINAL
--E EM SEGUIDA O UNNEST E O TRIM PARA ATRIBUIR CADA CATEGORIA A UMA LINHA

INSERT INTO usuario_categoria (usuario_id, categoria_id)
SELECT
    sub.rownum AS usuario_id,
    c.categoria_id
FROM (
    SELECT 
        ROW_NUMBER() OVER () AS rownum,
        unnest(string_to_array(Purchase_Categories, ';')) AS categoria
    FROM tabela_original
) AS sub
JOIN categoria c ON trim(sub.categoria) = c.nome;


SELECT * FROM usuario_categoria;

-- CONFERINDO A MIGRAÇÃO---------
SELECT 
    (SELECT COUNT(*) FROM usuario_categoria) AS TOTAL,
    (
        SELECT SUM(array_length(string_to_array(Purchase_Categories, ';'), 1))
        FROM tabela_original
    ) AS TOTAL_ESPERADO;


------MIGRNAOD DADOS PARA TABELA COMPORTAMENTO_COMPRA-----------
INSERT INTO comportamento_compra (
    usuario_id,
    Purchase_Frequency,
    Personalized_Recommendation_Frequency,
    Browsing_Frequency,
    Product_Search_Method,
    Search_Result_Exploration,
    Customer_Reviews_Importance,
    Add_to_Cart_Browsing,
    Cart_Completion_Frequency,
    Cart_Abandonment_Factors,
    Saveforlater_Frequency,
    Review_Left,
    Review_Reliability,
    Review_Helpfulness,
    Personalized_Recommendation_Frequency_Score,
    Recommendation_Helpfulness,
    Rating_Accuracy,
    Shopping_Satisfaction,
    Service_Appreciation,
    Improvement_Area
)
SELECT
    ROW_NUMBER() OVER (
        ORDER BY to_timestamp("timestamp", 'YYYY/MM/DD HH12:MI:SS AM "GMT"TZH:TZM')
    ) AS usuario_id,   -- IDS NA ORDEM DO TIMESTAMP DA TABELA, PARA GARANTIR QUE SEJAM ASSOCIADOS NA ORDEM DA TABELA USUÁRIOS TAMBÉM
    Purchase_Frequency,
    Personalized_Recommendation_Frequency,
    Browsing_Frequency,
    Product_Search_Method,
    Search_Result_Exploration,
    Customer_Reviews_Importance,
    Add_to_Cart_Browsing,
    Cart_Completion_Frequency,
    Cart_Abandonment_Factors,
    Saveforlater_Frequency,
    Review_Left,
    Review_Reliability,
    Review_Helpfulness,
    Personalized_Recommendation_Frequency_Score,
    Recommendation_Helpfulness,
    Rating_Accuracy,
    Shopping_Satisfaction,
    Service_Appreciation,
    regexp_replace(Improvement_Areas, ';+$', '')  -- REMOVER OS ';' QUE SURGIRAM NAS LINHAS DA ULTIMA COLUNA DA TABELA ORIGINAL
FROM tabela_original;


---TESTE MIGRAÇÃO TABELA COMPORTAMENTO_COMPRAS SE AS LINHAS BATEM ENTRE AS TABELAS
SELECT 
    (SELECT COUNT(*) FROM tabela_original) AS originais,
    (SELECT COUNT(*) FROM comportamento_compra) AS comportamento;


--VERIFICANDO SE HÁ DIVERGÊNCIA ENTRE AS INFORMAÇÕES NA COLUNA SERVICE_APPRECIATION USADA COMO EXEMPLO
--NA TABELA ORIGINAL E NA TABELA COMPRTAMENTO_COMPRAS

SELECT * FROM (
    SELECT
        ROW_NUMBER() OVER (ORDER BY to_timestamp("timestamp", 'YYYY/MM/DD HH12:MI:SS AM "GMT"TZH:TZM')) AS usuario_id_temp,
        "timestamp",
        age,
        gender,
        Service_Appreciation
    FROM tabela_original
) AS o
JOIN usuario u ON u.usuario_id = o.usuario_id_temp
JOIN comportamento_compra c ON c.usuario_id = u.usuario_id
WHERE o.Service_Appreciation <> c.Service_Appreciation;


