FROM  python:3.12.0a5-slim

WORKDIR /app

COPY . /app/

RUN pip3 install --no-cache-dir -r requirements.txt

CMD ["python3", "bot.py"]
