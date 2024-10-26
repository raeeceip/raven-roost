#!/bin/bash

# Exit on error
set -e

# Function to start the Rails API
start_rails_api() {
  echo "🚀 Starting Rails API..."
  cd roost-api
  bundle install
  rails server &
  cd ..
}

# Function to start the Astro frontend
start_astro_frontend() {
  echo "🚀 Starting Astro Frontend..."
  cd frontend
  npm install
  npm start &
  cd ..
}

# Start both applications
start_rails_api
start_astro_frontend

# Wait for both applications to exit
wait

echo "✅ Both applications are running!"