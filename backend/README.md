# BlueTrails Backend API

## Architecture

This backend is designed to be cloud-agnostic and supports deployment across multiple platforms:
- Cloudflare Workers
- Vercel Functions
- Render Web Services
- AWS Lambda
- Azure Functions

## Folder Structure

```
backend/
├── src/
│   ├── core/
│   │   ├── app.js             # Core Express.js application
│   │   ├── routes/
│   │   │   ├── index.js       # Route registry
│   │   │   ├── animals.js     # Animal endpoints
│   │   │   └── speeches.js    # Speech endpoints
│   │   ├── services/
│   │   │   ├── database.js    # Database abstraction
│   │   │   └── supabase.js    # Supabase client
│   │   ├── middleware/
│   │   │   ├── cors.js        # CORS handling
│   │   │   ├── auth.js        # Authentication
│   │   │   └── validation.js  # Request validation
│   │   └── utils/
│   │       ├── response.js    # Response formatting
│   │       ├── config.js      # Environment config
│   │       └── logger.js      # Logging utility
│   ├── adapters/
│   │   ├── cloudflare.js      # Cloudflare Worker entry
│   │   ├── vercel.js          # Vercel Functions entry
│   │   ├── render.js          # Render Web Service entry
│   │   ├── aws-lambda.js      # AWS Lambda handler
│   │   └── azure.js           # Azure Functions handler
│   └── platforms/
│       ├── server.js          # Traditional server (Render)
│       └── serverless.js      # Serverless helper functions
├── tests/
│   ├── routes/
│   │   ├── animals.test.js
│   │   └── speeches.test.js
│   └── services/
│       └── database.test.js
├── deploy/
│   ├── cloudflare/
│   │   └── wrangler.toml      # Cloudflare Worker config
│   ├── vercel/
│   │   └── vercel.json        # Vercel config
│   ├── render/
│   │   └── render.yaml        # Render config
│   ├── aws/
│   │   ├── serverless.yml     # Serverless Framework
│   │   └── sam-template.yaml  # AWS SAM template
│   └── azure/
│       └── host.json          # Azure Functions config
├── scripts/
│   ├── deploy-cloudflare.sh
│   ├── deploy-vercel.sh
│   ├── deploy-render.sh
│   ├── deploy-aws.sh
│   └── deploy-azure.sh
├── package.json
├── .env.example
└── README.md
```

## API Endpoints

### Animals
- `GET /api/animals?locale=en` - Get all animals with translations
- `GET /api/animals/:slug?locale=en` - Get specific animal data

### Speeches
- `GET /api/speeches?locale=en` - Get home page speeches

## Platform-Specific Entry Points

- **Cloudflare**: `src/adapters/cloudflare.js`
- **Vercel**: `api/` folder with `src/adapters/vercel.js`
- **Render**: `src/adapters/render.js` (traditional server)
- **AWS Lambda**: `src/adapters/aws-lambda.js`
- **Azure Functions**: `src/adapters/azure.js`

## Development

Currently focusing on Cloudflare Workers deployment. Other platforms will be added later.

## Database

Uses Supabase PostgreSQL with the following views:
- `v_animals` - Animals with basic translated info
- `v_animal_complete` - Complete animal data with all related content
- `v_home_speeches` - Home page speeches with translations