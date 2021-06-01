-- Step-1 - Create API Integration
create or replace api integration my_api_integration_01
  api_provider = aws_api_gateway
  api_aws_role_arn = 'arn:aws:iam::753066389454:role/SnowflakeAPIGW'
  api_allowed_prefixes = ('https://53jni6q2s7.execute-api.us-east-2.amazonaws.com/ext-func-stage/echo')
  enabled = true;
  
-- Step-2 - Update trust on AWS Side for API GW Role
describe integration my_api_integration_01;

-- Step-3 - Create External Function
create external function jumpcloud_user_groups(v varchar)
    returns variant
    api_integration = my_api_integration_01
    as 'https://53jni6q2s7.execute-api.us-east-2.amazonaws.com/ext-func-stage/echo';
    
-- Step-4 - Call the API
select jumpcloud_user_groups('david.li@awesome.com');

-- Step-5 - Schedule a Proc to assign roles
                      
CREATE TASK task_assign_roles
  WAREHOUSE = COMPUTE_WH
  SCHEDULE = '60 minute'
AS
  CALL grant_previliges_jumpcloud_users();
  
                             
-- Procedue to Grant Roles based on Groups
CREATE OR REPLACE PROCEDURE GRANT_PREVILIGES_JUMPCLOUD_USERS()
  RETURNS FLOAT NOT NULL 
  LANGUAGE JAVASCRIPT
  EXECUTE AS CALLER 
  AS    
  $$ 
    -- All changes to users on JumpCloud side will be available to Snowflake via JC Connector
    var get_grant_commands = `select 'grant'||' role '||array_to_string(Groups, ', ')||' to user "'|| upper(User)||'"' as GRANT_COMMAND from
                          (select RESOURCE_NAME as User, jumpcloud_user_groups(RESOURCE_NAME) as Groups,max(EVENT_TIMESTAMP) as LAST_UPDATE_TIME
                              from table(snowflake.information_schema.rest_event_history(
                                  'scim',
                                  dateadd('minutes',-9000,current_timestamp()),
                                  current_timestamp(),
                                  200))
                                where status='SUCCESS' and RESOURCE_NAME is not null
                                group by RESOURCE_NAME
                           )`;
    var grant_commands = snowflake.createStatement( {sqlText: get_grant_commands} ).execute();
 
    
    --Grant Roles to users one by one
    while (grant_commands.next())  {
       var grant_command = snowflake.createStatement( {sqlText: grant_commands.getColumnValue(1)} );
       grant_command.execute();
     
       }
  return 1;
  $$
  ;
  

