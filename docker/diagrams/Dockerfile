FROM python:3.12.12-slim

ARG UV_VERSION="${UV_VERSION:-0.9.12}"

# install some basic essentials
RUN apt-get update -y && \
    apt-get install -y make curl graphviz

# install uv
RUN curl -LsSf https://astral.sh/uv/${UV_VERSION}/install.sh | sh

# working directory
WORKDIR /vault-poc

# PATH -- This is to ensure uv is added to the PATH during the build step
ENV PATH="/root/.local/bin:$PATH"
