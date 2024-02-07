#!/bin/sh

ROOT_DIR=/usr/share/nginx/html

# Replace env vars in files served by NGINX
for file in $ROOT_DIR/js/*.js* $ROOT_DIR/index.html;
do
  sed -i 's@http://localhost:8080@'${VUE_APP_API_URL}'@g' $file
  # Your other variables here...
done

# Let container execution proceed
nginx -g 'daemon off;'