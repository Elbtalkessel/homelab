#!/usr/bin/env sh

DB_CONTAINER=new-api-postgres.container
REDIS_CONTAINER=new-api-redis.container
APP_CONTAINER=new-api.container

DRY_RUN=${1:-""}


# Read value of any given key name for a quadlet file.
getKeyValue() {
    KEY=$1 perl -ne '$key = $ENV{KEY}; /^$key="?(.*)"?$/ && print $1' "$2"
}


# Read environment value for a given environment name.
# arg0: Name of environment (Environment="<this-one>=").
# arg1: File path to read from.
getEnvFrom() {
    [ -z "$1" ] && echo "name is missing" && exit 1
    [ -z "$2" ] && echo "file is missing" && exit 1
    cmd=$(printf 'm/Environment="?%s=([^"]+)"?/ && print $1' "$1")
	perl -ne "$cmd" "$2"
}


# Read name of a secret for a given target.
# arg0: Name of a target (type=env,target=<this-one>)
# arg1: File path to read from.
getSecretNameFrom() {
    [ -z "$1" ] && echo "name is missing" && exit 1
    [ -z "$2" ] && echo "file is missing" && exit 1
    cmd=$(printf 'm/^Secret="?([^,]+),type=env,target=%s"?$/ && print $1' "$1")
	perl -ne "$cmd" "$2"
}


# Random string for creating secret tokens.
getRandomString() {
    tr -dc 'A-Za-z0-9' </dev/urandom | head -c 32
}


# PostgreSQL connection string.
# arg0: connection password.
getPostgresDSN() {
    [ -z "$1" ] && echo "password missing" && exit 1
    name=$(getEnvFrom POSTGRES_DB "$DB_CONTAINER")
    user=$(getEnvFrom POSTGRES_USER "$DB_CONTAINER")
    host=$(getKeyValue ContainerName "$DB_CONTAINER")
    printf "postgresql://%s:%s@%s:5432/%s" "$user" "$1" "$host" "$name"
}


# Redis connection string.
# arg0: connection password.
getRedisDSN() {
    [ -z "$1" ] && echo "password missing" && exit 1
    host=$(getKeyValue ContainerName "$REDIS_CONTAINER")
    printf "redis://:%s@%s:6379" "$1" "$host"
}


# Create a podman secret.
# arg0: secret string.
# arg1: environment name it exposed under.
# arg2: file path where the secret declared.
createSecret() {
    [ -z "$1" ] && echo "secret is missing" && exit 1
    [ -z "$2" ] && echo "environment name is missing" && exit 1
    [ -z "$3" ] && echo "file is missing" && exit 1
    name=$(getSecretNameFrom "$2" "$3")
    if [ -z "$DRY_RUN" ]; then
        printf '%s' "$1" | podman secret create "$name" -
    else
        printf 'printf %s | podman secret create %s -\n' "$1" "$name"
    fi
}


postgres_password=$(getRandomString)
postgres_dsn=$(getPostgresDSN "$postgres_password")
createSecret "$postgres_dsn" "SQL_DSN" "$APP_CONTAINER"
createSecret "$postgres_password" "POSTGRES_PASSWORD" "$DB_CONTAINER"

#redis_password=$(getRandomString)
#redis_dsn=$(getRedisDSN "$redis_password")
#createSecret "$redis_dsn" "REDIS_CONN_STRING" "$APP_CONTAINER"
#createSecret "$redis_password" "REDIS_PASSWORD" "$REDIS_CONTAINER"

createSecret "$(getRandomString)" "SESSION_SECRET" "$APP_CONTAINER"
createSecret "$(getRandomString)" "CRYPTO_SECRET" "$APP_CONTAINER"
