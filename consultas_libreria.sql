-- ==============================================================================
-- PROYECTO: Análisis Operativo - Librería (Databricks / PostgreSQL)
-- DESCRIPCIÓN: Consultas limpias utilizadas para alimentar el Dashboard
-- ==============================================================================

-- 1. Aporte por tipo de producto (Categoría)
-- Limpieza: Filtra cantidades/precios <= 0, nombres nulos o mal escritos y agrupa vacíos.
SELECT 
    COALESCE(NULLIF(TRIM(c.categoria), ''), 'Sin categoría') AS tipo_producto,
    COUNT(DISTINCT d.operacion_id) AS total_operaciones,
    SUM(d.cantidad) AS total_unidades,
    ROUND(SUM(d.cantidad * d.precio_unitario - COALESCE(d.descuento, 0)), 2) AS importe_total
FROM libreria_catalog.public.detalle_operacion d
JOIN libreria_catalog.public.catalogo c 
    ON d.producto_id = c.producto_id
WHERE d.cantidad > 0 
  AND d.precio_unitario > 0
  AND (d.cantidad * d.precio_unitario - COALESCE(d.descuento, 0)) > 0
  AND c.nombre IS NOT NULL
  AND LOWER(TRIM(c.nombre)) NOT IN ('', 'n/a', 'null', 'prodcto mal escrto')
GROUP BY COALESCE(NULLIF(TRIM(c.categoria), ''), 'Sin categoría')
ORDER BY importe_total DESC;


-- 2. Unidades vendidas por sede, categoría y producto
-- Limpieza: Excluye sedes y productos nulos, vacíos, 'N/A' o con errores de escritura.
SELECT 
    TRIM(s.nombre) AS sede,
    COALESCE(NULLIF(TRIM(c.categoria), ''), 'Sin categoría') AS categoria,
    TRIM(c.nombre) AS producto,
    SUM(d.cantidad) AS total_unidades
FROM libreria_catalog.public.detalle_operacion d
JOIN libreria_catalog.public.operaciones o 
    ON d.operacion_id = o.operacion_id
JOIN libreria_catalog.public.sedes s 
    ON o.sede_id = s.sede_id
JOIN libreria_catalog.public.catalogo c 
    ON d.producto_id = c.producto_id
WHERE s.nombre IS NOT NULL 
  AND TRIM(s.nombre) NOT IN ('', 'N/A', 'null', 'NULL')
  AND c.nombre IS NOT NULL
  AND LOWER(TRIM(c.nombre)) NOT IN ('', 'n/a', 'null', 'prodcto mal escrto')
  AND d.cantidad > 0
GROUP BY 
    TRIM(s.nombre),
    COALESCE(NULLIF(TRIM(c.categoria), ''), 'Sin categoría'),
    TRIM(c.nombre)
ORDER BY sede ASC, total_unidades DESC;


-- 3. Evolución mensual del importe completado
-- Limpieza: Filtra estado 'completado' y descarta fechas ficticias (1900, 1970, 2099, 2100).
SELECT 
    DATE_FORMAT(DATE_TRUNC('month', o.fecha), 'yyyy-MM') AS mes,
    COUNT(DISTINCT o.operacion_id) AS operaciones_completadas,
    ROUND(SUM(d.cantidad * d.precio_unitario - COALESCE(d.descuento, 0)), 2) AS importe_completado
FROM libreria_catalog.public.operaciones o
JOIN libreria_catalog.public.detalle_operacion d 
    ON o.operacion_id = d.operacion_id
WHERE LOWER(o.estado) IN ('completado', 'completada')
  AND o.fecha IS NOT NULL
  AND o.fecha >= '2000-01-01'
  AND o.fecha <= CURRENT_DATE()
  AND d.cantidad > 0
  AND d.precio_unitario > 0
GROUP BY DATE_TRUNC('month', o.fecha)
ORDER BY mes ASC;


-- 4. Importe total por segmento de cliente y categoría de producto
-- Limpieza: Descarta clientes sin segmento válido, productos inválidos y montos <= 0.
SELECT 
    TRIM(cl.segmento) AS segmento,
    COALESCE(NULLIF(TRIM(c.categoria), ''), 'Sin categoría') AS categoria,
    ROUND(SUM(d.cantidad * d.precio_unitario - COALESCE(d.descuento, 0)), 2) AS importe_total
FROM libreria_catalog.public.detalle_operacion d
JOIN libreria_catalog.public.operaciones o 
    ON d.operacion_id = o.operacion_id
JOIN libreria_catalog.public.clientes cl 
    ON o.cliente_id = cl.cliente_id
JOIN libreria_catalog.public.catalogo c 
    ON d.producto_id = c.producto_id
WHERE cl.segmento IS NOT NULL 
  AND TRIM(cl.segmento) <> ''
  AND c.nombre IS NOT NULL
  AND LOWER(TRIM(c.nombre)) NOT IN ('', 'n/a', 'null', 'prodcto mal escrto')
  AND d.cantidad > 0 
  AND d.precio_unitario > 0
  AND (d.cantidad * d.precio_unitario - COALESCE(d.descuento, 0)) > 0
GROUP BY 
    TRIM(cl.segmento),
    COALESCE(NULLIF(TRIM(c.categoria), ''), 'Sin categoría')
ORDER BY segmento ASC, importe_total DESC;
