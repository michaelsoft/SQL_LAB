declare @id int = 1
declare @Vals nvarchar(max) = '
[{"FieldName": "f1", "FieldValue": "v1"}, 
 {"FieldName": "f2", "FieldValue": "v22"}, 
 {"FieldName": "f4", "FieldValue": "v4"}]
'

declare @sql nvarchar(max);
-- Map the fields from parameter with fields existing in db to determine which fields are existing, which are new.
WITH FieldMapping_CTE (id, FieldName, NewVal, FieldIndex, OldVal)  
AS  
(
	select @id as id, NewValStr.FieldName, NewValStr.NewVal, existTagValStr.FieldIndex, existTagValStr.OldVal
	from (select [key], json_value([value], '$.FieldName') as FieldName, [value] as NewVal  from OpenJson(@Vals)) NewValStr
			left join
			(select [key] as FieldIndex, json_value([value], '$.FieldName') as FieldName, [value] as OldVal from t1 t cross apply openjson(vals) where t.id = @id) existTagValStr
    	    on NewValStr.FieldName = existTagValStr.FieldName 
),
-- Generate the sql for each field
Sql_CTE (sqlStr)  
AS  
(  
    -- For existing fields
    select 'update [t1] set [vals] = json_modify([vals], ''$[' + FieldIndex + ']'',JSON_QUERY(''' + NewVal + ''')) where id = ''' + cast(id as nvarchar(50)) + '''' as sqlStr
	from FieldMapping_CTE
	where FieldIndex is not null

	union all

	-- For new added fields
	select 'update [t1] set [vals] = json_modify([vals], ''append $'',  JSON_QUERY(''' + NewVal + ''') ) where id = ''' + cast(id as nvarchar(50)) + '''' as sqlStr
	from FieldMapping_CTE
	where FieldIndex is null
)
--Link multiple sqls together.
SELECT
    @sql = CASE
        WHEN @sql IS NULL
        THEN sqlStr
        ELSE @sql + ';' + sqlStr
    END
FROM Sql_CTE;

--print @sql
EXECUTE sp_executesql @sql

go