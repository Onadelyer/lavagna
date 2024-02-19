FROM gcr.io/datadoghq/agent:7.35.0

COPY conf.d/postgres-datadog.conf.yaml /etc/datadog-agent/conf.d/postgres.d/conf.yaml

RUN sed -i "s/%%POSTGRES_HOST%%/${POSTGRES_HOST}/g" /etc/datadog-agent/conf.d/postgres.d/conf.yaml && \
    sed -i "s/%%POSTGRES_PORT%%/${POSTGRES_PORT}/g" /etc/datadog-agent/conf.d/postgres.d/conf.yaml && \
    sed -i "s/%%POSTGRES_USER%%/${POSTGRES_USER}/g" /etc/datadog-agent/conf.d/postgres.d/conf.yaml && \
    sed -i "s/%%POSTGRES_PASSWORD%%/${POSTGRES_PASSWORD}/g" /etc/datadog-agent/conf.d/postgres.d/conf.yaml