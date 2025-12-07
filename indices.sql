--indices da tabela usuário para agilizar as consultas considerando
--que todos os campos são de igual relevância para futuras análises
CREATE INDEX idx_usuario_age ON usuario(age);
CREATE INDEX idx_usuario_gender ON usuario(gender);
CREATE INDEX idx_usuario_criacao ON usuario(data_criacao);
----------------------------------------------------------------------

--indices da tabela categoria para agilizar futuras consultas mais complexa
--pois a tabela possui poucas categorias, logo para consultas internas acaba não fazendo muita diferença
CREATE INDEX idx_categoria_nome ON categoria(nome);
-----------------------------------------------------------------------

--indices da tabela relacional usuario_categoria tem como objetivo acelerar as consultas
-- de associação entre usuário e categoria
CREATE INDEX idx_usuario_categoria_usuario ON usuario_categoria(usuario_id);
CREATE INDEX idx_usuario_categoria_categoria ON usuario_categoria(categoria_id);
----------------------------------------------------------------------

--indices da tabela comportamento_compras
--melhorarar a consulta voltada as colunas consideradas mais relevantes da tabela
CREATE INDEX idx_comportamento_usuario ON comportamento_compra(usuario_id);
CREATE INDEX idx_comportamento_purchase_frequency ON comportamento_compra(Purchase_Frequency);
CREATE INDEX idx_comportamento_search_method ON comportamento_compra(Product_Search_Method);
CREATE INDEX idx_comportamento_cart_abandonment ON comportamento_compra(Cart_Abandonment_Factors);
CREATE INDEX idx_comportamento_shopping_satisfaction ON comportamento_compra(Shopping_Satisfaction);
CREATE INDEX idx_comportamento_service_appreciation ON comportamento_compra(Service_Appreciation);
CREATE INDEX idx_comportamento_improvement_area ON comportamento_compra(Improvement_Area);


SELECT * from comportamento_compra;