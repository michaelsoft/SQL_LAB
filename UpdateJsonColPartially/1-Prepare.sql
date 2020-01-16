drop table if exists t1
go

create table t1 (id int primary key, vals nvarchar(max))

insert into t1 
  select 1, '[{"FieldName": "f1", "FieldValue": "v1"}, {"FieldName": "f2", "FieldValue": "v2"}, {"FieldName": "f3", "FieldValue": "v3"}]'

go

select * from t1

