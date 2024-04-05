 create database if not exists clean;
 
 
 use clean;
 
select * from clean.limpieza  limit 10;

select * from limpieza;

-- aqui declaramos un procedimiento almacenado
DELIMITER // 
CREATE PROCEDURE limp()
BEGIN
	select * from limpieza; 
END //
DELIMITER ;

CALL limp();

select * from limpieza limit 1 offset 14809; 
-- aqui escribo un comentario 
-- aqui se hace el cambio de nombre de la columna
ALTER TABLE limpieza CHANGE COLUMN `Id_emp` Id_employee varchar (20) null;
ALTER TABLE limpieza CHANGE COLUMN `Apellido` last_name VARCHAR (200) null;

-- Identificar Duplicados --
select Id_employee, count(*) as cantidad_duplicados
from limpieza
group by Id_employee
Having count(*) > 1;

-- Contar Números de Duplicados --
select count(*) as cantidad_duplicados
from (
select Id_employee, count(*) as cantidad_duplicados
from limpieza
group by Id_employee
Having count(*) > 1
) as subquery; 
-- Eliminar Duplicados --
-- 1-- Crear una tabla temporal --
-- renombrar tabla --
rename table limpieza to conduplicados;

CREATE TEMPORARY TABLE Temp_limpieza AS
SELECT DISTINCT * FROM conduplicados;

SELECT 
    COUNT(*) AS original
FROM
    conduplicados;
SELECT 
    COUNT(*) AS original
FROM
    Temp_limpieza;

-- 3. Convertir Tabla Temporal a permanente (eliminar los duplicados) --
CREATE TABLE LIMPIEZA AS SELECT * FROM
    TEMP_LIMPIEZA;

CALL LIMP();

DROP TABLE CONDUPLICADOS;
SET sql_safe_updates = 0;

ALTER TABLE limpieza CHANGE COLUMN star_date Start_Date varchar (50) null;
ALTER TABLE limpieza CHANGE COLUMN finish_date Finish_Date varchar (50) null;

-- Ver Propiedades de la Tabla -- (metadato)
DESCRIBE LIMPIEZA;

CALL LIMP();
-- 1. ELIMINAR ESPACIOS EN LOS NOMBRES--
select name from limpieza
where length(name)- length(trim(name)) > 0;

-- Actualizar Tabla (2.1 Ensayo - 2.2 Actualizar) --
select name, trim(name) as name  
from limpieza 
where length(name)- length(trim(name)) > 0;

UPDATE LIMPIEZA SET NAME = TRIM(NAME)
where length(name)- length(trim(name)) > 0;

-- Convertir y darle Formato sin espacios a Last_Name --

select last_name, trim(last_name) as last_name  
from limpieza 
where length(last_name)- length(trim(last_name)) > 0;

UPDATE LIMPIEZA SET last_name = TRIM(last_name)
where length(last_name)- length(trim(last_name)) > 0;

-- Remover espacios entre dos palabras --
-- 1. Identificar - 2. Actualizar Tabla
UPDATE LIMPIEZA SET area = REPLACE(area,' ','    ');
call limp();


select area from limpieza
where area regexp '\\s{2,}';
-- en el siguiente se redujo los espacios a sencillo espacio en la seccion de area --
select area, trim(regexp_replace(area, '\\s+',' ')) as ensayo from limpieza;

-- actualizar la tabla con los cambios recientes --
UPDATE limpieza SET area = trim(regexp_replace(area, '\\s+',' '));
call limp();

-- BUSCAR Y REEMPLAZAR -- (ENSAYAR-> ACTUALIZAR TABLA-> MODIFICAR PROPIEDAD (si es necesario))

SELECT gender,
case
	when gender = 'hombre' then 'male'
    when gender = 'mujer' then 'female'
    else 'other'
END as gender1
from limpieza;

UPDATE limpieza SET gender = CASE
	when gender = 'hombre' then 'male'
    when gender = 'mujer' then 'female'
    else 'other'
END;

call limp();

-- en la columna type hay numeros boleanos se debe a convertir a datos relevantes --
DESCRIBE LIMPIEZA;
-- PASO A SEGUIR ES PASAR DE INT A TEXT --
ALTER TABLE LIMPIEZA MODIFY COLUMN type TEXT;

Select type,
CASE
	when type = 1 then 'Remote'
    when type = 0 then 'Hybrid'
    Else 'Other'
END as Type1
from limpieza;

UPDATE limpieza 
SET Type = CASE
	when type = 1 then 'Remote'
    when type = 0 then 'Hybrid'
    Else 'Other'
END;
call limp();

-- DAR FORMATO DE NUMERO A UN TEXTO--
-- para esto se va a ser una funcion anidada--
select salary,
CAST(trim(REPLACE(REPLACE(salary, '$',''),',','')) AS decimal (15, 2))  AS salary1 from limpieza;

UPDATE limpieza SET salary = CAST(trim(REPLACE(REPLACE(salary,'$',''), ',','')) AS decimal (15, 2));

-- teniendo el formato de numero ---

alter table limpieza modify column salary int null;

DESCRIBE LIMPIEZA;

-- AJUSTANDO FORMATOS DE FECHAS ---
select birth_date from limpieza;


select birth_date, case
	when birth_date like '%/%' then date_format(str_to_date(birth_date, '%m/%d/%Y'), '%Y-%m-%d')
	when birth_date like '%-%' then date_format(str_to_date(birth_date, '%m/%d/%Y'), '%Y-%m-%d')
else null
end as new_birth_date
from limpieza;
-- Actualizar la Tabla--
UPDATE limpieza2
SET birth_date= CASE
	when birth_date like '%/%' then date_format(str_to_date(birth_date, '%m/%d/%Y'), '%Y-%m-%d')
	when birth_date like '%-%' then date_format(str_to_date(birth_date, '%m/%d/%Y'), '%Y-%m-%d')
else null
END;

call limp();

-------- Cambiar el tipo de dato de la columna ------------------
ALTER TABLE limpieza2 MODIFY COLUMN birth_date date;
describe limpieza;

---- Ahora modificar start_date ----------

select Start_Date, case
	when Start_Date like '%/%' then date_format(str_to_date(Start_Date, '%m/%d/%Y'), '%Y-%m-%d')
	when Start_Date like '%-%' then date_format(str_to_date(Start_Date, '%m/%d/%Y'), '%Y-%m-%d')
else null
end as new_Start_Date
from limpieza;

-- Actualizar la Tabla--
UPDATE limpieza
SET Start_Date= CASE
	when Start_Date like '%/%' then date_format(str_to_date(Start_Date, '%m/%d/%Y'), '%Y-%m-%d')
	when Start_Date like '%-%' then date_format(str_to_date(Start_Date, '%m/%d/%Y'), '%Y-%m-%d')
else null
END;

call limp();


-------- Cambiar el tipo de dato de la columna ------------------
ALTER TABLE limpieza MODIFY COLUMN Start_Date date;
describe limpieza;

--------- Explorar la columna de Finish_Date ---------------------

select Finish_Date from limpieza;

---------- Explorando otras funciones de fecha -----------------------
-------- # "ensayos" hacer consultas de como quedarian los datos si queremos ensayar diversos cambios ---------


SELECT Finish_Date, str_to_date(Finish_Date, '%Y-%m-%d %H:%i:%s') AS fecha FROM limpieza; -- convierte el valor en objeto de fecha (timestamp)
SELECT Finish_Date, date_format(str_to_date(Finish_Date, '%Y-%m-%d %H:%i:%s'), '%Y-%m-%d') AS fecha FROM limpieza; -- objeto en formato de fecha, luego 
SELECT Finish_Date, str_to_date(Finish_Date, '%Y-%m-%d') AS fd from limpieza; -- separar solo la fecha
SELECT Finish_Date, str_to_date(Finish_Date, '%H:%i:%s') AS hour_stamp FROM limpieza; -- separar solo la hora no funciona
-- la siguiente consulta se hace para separar la hora en otra columna  y se puede presentar porque se esta analizando el volumen de clientes a lo largo del dia
-- en un centro comercial o los ingresos en una pagina web--
SELECT Finish_Date, date_format(Finish_Date, '%H:%i:%s') AS hour_stamp FROM limpieza; -- separar solo la hora (marca de tiempo)

-- # Dividiendo los elementos de la hora (EN HORAS, MINUTOS,SEGUNDOS ) --

select Finish_Date,
	date_format( Finish_Date, '%H') AS hours,
    date_format( Finish_Date, '%i') AS minutes,
	date_format( Finish_Date, '%s') AS seconds,
    date_format(Finish_Date, '%H:%i:%s') AS hour_stamp
FROM limpieza;

/* Diferencia entre timestamp y datetime
-- timestamp (YYYY-MM-DD HH:MM:SS ----) - desde: 01 enero 1970 a las 00:00:00 UTC , hasta milesimas de segundo
-- datetime desde año 1000 a 9999- no  tiene en cuenta la zona horaria, hasta segundos. */

-- Se va a hacer una copia de seguridad de finish_date --
ALTER TABLE LIMPIEZA ADD COLUMN date_backup text;

call limp();

-- Para copiar los datos de Finish_Date a Date_Backup--
UPDATE LIMPIEZA SET date_backup= Finish_Date;

-- Por medio de la siguiente consulta, se elimino la UTC--
SELECT Finish_Date, str_to_date(Finish_Date, '%Y-%m-%d %H:%i:%s') AS fecha FROM limpieza;

-- Se actualiza la tabla por medio de UPDATE--
UPDATE limpieza set Finish_Date= str_to_date(Finish_Date, '%Y-%m-%d %H:%i:%s UTC')
WHERE Finish_Date <> '';

-- LUEGO SE VA A SEPARAR LA FECHA DE LA HORA EN COLUMNAS DIFERENTES --
ALTER TABLE limpieza
	ADD COLUMN fecha date,
    ADD COLUMN hora time;

call limp();

UPDATE limpieza 
SET fecha = date(Finish_Date),
	hora = time(Finish_Date)
where Finish_Date is not null and Finish_Date <> '';

-- Para que los espacios vacios se categorizan como nulos --
UPDATE limpieza SET Finish_Date = null where Finish_Date = '';

-- Entonces ya se puede actualizar la propiedad de la tabla -- (SE PUEDE USAR DATETIME O TIMESTAMP)
ALTER TABLE limpieza MODIFY COLUMN Finish_Date datetime;
DESCRIBE limpieza;

-- Calculos con Fechas -- ( para calcular la edad de los empleados, la edad de los clientes, el tiempo que pasan en un determinado lugar en un centro comercial)
-- se calculara la edad de los empleados por lo que tenemos la fecha de nacimiento de c/u de ellos--

ALTER TABLE limpieza add column age INT; 
call limp();

-- en la siguiente consulta se quiere saber la edad de los empleados cuando ingresaron a la compañia--
select name, birth_date, Start_Date, timestampdiff(year, birth_date, Start_Date) as edad_de_ingreso from limpieza;

UPDATE limpieza
set AGE = timestampdiff(year, birth_date, curdate());

select * from limpieza;

 SET SQL_SAFE_UPDATES = 0;

call limp();

-- Para filtrar informacion --


-- Crear Funciones de Texto (correo electronico para los empleados)-- 
Select concat(substring_index(name,' ', 1),'_', substring(last_name, 1, 2), '.', substring(type, 1, 2), '@consulting.com') as email from limpieza;

alter table limpieza add column email varchar(100);

UPDATE LIMPIEZA set email = concat(substring_index(name,' ', 1),'_', substring(last_name, 1, 2), '.', substring(type, 1, 2), '@consulting.com');

-- CREANDO Y EXPORTANDO LOS DATOS DEFINITIVOS --

SELECT Id_employee, Name, last_name, age, Gender, area, salary, Start_Date, Finish_Date, email FROM LIMPIEZA
WHERE Finish_Date <= curdate() OR Finish_Date is null
order by area, last_name;

-- CONTAR EMPLEADOS POR AREA ----------
SELECT area, count(*) as cantidad_empleados from limpieza
GROUP BY area
ORDER BY cantidad_empleados DESC;

