# gpt-docker

## Recent Change
- **APCu PHP extension is now installed and enabled** in the Dockerfile. This allows PHP applications to use APCu caching.

## How to Build the Docker Image

```sh
docker build --platform=linux/amd64 -t php74-oracle .
```

## How to Run the Container (Single Container)

```sh
docker run -d \
  --platform linux/amd64 \
  -p 8081:80 \
  --name php74-app \
  -v $(pwd)/app:/var/www/html \
  php74-oracle
```
- Access your app at: http://localhost:8081

## How to Run with Docker Compose (Recommended for Multi-Service Setups)

1. Create a `docker-compose.yml` file (if you need multiple services).
2. Start all services:

```sh
docker compose up -d
```

## Notes
- The Dockerfile now includes installation and enabling of the APCu extension via:
  ```Dockerfile
  pecl install apcu \
  && docker-php-ext-enable apcu
  ```
- If you encounter issues, check container logs:
  ```sh
  docker logs <container_name>
  ``` 