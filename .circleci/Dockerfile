FROM hashicorp/terraform:1.5.7
FROM python:3.10-slim-bullseye

# Install poetry
RUN pip install poetry==1.6.1

# Install terraform
COPY --from=0 /bin/terraform /bin/

# Install build tools
RUN apt-get update && apt-get install -y \
    curl \
    git \
    make \
    zip \
    && rm -rf /var/lib/apt/lists/*

ENTRYPOINT []
