# API Documentation

This document describes the REST API endpoints for managing categories, assets, and investment transactions.

## Base URL

```
http://localhost:3000/api/v1
```

## Authentication

All API endpoints require JWT authentication. You must include a valid JWT token in the `Authorization` header with each request.

### Getting a JWT Token

First, authenticate to get a JWT token:

**Endpoint:** `POST /login`

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "your_password"
}
```

**Success Response (200 OK):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxLCJleHAiOjE3MTk5MjQ4MDB9.abc123..."
}
```

### Using the JWT Token

Include the JWT token in the `Authorization` header for all API requests:

```
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxLCJleHAiOjE3MTk5MjQ4MDB9.abc123...
```

### Authentication Errors

**401 Unauthorized** - Missing or invalid JWT token:
```json
{
  "error": "Invalid token"
}
```

**401 Unauthorized** - User not found:
```json
{
  "error": "User not found"
}
```

## Categories API

### List All Categories

Lists all categories ordered by name.

**Endpoint:** `GET /api/v1/categories`

**Response Format:**
```json
[
  {
    "id": 1,
    "name": "Stocks",
    "created_at": "2025-07-01T10:00:00.000Z",
    "updated_at": "2025-07-01T10:00:00.000Z"
  },
  {
    "id": 2,
    "name": "Bonds",
    "created_at": "2025-07-01T10:01:00.000Z",
    "updated_at": "2025-07-01T10:01:00.000Z"
  }
]
```

**Example curl request:**
```bash
curl -X GET "http://localhost:3000/api/v1/categories" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

## Assets API

### List All Assets

Lists all assets with their associated category information, ordered by name.

**Endpoint:** `GET /api/v1/assets`

**Query Parameters:**
- `category_id` (optional): Filter assets by category ID

**Response Format:**
```json
[
  {
    "id": 1,
    "name": "Apple Inc",
    "type": "StockAsset",
    "created_at": "2025-07-01T10:00:00.000Z",
    "updated_at": "2025-07-01T10:00:00.000Z",
    "category": {
      "id": 1,
      "name": "Stocks"
    }
  },
  {
    "id": 2,
    "name": "Google Inc",
    "type": "StockAsset",
    "created_at": "2025-07-01T10:01:00.000Z",
    "updated_at": "2025-07-01T10:01:00.000Z",
    "category": {
      "id": 1,
      "name": "Stocks"
    }
  }
]
```

**Example curl requests:**

List all assets:
```bash
curl -X GET "http://localhost:3000/api/v1/assets" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

Filter assets by category:
```bash
curl -X GET "http://localhost:3000/api/v1/assets?category_id=1" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

## Investment Transactions API

### List Investment Transactions

Lists investment transactions belonging to the authenticated user, with user and asset information, ordered by date (descending).

**Endpoint:** `GET /api/v1/investment_transactions`

**Query Parameters:**
- `asset_id` (optional): Filter transactions by asset ID

**Note:** Only transactions belonging to the authenticated user are returned. The `user_id` parameter is no longer supported as user scoping is handled automatically via JWT authentication.

**Response Format:**
```json
[
  {
    "id": 1,
    "transaction_type": "buy",
    "quantity": "100.0",
    "nav": "150.5",
    "total_amount": "15050.0",
    "fee": "50.0",
    "unit": "shares",
    "date": "2025-07-01",
    "created_at": "2025-07-01T10:00:00.000Z",
    "updated_at": "2025-07-01T10:00:00.000Z",
    "user": {
      "id": 1,
      "email": "user@example.com"
    },
    "asset": {
      "id": 1,
      "name": "Apple Inc",
      "type": "StockAsset"
    }
  }
]
```

**Example curl requests:**

List all transactions for authenticated user:
```bash
curl -X GET "http://localhost:3000/api/v1/investment_transactions" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

Filter by asset:
```bash
curl -X GET "http://localhost:3000/api/v1/investment_transactions?asset_id=1" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Get Single Investment Transaction

Retrieves a specific investment transaction with full details including category information.

**Endpoint:** `GET /api/v1/investment_transactions/:id`

**Response Format:**
```json
{
  "id": 1,
  "transaction_type": "buy",
  "quantity": "100.0",
  "nav": "150.5",
  "total_amount": "15050.0",
  "fee": "50.0",
  "unit": "shares",
  "date": "2025-07-01",
  "created_at": "2025-07-01T10:00:00.000Z",
  "updated_at": "2025-07-01T10:00:00.000Z",
  "user": {
    "id": 1,
    "email": "user@example.com"
  },
  "asset": {
    "id": 1,
    "name": "Apple Inc",
    "type": "StockAsset",
    "category": {
      "id": 1,
      "name": "Stocks"
    }
  }
}
```

**Example curl request:**
```bash
curl -X GET "http://localhost:3000/api/v1/investment_transactions/1" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Note:** You can only access transactions that belong to your authenticated user account.

### Create Investment Transaction

Creates a new investment transaction.

**Endpoint:** `POST /api/v1/investment_transactions`

**Request Body:**
```json
{
  "investment_transaction": {
    "asset_id": 1,
    "transaction_type": "buy",
    "quantity": 100.0,
    "nav": 150.50,
    "total_amount": 15050.0,
    "fee": 50.0,
    "unit": "shares",
    "date": "2025-07-01"
  }
}
```

**Note:** The `user_id` field is no longer required or accepted in the request body. The transaction will be automatically associated with the authenticated user.

**Success Response (201 Created):**
Returns the created transaction in the same format as the show endpoint.

**Error Response (422 Unprocessable Entity):**
```json
{
  "errors": {
    "asset_id": ["can't be blank"],
    "quantity": ["must be greater than or equal to 0"]
  }
}
```

**Example curl request:**
```bash
curl -X POST "http://localhost:3000/api/v1/investment_transactions" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "investment_transaction": {
      "asset_id": 1,
      "transaction_type": "buy",
      "quantity": 100.0,
      "nav": 150.50,
      "total_amount": 15050.0,
      "fee": 50.0,
      "unit": "shares",
      "date": "2025-07-01"
    }
  }'
```

### Update Investment Transaction

Updates an existing investment transaction.

**Endpoint:** `PUT /api/v1/investment_transactions/:id` or `PATCH /api/v1/investment_transactions/:id`

**Request Body:**
```json
{
  "investment_transaction": {
    "quantity": 200.0,
    "nav": 160.75,
    "total_amount": 32150.0
  }
}
```

**Success Response (200 OK):**
Returns the updated transaction in the same format as the show endpoint.

**Error Response (422 Unprocessable Entity):**
```json
{
  "errors": {
    "quantity": ["must be greater than or equal to 0"]
  }
}
```

**Example curl request:**
```bash
curl -X PUT "http://localhost:3000/api/v1/investment_transactions/1" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "investment_transaction": {
      "quantity": 200.0,
      "nav": 160.75,
      "total_amount": 32150.0
    }
  }'
```

### Delete Investment Transaction

Deletes an investment transaction.

**Endpoint:** `DELETE /api/v1/investment_transactions/:id`

**Success Response:** `204 No Content` (empty response body)

**Example curl request:**
```bash
curl -X DELETE "http://localhost:3000/api/v1/investment_transactions/1" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Note:** You can only update and delete transactions that belong to your authenticated user account.

## Field Descriptions

### Investment Transaction Fields

- `asset_id` (integer, required): ID of the asset being transacted
- `transaction_type` (string, required): Type of transaction (e.g., "buy", "sell")
- `quantity` (decimal, required): Number of units transacted (≥ 0)
- `nav` (decimal, required): Net Asset Value per unit (≥ 0)
- `total_amount` (decimal, optional): Total transaction amount (≥ 0)
- `fee` (decimal, optional): Transaction fee (≥ 0)
- `unit` (string, required): Unit of measurement (e.g., "shares", "grams", "pieces")
- `date` (date, required): Date of the transaction

**Note:** The `user_id` field is no longer accepted in request bodies. Transactions are automatically associated with the authenticated user via JWT token.

## Asset Types

The following asset types are supported:
- `FundAsset`
- `StockAsset`
- `GoldAsset`
- `BondAsset`
- `RealEstateAsset`
- `CryptocurrencyAsset`

## Error Handling

All endpoints return appropriate HTTP status codes:

- `200 OK`: Successful GET/PUT requests
- `201 Created`: Successful POST requests
- `204 No Content`: Successful DELETE requests
- `401 Unauthorized`: Missing, invalid, or expired JWT token
- `404 Not Found`: Resource not found or user trying to access another user's resource
- `422 Unprocessable Entity`: Validation errors

Error responses include a JSON object with an `error` or `errors` key:

**Authentication errors (401):**
```json
{
  "error": "Invalid token"
}
```

**Not found errors (404):**
```json
{
  "error": "Record not found"
}
```

**Validation errors (422):**
```json
{
  "errors": {
    "field_name": ["validation message"]
  }
}
```

## Testing

All endpoints are thoroughly tested with RSpec. To run the API tests:

```bash
# Run all API controller tests
docker-compose exec web bundle exec rspec spec/controllers/api/v1/

# Run specific controller tests
docker-compose exec web bundle exec rspec spec/controllers/api/v1/categories_controller_spec.rb
docker-compose exec web bundle exec rspec spec/controllers/api/v1/assets_controller_spec.rb
docker-compose exec web bundle exec rspec spec/controllers/api/v1/investment_transactions_controller_spec.rb
```
