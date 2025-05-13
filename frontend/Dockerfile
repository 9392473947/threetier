# Use official Nginx image
FROM nginx:alpine

# Install envsubst (for template substitution)
RUN apk add --no-cache gettext

# Set working directory
WORKDIR /usr/share/nginx/html/

# Clean default nginx static files
RUN rm -rf ./*

# Copy frontend files
COPY index.html .
COPY config.template.js .

# Expose your frontend port
EXPOSE 80

# Runtime: substitute env vars and then start nginx
ENTRYPOINT ["/bin/sh", "-c", "envsubst < /usr/share/nginx/html/config.template.js > /usr/share/nginx/html/config.js && exec nginx -g 'daemon off;'"]
