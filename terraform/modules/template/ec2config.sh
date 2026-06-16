#!/bin/bash
dnf update -y
dnf install -y httpd php stress aws-cli cronie

systemctl start httpd
systemctl enable httpd
systemctl start crond
systemctl enable crond

BUCKET_NAME="my-portfolio-scalability-app-code"
WEB_DIR="/var/www/html"

aws s3 sync s3://$BUCKET_NAME $WEB_DIR
chown -R apache:apache $WEB_DIR

cat << 'EOF' > /usr/local/bin/sync_app.sh
#!/bin/bash
PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
BUCKET_NAME="my-portfolio-scalability-app-code"
WEB_DIR="/var/www/html"

aws s3 sync s3://$BUCKET_NAME $WEB_DIR --quiet
chown -R apache:apache $WEB_DIR
EOF

chmod +x /usr/local/bin/sync_app.sh
echo "* * * * * /usr/local/bin/sync_app.sh" | crontab -