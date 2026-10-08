-- Motor utilizado: SQL Server (SSMS)
-- Modulo 5 - Pre-entrega: Consultas con JOINs para RetailPro
-- Base de datos: Ventas_Tech_DB (creada en el Modulo 3)
-- Este script solo consulta datos; no modifica las tablas.

USE Ventas_Tech_DB;
GO

-- =========================================================
-- CONSULTA 1 - VISTA BASE DEL PROYECTO (INNER JOIN)
-- Une las ventas con clientes, productos y categorias.
-- Cada fila representa una venta registrada.
-- =========================================================
SELECT
    v.id_venta,
    v.fecha_venta,
    c.id_cliente,
    c.nombre AS nombre_cliente,
    c.ciudad AS ciudad_cliente,
    p.id_producto,
    p.nombre_producto,
    cat.nombre_categoria AS categoria,
    v.cantidad,
    v.precio_unitario,
    v.cantidad * v.precio_unitario AS total_venta
FROM ventas AS v
INNER JOIN clientes AS c
    ON v.id_cliente = c.id_cliente
INNER JOIN productos AS p
    ON v.id_producto = p.id_producto
INNER JOIN categorias AS cat
    ON p.id_categoria = cat.id_categoria
ORDER BY v.fecha_venta, v.id_venta;
GO

-- =========================================================
-- CONSULTA 2 - CLIENTES SIN VENTAS (LEFT JOIN)
-- El LEFT JOIN conserva todos los clientes, aunque no compraran.
-- WHERE v.id_venta IS NULL identifica los que no tienen ventas.
-- =========================================================
SELECT
    c.id_cliente,
    c.nombre AS nombre_cliente,
    c.email,
    c.fecha_registro
FROM clientes AS c
LEFT JOIN ventas AS v
    ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL
ORDER BY c.nombre;
GO

-- =========================================================
-- CONSULTA 3 - PRODUCTOS SIN VENTAS (LEFT JOIN)
-- Busca productos del catalogo que no aparecen en ventas.
-- =========================================================
SELECT
    p.id_producto,
    p.nombre_producto,
    cat.nombre_categoria AS categoria,
    p.precio
FROM productos AS p
INNER JOIN categorias AS cat
    ON p.id_categoria = cat.id_categoria
LEFT JOIN ventas AS v
    ON p.id_producto = v.id_producto
WHERE v.id_venta IS NULL
ORDER BY p.nombre_producto;
GO

-- =========================================================
-- CONSULTA 4 - CONSOLIDADO POR ORIGEN (UNION ALL)
-- La tabla ventas no tiene una columna canal.
-- Creamos etiquetas ficticias para dos periodos distintos:
-- 'Primera quincena' (dias 1 al 15) y
-- 'Segunda quincena' (dias 16 al final del mes).
-- Los filtros no se superponen: cada venta aparece una sola vez.
-- =========================================================
SELECT
    consolidado.canal,
    COUNT(*) AS cantidad_ventas,
    SUM(consolidado.total) AS total_canal
FROM (
    SELECT
        v.id_venta,
        v.cantidad * v.precio_unitario AS total,
        'Primera quincena' AS canal
    FROM ventas AS v
    WHERE DAY(v.fecha_venta) BETWEEN 1 AND 15

    UNION ALL

    SELECT
        v.id_venta,
        v.cantidad * v.precio_unitario AS total,
        'Segunda quincena' AS canal
    FROM ventas AS v
    WHERE DAY(v.fecha_venta) >= 16
) AS consolidado
GROUP BY consolidado.canal
ORDER BY consolidado.canal;
GO

-- =========================================================
-- COMPROBACION OPCIONAL
-- La suma de ambos grupos de la consulta 4 debe coincidir
-- con la facturacion total de la tabla ventas.
-- Ejecutar por separado si se quiere comprobar el importe.
-- SELECT SUM(cantidad * precio_unitario) AS total_general FROM ventas;
-- =========================================================
