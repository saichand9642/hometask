# Stage 1 - Build stage
FROM python:3.8-slim AS builder
WORKDIR /app
COPY app_a.py requirements.txt ./
RUN pip install --user -r requirements.txt

# Stage 2 - Runtime stage
FROM python:3.8-slim
WORKDIR /app
COPY --from=builder /root/.local /root/.local
ENV PATH=/root/.local/bin:$PATH
COPY app_a.py .
EXPOSE 5000
CMD ["python", "app_a.py"]

