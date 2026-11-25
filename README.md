# Análisis Operativo - Librería (Databricks & PostgreSQL)

Proyecto individual de Inteligencia de Negocios desarrollado en **Databricks** conectado a una base de datos transaccional en **PostgreSQL**, enfocado en la auditoría, limpieza de datos en SQL y visualización operativa.

## Enlace al Dashboard
* **Dashboard Publicado:** https://dbc-dcdf396f-a484.cloud.databricks.com/dashboardsv3/01f1e81fe25315a3af83bc10f24a0d47/published?o=7474644891834986

## Limpieza y Calidad de Datos (SQL)
Antes de generar las visualizaciones, se auditaron las tablas (`catalogo`, `clientes`, `detalle_operacion`, `operaciones`, `sedes`) aplicando limpieza no destructiva en consultas `SELECT`:
* **Estandarización de texto:** Uso de `TRIM`, `LOWER`, `COALESCE` y `NULLIF` para unificar sedes y agrupar categorías vacías bajo `'Sin categoría'`.
* **Filtrado de registros corruptos:** Exclusión de cantidades/precios negativos o en cero, y productos inválidos (`'N/A'`, `'null'`, `'prodcto mal escrto'`).
* **Integridad temporal:** Descarte de fechas fuera de rango histórico (`1900`, `1970`, `2099`, `2100`) y filtrado exclusivo de operaciones con estado completado para la serie mensual.

## Estructura del Repositorio
* `consultas_libreria.sql`: Las 4 consultas SQL independientes que alimentan cada widget del tablero.
* `dashboard_libreria.png`: Vista final del dashboard publicado en cuadrícula 2x2.

## Hallazgos Principales
1. **Aporte por Categoría:** **Tecnología, Ficción y Educación** lideran los ingresos (~$15,000 cada una).
2. **Volumen por Sede:** La sucursal **Norte** encabeza las ventas con más de 1,000 unidades, seguida por Centro y Sur.
3. **Evolución Mensual:** Tras un pico en 2024 y una caída en 2025, las ventas completadas muestran una fuerte recuperación en 2026.
4. **Segmentación:** Los clientes **Frecuentes, Nuevos y Ocasionales** mantienen aportes equilibrados ($17k–$19k por segmento).
