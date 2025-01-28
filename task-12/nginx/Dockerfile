FROM nginx:mainline-alpine@sha256:814a8e88df978ade80e584cc5b333144b9372a8e3c98872d07137dbf3b44d0e4

# Install image filter module
RUN apk add --no-cache nginx-module-image-filter

# Copy configs and files
COPY ./etc/nginx.conf /etc/nginx/nginx.conf
COPY ./etc/conf.d /etc/nginx/conf.d
COPY ./share /usr/share/nginx

# Change ownership for non root
RUN chown -R nginx:nginx /etc/nginx /usr/share/nginx /var/log/nginx /run /var/cache/nginx

# Switch to non-root user
USER nginx

# Expose a non-privileged ports 
# HTTP
EXPOSE 8080 
# HTTPS
EXPOSE 8443

# Volume for certs
VOLUME [ "/ssl" ]

CMD ["nginx", "-g", "daemon off;"]
