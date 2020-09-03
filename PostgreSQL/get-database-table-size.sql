WITH public_table_sizes AS (
    SELECT
        table_name,
        pg_table_size(         '"' || table_schema || '"."' || table_name || '"') AS table_size_in_bytes,
        pg_indexes_size(       '"' || table_schema || '"."' || table_name || '"') AS indexes_size_in_bytes,
        pg_total_relation_size('"' || table_schema || '"."' || table_name || '"') AS total_size_in_bytes,
        psut.n_live_tup AS row_count
    FROM information_schema.tables AS ist
    INNER JOIN pg_stat_user_tables AS psut
        ON psut.relname = ist.table_name
    WHERE ist.table_schema='public'
)
SELECT
    table_name,
    pg_size_pretty(table_size_in_bytes) AS table_size,
    pg_size_pretty(indexes_size_in_bytes) AS indexes_size,
    pg_size_pretty(total_size_in_bytes) AS total_size,
    pg_size_pretty(row_count) AS "#rows",
    table_size_in_bytes,
    indexes_size_in_bytes,
    total_size_in_bytes,
    row_count AS row_count_raw
FROM public_table_sizes
ORDER BY table_name;