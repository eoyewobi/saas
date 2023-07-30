FROM python:3.9-alpine

# Install system dependencies
RUN apk add --no-cache libffi-dev gcc musl-dev

# Upgrade pip
RUN pip install --upgrade pip

# Set working directory and copy necessary files
WORKDIR /app
COPY app.py config requirements.txt templates ./

# venv
ENV VIRTUAL_ENV=/home/app/venv
RUN python -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Install pre-built wheels for certain packages, including MarkupSafe and greenlet
RUN pip install --no-cache-dir wheel \
    && pip wheel --no-cache-dir MarkupSafe \
    && pip wheel --no-cache-dir greenlet

# Install application requirements using --no-index to avoid building wheels
RUN pip install --no-cache-dir --no-index -r requirements.txt

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
