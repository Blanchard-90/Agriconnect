#!/bin/sh
set -eu

# Render's generated secret is not necessarily formatted as a Laravel APP_KEY.
if ! php -r '$key = getenv("APP_KEY") ?: ""; $decoded = str_starts_with($key, "base64:") ? base64_decode(substr($key, 7), true) : false; exit($decoded !== false && strlen($decoded) === 32 ? 0 : 1);'; then
    export APP_KEY="$(php -r '$key = getenv("APP_KEY") ?: ""; if ($key === "") { fwrite(STDERR, "APP_KEY is required.\n"); exit(1); } echo "base64:".base64_encode(hash("sha256", $key, true));')"
fi

php artisan config:clear
php artisan storage:link --force
php artisan migrate --force
php artisan config:cache

exec apache2-foreground
