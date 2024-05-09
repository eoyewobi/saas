FROM python:3.8-slim

# Upgrade pip
RUN pip install --upgrade pip

# Set working directory and copy necessary files
WORKDIR /app
COPY app.py config requirements.txt templates ./

# venv
ENV VIRTUAL_ENV=/home/app/venv
RUN python -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

RUN pip install -r requirements.txt

# Add a non-root user with UID 1000
RUN useradd --uid 1000 myuser
RUN mkdir -p /home/myuser
RUN chown -R myuser:myuser /home/myuser
USER myuser

# Define the port number the container should expose
EXPOSE 8000

# Set the environment variable for Flask app
ENV FLASK_APP=app.py

# Set the default Gunicorn configuration file and entry point
ENTRYPOINT ["gunicorn"]
CMD ["-c", "config.gunicorn", "app:create_app()"]
