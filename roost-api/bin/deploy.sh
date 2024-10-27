#!/bin/bash

# Exit on error
set -e

# Deploy the application
echo "Deploying application..."
fly deploy

# Wait for deployment to complete
sleep 10

# Run database migrations
echo "Running database migrations..."
fly ssh console -C "cd /rails && bundle exec rails db:migrate"

# Reindex Elasticsearch
echo "Reindexing Elasticsearch..."
fly ssh console -C "cd /rails && bundle exec rails elasticsearch:reindex"

echo "Deployment completed successfully!"