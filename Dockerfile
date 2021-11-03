FROM python:alpine

WORKDIR /app

COPY ./main.py /app

RUN pip install pychromecast

ENTRYPOINT ["./main.py"]
