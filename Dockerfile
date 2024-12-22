FROM python:3.11-alpine
RUN apk update && \
    apk add --no-cache tzdata
ENV TZ=Africa/Lagos
WORKDIR /client
RUN pip install --no-cache-dir fastapi uvicorn
COPY . /client
EXPOSE 8000
CMD ["uvicorn", "api:app", "--host", "0.0.0.0", "--port", "8000"]


