CREATE PROCEDURE [grep] 
( 
  @string         varchar(1000) = '', 
  @ShowReferences char(1)       = 'Y' 
) 
AS 
begin 
/****************************************************************************/ 
/*                                                                          */ 
/* TITLE:   sp_FindReferences                                               */ 
/*                                                                          */ 
/* DATE:    18 February, 2004                                               */ 
/*                                                                          */ 
/* AUTHOR:  WILLIAM MCEVOY                                                  */ 
/*                                                                          */ 
/****************************************************************************/ 
/*                                                                          */ 
/* DESCRIPTION:  SEARCH SYSCOMMENTS FOR INPUT STRING, OUTPUT NAME OF OBJECT */ 
/*                                                                          */ 
/****************************************************************************/ 
set nocount on 
 
declare @errnum         int         , 
        @errors         char(1)     , 
        @rowcnt         int         , 
        @output         varchar(255) 
 
select  @errnum         = 0         , 
        @errors         = 'N'       , 
        @rowcnt         = 0         , 
        @output         = ''         
 
/****************************************************************************/ 
/* INPUT DATA VALIDATION                                                    */ 
/****************************************************************************/ 
 
 
/****************************************************************************/ 
/* M A I N   P R O C E S S I N G                                            */ 
/****************************************************************************/ 
 
-- Create temp table to hold results 
create table #Results 
( 
  Name        varchar(100), 
  Type        varchar(100), 
  DateCreated varchar(100), 
  ProcLine    varchar(4000), 
  SchemaName      varchar(100) 
) 
 
 
IF (@ShowReferences = 'N') 
BEGIN 
  insert into #Results 
  select distinct 
         'Name' = convert(varchar(55),SO.name), 
         'Type' = SO.type, 
         create_date, 
         '', 
   schemaObject.Name 
    from  sys.objects  SO 
  join sys.schemas schemaObject 
   on so.schema_id = schemaObject.schema_id 
    join syscomments SC on SC.id = SO.object_id 
   where SC.text like '%' + @string + '%' 
  union 
  select distinct 
         'Name' = convert(varchar(55),SO.name), 
         'Type' = SO.type, 
         create_date, 
         '', 
   schemaObject.Name 
    from  sys.objects  SO 
  join sys.schemas schemaObject 
   on so.schema_id = schemaObject.schema_id 
   where SO.name like '%' + @string + '%' 
  union 
  select distinct 
         'Name' = convert(varchar(55),SO.name), 
         'Type' = SO.type, 
         create_date, 
         '', 
   schemaObject.Name 
    from  sys.objects  SO 
  join sys.schemas schemaObject 
   on so.schema_id = schemaObject.schema_id 
    join syscolumns SC on SC.id = SO.object_id 
   where SC.name like '%' + @string + '%' 
   order by 2,1 
END 
ELSE 
BEGIN 
  insert into #Results 
  select  
         'Name'      = convert(varchar(55),SO.name), 
         'Type'      = so.type, 
         create_date, 
         'Proc Line' = text, 
   'SchemaName' = schemaObject.name 
    from sys.objects  SO 
    join syscomments SC on SC.id = SO.object_id 
 join sys.schemas schemaObject 
  on schemaObject.schema_id = so.schema_id 
   where SC.text like '%' + @string + '%' 
  union 
  select  
         'Name'      = convert(varchar(55),SO.name), 
         'Type'      = so.type, 
         create_date, 
         'Proc Line' = '', 
   'SchemaName' = schemaobject.Name 
    from sys.objects  SO 
  join sys.schemas schemaObject 
   on so.schema_id = schemaObject.schema_id 
   where SO.name like '%' + @string + '%' 
  union 
  select  
         'Name' = convert(varchar(55),SO.name), 
         'Type' = so.type, 
         create_date, 
         'Proc Line' = '', 
   'SchemaName' = schemaobject.Name 
    from sys.objects  SO 
 join sys.schemas schemaObject 
  on schemaObject.schema_id = so.schema_id 
    join syscolumns SC on SC.id = SO.object_ID 
   where SC.name like '%' + @string + '%' 
   order by 2,1 
END 
 
 
IF (@ShowReferences = 'N') 
BEGIN 
  select schemaname, 
  Name, 
         'Type' = Case (Type) 
                    when 'P'  then 'Procedure' 
                    when 'TR' then 'Trigger' 
                    when 'X'  then 'Xtended Proc' 
                    when 'U'  then 'Table' 
      when 'C'  then 'Check Constraint' 
                    when 'D'  then 'Default' 
                    when 'F'  then 'Foreign Key' 
                    when 'K'  then 'Primary Key' 
                    when 'V'  then 'View' 
                    else Type 
                  end, 
         DateCreated 
    from #Results 
    order by Type, schemaName, Name 
END 
ELSE 
BEGIN 
  select SchemaName, 
  Name, 
         'Type' = Case (Type) 
                    when 'P'  then 'Procedure' 
                    when 'TR' then 'Trigger' 
                    when 'X'  then 'Xtended Proc' 
                    when 'U'  then 'Table' 
                    when 'C'  then 'Check Constraint' 
                    when 'D'  then 'Default' 
                    when 'F'  then 'Foreign Key' 
                    when 'K'  then 'Primary Key' 
                    when 'V'  then 'View' 
                    else Type 
                  end, 
         DateCreated, 
         ProcLine 
    from #Results 
    order by Type, SchemaName, Name 
END 
 
drop table #Results 
 
end 
