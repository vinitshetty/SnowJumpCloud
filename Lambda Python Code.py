#Please update your JumpCloud API Key below
#For each API request received from Snowflake which will have an array of USERNAMES, GROUPS associated in JUMPCLOUD will be returned as a response

import json
from botocore.vendored import requests
import logging

logger = logging.getLogger()
logger.setLevel(logging.DEBUG)

def handler(event, context):
    status_code = 200
    array_of_rows_to_return = []
    try:
        logger.debug('event input')
        logger.debug(event)
        event_body = event["body"]
        payload = json.loads(event_body)
        rows = payload["data"]
        
        url = 'https://console.jumpcloud.com/api/search/systemusers'
        headers = {'content-type': 'application/json', 'accept': 'application/json',
        'x-api-key':'Your API Key'}
        
        for row in rows:
            row_number = row[0]
            input_value = row[1]

            # Find Unique UserID
            body = {
                      "searchFilter": {
                        "searchTerm": input_value,
                        "fields": ["email"]
                      },
                      "fields" : "_id"
                     }
                     
            r = requests.post(url, data=json.dumps(body), headers=headers)
            userID=json.loads(r.content)["results"][0]["_id"]
            
            # Find Groups Tagged
            url_grps='https://console.jumpcloud.com/api/v2/users/'+userID+'/memberof'
            response = requests.get(url_grps, headers=headers)
        
            
            # Loop Through the Groups
            output=[]
            for grp in json.loads(response.text):
                output.append(grp["compiledAttributes"]["ldapGroups"][0]["name"])
            
            row_to_return = [row_number, output]
            logger.debug(row_to_return)
            
            array_of_rows_to_return.append(row_to_return)
        json_compatible_string_to_return = json.dumps({"data" : array_of_rows_to_return})
    except Exception as err:
        status_code = 400
        json_compatible_string_to_return = event_body
    return {
        'statusCode': status_code,
        'body': json_compatible_string_to_return
    }
