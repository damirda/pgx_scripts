SELECT ni.nspname AS "namepsace", 
       ct.relname AS "table", 
       ci.relname AS "dup index",
       pg_get_indexdef(i.indexrelid) AS "dup index definition", 
       cii.relname AS "encompassing index", 
       pg_get_indexdef(ii.indexrelid) AS "encompassing index definition"
  FROM pg_index i
  JOIN pg_class ct ON i.indrelid=ct.oid
  JOIN pg_class ci ON i.indexrelid=ci.oid
  JOIN pg_namespace ni ON ci.relnamespace=ni.oid
  JOIN pg_index ii ON ii.indrelid=i.indrelid AND
                      ii.indexrelid != i.indexrelid AND
                      array_to_string(ii.indkey, ' ') like (array_to_string(i.indkey, ' ') || '%') AND
                      array_to_string(ii.indcollation, ' ') like (array_to_string(i.indcollation, ' ') || '%') AND
                      array_to_string(ii.indclass, ' ') like (array_to_string(i.indclass, ' ') || '%') AND
                      NOT (ii.indkey::integer[] @> ARRAY[0]) AND
                      NOT (i.indkey::integer[] @> ARRAY[0]) AND
                      CASE WHEN i.indisunique THEN ii.indisunique ELSE true END
  JOIN pg_class ctii ON ii.indrelid=ctii.oid
  JOIN pg_class cii ON ii.indexrelid=cii.oid
  JOIN pg_namespace nii ON cii.relnamespace=nii.oid
 WHERE ct.relname NOT LIKE 'pg_%' AND
       NOT i.indisprimary
 ORDER BY 1, 2, 3
       ;
