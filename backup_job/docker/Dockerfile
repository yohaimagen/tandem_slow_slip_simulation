FROM python:3.12.9-alpine3.20

# Create a non-root user
RUN adduser --disabled-password --gecos "" appuser

# Create storage directory
RUN mkdir -p /home/appuser/storage && \
    chown -R appuser:appuser /home/appuser/storage

# Switch to non-root user
USER appuser
WORKDIR /home/appuser

# Install AWS CLI and boto3 without extra dependencies
RUN pip install --no-cache-dir --user \
    awscli \
    boto3

# Add .local/bin to PATH
ENV PATH="/home/appuser/.local/bin:${PATH}"

# Set the storage directory as a volume
VOLUME ["/home/appuser/storage"]

# Default command
CMD ["/bin/sh"]