# PHP 7.4 + Oracle Docker Setup

A Docker container setup for PHP 7.4 with Apache and Oracle Instant Client support, optimized for Mac AMD64 architecture.

## Features

- PHP 7.4 with Apache
- Oracle Instant Client 19.27
- OCI8 and PDO_OCI extensions
- Common PHP extensions (GD, cURL, mbstring, zip)
- Composer installed
- Proper networking for container-to-container communication

## Prerequisites

- Docker Desktop for Mac
- Oracle Instant Client ZIP files (see setup section)

## Project Structure

```
your-project/
├── Dockerfile
├── docker-compose.yml
├── README.md
├── app/                    # Your PHP projects go here
│   ├── project1/
│   ├── project2/
│   └── ...
└── oracle/                 # Oracle Instant Client files
    ├── instantclient-basic-linux.x64-19.27.0.0.0dbru.zip
    └── instantclient-sdk-linux.x64-19.27.0.0.0dbru.zip
```

## Setup Instructions

### 1. Clone/Download Files
Place the `Dockerfile` and `docker-compose.yml` in your project root.

### 2. Oracle Instant Client Setup
1. Download Oracle Instant Client from Oracle's website:
   - `instantclient-basic-linux.x64-19.27.0.0.0dbru.zip`
   - `instantclient-sdk-linux.x64-19.27.0.0.0dbru.zip`

2. Create an `oracle/` directory in your project root
3. Place both ZIP files in the `oracle/` directory

### 3. Add Your PHP Projects
Place your PHP projects in the `app/` directory. They will be accessible as:
- `http://localhost:8081/project1/`
- `http://localhost:8081/project2/`

## Running the Container

### Build and Start
```bash
docker-compose up --build
```

### Run in Background
```bash
docker-compose up -d --build
```

### Stop Container
```bash
docker-compose down
```

### Clean Rebuild
```bash
docker-compose down
docker rmi php74-oracle 2>/dev/null || true
docker-compose up --build
```

## Accessing Your Applications

- **External Access (Browser)**: `http://localhost:8081/`
- **Container Internal Calls**: Use `host.docker.internal:8081`

### Example URLs
- Main app: `http://localhost:8081/`
- Project 1: `http://localhost:8081/project1/`
- Project 2: `http://localhost:8081/project2/`

## Container-to-Container Communication

When your PHP code needs to make HTTP requests to other services in the same container, use the `BASE_URL` environment variable:

```php
// Get base URL for internal calls
$baseUrl = $_ENV['BASE_URL'] ?? 'http://localhost:8081';
$url = $baseUrl . '/path/to/your/endpoint.php';

// Make cURL request
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $url);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
$response = curl_exec($ch);
curl_close($ch);
```

## Environment Variables

The container includes these environment variables:
- `ORACLE_HOME`: `/opt/oracle/instantclient`
- `LD_LIBRARY_PATH`: `/opt/oracle/instantclient`
- `BASE_URL`: `http://host.docker.internal:8081`

## Installed PHP Extensions

- **Core**: curl, mbstring, zip, gd
- **Oracle**: oci8, pdo_oci
- **Graphics**: GD with FreeType and JPEG support
- **Other**: XML, JSON (built-in)

## Troubleshooting

### Common Issues

1. **403 Forbidden on package download**:
   ```bash
   # Ensure platform is set correctly
   DOCKER_DEFAULT_PLATFORM=linux/amd64 docker-compose up --build
   ```

2. **Oracle connection issues**:
   - Verify Oracle ZIP files are in the `oracle/` directory
   - Check Oracle connection strings in your PHP code

3. **File permissions**:
   ```bash
   # Fix file permissions if needed
   docker-compose exec app chown -R www-data:www-data /var/www/html
   ```

4. **Container-to-container communication fails**:
   - Use `host.docker.internal:8081` for internal calls
   - Use `localhost:8081` for external browser access

### Useful Commands

```bash
# View container logs
docker-compose logs -f

# Access container shell
docker-compose exec app bash

# Check PHP configuration
docker-compose exec app php -m

# Check Oracle extensions
docker-compose exec app php -m | grep -i oci
```

## Customization

### Adding More PHP Extensions
Edit the `Dockerfile` and add to the `docker-php-ext-install` line:
```dockerfile
RUN docker-php-ext-install -j$(nproc) zip curl mbstring gd your-extension-here
```

### Changing Ports
Edit `docker-compose.yml`:
```yaml
ports:
  - "your-port:80"  # Change your-port to desired port
```

### Adding Environment Variables
Edit `docker-compose.yml`:
```yaml
environment:
  ORACLE_HOME: /opt/oracle/instantclient
  LD_LIBRARY_PATH: /opt/oracle/instantclient
  BASE_URL: "http://host.docker.internal:8081"
  YOUR_CUSTOM_VAR: "your-value"
```

## Performance Tips

- Use `docker-compose up -d` to run in background
- Mount only necessary directories with volumes
- Use `.dockerignore` to exclude unnecessary files from build context

## Security Notes

- This setup is for development purposes
- For production, consider:
  - Using specific PHP/Apache versions
  - Implementing proper security headers
  - Using secrets management for sensitive data
  - Regular security updates

## License

MIT License - Feel free to use and modify as needed.