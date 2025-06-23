# Build with: docker build --platform=linux/amd64 -t your-image-name .
FROM php:7.4-apache

# Install system dependencies and PHP extensions
RUN apt-get update && apt-get install -y \
    git unzip curl libaio1 libcurl4-openssl-dev libonig-dev libzip-dev \
    libpng-dev libjpeg-dev libxml2-dev libfreetype6-dev \
 && docker-php-ext-configure gd \
        --with-freetype --with-jpeg \
 && docker-php-ext-install -j$(nproc) zip curl mbstring gd

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Create Oracle directory and copy Instant Client ZIP files
RUN mkdir -p /opt/oracle
COPY oracle/instantclient-basic-linux.x64-19.27.0.0.0dbru.zip /opt/oracle/
COPY oracle/instantclient-sdk-linux.x64-19.27.0.0.0dbru.zip /opt/oracle/

# Extract and configure Oracle Instant Client
RUN unzip -o /opt/oracle/instantclient-basic-linux.x64-19.27.0.0.0dbru.zip -d /opt/oracle/ \
 && unzip -o /opt/oracle/instantclient-sdk-linux.x64-19.27.0.0.0dbru.zip -d /opt/oracle/ \
 && ln -s /opt/oracle/instantclient_19_27 /opt/oracle/instantclient \
 && ln -sf /opt/oracle/instantclient/libclntsh.so.19.1 /opt/oracle/instantclient/libclntsh.so

# Configure linker
RUN echo "/opt/oracle/instantclient" > /etc/ld.so.conf.d/oracle-instantclient.conf \
 && ldconfig

# Install oci8 and pdo_oci PHP extensions
RUN echo "instantclient,/opt/oracle/instantclient" | pecl install oci8-2.2.0 \
 && docker-php-ext-enable oci8 \
 && docker-php-ext-configure pdo_oci --with-pdo-oci=instantclient,/opt/oracle/instantclient,19.27 \
 && docker-php-ext-install pdo_oci

# Enable Apache modules
RUN a2enmod headers rewrite

# Set ServerName to avoid warnings
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Configure access to /var/www/html
RUN echo '<Directory /var/www/html>\n\
    Options Indexes FollowSymLinks\n\
    AllowOverride All\n\
    Require all granted\n\
</Directory>' >> /etc/apache2/apache2.conf

# Copy project files
COPY app/ /var/www/html/

# Set file permissions
RUN chown -R www-data:www-data /var/www/html \
 && chmod -R 755 /var/www/html

# Start Apache
CMD ["apache2-foreground"]
