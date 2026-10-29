#!/bin/sh
set -eu

php artisan config:clear
php artisan storage:link --force
php artisan migrate --force
php artisan config:cache

exec apache2-foreground
