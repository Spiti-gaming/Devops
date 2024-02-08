# Discover of Docker



## DataBase with Postgres discover 

Dockerfile for PostgresSQL Database Container

```Dockerfile
# Use the official PostgreSQL image as the base
FROM postgres:14.1-alpine

# Set environment variables for database configuration
ENV POSTGRES_DB=db \
POSTGRES_USER=usr \
POSTGRES_PASSWORD=pwd

### Copy initialization scripts into the container
COPY ./Sql_File/* /docker-entrypoint-initdb.d/
```
Commands for Building the Database Container
Build the Docker image: Run the following command in the directory containing the Dockerfile and initialization scripts:

```bash
docker build -t spitii/devops-database:latest Postgre
```

Create a Docker network (if not already created):

```bash
docker network create app-network
```

Create a Docker volume (if not already created):

```bash
docker volume create TP1DB
```

Run the PostgresSQL container:

```bash
docker run -d \
--net=app-network \
 -v TP1DB:/var/lib/postgresql/data \
--name=database \
spitii/devops-database:latest
```
Here,--net=app-network connects the container to the existing app-network, enabling access to the PostgresSQL database.

Start Adminer:

```bash
docker run -d \
 -p 8090:8080 \
 --net=app-network \
 --name=adminer \
  adminer
```
Checking Database Connectivity  
To check if the database container is up and running,
and that data initialization scripts have been executed successfully:

Connect to the database using Adminer  
On it, use database container name as server name.  
User and password are defined in the Dockerfile.    
  


### Documenting Database Container Essentials
Commands:
```bash
docker build -t spitii/devops-database:latest Postgre # Builds the Docker image using the provided caddy.httpd.Dockerfile.
docker network create app-network # Creates a Docker network named app-network if it doesn't already exist.
docker run ... # Runs the PostgresSQL container with appropriate options for port binding, network connection, and volume mounting.
docker restart adminer # Restarts the Adminer container if needed.
```
Dockerfile:

- Specify the base image (postgres:14.1-alpine).
- Sets environment variables for database configuration.
- Copies initialization scripts into the container's initialization directory.

## Back-End Part 

To run a simple Java hello-world class in a Docker container, you can follow these steps:

1. **Compile Java File**:
   Compile the `Main.java` file using `javac` command:
   ```
   javac Main.java
   ```

2. **Write Dockerfile**:
   Create a Dockerfile to build an image that will run the compiled Java class.
   We'll use an appropriate Java Runtime Environment (JRE) as the base image.

   ```Dockerfile
   # Choose a Java JRE base image
   FROM openjdk:17-alpine

   # Copy the compiled Java class into the container
   COPY Main.class /app/Main.class

   # Set the working directory
   WORKDIR /app

   # Run the Java class
   CMD ["java", "Main"]
   ```

   In the Dockerfile:
    - `FROM openjdk:17-alpine`: This line chooses the OpenJDK 17 JRE Alpine image as the base image.
    - `COPY Main.class /app/Main.class`: Copies the compiled Java class into the `/app` directory inside the container.
    - `WORKDIR /app`: Sets the working directory inside the container.
    - `CMD ["java", "Main"]`: Specifies the command to run the Java class when the container starts.

3. **Build Docker Image**:
   Build the Docker image using the Dockerfile:
   ```
   docker build -t java_hello_world .
   ```

4. **Run Docker Container**:
   Run the Docker container based on the built image:
   ```
   docker run java_hello_world
   ```

This displays "Hello World!" in the console,
indicating that the Java hello-world class is successfully executed within the Docker container.

### **Why do we need a multistage build? And explain each step of this Dockerfile.**

**Multistage Build Purpose:**
A multistage build in Docker allows us to optimize the size and efficiency of our Docker images.
It helps in reducing the final image size by separating the build environment from the runtime environment.
This is particularly useful in scenarios
like compiling source code where we need additional tools and dependencies for building the application,
but we want to exclude those from the final runtime image.

**Explanation of Each Step in the Dockerfile:**

```Dockerfile
# Build stage
FROM maven:3.8.6-amazoncorretto-17 AS myapp-build
```
- This line defines the first stage of the multistage build.
- It uses the Maven image with a specific version (`3.8.6-amazoncorretto-17`) as the base image for the build stage.
- It sets the name of this stage as `myapp-build` for reference in subsequent stages.
- In the case of that project, the usage package was `maven:3-eclipse-temurin-17`.

```Dockerfile
ENV MYAPP_HOME /opt/myapp
WORKDIR $MYAPP_HOME
```
- Sets an environment variable `MYAPP_HOME` to `/opt/myapp`.
- Sets the working directory to `/opt/myapp`.

```Dockerfile
COPY pom.xml .
COPY src ./src
```
- Copies the `pom.xml` file and the `src` directory (containing the source code) from the local filesystem into the Docker container's working directory.

```Dockerfile
RUN mvn package -DskipTests
```
- Executes the Maven command to package the application.
- `-DskipTests` flag is used to skip running tests during the build process.
- Before that you can add `RUN mvn dependency:go-offline` to limit the maven download of package.
```Dockerfile
# Run stage
FROM amazoncorretto:17
```
- This line defines the second stage of the multistage build.
- It uses the Amazon Corretto JDK image with Java 17 as the base image for the runtime stage.
- In the case of that project, the usage package was `eclipse-temurin:17`.

```Dockerfile
ENV MYAPP_HOME /opt/myapp
WORKDIR $MYAPP_HOME
```
- Sets the same `MYAPP_HOME` environment variable and working directory as in the build stage.
- Like the previous stage.

```Dockerfile
COPY --from=myapp-build $MYAPP_HOME/target/*.jar $MYAPP_HOME/myapp.jar
```
- Copy the compiled JAR file from the build stage into the runtime stage.
- `--from=myapp-build` specifies that the source for the copy operation is from the `myapp-build` stage.

```Dockerfile
ENTRYPOINT java -jar myapp.jar
```
- Define the command to be executed when the container starts.
- It runs the Java application by executing the JAR file (`myapp.jar`) using `java -jar` command.
- You can replace the entrypoint by CMD only if another entrypoint is defined in the image. That let image to init env

**Summary:**
- The multistage build starts with a build stage where Maven is used to compile and package the Java application.
- Once the build is complete, the runtime stage starts with a minimal runtime environment containing only the necessary components to execute the Java application, resulting in a smaller and more efficient Docker image.
- This separation ensures that the final Docker image only contains the compiled application artifact and runtime dependencies, reducing the overall image size and improving security.


To build and run the backend API connected to the database, follow these steps:

1. **Adjust Application Configuration**:
   Adjust the configuration in `simple-api/src/main/resources/application.yml` to connect to the database container.
   You'll need to specify the database URL, username, and password in the configuration file.
   For example:

   ```yaml
       url: jdbc:postgresql://database:5432/db
       username: usr
       password: pwd
   ```

2. **Accessing the Database Container from Backend Application**:

    Build the backend image

   ```bash
   docker build -t spitii/devops-backend:latest Backend_2.0
   ```

   Launch the backend and connect it to the same network of the database.

   ```bash
   docker run -d \
     --name backend \
     --network app-network \
     -p 8080:8080 \
     spitii/devops-backend
   ```

3. **Accessing the API**:
   Once both containers are running and connected to the same network,
   you should be able to access your application API.
   For example, if your API exposes endpoints like `/students`, you can access it using a web browser
   
   By Default, we need `/` at the end, but the code here doesn't want (more pretty)

   This should return the JSON response containing student information as specified.


By following these steps,
you should have your backend API connected to the database container and accessible through the specified endpoints.

## Http with apache

Dockerfile for Apache 2 Container

```Dockerfile
# Use the official httpd image as the base
FROM httpd:latest

# Copy conf and entrypoint of Apache 2 server
COPY httpd.conf /usr/local/apache2/conf/httpd.conf
COPY index.html /usr/local/apache2/htdocs/index.html
```
Commands for Building the Database Container
Build the Docker image: Run the following command in the directory containing the Dockerfile:

```bash
docker build -t spitii/devops-httpd:latest httpd
```

Restart Api without port :

```bash
docker stop
docker run -d \
 --name backend \
 --network app-network \
 spitii/devops-backend
```

Run the Apache 2 container:

```bash
docker run -d \
--net=app-network \
-p "80:80" \
--name=httpd \
spitii/devops-httpd:latest
```
Now, you have access to index.html in localhost (or server ip).  
And Access to the api with `/api/` in a middle of api request and front-end element.  


You have another alternative of apache. Like caddy, these tools have auto https certification. 


For the following element, you have the accessible docker compose in that repository. 

And all the images are accessible on https://hub.docker.com/repositories/spitii


## GitHub action Part (Day 2)

### org.testcontainers

The test containers is a light environment,  
it helps to provide a light environment for the test.  
In your case, it provides a light postgres docker image for junit test.

## GitHub action test pipeline

The test pipeline like : 
```yml
name: CI devops 2023
on:
  #to begin you want to launch this job in main and develop
  push:
    branches: ["master"]
  pull_request:

jobs:
  test-backend:
    runs-on: ubuntu-22.04
    steps:
      #checkout your github code using actions/checkout@v2.5.0
      - uses: actions/checkout@v2.5.0

      #do the same with another action (actions/setup-java@v3) that enable to setup jdk 17
      - name: Set up JDK 17
        uses: actions/setup-java@v3
        with:
            cache: 'maven'
            distribution: 'temurin'
            java-version: '17'
      #finally build your app with the latest command
      - name: Build and test with Maven
        run: mvn clean verify --file Backend_2.0/pom.xml
```

Provide test on push in master and on any pull_request.  
For more security, you can lock master for hard push.  

It uses the temurin version of jdk 17 with maven.  
And execute test on the Backend_2.0

## Ansible

In that ansible project you have only one machine with id-rsa. 

That machine inventory is : 
centos@matthieu.lapetitte.takima.cloud

The arguments -i in command permit you to pass the inventory file. 

```yml
- hosts: all # select all elements in inventories
  gather_facts: false # Disables facts gathering at the start.
  become: true  # Sets the execution privilege to super user ('become' is equivalent to 'sudo').

# Install Docker
  tasks:

  # Installs device-mapper-persistent-data and lvm2 using YUM, 
  # making sure they are the latest versions.
  - name: Install device-mapper-persistent-data
    yum:
      name: device-mapper-persistent-data
      state: latest

  - name: Install lvm2
    yum:
      name: lvm2
      state: latest

  # Adds Docker's repository to the YUM config manager using a command.

  - name: add repo docker
    command:
      cmd: sudo yum-config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo

  # Installs Docker (docker-ce) using YUM, ensuring it is present on the system.

  - name: Install Docker
    yum:
      name: docker-ce
      state: present

  # Installs Python 3 using YUM, ensuring it is present on the system.

  - name: Install python3
    yum:
      name: python3
      state: present

# Installs Docker Python module using Python's pip3 installer.

  - name: Install docker with Python 3
    pip:
      name: docker
      executable: pip3
      #Sets the Python interpreter to Python3 for Ansible.
    vars:
      ansible_python_interpreter: /usr/bin/python3

# Ensures the Docker service is running.
  - name: Make sure Docker is running
    service: name=docker state=started
    tags: docker
```

The prévious playbook permit to install all prerequisite to execute docker container

```yml
- name: Deploy Proxy
  docker_container:
    name: httpd
    image: spitii/devops-httpd:master
    recreate: true #recreates the container if it already exists.
    pull: true #Use only last version of image and not the last download.
    networks: #attaches it to 'Back-end' and 'Front-end' networks.
      - name: Back-end
      - name: Front-end
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - "Caddy:/config"
    env:
      URL: "https://matthieu.lapetitte.takima.cloud:443"
      FRONTEND_NAME: "frontend"
      BACKEND_NAME: "backend"
```

The previous task is to deploy the last proxy to the destination server.

