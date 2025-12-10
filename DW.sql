
--A ideia desse DW é responder a seguinte questão
--Quais motivos de abandono são mais frequentes em um dado periodo de tempo(dias)?
CREATE TABLE dim_tempo(
    id_tempo INT PRIMARY KEY not NULL,
    dia INT,
    mes INT,
    ano INT,
    nome_mes varchar(20),
    periodo_dias INT
);

CREATE TABLE dim_usuario(
    id_usuario INT PRIMARY KEY NOT NULL,
    faixa_etaria VARCHAR(20)
);


CREATE TABLE dim_abandono_motivo(
    id_motivo SERIAL PRIMARY KEY,
    motivo TEXT
);

CREATE TABLE fato_abandono(
    id_abandono SERIAL PRIMARY KEY,
    id_usuario INT,
    id_motivo INT, 
    id_tempo INT,
    quantidade INT DEFAULT 1,
    
    CONSTRAINT fk_usuario FOREIGN KEY (id_usuario) REFERENCES dim_usuario(id_usuario),
    CONSTRAINT fk_motivo FOREIGN KEY (id_motivo) REFERENCES dim_abandono_motivo(id_motivo),
    CONSTRAINT fk_tempo FOREIGN KEY (id_tempo) REFERENCES dim_tempo(id_tempo)
);