FROM gcr.io/datadoghq/agent:7

ARG POSTGRES_HOST
ARG POSTGRES_PORT
ARG POSTGRES_USER
ARG POSTGRES_PASSWORD

ENV POSTGRES_HOST=$POSTGRES_HOST
ENV POSTGRES_PORT=$POSTGRES_PORT
ENV POSTGRES_USER=$POSTGRES_USER
ENV POSTGRES_PASSWORD=$POSTGRES_PASSWORD

COPY conf.d/postgres-datadog.conf.yaml /etc/datadog-agent/conf.d/postgres.d/conf.yaml

RUN sed -i "s/%%POSTGRES_HOST%%/${POSTGRES_HOST}/g" /etc/datadog-agent/conf.d/postgres.d/conf.yaml && \
    sed -i "s/%%POSTGRES_PORT%%/${POSTGRES_PORT}/g" /etc/datadog-agent/conf.d/postgres.d/conf.yaml && \
    sed -i "s/%%POSTGRES_USER%%/${POSTGRES_USER}/g" /etc/datadog-agent/conf.d/postgres.d/conf.yaml && \
    sed -i "s/%%POSTGRES_PASSWORD%%/${POSTGRES_PASSWORD}/g" /etc/datadog-agent/conf.d/postgres.d/conf.yaml