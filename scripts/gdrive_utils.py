import os
import base64
import smtplib
import requests
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from google.oauth2.service_account import Credentials
from googleapiclient.discovery import build
from googleapiclient.http import MediaFileUpload
from datetime import datetime


def authenticate_gdrive():
    base64_creds = os.environ.get('GOOGLE_DRIVE_CREDENTIALS')
    if not base64_creds:
        raise Exception("GOOGLE_DRIVE_CREDENTIALS not found in environment variables")

    creds_json = base64.b64decode(base64_creds).decode('utf-8')
    with open(os.path.join(os.path.dirname(__file__), 'service-account.json'), 'w') as f:
        f.write(creds_json)

    creds = Credentials.from_service_account_file(os.path.join(os.path.dirname(__file__), 'service-account.json'))
    return build('drive', 'v3', credentials=creds)


def upload_file(service, file_path, custom_name, drive_folder_id="1-8sPcsV0e00qlbH6F8d9bUUouR8UuuuR"):
    file_metadata = {
        'name': custom_name,
        'parents': [drive_folder_id] if drive_folder_id else []
    }
    media = MediaFileUpload(file_path, resumable=True)
    file = service.files().create(
        body=file_metadata,
        media_body=media,
        fields='id, webViewLink'
    ).execute()
    print(f"File ID: {file.get('id')} uploaded successfully.")
    
    permission = {'type': 'anyone', 'role': 'reader'}
    service.permissions().create(fileId=file.get('id'), body=permission).execute()

    return file.get('webViewLink')


# def send_email(apk_drive_link):
#     sender_email = os.environ.get("EMAIL_USERNAME")
#     sender_password = os.environ.get("EMAIL_PASSWORD")
#     recipient_email = "loxor57@gmail.com"  # Change this to the actual recipient

#     if not sender_email or not sender_password:
#         raise Exception("Email credentials not set in environment variables")

#     subject = "New APK Build Available"
#     body = f"Hello,\n\nA new LessonsApp APK build has been uploaded. You can download it from the link below:\n{apk_drive_link}\n\nBest Regards,\nCI/CD Pipeline"

#     msg = MIMEMultipart()
#     msg["From"] = sender_email
#     msg["To"] = recipient_email
#     msg["Subject"] = subject
#     msg.attach(MIMEText(body, "plain"))

#     try:
#         with smtplib.SMTP_SSL("smtp.gmail.com", 465) as server:
#             server.login(sender_email, sender_password)
#             server.sendmail(sender_email, recipient_email, msg.as_string())
#         print("Email sent successfully")
#     except Exception as e:
#         print(f"Failed to send email: {e}")


def sanitize_filename(filename):
    return filename.replace(':', '_').replace('/', '_')


if __name__ == '__main__':
    current_date = datetime.now().strftime("%Y-%m-%d %H:%M")
    apk_path = 'build/app/outputs/flutter-apk/app-release.apk'
    apk_name = sanitize_filename(f"LessonsApp_{current_date}.apk")

    gdrive_service = authenticate_gdrive()
    apk_drive_link = upload_file(gdrive_service, apk_path, apk_name)

    # send_email(apk_drive_link)
