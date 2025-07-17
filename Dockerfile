# Build with: docker build --platform=linux/amd64 -t your-image-name .
FROM php:7.4-apache

# Set environment variables
ENV ORACLE_HOME=/opt/oracle/instantclient
ENV LD_LIBRARY_PATH=$ORACLE_HOME
ENV PATH=$ORACLE_HOME:$PATH

# Install system dependencies and PHP extensions in one layer
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    unzip \
    curl \
    libaio1 \
    libcurl4-openssl-dev \
    libonig-dev \
    libzip-dev \
    libpng-dev \
    libjpeg-dev \
    libxml2-dev \
    libfreetype6-dev \
    libicu-dev \
 && docker-php-ext-configure gd \
        --with-freetype --with-jpeg \
 && docker-php-ext-install -j$(nproc) \
        zip \
        curl \
        mbstring \
        gd \
        intl \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Create Oracle directory and copy Instant Client ZIP files
RUN mkdir -p /opt/oracle
COPY oracle/instantclient-basic-linux.x64-19.27.0.0.0dbru.zip /opt/oracle/
COPY oracle/instantclient-sdk-linux.x64-19.27.0.0.0dbru.zip /opt/oracle/

# Extract and configure Oracle Instant Client, then clean up
RUN cd /opt/oracle \
 && unzip -o instantclient-basic-linux.x64-19.27.0.0.0dbru.zip \
 && unzip -o instantclient-sdk-linux.x64-19.27.0.0.0dbru.zip \
 && ln -s /opt/oracle/instantclient_19_27 /opt/oracle/instantclient \
 && ln -sf /opt/oracle/instantclient/libclntsh.so.19.1 /opt/oracle/instantclient/libclntsh.so \
 && echo "/opt/oracle/instantclient" > /etc/ld.so.conf.d/oracle-instantclient.conf \
 && ldconfig \
 && rm -f /opt/oracle/*.zip

# Install oci8 and pdo_oci PHP extensions
RUN echo "instantclient,/opt/oracle/instantclient" | pecl install oci8-2.2.0 -y \
 && docker-php-ext-enable oci8

RUN docker-php-ext-configure pdo_oci --with-pdo-oci=instantclient,/opt/oracle/instantclient,19.27 \
 && docker-php-ext-install pdo_oci

RUN pecl install apcu -y \
 && docker-php-ext-enable apcu

# Install Xdebug (optionally specify version for PHP 7.4)
RUN pecl install xdebug-3.1.6 -y \
 && docker-php-ext-enable xdebug

# Configure Apache
RUN a2enmod headers rewrite \
 && echo "ServerName localhost" >> /etc/apache2/apache2.conf \
 && echo '<Directory /var/www/html>\n\
    Options Indexes FollowSymLinks\n\
    AllowOverride All\n\
    Require all granted\n\
</Directory>' >> /etc/apache2/apache2.conf

# Configure Xdebug
RUN echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
 && echo "xdebug.mode=develop,debug" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
 && echo "xdebug.start_with_request=yes" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
 && echo "xdebug.client_host=host.docker.internal" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
 && echo "xdebug.log=/tmp/xdebug.log" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

# Copy project files
COPY app/ /var/www/html/

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html \
 && find /var/www/html -type d -exec chmod 755 {} \; \
 && find /var/www/html -type f -exec chmod 644 {} \;

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

# Expose port
EXPOSE 80 9003

# Start Apache
CMD ["apache2-foreground"]