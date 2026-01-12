#!/bin/bash

echo "=========================================="
echo "RESET DATABASE VA MIGRATIONS (LINUX VERSION)"
echo "=========================================="

# 1. Xoa cache Python
echo -e "\n[1/7] Xoa cache Python..."
find . -name "__pycache__" -type d -exec rm -rf {} +
find . -name "*.pyc" -delete
echo "OK - Da xoa cache"

# 2. Xoa tat ca migrations (tru __init__.py)
echo -e "\n[2/7] Xoa migrations cu..."
find app_quan_ly/migrations/ -type f ! -name "__init__.py" -delete
echo "OK - Da xoa migrations cu"

# 3. Tao migration moi tu models
echo -e "\n[3/7] Tao migrations moi..."
python manage.py makemigrations app_quan_ly
if [ $? -ne 0 ]; then
    echo "ERROR - Loi khi tao migrations!"
    exit 1
fi
echo "OK - Da tao migrations moi"

# 4. Migrate lan dau (tao tables)
echo -e "\n[4/7] Migrate lan dau..."
python manage.py migrate
if [ $? -ne 0 ]; then
    echo "ERROR - Loi khi migrate!"
    exit 1
fi
echo "OK - Da tao tables"

# 5. Copy migration phan quyen
echo -e "\n[5/7] Copy migration phan quyen..."
if [ -f "0002_create_groups_and_permissions.py" ]; then
    cp 0002_create_groups_and_permissions.py app_quan_ly/migrations/
    echo "OK - Da copy migration phan quyen"
else
    echo "ERROR - Khong tim thay file 0002_create_groups_and_permissions.py"
    exit 1
fi

# 6. Migrate lan 2 (tao groups)
echo -e "\n[6/7] Migrate phan quyen..."
python manage.py migrate
if [ $? -ne 0 ]; then
    echo "ERROR - Loi khi migrate phan quyen!"
    exit 1
fi

# 7. Tao user mau
echo -e "\n[7/7] Tao user mau..."
mkdir -p app_quan_ly/management/commands
touch app_quan_ly/management/__init__.py
touch app_quan_ly/management/commands/__init__.py

if [ -f "create_sample_users.py" ]; then
    cp create_sample_users.py app_quan_ly/management/commands/
    python manage.py create_sample_users
    echo "OK - Da tao user mau"
fi

echo -e "\n=========================================="
echo "SUCCESS - HOAN TAT!"
echo "=========================================="