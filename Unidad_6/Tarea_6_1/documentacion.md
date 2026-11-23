# Sintaxis y clasificación de sentencias SQL

**Unidad 6 · Tarea 6.1**  
**Proyecto** Préstamo de material deportivo universitario  
**Alumno** Jesús Armando Zendejo Altamirano

## Características de SQL y clasificación de sentencias

SQL es el lenguaje estándar para definir estructuras, consultar y modificar datos relacionales. En una consulta declarativa se expresa qué filas y columnas se necesitan. El motor de SQL Server elige un plan para obtenerlas. Transact-SQL, abreviado T-SQL, es el dialecto de SQL Server y añade opciones propias como TOP, OUTPUT y bloques TRY…CATCH.

Las tablas se identifican por su esquema y nombre, por ejemplo dbo.Ejemplar. El tipo de dato delimita los valores de cada columna. Las restricciones PRIMARY KEY, FOREIGN KEY, UNIQUE, CHECK y NOT NULL expresan reglas que el motor verifica. SQL puede devolver duplicados y las consultas tienen un orden garantizado únicamente cuando incluyen ORDER BY en el resultado final.

| Sentencia | Familia y subclase | Objeto directo | Efecto principal |
|---|---|---|---|
| CREATE | LDD · creación | Base, tabla u objeto | Crea su definición y las restricciones indicadas. |
| ALTER | LDD · modificación | Objeto existente | Cambia columnas, restricciones u otras propiedades. |
| DROP | LDD · eliminación | Objeto existente | Elimina la definición y, al quitar una tabla, sus datos. |
| TRUNCATE | LDD · vaciado | Tabla o particiones | Desasigna páginas de datos y conserva la definición. |
| INSERT | LMD · alta | Filas nuevas | Agrega filas literales o producidas por una consulta. |
| UPDATE | LMD · cambio | Filas existentes | Asigna nuevos valores a las columnas elegidas. |
| DELETE | LMD · baja | Filas existentes | Elimina filas, con filtro opcional. |
| SELECT | LMD · consulta | Conjunto de resultados | Lee, calcula, agrupa o combina datos. |

Microsoft incluye SELECT en LMD. Algunos cursos lo llaman Lenguaje de Consulta de Datos, LQD o DQL. En este informe se usa la clasificación solicitada.

Las formas siguientes resumen la sintaxis de SQL Server. Los corchetes marcan elementos opcionales, las llaves agrupan alternativas y la barra vertical significa «o». Los nombres entre ángulos son marcadores que se reemplazan. La elipsis indica repetición.

<!-- page -->
## Sentencias LDD para crear y modificar estructuras

### CREATE

```sql
CREATE DATABASE <base> [COLLATE <intercalacion>];

CREATE TABLE [<esquema>.]<tabla> (
    <columna_def> [, <columna_def> ...]
    [, <restriccion_tabla> ...]
);
<columna_def> ::= <columna> <tipo>
    [IDENTITY(<semilla>, <incremento>)] [NULL | NOT NULL] [DEFAULT <valor>]
<restriccion_tabla> ::= [CONSTRAINT <nombre>] {
    PRIMARY KEY (<columnas_pk>) | UNIQUE (<columnas_unicas>)
    | FOREIGN KEY (<columnas_fk>) REFERENCES <tabla_padre> (<columnas_clave>)
        [ON DELETE {NO ACTION | CASCADE | SET NULL | SET DEFAULT}]
    | CHECK (<condicion>)
}
```

CREATE DATABASE establece el contenedor. COLLATE elige reglas de comparación y ordenación de texto. CREATE TABLE define las columnas, su tipo y si aceptan NULL. En la forma mostrada se usan comas entre definiciones y se omite la última coma.

PRIMARY KEY identifica una fila y exige valores únicos y no nulos. FOREIGN KEY apunta a una clave primaria o única de la tabla padre. Las columnas referenciadas y las columnas de la FK deben corresponder en cantidad, orden y tipos admitidos. UNIQUE evita valores repetidos de la clave alternativa. CHECK rechaza las filas que dan falso en la condición. NOT NULL permite exigir un valor cuando la condición podría resultar desconocida. DEFAULT se usa cuando se omite la columna o se solicita DEFAULT.

IDENTITY genera valores al insertar. La unicidad se impone con una clave. CASCADE propaga el borrado y SET NULL exige columnas foráneas anulables. En el proyecto, dbo.Ejemplar declara FK hacia dbo.TipoMaterial.

### ALTER

```sql
ALTER TABLE dbo.<tabla> ADD <columna> <tipo> [NULL | NOT NULL];
ALTER TABLE dbo.<tabla> ALTER COLUMN <columna> <tipo> {NULL | NOT NULL};
ALTER TABLE dbo.<tabla> DROP COLUMN <columna>;
ALTER TABLE dbo.<tabla> WITH CHECK
    ADD CONSTRAINT <nombre> CHECK (<condicion>);
ALTER TABLE dbo.<tabla> DROP CONSTRAINT <nombre>;
ALTER TABLE dbo.<tabla> WITH CHECK CHECK CONSTRAINT <nombre>;
```

ADD incorpora una columna o restricción. ALTER COLUMN modifica el tipo o la nulabilidad y puede fallar si hay datos incompatibles o dependencias. Para añadir una columna NOT NULL a una tabla con filas, se puede proporcionar DEFAULT para inicializarlas. DROP COLUMN exige resolver sus dependencias.

WITH CHECK valida las filas existentes al agregar o volver a habilitar un CHECK o una FK. El doble CHECK de la última forma comprueba los datos existentes y habilita la restricción. En el proyecto se puede añadir una nota opcional a un ejemplar con ADD nota nvarchar(120) NULL.

<!-- page -->
## Sentencias LDD para eliminar o vaciar objetos

### DROP

```sql
DROP TABLE [IF EXISTS] [<esquema>.]<tabla> [, <otra_tabla>, ...];
```

DROP TABLE elimina la definición, el contenido y los índices y restricciones propios de la tabla. IF EXISTS, disponible desde SQL Server 2016, permite ejecutar la sentencia cuando el objeto falta. Los permisos y las dependencias todavía se verifican.

Si otra tabla referencia el objeto con una FK, se debe resolver esa dependencia antes de quitarlo. Si se eliminan las dos tablas en una sentencia, se lista primero la tabla hija. En el proyecto, la FK de Ejemplar impide eliminar la tabla TipoMaterial mientras exista esa referencia.

### TRUNCATE

```sql
TRUNCATE TABLE [<esquema>.]<tabla>
    [WITH (PARTITIONS (<numero> [TO <numero>] [, ...]))];
```

TRUNCATE TABLE conserva la estructura y quita todas las filas, o las de las particiones indicadas. Carece de WHERE. Desasigna páginas y, al truncar la tabla completa, reinicia su contador IDENTITY a la semilla. No activa disparadores DELETE. SQL Server permite revertir el truncamiento en una transacción.

La opción PARTITIONS se usa con tablas particionadas y exige índices alineados con la tabla. Las FK desde otras tablas impiden el truncamiento, incluso si la tabla hija está vacía. SQL Server admite la excepción de una FK que se referencia a sí misma. También hay limitaciones para tablas temporales con control de versiones del sistema y tablas que participan en vistas indexadas.

| Operación | Permite WHERE | Conserva la definición | Filas afectadas |
|---|---|---|---|
| DROP TABLE | No | No | Todas junto con el objeto. |
| TRUNCATE TABLE | No | Sí | Todas, o las de particiones elegidas. |
| DELETE | Sí | Sí | Las que cumplen WHERE, o todas si se omite. |

Un DELETE de una fila de TipoMaterial puede proceder si ningún Ejemplar la referencia. TRUNCATE y DROP evalúan la dependencia entre tablas y se aplican al objeto, por lo que ese caso se resuelve con DELETE.

<!-- page -->
## Sentencias LMD para insertar y actualizar filas

### INSERT

```sql
INSERT [TOP (<n>)] [INTO] <tabla> [(<columnas>)]
    [OUTPUT <expresiones> [INTO <destino_salida>]]
    { VALUES (<valores>) [, (...)]
    | SELECT <expresiones> FROM <fuente>
    | DEFAULT VALUES };
```

La lista de columnas determina el destino de cada valor por posición. Las columnas omitidas deben admitir NULL, tener un valor predeterminado o generarse automáticamente. Se validan conversiones, unicidad, CHECK y referencias. Para enviar texto Unicode a una columna nvarchar se utiliza un literal N'…'.

VALUES inserta una o varias filas. INSERT … SELECT usa una consulta como origen. OUTPUT inserted.<columna> permite recuperar, por ejemplo, el identificador generado. La asignación explícita de una columna IDENTITY requiere SET IDENTITY_INSERT <tabla> ON durante la operación.

Ejemplo sobre el catálogo del proyecto, suponiendo que el identificador esté libre.

```sql
INSERT dbo.TipoMaterial (idTipo, nombre, deporte)
VALUES (9305, N'Cronómetro', N'Atletismo');
```

### UPDATE

```sql
UPDATE [TOP (<n>)] <tabla_o_alias>
    SET <columna> = {<expresion> | DEFAULT | NULL} [, ...]
    [OUTPUT <expresiones> [INTO <destino_salida>]]
    [FROM <fuentes_y_reuniones>]
    [WHERE <predicado>];
```

SET admite varias asignaciones. WHERE determina las filas elegibles. Si se omite y tampoco hay otro filtro, se actualizan todas las filas elegibles. Las restricciones se aplican a los nuevos valores. En UPDATE … FROM se debe asegurar una única fila fuente por fila destino que se actualiza.

OUTPUT deleted.<columna> e inserted.<columna> muestran el valor previo y posterior. TOP limita cuántas filas elegibles se actualizan, sin establecer por sí solo cuáles serán. Una consulta derivada y ordenada puede determinar las claves objetivo.

```sql
UPDATE dbo.Ejemplar
SET idTipo = 9305
WHERE codigoInventario = 'U6-CON-01';
```

El motor comprueba que el tipo 9305 exista. El ejemplo se revierte en las pruebas de la Tarea 6.2.

<!-- page -->
## Sentencias LMD para eliminar y consultar filas

### DELETE

```sql
DELETE [TOP (<n>)] [FROM] <tabla_o_alias>
    [OUTPUT <expresiones> [INTO <destino_salida>]]
    [FROM <fuentes_y_reuniones>]
    [WHERE <predicado>];
```

WHERE limita las filas elegibles. Sin filtro, DELETE puede afectar todas las filas de la tabla. Si existen referencias, el motor aplica la acción declarada en la FK. NO ACTION bloquea el borrado que dejaría filas huérfanas. OUTPUT deleted permite recuperar valores de las filas eliminadas.

Una segunda cláusula FROM en T-SQL permite usar reuniones para identificar filas. TOP limita la cantidad, sin asegurar un orden. Una selección ordenada de claves sirve cuando interesa borrar un lote específico.

### SELECT

```sql
[WITH <nombre_cte> AS (<consulta>) [, ...]]
SELECT [ALL | DISTINCT] [TOP (<n>) [PERCENT] [WITH TIES]]
    <columnas_o_expresiones>
[FROM <fuente> [{INNER | LEFT [OUTER]} JOIN <fuente> ON <condicion>]]
[WHERE <predicado_de_fila>]
[GROUP BY <expresiones> [, ...]]
[HAVING <predicado_de_grupo>]
[ORDER BY <expresion> [ASC | DESC] [, ...]
    [OFFSET <n> ROWS [FETCH NEXT <m> ROWS ONLY]]];
```

FROM define el origen y JOIN combina filas. WHERE filtra antes de agrupar. GROUP BY reúne filas por claves y HAVING filtra los grupos. En una consulta agregada, las expresiones seleccionadas que dependen de columnas sin agregar deben basarse en las claves de agrupación.

ALL conserva duplicados. DISTINCT los elimina. TOP con ORDER BY define qué filas encabezan el resultado. WITH TIES incluye empates y requiere ORDER BY. OFFSET y FETCH permiten paginar y requieren ORDER BY. TOP y OFFSET no se combinan en el mismo ámbito de consulta. Una CTE asigna un nombre a una expresión de consulta disponible durante una sentencia. Si hay una sentencia previa en el mismo lote, se termina con punto y coma.

```sql
SELECT idTipo, COUNT(*) AS ejemplares
FROM dbo.Ejemplar
WHERE estadoOperativo = 'apto'
GROUP BY idTipo
HAVING COUNT(*) >= 2
ORDER BY ejemplares DESC, idTipo;
```

La consulta del ejemplo conserva grupos con al menos dos ejemplares aptos. SELECT INTO es una variante que crea una tabla nueva a partir de la consulta.

<!-- page -->
## Aplicación en SQL Server y fuentes

| Necesidad del proyecto | Sentencia | Comprobación |
|---|---|---|
| Crear TipoMaterial y Ejemplar | CREATE TABLE | Se definen PK, FK y restricciones. |
| Agregar un atributo opcional | ALTER TABLE ADD | La tabla conserva las filas previas. |
| Incorporar un tipo de material | INSERT | Su clave debe estar libre. |
| Cambiar la clasificación de una pieza | UPDATE … WHERE | El tipo nuevo debe existir. |
| Eliminar un tipo sin ejemplares | DELETE … WHERE | El motor comprueba la FK. |
| Identificar tipos con piezas aptas | SELECT | WHERE selecciona filas y HAVING selecciona grupos. |

En SQL Server, BEGIN TRANSACTION abre una transacción explícita. COMMIT confirma sus cambios y ROLLBACK los revierte. La Tarea 6.2 usa transacciones para probar actualizaciones y borrados sin alterar los datos de ejemplo. CREATE DATABASE se ejecuta como instrucción autoconfirmada y queda fuera de la transacción que crea las tablas.

### Fuentes

- Microsoft Learn. [CREATE TABLE](https://learn.microsoft.com/sql/t-sql/statements/create-table-transact-sql) y [CREATE DATABASE](https://learn.microsoft.com/sql/t-sql/statements/create-database-transact-sql).
- Microsoft Learn. [ALTER TABLE](https://learn.microsoft.com/sql/t-sql/statements/alter-table-transact-sql).
- Microsoft Learn. [DROP TABLE](https://learn.microsoft.com/sql/t-sql/statements/drop-table-transact-sql) y [TRUNCATE TABLE](https://learn.microsoft.com/sql/t-sql/statements/truncate-table-transact-sql).
- Microsoft Learn. [Sentencias LMD](https://learn.microsoft.com/sql/t-sql/queries/queries), [INSERT](https://learn.microsoft.com/sql/t-sql/statements/insert-transact-sql) y [OUTPUT](https://learn.microsoft.com/sql/t-sql/queries/output-clause-transact-sql).
- Microsoft Learn. [UPDATE](https://learn.microsoft.com/sql/t-sql/queries/update-transact-sql), [DELETE](https://learn.microsoft.com/sql/t-sql/statements/delete-transact-sql) y [SELECT](https://learn.microsoft.com/sql/t-sql/queries/select-transact-sql).
