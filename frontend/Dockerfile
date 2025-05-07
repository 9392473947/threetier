# Use official Nginx image
FROM nginx:alpine
WORKDIR /usr/share/nginx/html/
RUN rm -r *
# Copy your HTML file(s) into Nginx's default web directory
COPY index.html /usr/share/nginx/html/

# Optional: Expose port 80 (default Nginx port)
EXPOSE 82
