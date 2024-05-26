import json
import boto3

def lambda_handler(event, context):
    rekognition = boto3.client('rekognition')
    s3 = boto3.client('s3')

    bucket_name = event['Records'][0]['s3']['bucket']['name']
    object_key = event['Records'][0]['s3']['object']['key']
    result_bucket = 'homesandbox-text-detection-results-dev'  #TODO change using SSM

    # Detect text in the image
    response = rekognition.detect_text(
        Image={
            'S3Object': {
                'Bucket': bucket_name,
                'Name': object_key
            }
        }
    )

    # Prepare result data
    result_data = {
        'TextDetections': response['TextDetections']
    }

    # Save result to the result bucket
    s3.put_object(
        Bucket=result_bucket,
        Key=f"results/{object_key}.json",
        Body=json.dumps(result_data)
    )
    print(f"event: ${event}")
    return {
        'statusCode': 200,
        'body': json.dumps('Text detection complete!')
    }
