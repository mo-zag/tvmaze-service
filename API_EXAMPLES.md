# API Examples

This document provides examples of how to use the TVMaze API endpoints.

## Base URL
- Local Development: `http://localhost:3000/api/v1`
- Production: `https://your-domain.com/api/v1`

## Authentication

The API is protected with HTTP Basic Authentication. You'll need to provide credentials with each request.

**Default Credentials:**
- Username: `admin`
- Password: `password123`

**Environment Variables:**
- `API_USERNAME`: Username for API access
- `API_PASSWORD`: Password for API access

## Health Check
```bash
curl http://localhost:3000/up
```

## TV Shows Endpoints

### 1. List TV Shows (Basic)
```bash
curl -u admin:password123 "http://localhost:3000/api/v1/tv_shows"
```

### 2. List TV Shows with Date Range
```bash
curl -u admin:password123 "http://localhost:3000/api/v1/tv_shows?date_from=2024-01-01&date_to=2024-03-31"
```

### 3. List TV Shows with Country Filter
```bash
curl -u admin:password123 "http://localhost:3000/api/v1/tv_shows?country=US"
```

### 4. List TV Shows with Distributor Filter
```bash
curl -u admin:password123 "http://localhost:3000/api/v1/tv_shows?distributor=HBO"
```

### 5. List TV Shows with Rating Filter
```bash
curl -u admin:password123 "http://localhost:3000/api/v1/tv_shows?rating=8.0"
```

### 6. List TV Shows with Genre Filter
```bash
curl -u admin:password123 "http://localhost:3000/api/v1/tv_shows?genre=Drama"
```

### 7. List TV Shows with Pagination
```bash
curl -u admin:password123 "http://localhost:3000/api/v1/tv_shows?page=1&per_page=10"
```

### 8. Complex Filtering Example
```bash
curl -u admin:password123 "http://localhost:3000/api/v1/tv_shows?date_from=2024-01-01&date_to=2024-03-31&country=US&rating=8.0&genre=Drama&page=1&per_page=20"
```

### 9. Get Specific TV Show
```bash
curl -u admin:password123 "http://localhost:3000/api/v1/tv_shows/1"
```

## Analytics Endpoints

### 1. Shows with Episode Statistics
```bash
curl -u admin:password123 "http://localhost:3000/api/v1/analytics/shows_with_episode_stats"
```

### 2. Top Rated Shows by Genre
```bash
curl -u admin:password123 "http://localhost:3000/api/v1/analytics/top_rated_by_genre?limit=5"
```

### 3. Network Performance Analysis
```bash
curl -u admin:password123 "http://localhost:3000/api/v1/analytics/network_performance"
```

### 4. Monthly Episode Trends
```bash
curl -u admin:password123 "http://localhost:3000/api/v1/analytics/monthly_trends?year=2024"
```

### 5. Country Distribution
```bash
curl -u admin:password123 "http://localhost:3000/api/v1/analytics/country_distribution"
```

## Using Environment Variables for Authentication

You can also use environment variables to avoid hardcoding credentials:

```bash
# Set environment variables
export API_USERNAME=admin
export API_PASSWORD=password123

# Use in curl
curl -u "$API_USERNAME:$API_PASSWORD" "http://localhost:3000/api/v1/tv_shows"
```

## Response Examples

### TV Shows List Response
```json
{
  "data": [
    {
      "id": 1,
      "tvmaze_id": 123,
      "name": "Breaking Bad",
      "show_type": "Drama",
      "language": "English",
      "status": "Ended",
      "runtime": 60,
      "premiered": "2008-01-20",
      "ended": "2013-09-29",
      "official_site": "https://www.amc.com/shows/breaking-bad",
      "summary": "<p>A high school chemistry teacher turned methamphetamine manufacturer...</p>",
      "image_url": "https://static.tvmaze.com/uploads/images/original_untouched/0/2400.jpg",
      "weight": 100,
      "rating": 9.5,
      "network": {
        "id": 1,
        "name": "AMC",
        "official_site": "https://www.amc.com",
        "timezone": "America/New_York",
        "country": {
          "name": "United States",
          "code": "US",
          "timezone": "America/New_York"
        }
      },
      "genres": [
        {
          "id": 1,
          "name": "Drama"
        },
        {
          "id": 2,
          "name": "Crime"
        }
      ],
      "episodes": [
        {
          "id": 1,
          "name": "Pilot",
          "season": 1,
          "number": 1,
          "episode_type": "regular",
          "airdate": "2008-01-20",
          "airtime": "22:00",
          "airstamp": "2008-01-21T03:00:00+00:00",
          "runtime": 58,
          "summary": "<p>When an unassuming high school chemistry teacher discovers he has a rare form of lung cancer...</p>",
          "image_url": "https://static.tvmaze.com/uploads/images/original_untouched/0/2400.jpg",
          "rating": 9.0
        }
      ],
      "created_at": "2024-01-01T00:00:00.000Z",
      "updated_at": "2024-01-01T00:00:00.000Z"
    }
  ],
  "meta": {
    "page": 1,
    "per_page": 20,
    "total_count": 100,
    "total_pages": 5
  }
}
```

### Analytics Response Example
```json
{
  "data": [
    {
      "network_name": "HBO",
      "total_shows": 25,
      "avg_show_rating": 8.7,
      "active_shows": 15,
      "ended_shows": 10
    },
    {
      "network_name": "Netflix",
      "total_shows": 45,
      "avg_show_rating": 7.9,
      "active_shows": 30,
      "ended_shows": 15
    }
  ]
}
```

## Error Responses

### 401 Unauthorized
```json
{
  "error": "HTTP Basic: Access denied."
}
```

### 404 Not Found
```json
{
  "error": "Show not found"
}
```

### 400 Bad Request (Invalid Date)
```json
{
  "error": "Invalid date format"
}
```

## Postman Collection

You can import this collection into Postman:

```json
{
  "info": {
    "name": "TVMaze API",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "auth": {
    "type": "basic",
    "basic": [
      {
        "key": "username",
        "value": "admin",
        "type": "string"
      },
      {
        "key": "password",
        "value": "password123",
        "type": "string"
      }
    ]
  },
  "item": [
    {
      "name": "Health Check",
      "request": {
        "method": "GET",
        "url": "http://localhost:3000/up"
      }
    },
    {
      "name": "List TV Shows",
      "request": {
        "method": "GET",
        "url": "http://localhost:3000/api/v1/tv_shows"
      }
    },
    {
      "name": "Get TV Show by ID",
      "request": {
        "method": "GET",
        "url": "http://localhost:3000/api/v1/tv_shows/1"
      }
    },
    {
      "name": "Analytics - Network Performance",
      "request": {
        "method": "GET",
        "url": "http://localhost:3000/api/v1/analytics/network_performance"
      }
    }
  ]
}
```

## Rate Limiting

The API respects rate limits to prevent abuse:
- 1000 requests per minute per IP address
- 429 status code when limit exceeded
- Retry-After header indicates when to retry

## Security Notes

- **Production**: Change default credentials immediately
- **HTTPS**: Always use HTTPS in production
- **Credential Rotation**: Regularly rotate API credentials
- **Access Logging**: Monitor API access for security
- **Rate Limiting**: Implement additional rate limiting if needed 