FROM ubuntu:latest

RUN apt-get update && apt-get install -y nginx

#copy /nginx.html /usr/share/nginx/html/index.html

COPY /nginx.html /var/www/html

CMD ["nginx", "-g", "daemon off;"]