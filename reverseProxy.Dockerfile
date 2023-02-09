# Use the official Nginx image as the base image
FROM nginx

# Install certbot
RUN apt-get update && apt-get install -y certbot

# Obtain an SSL certificate from Let's Encrypt
ARG domain
ARG email
RUN certbot certonly --standalone -d $domain --email $email --agree-tos

# Copy the Nginx configuration file
COPY nginx.conf /etc/nginx/nginx.conf