FROM python:3.9.2-alpine

# upgrade pip
RUN pip3 install --upgrade pip

COPY app.py /app/
COPY requirements.txt /app/
COPY templates /app/

WORKDIR /app

# venv
ENV VIRTUAL_ENV=/home/app/venv

# python setup
RUN python -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
RUN export FLASK_APP=app.py
RUN pip3 install -r requirements.txt

# define the port number the container should expose
EXPOSE 5000

CMD ["python3", "app.py"]