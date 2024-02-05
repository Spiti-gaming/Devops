# Dicover of Docker

## Database with Postgres discover

To init the data base we need to init password, user and databasename

To Build Postgres :

```Powershell
Docker build -t spiti/dbapp:latest Postgre
```


To execute Postgres :

```Powershell
Docker run -v TP1DB:/var/lib/postgresql/data --name dpapp --rm -ti -d --net-alias=dpapp --net=app-network spiti/dbapp
```
To increas the security we don't add the redirect of database port on host, only the virtualnetwork can access


For the database test we use adminer with :

```Powershell
docker run -p 8090:8080 --net=app-network --name=adminer -d adminer
```