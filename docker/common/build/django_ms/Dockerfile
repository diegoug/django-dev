# -----------------------------------------------------------------------------
# Builder image, it creates the wheels to install to the final images
# -----------------------------------------------------------------------------
FROM python:3.10.0-bullseye AS builder

WORKDIR /usr/src/app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

RUN apt-get update \
&& apt-get -y install build-essential

# Compile Python dependencies to wheels
COPY requirements.txt .
COPY docker/ docker/

RUN pip3 install --no-cache-dir --upgrade pip
RUN pip3 wheel --no-cache-dir --no-deps --wheel-dir /usr/src/wheels -r requirements.txt

# -----------------------------------------------------------------------------
# Main image, it has the shared layers between development and production
# -----------------------------------------------------------------------------
FROM python:3.10.0-slim-bullseye AS main

# Universal buffer workaround (refer to Python base image for details)
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Python ENV
ENV PYTHONPATH=/home/app/web/

# Install netcat to run the entrypoint.sh, and libpq to connect to Postgres
RUN apt-get update \
&& apt-get -y install netcat \
&& apt-get -y install libpq5 \
&& apt-get -y install gettext \
&& apt-get -y install gdal-bin

# Create app directories
ENV HOME=/home/app
ENV APP_HOME=/home/app/web
RUN mkdir -p $APP_HOME && mkdir -p $HOME

# Install the wheels compiled in the builder image
COPY --from=builder /usr/src/wheels /wheels
RUN pip3 install --no-cache-dir --upgrade pip
RUN pip3 install --no-cache /wheels/*
RUN rm -rf /wheels

# -----------------------------------------------------------------------------
# Development image, includes a SSH keygen server, inherited from the original image
# -----------------------------------------------------------------------------
FROM main AS development

RUN apt-get update \
&& apt-get -y install openssh-server

RUN mkdir /var/run/sshd && mkdir /home/app/.ssh/

COPY docker/entrypoint.dev.sh /home/app/entrypoint.dev.sh

RUN sed -i 's/\r$//g'  /home/app/entrypoint.dev.sh
RUN chmod +x /home/app/entrypoint.dev.sh

WORKDIR /home/app/web

ENTRYPOINT ["/home/app/entrypoint.dev.sh"]
CMD ["/usr/sbin/sshd", "-D", "-f", "/etc/ssh/sshd_config"]

# -----------------------------------------------------------------------------
# Production image, includes the application files
# -----------------------------------------------------------------------------
FROM main AS production

COPY docker/entrypoint.prod.sh /home/app/entrypoint.prod.sh

RUN sed -i 's/\r$//g'  /home/app/entrypoint.prod.sh
RUN chmod +x /home/app/entrypoint.prod.sh

WORKDIR /home/app/web
COPY . .
RUN mv build_dependencies/* /home/app/web/ && rm -rf build_dependencies/ && rm -rf docker/

ENTRYPOINT ["/home/app/entrypoint.prod.sh"]