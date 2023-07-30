FROM python:3.9-bookworm

# Upgrade pip
RUN pip install --upgrade pip

# Set working directory and copy necessary files
WORKDIR /app
COPY app.py config requirements.txt templates ./

# venv
ENV VIRTUAL_ENV=/home/app/venv
RUN python -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Install build dependencies, install requirements, and remove build dependencies
RUN apk add --no-cache --virtual .build-deps gcc musl-dev \
    && pip install --no-cache-dir -r requirements.txt \
    && apk del .build-deps

# Add a non-root user
RUN adduser -D 1000
USER 1000

# Define the port number the container should expose
EXPOSE 8000

# Set the environment variable for Flask app
ENV FLASK_APP=app.py

# Set the default Gunicorn configuration file and entry point
ENTRYPOINT ["gunicorn"]
CMD ["-c", "config.gunicorn", "app:create_app()"]

