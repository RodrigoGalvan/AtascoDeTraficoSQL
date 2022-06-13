CREATE TABLE tb_usuario(
	id_usuario SERIAL PRIMARY KEY,
	usuario varchar(30) IS NOT NULL,
	contrasena varchar(30) IS NOT NULL,
	correo varchar(254) IS NOT NULL
);

CREATE TABLE tb_puntuaje(
	id_puntuaje SERIAL PRIMARY KEY,
	id_usuario int,
	puntuaje int,
	fecha timestamp default now()
);

ALTER TABLE tb_puntuaje
ADD CONSTRAINT FK_PuntuajeUsuario 
FOREIGN KEY (id_usuario) 
REFERENCES tb_usuario(id_usuario);

--INSERT
CREATE OR REPLACE PROCEDURE sp_usuario_insert(usuario varchar(30), contrasena varchar(30), correo varchar(254))
AS $$
	INSERT INTO tb_usuario (usuario , contrasena, correo)
	VALUES (usuario, contrasena, correo)
$$ LANGUAGE SQL;

--UPDATE
CREATE OR REPLACE PROCEDURE sp_usuario_update(_id_usuario int, _usuario varchar(30), _contrasena varchar(30), _correo varchar(254))
AS $$
	UPDATE tb_usuario
		SET usuario= _usuario, contrasena = _contrasena, correo = _correo
		WHERE id_usuario = _id_usuario
$$ LANGUAGE SQL;

--DELETE
CREATE OR REPLACE PROCEDURE public.sp_usuario_delete(IN _id_usuario integer)
 LANGUAGE sql
AS $procedure$
	delete from tb_puntuaje where id_usuario = _id_usuario;
	DELETE FROM tb_usuario WHERE id_usuario = _id_usuario;
$procedure$
;


CREATE TABLE tb_Bitacora(
	ids SERIAL,
	nombre varchar(50),
	fecha timestamp default now(),
	tipo varchar(10)
);

--Insertar usuario
CREATE OR REPLACE FUNCTION fn_ins_bitacora()
RETURNS TRIGGER AS $insertar$
DECLARE
BEGIN
	INSERT INTO tb_Bitacora VALUES(NEW.id_usuario,NEW.usuario, CURRENT_TIMESTAMP  ,'Insert');
	RETURN NEW;
END;
$insertar$ LANGUAGE plpgsql;


CREATE TRIGGER tg_insertar_bitacora AFTER INSERT
ON tb_usuario
FOR EACH ROW
EXECUTE PROCEDURE fn_ins_bitacora();

--Borrar usuario
CREATE OR REPLACE FUNCTION fn_del_bitacora()
RETURNS TRIGGER AS $delete$
DECLARE
BEGIN
	INSERT INTO tb_Bitacora VALUES(OLD.id_usuario,old.usuario, CURRENT_TIMESTAMP, 'Delete');
	RETURN NEW;
END;
$delete$ LANGUAGE plpgsql;

CREATE TRIGGER tg_borrar_bitacora AFTER DELETE
ON tb_usuario
FOR EACH ROW
EXECUTE PROCEDURE fn_del_bitacora();

CREATE OR REPLACE VIEW public.vista_puntuaje_usuario
AS SELECT tb_usuario.usuario,
    tb_puntuaje.puntuaje, tb_usuario.id_usuario
   FROM tb_puntuaje
     JOIN tb_usuario ON tb_puntuaje.id_usuario = tb_usuario.id_usuario
  ORDER BY tb_puntuaje.puntuaje DESC
 LIMIT 10;

CREATE OR REPLACE PROCEDURE sp_puntuaje_insert(_id_usuario int, _puntuaje int)
 LANGUAGE sql
AS $procedure$
	INSERT INTO tb_puntuaje (id_usuario , puntuaje)
	VALUES (_id_usuario, _puntuaje)
$procedure$
;



alter table public.tb_bitacora owner to "admin";
alter table tb_puntuaje owner to "admin";
alter table tb_usuario owner to "admin";
alter view vista_puntuaje_usuario owner to "admin";
alter function fn_del_bitacora() owner to "admin";
alter function fn_ins_bitacora() owner to "admin";
alter procedure sp_puntuaje_insert(int4, int4) owner to "admin";
alter procedure sp_usuario_delete(int4) owner to "admin";
alter procedure sp_usuario_insert(varchar, varchar, varchar) owner to "admin";
alter procedure sp_usuario_update(int4, varchar, varchar, varchar) owner to "admin";
alter sequence tb_bitacora_ids_seq owner to "admin";
alter sequence tb_puntuaje_id_puntuaje_seq owner to "admin";
alter sequence tb_usuario_id_usuario_seq owner to "admin";
