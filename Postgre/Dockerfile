# Use the official PostgreSQL image as the base
FROM postgres:14.1-alpine

# Set environment variables for database configuration
ENV POSTGRES_DB=db \
POSTGRES_USER=usr \
POSTGRES_PASSWORD=pwd

### Copy initialization scripts into the container
COPY ./Sql_File/* /docker-entrypoint-initdb.d/