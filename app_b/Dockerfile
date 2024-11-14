# Stage 1 - Build stage
FROM python:3.8-slim AS builder
WORKDIR /app
COPY app_b/app_b.py app_b/requirements.txt ./
RUN pip install --user -r requirements.txt

# Stage 2 - Runtime stage
FROM python:3.8-slim
WORKDIR /app

# Install sqlite3
RUN apt-get update && apt-get install -y sqlite3

# Copy installed Python packages from the builder stage
COPY --from=builder /root/.local /root/.local
ENV PATH=/root/.local/bin:$PATH

# Copy app_b.py and schema.sql
COPY app_b/app_b.py .
COPY app_b/schema.sql /app/schema.sql

# Create the /app/data directory and set permissions
RUN mkdir -p /app/data && \
    sqlite3 /app/data/database.db < schema.sql  # Initialize the database

EXPOSE 5001
CMD ["python", "app_b.py"]

