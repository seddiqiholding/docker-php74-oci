# PHP 7.4 + Oracle (OCI) Docker Image

This repository provides a Docker image for running PHP 7.4 with Oracle (OCI8) support. It is designed for development and deployment of PHP applications that require connectivity to Oracle databases.

## Contents

- **Dockerfile**: Builds the PHP 7.4 image with OCI8 extension.
- **oracle-instantclient/**: Contains Oracle Instant Client RPMs or zip files required for OCI8.
- **php.ini**: Custom PHP configuration file.
- **src/**: (Optional) Place your PHP application code here.
- **.env**: (Optional) Environment variables for container configuration.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) installed on your system.
- Oracle Instant Client files (Basic and SDK) in the `oracle-instantclient/` directory.

## Build the Image

1. Place the required Oracle Instant Client files in the `oracle-instantclient/` directory.
2. Build the Docker image:

   ```sh
   docker build -t php74-oci .
   ```

## Run the Container

You can run the container with:

```sh
docker run -d --name php74-oci \
  -v $(pwd)/src:/var/www/html \
  -p 8080:80 \
  php74-oci
```

- Mount your PHP application code to `/var/www/html`.
- Expose port 80 from the container to port 8080 on your host.

## Configuration

- **php.ini**: Customize PHP settings by editing this file.
- **Environment Variables**: Use a `.env` file or pass variables with `-e` to `docker run` as needed.

## Connecting to Oracle

- Ensure your application uses the correct Oracle connection strings.
- The OCI8 extension is enabled and ready to use.

## Customization

- Modify the `Dockerfile` to install additional PHP extensions or tools as needed.
- Place your application code in the `src/` directory or mount it as a volume.

## License

This project is for internal or educational use. Ensure you comply with Oracle's licensing for the Instant Client.

