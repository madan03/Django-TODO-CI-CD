FROM python:3

# Create a non-root user with limited privileges
RUN groupadd -r myuser && useradd -r -g myuser myuser

# Set the working directory
WORKDIR /data

# Install required dependencies
RUN pip install django==3.2

# Copy the application code into the container
COPY . .

# Change ownership of the working directory to the non-root user
RUN chown -R myuser:myuser /data

# Switch to the non-root user
USER myuser

# Run the migration as the non-root user
RUN python manage.py migrate

# Expose the port
EXPOSE 8000

# Start the Django development server
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]







