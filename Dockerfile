FROM python:3.12-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libffi-dev \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip, setuptools, and wheel
RUN pip install --upgrade pip setuptools wheel

# Set working directory and copy necessary files
WORKDIR /app
COPY app.py config requirements.txt templates ./

# Create and activate a virtual environment
ENV VIRTUAL_ENV=/home/app/venv
RUN python -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Install Python dependencies
RUN pip install -r requirements.txt

# Add a non-root user with UID 1000
RUN useradd --uid 1000 myuser
RUN mkdir -p /home/myuser
RUN chown -R myuser:myuser /home/myuser
USER myuser

# Expose the port and set environment variables
EXPOSE 8000
ENV FLASK_APP=app.py

# Set the default entry point
ENTRYPOINT ["gunicorn"]
CMD ["-c", "config.gunicorn", "app:create_app()"]
