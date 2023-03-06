def send_email(subject, sender, recipients, text, aws_access_key_id, aws_secret_access_key):
    import boto3
    from botocore.exceptions import ClientError

    SENDER = sender

    RECIPIENTS = recipients.split('|||')

    AWS_REGION = "us-east-1"

    # The subject line for the email.
    SUBJECT = subject

    # The email body for recipients with non-HTML email clients.
    BODY_TEXT = text      

    # The character encoding for the email.
    CHARSET = "UTF-8"

    # Create a new SES resource and specify a region.
    print('aws_access_key_id:', aws_access_key_id)
    print('aws_secret_access_key:', aws_secret_access_key)
    client = boto3.client('ses', region_name=AWS_REGION, aws_access_key_id=aws_access_key_id, aws_secret_access_key=aws_secret_access_key)

    # Try to send the email.
    try:
        #Provide the contents of the email.
        response = client.send_email(
            Destination={
                'ToAddresses': RECIPIENTS,
            },
            Message={
                'Body': {
                    'Text': {
                        'Charset': CHARSET,
                        'Data': BODY_TEXT,
                    },
                },
                'Subject': {
                    'Charset': CHARSET,
                    'Data': SUBJECT,
                },
            },
            Source=SENDER,
        )
    # Display an error if something goes wrong.	
    except ClientError as e:
        print(e.response['Error']['Message'])
    else:
        print("Email sent! Message ID:"),
        print(response['MessageId'])


if __name__ == "__main__":
    import sys
    send_email(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5], sys.argv[6])
