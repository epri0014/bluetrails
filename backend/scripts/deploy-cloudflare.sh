#!/bin/bash

# BlueTrails Backend - Cloudflare Worker Deployment Script

echo "🚀 Deploying BlueTrails Backend to Cloudflare Workers..."

# Check if wrangler is installed
if ! command -v wrangler &> /dev/null; then
    echo "❌ Wrangler CLI not found. Please install it first:"
    echo "npm install -g wrangler"
    exit 1
fi

# Navigate to backend directory
cd "$(dirname "$0")/.."

# Copy wrangler config to root
cp deploy/cloudflare/wrangler.toml ./wrangler.toml

# Install dependencies
echo "📦 Installing dependencies..."
npm install

# Deploy to Cloudflare Workers
echo "🚀 Deploying to Cloudflare Workers..."
wrangler deploy

# Clean up
rm -f ./wrangler.toml

echo "✅ Deployment completed!"
echo "📋 Next steps:"
echo "1. Set environment variables in Cloudflare dashboard:"
echo "   - SUPABASE_URL"
echo "   - SUPABASE_KEY"
echo "   - ALLOWED_ORIGINS"
echo "2. Test the endpoints:"
echo "   - GET /health"
echo "   - GET /api/animals?locale=en"
echo "   - GET /api/speeches?locale=en"