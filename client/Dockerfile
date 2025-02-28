FROM python:3.9
WORKDIR /app
COPY client.py .
RUN pip install flask jsonify requests
EXPOSE 8000
CMD ["python", "client.py"]
