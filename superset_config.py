import os
SQLALCHEMY_DATABASE_URI = os.getenv(
    "SUPERSET_DB_URI",
    "mysql://root:root@mysql:3306/superset?charset=utf8mb4"
)
SECRET_KEY = os.getenv("SUPERSET_SECRET_KEY", "change_me_random_string")