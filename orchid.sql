CREATE DATABASE orchid;
USE orchid;

/*========================================================================================================================
                                                      INTEGRANTES ORCHID 
                                                        Gabriel Gomes
                                                       Julia Yoshimura
                                                       Mateus da Silva
                                                        Sandro Guedes
                                                         Thais Gomes
                                                       Thalita Lourenço
==========================================================================================================================*/

/*========================================================================================================================
                                                    REGRAS RELACIONAMENTOS
                                                         TER 1:1
                                                         TER 1:N 
											 TER 1 RELACIONAMENTO DEPENDENTE
==========================================================================================================================*/

/*========================================================================================================================
                                                    LEGENDA
[#] → Tabela de referência ou controle interno (empresa Orchid)

[>] → Tabelas dos clientes/produtores (usuários do sistema)

[~] → Tabelas que fazem registros de interações entre cliente e sistema (ex: sensores, plantios, leituras)
==========================================================================================================================*/

/* 
===========================================================
[#] TABELA: especie_orquidea
Tipo: Referência (uso interno da empresa Orchid)
Finalidade: Cadastro das espécies de orquídeas
===========================================================
*/
CREATE TABLE especie_orquidea (
    id_especie INT PRIMARY KEY AUTO_INCREMENT,
    nome_especie VARCHAR(50) NOT NULL UNIQUE
);

/* Inserção das espécies iniciais */
INSERT INTO especie_orquidea (nome_especie) VALUES
('Phalaenopsis'),
('Cattleya'),
('Vanda');

/* 
===========================================================
[#] TABELA: faixa_luminosidade
Tipo: Referência (uso interno da empresa Orchid)
Finalidade: Definir os limites mínimos e máximos de luminosidade para cada espécie
Relacionamento: 1 faixa para 1 espécie (1:1)
===========================================================
*/
CREATE TABLE faixa_luminosidade (
    id_faixa INT PRIMARY KEY AUTO_INCREMENT,
    fk_especie INT NOT NULL UNIQUE,
    faixa_min_lux DECIMAL(10,2) NOT NULL,
    faixa_max_lux DECIMAL(10,2) NOT NULL,
    observacao VARCHAR(255),
    CONSTRAINT fk_faixa_especie
        FOREIGN KEY (fk_especie) REFERENCES especie_orquidea(id_especie)
);

/* Inserção das faixas de luminosidade por espécie */
INSERT INTO faixa_luminosidade (fk_especie, faixa_min_lux, faixa_max_lux, observacao) VALUES
(1, 1000, 2000, 'Baixa tolerância a mudanças bruscas de temperatura.'),
(2, 2000, 4000, 'Necessita de luz intensa, mas indireta.'),
(3, 5000, 10000, 'Requer alta intensidade de luz e boa ventilação.');

/* 
===========================================================
[>] TABELA: cadastro
Tipo: Usuários do sistema (clientes/produtores)
Finalidade: Dados das empresas que usam o sistema
===========================================================
*/
CREATE TABLE cadastro (
    id_cadastro INT PRIMARY KEY AUTO_INCREMENT,
    empresa VARCHAR(50) NOT NULL UNIQUE,
    cnpj CHAR(14) NOT NULL UNIQUE,
    email VARCHAR(50) NOT NULL UNIQUE,
    telefone VARCHAR(11),
    cep CHAR(8) NOT NULL,
    senha VARCHAR(30) NOT NULL,
    CONSTRAINT chk_email_format CHECK (email LIKE '%@%')
);

/* 
===========================================================
[#] TABELA: orquidario
Tipo: Referência (controle interno da empresa Orchid)
Finalidade: Cadastro dos orquidários onde os sensores estão localizados
Relacionamento: Um orquidário pode ter muitos sensores (1:N)
- Muitos orquidários para 1 espécie (1:N)
- Muitos orquidários para 1 produtor (1:N)
===========================================================
*/
CREATE TABLE orquidario (
    id_orquidario INT PRIMARY KEY AUTO_INCREMENT,
    nome_orquidario VARCHAR(100) NOT NULL,            
    logradouro VARCHAR(255) NOT NULL,                 
    numero INT NOT NULL,                               
    bairro VARCHAR(100) NOT NULL,                     
    cidade VARCHAR(100) NOT NULL,                      
    estado VARCHAR(2) NOT NULL,                        
    cep CHAR(8) NOT NULL,
        fk_especie INT NOT NULL,
    fk_cadastro INT NOT NULL,
    descricao_local VARCHAR(100),
    CONSTRAINT fk_orquidario_especie 
        FOREIGN KEY (fk_especie) REFERENCES especie_orquidea(id_especie),
    CONSTRAINT fk_orquidario_cadastro 
        FOREIGN KEY (fk_cadastro) REFERENCES cadastro(id_cadastro)
);

/* 
===========================================================
[~] TABELA: sensor
Tipo: Equipamento dos clientes (ligado ao cadastro)
Finalidade: Sensores instalados nos orquidários dos produtores
Relacionamento: Muitos sensores para 1 orquidário (1:N)
-Muitos sensores para 1 produtor (1:N)
===========================================================
*/
CREATE TABLE sensor (
    id_sensor INT PRIMARY KEY AUTO_INCREMENT,
		status_sensor VARCHAR(12) NOT NULL,
    fk_orquidario INT NOT NULL,  
    fk_cadastro INT NOT NULL,    
    CONSTRAINT chk_status_sensor 
        CHECK (status_sensor IN ('Ativo', 'Inativo', 'Manutenção')),
    CONSTRAINT fk_sensor_orquidario 
        FOREIGN KEY (fk_orquidario) REFERENCES orquidario(id_orquidario),
    CONSTRAINT fk_sensor_cadastro 
        FOREIGN KEY (fk_cadastro) REFERENCES cadastro(id_cadastro)
);

/* 
===========================================================
[~] TABELA: registro_luminosidade
Tipo: Coleta de dados (sensores em funcionamento)
Finalidade: Guarda os dados de luminosidade em cada plantio
Relacionamentos:
- Muitas leituras para 1 plantio (1:N)
- Muitas leituras para 1 sensor (1:N)
===========================================================
*/
CREATE TABLE registro_luminosidade (
    id_registro_luminosidade INT PRIMARY KEY AUTO_INCREMENT,
    fk_sensor INT NOT NULL,
    intensidade_luz DECIMAL(10,2) NOT NULL,
    status_luz VARCHAR(50) NOT NULL,
    horario_att DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_status_luz 
        CHECK (status_luz IN ('Iluminação Adequada', 'Iluminação Excessiva', 'Iluminação Insuficiente')),
    CONSTRAINT fk_registro_sensor 
        FOREIGN KEY (fk_sensor) REFERENCES sensor(id_sensor)
);

/* 
===============================================================
[#] TABELA: instalacao
Tipo: Controle interno (empresa Orchid)
Finalidade: Registro das instalações feitas para os clientes
Relacionamento: Múltiplas instalações para 1 cadastro (1:N)
Dependente: instalação depende do cadastro existir
================================================================
*/
CREATE TABLE instalacao (
    id_instalacao INT PRIMARY KEY AUTO_INCREMENT,
    fk_cadastro INT NOT NULL,
    dt_instalacao DATE NOT NULL,
    valor_instalacao DECIMAL(10,2) NOT NULL,
    validade_produto DATE NOT NULL,
    qtd_produto_instalado INT NOT NULL,
    CONSTRAINT fk_instalacao_cadastro
        FOREIGN KEY (fk_cadastro) REFERENCES cadastro(id_cadastro)
);

/* 
====================================================================
[#] TABELA: devolucao
Tipo: Controle interno (empresa Orchid)
Finalidade: Registra devoluções de produtos feitas pelos clientes
Relacionamento: Cada instalação pode ter no máximo 1 devolução (1:1)
====================================================================
*/
CREATE TABLE devolucao (
    fk_instalacao INT PRIMARY KEY,
    motivo_devolucao VARCHAR(255) NOT NULL,
    dt_devolucao DATE NOT NULL,
    CONSTRAINT fk_instalacao_devolucao
        FOREIGN KEY (fk_instalacao) REFERENCES instalacao(id_instalacao)
);
