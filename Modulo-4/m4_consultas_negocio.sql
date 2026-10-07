-- Motor utilizado: SQL Server (SSMS)
-- Pre-entrega 4: Consultas SQL de negocio
-- Base de datos: Ventas_Tech_DB
-- Se trabaja solamente con la tabla ventas.

USE Ventas_Tech_DB;
GO

-- =========================================================
-- CONSULTA 1 - RESUMEN EJECUTIVO MENSUAL
-- Total facturado, cantidad de pedidos y ticket promedio por mes.
-- =========================================================

SELECT
    MONTH(fecha_venta) AS mes,
    SUM(cantidad * precio_unitario) AS total_facturado,
    COUNT(*) AS cantidad_pedidos,
    AVG(cantidad * precio_unitario) AS ticket_promedio
FROM ventas
GROUP BY MONTH(fecha_venta)
ORDER BY mes;
GO


-- =========================================================
-- CONSULTA 2 - RANKING DE PRODUCTOS
-- Top 5 de productos por total facturado.
-- =========================================================

SELECT TOP 5
    id_producto,
    SUM(cantidad) AS unidades_vendidas,
    SUM(cantidad * precio_unitario) AS total_facturado
FROM ventas
GROUP BY id_producto
ORDER BY total_facturado DESC;
GO


-- =========================================================
-- CONSULTA 3 - CLIENTES RECURRENTES
-- Clientes que realizaron mas de un pedido.
-- =========================================================

SELECT
    id_cliente,
    COUNT(*) AS cantidad_pedidos,
    SUM(cantidad * precio_unitario) AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY total_gastado DESC;
GO


-- =========================================================
-- CONSULTA 4 - MESES VS. PROMEDIO MENSUAL
-- Compara la facturacion de cada mes con el promedio mensual general.
-- =========================================================

WITH facturacion_mensual AS (
    SELECT
        MONTH(fecha_venta) AS mes,
        SUM(cantidad * precio_unitario) AS total_facturado
    FROM ventas
    GROUP BY MONTH(fecha_venta)
),
promedio_general AS (
    SELECT AVG(total_facturado) AS promedio_mensual
    FROM facturacion_mensual
)
SELECT
    f.mes,
    f.total_facturado,
    p.promedio_mensual,
    CASE
        WHEN f.total_facturado > p.promedio_mensual THEN 'Por encima'
        WHEN f.total_facturado < p.promedio_mensual THEN 'Por debajo'
        ELSE 'Igual al promedio'
    END AS comparacion_promedio
FROM facturacion_mensual AS f
CROSS JOIN promedio_general AS p
ORDER BY f.mes;
GO


-- =========================================================
-- HALLAZGOS
-- =========================================================
-- 1. En marzo se registraron 10 pedidos y una facturacion total de 6444.00.
-- 2. El producto 1 lidera el ranking: genero 3600.00 de facturacion con 3 unidades vendidas.
-- 3. Los cinco clientes son recurrentes porque cada uno realizo 2 pedidos.
--    El cliente 1 es el de mayor gasto total, con 2640.00.

