FROM python:3.9.2-alpine

# upgrade pip
RUN pip install --upgrade pip

COPY app.py /app/
COPY requirements.txt /app/
COPY templates /app/templates/

WORKDIR /app

# venv
ENV VIRTUAL_ENV=/home/app/venv

# python setup
RUN python -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
RUN export FLASK_APP=app.py
RUN apk add --no-cache --virtual .build-deps gcc musl-dev \
    && apk add build-base && pip install --no-cache-dir -r requirements.txt \
    && apk del .build-deps

# define the port number the container should expose
EXPOSE 8000

CMD ["gunicorn","-c","python:config.gunicorn", "app:create_app()"]