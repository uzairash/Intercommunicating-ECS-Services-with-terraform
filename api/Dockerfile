FROM python:3.9
WORKDIR /app
COPY api_service.py .
RUN pip install flask jsonify
EXPOSE 5000
CMD ["python", "api_service.py"]
