frontend

sudo docker run -d   -p 80:80   -e API_URL=http://13.127.21.123:5000/api/items   -e REGISTER_URL=http://13.127.21.123:5000/api/register   --name my-frontend  tfrontend


backend

sudo docker run -d   -e DB_HOST=13.127.21.123   -e DB_PORT=5432   -e DB_NAME=cruddb   -e DB_USER=cruduser   -e DB_PASSWORD=admin
   -p 5000:5000   --name my-backend   tbackend:latest

Database

DB_HOST=13.127.21.123
DB_PORT=5432
DB_NAME=cruddb
DB_USER=cruduser
DB_PASSWORD=admin
