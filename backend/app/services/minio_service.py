from minio import Minio
from datetime import timedelta

minio_client = Minio(
    "192.168.18.150:9000",
    access_key="minioadmin",
    secret_key="minioadmin",
    secure=False
)

BUCKET_NAME = "tptrader-profile"

def generate_presigned_url(mobile: str):
    object_name = f"profile_{mobile}.jpg"

    upload_url = minio_client.presigned_put_object(
        BUCKET_NAME,
        object_name,
        expires=timedelta(hours=1)
    )

    final_url = f"http://192.168.18.150:9000/{BUCKET_NAME}/{object_name}"

    return upload_url, final_url
