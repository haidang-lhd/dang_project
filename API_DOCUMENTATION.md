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

## Profit Analytics API

### Calculate Profit

Calculates the profit and loss for the authenticated user's entire investment portfolio. The results are broken down by asset category and include detailed metrics for each asset.

**Endpoint:** `GET /api/v1/profit_analytics/calculate_profit`

**Response Format (200 OK):**

The response contains two main keys: `category_details` and `chart_data`.

- `category_details`: An object where each key is a category name (e.g., "Stocks", "Bonds"). Each category contains its aggregated financial data and a list of its assets.
- `chart_data`: Data formatted for easy use in charts, including a summary for each category and a portfolio-wide summary.

```json
{
  "category_details": {
    "Stocks": {
      "invested": 15050.0,
      "current_value": 16000.0,
      "profit": 950.0,
      "profit_percentage": 6.31,
      "assets": [
        {
          "id": 1,
          "name": "Apple Inc",
          "invested": 15050.0,
          "current_value": 16000.0,
          "profit": 950.0,
          "profit_percentage": 6.31,
          "quantity": 100.0,
          "current_price": 160.0
        }
      ]
    },
    "Bonds": {
      "invested": 5000.0,
      "current_value": 5100.0,
      "profit": 100.0,
      "profit_percentage": 2.0,
      "assets": [
        {
          "id": 2,
          "name": "US Treasury Bond",
          "invested": 5000.0,
          "current_value": 5100.0,
          "profit": 100.0,
          "profit_percentage": 2.0,
          "quantity": 50.0,
          "current_price": 102.0
        }
      ]
    }
  },
  "chart_data": {
    "categories": [
      {
        "label": "Stocks",
        "invested": 15050.0,
        "current_value": 16000.0,
        "profit": 950.0,
        "profit_percentage": 6.31
      },
      {
        "label": "Bonds",
        "invested": 5000.0,
        "current_value": 5100.0,
        "profit": 100.0,
        "profit_percentage": 2.0
      }
    ],
    "portfolio_summary": {
      "total_invested": 20050.0,
      "total_current_value": 21100.0,
      "total_profit": 1050.0,
      "total_profit_percentage": 5.24
    }
  }
}
```

**Example curl request:**

```bash
curl -X GET "http://localhost:3000/api/v1/profit_analytics/calculate_profit" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Field Descriptions

#### Category Details

- `invested`: Total amount invested in this category.
- `current_value`: Total current market value of all assets in this category.
- `profit`: Total profit (`current_value` - `invested`).
- `profit_percentage`: Profit as a percentage of the amount invested.
- `assets`: A list of individual assets within the category.

#### Asset Details

- `id`: The asset's unique ID.
- `name`: The asset's name.
- `invested`: Total amount invested in this specific asset.
- `current_value`: Current market value of this asset.
- `profit`: Profit from this asset.
- `profit_percentage`: Profit percentage for this asset.
- `quantity`: Total quantity held of this asset.
- `current_price`: The most recent price per unit for this asset.

#### Chart Data

- `categories`: An array of objects, each summarizing a category's financial performance.
- `portfolio_summary`: An object summarizing the financial performance of the entire portfolio.

### Calculate Detailed Profit

Calculates the detailed profit and loss for each individual investment transaction, grouped by category. This endpoint provides granular insights into the performance of each transaction.

**Endpoint:** `GET /api/v1/profit_analytics/calculate_detail_profit`

**Response Format (200 OK):**

The response contains `category_details` and `chart_data`.

- `category_details`: An object where each key is a category name (e.g., "Stocks", "Bonds"). Each category contains aggregated financial data and a list of individual transactions.
- `chart_data`: Data formatted for easy use in charts, including a summary for each category and a portfolio-wide summary.

```json
{
  "category_details": {
    "Stocks": {
      "total_invested": 15050.0,
      "total_current_value": 16000.0,
      "total_profit": 950.0,
      "total_profit_percentage": 6.31,
      "transactions": [
        {
          "id": 1,
          "asset_name": "Apple Inc",
          "transaction_date": "2025-07-01",
          "transaction_type": "buy",
          "quantity": 100.0,
          "nav": 150.5,
          "invested": 15050.0,
          "current_price": 160.0,
          "current_value": 16000.0,
          "profit": 950.0,
          "profit_percentage": 6.31
        }
      ]
    },
    "Bonds": {
      "total_invested": 5000.0,
      "total_current_value": 5100.0,
      "total_profit": 100.0,
      "total_profit_percentage": 2.0,
      "transactions": [
        {
          "id": 2,
          "asset_name": "US Treasury Bond",
          "transaction_date": "2025-07-01",
          "transaction_type": "buy",
          "quantity": 50.0,
          "nav": 100.0,
          "invested": 5000.0,
          "current_price": 102.0,
          "current_value": 5100.0,
          "profit": 100.0,
          "profit_percentage": 2.0
        }
      ]
    }
  },
  "chart_data": {
    "categories": [
      {
        "label": "Stocks",
        "total_invested": 15050.0,
        "total_current_value": 16000.0,
        "total_profit": 950.0,
        "total_profit_percentage": 6.31
      },
      {
        "label": "Bonds",
        "total_invested": 5000.0,
        "total_current_value": 5100.0,
        "total_profit": 100.0,
        "total_profit_percentage": 2.0
      }
    ],
    "portfolio_summary": {
      "total_invested": 20050.0,
      "total_current_value": 21100.0,
      "total_profit": 1050.0,
      "total_profit_percentage": 5.24
    }
  }
}
```

**Example curl request:**

```bash
curl -X GET "http://localhost:3000/api/v1/profit_analytics/calculate_detail_profit" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Field Descriptions (Detailed Profit)

#### Category Details (Detailed Profit)

- `total_invested`: Total amount invested in this category across all transactions.
- `total_current_value`: Total current market value of all assets in this category across all transactions.
- `total_profit`: Total profit (`total_current_value` - `total_invested`) for the category.
- `total_profit_percentage`: Total profit as a percentage of the total amount invested for the category.
- `transactions`: A list of individual investment transactions within the category.

#### Transaction Details

- `id`: The transaction's unique ID.
- `asset_name`: The name of the asset involved in the transaction.
- `transaction_date`: The date of the transaction.
- `transaction_type`: The type of transaction (e.g., "buy", "sell").
- `quantity`: The quantity of units transacted.
- `nav`: The Net Asset Value per unit at the time of the transaction.
- `invested`: The total amount invested in this specific transaction (`quantity * nav`).
- `current_price`: The current price per unit of the asset.
- `current_value`: The current market value of this transaction (`quantity * current_price`).
- `profit`: Profit from this transaction (`current_value` - `invested`).
- `profit_percentage`: Profit percentage for this transaction.

#### Chart Data (Detailed Profit)

- `categories`: An array of objects, each summarizing a category's financial performance based on detailed transactions.
- `portfolio_summary`: An object summarizing the financial performance of the entire portfolio based on detailed transactions.
