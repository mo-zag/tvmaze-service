# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

# TVMaze Data Ingestion Service

A Ruby on Rails application that continuously ingests TV show data from the TVMaze API, stores it in PostgreSQL, and exposes it through a RESTful API.

## Features

- **Daily Data Ingestion**: Fetches upcoming TV show releases for the next 90 days
- **Idempotent Updates**: Safely updates existing records without duplicates
- **RESTful API**: JSON endpoints with filtering, pagination, and date range support
- **Analytical Queries**: Advanced SQL queries using CTEs, window functions, and aggregates
- **Docker Support**: Complete containerized development environment
- **HTTP Basic Authentication**: Secure API access with username/password

## Quick Start

### Prerequisites

- Docker and Docker Compose
- Ruby 3.2+ (for local development without Docker)

### Using Docker (Recommended)

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd tvmaze
   ```

2. **Start the services**
   ```bash
   docker-compose up -d
   ```

3. **Setup the database**
   ```bash
   docker-compose exec web bundle exec rails db:create db:migrate db:seed
   ```

4. **Ingest initial data**
   ```bash
   docker-compose exec web bundle exec rails tvmaze:backfill
   ```

5. **Access the API**
   - API Base URL: `http://localhost:3000/api/v1`
   - Health Check: `http://localhost:3000/up`
   - **Authentication Required**: Username: `admin`, Password: `password123`

### Local Development

1. **Install dependencies**
   ```bash
   bundle install
   ```

2. **Setup database**
   ```bash
   rails db:create db:migrate db:seed
   ```

3. **Set environment variables**
   ```bash
   export API_USERNAME=admin
   export API_PASSWORD=password123
   ```

4. **Start the server**
   ```bash
   rails server
   ```

## API Endpoints

### Authentication

All API endpoints require HTTP Basic Authentication:

```bash
curl -u admin:password123 "http://localhost:3000/api/v1/tv_shows"
```

**Default Credentials:**
- Username: `admin`
- Password: `password123`

**Environment Variables:**
- `API_USERNAME`: Username for API access
- `API_PASSWORD`: Password for API access

### TV Shows

- `GET /api/v1/tv_shows` - List TV shows with filtering and pagination
- `GET /api/v1/tv_shows/:id` - Get specific TV show details

#### Query Parameters

- `date_from` - Start date for episode air dates (default: today)
- `date_to` - End date for episode air dates (default: today + 90 days)
- `country` - Filter by country code (e.g., "US", "GB")
- `distributor` - Filter by network/distributor name
- `rating` - Filter by minimum show rating
- `genre` - Filter by genre name
- `page` - Page number for pagination (default: 1)
- `per_page` - Items per page (max: 100, default: 20)

#### Example Request

```bash
curl -u admin:password123 "http://localhost:3000/api/v1/tv_shows?date_from=2024-01-01&date_to=2024-03-31&country=US&rating=8.0&page=1&per_page=10"
```

### Analytics

- `GET /api/v1/analytics/shows_with_episode_stats` - Shows with episode counts and average ratings
- `GET /api/v1/analytics/top_rated_by_genre` - Top rated shows by genre
- `GET /api/v1/analytics/network_performance` - Network performance analysis
- `GET /api/v1/analytics/monthly_trends` - Monthly episode release trends
- `GET /api/v1/analytics/country_distribution` - Country distribution of shows

## Database Schema

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│  countries  │    │  networks   │    │    shows    │
├─────────────┤    ├─────────────┤    ├─────────────┤
│ id (PK)     │◄───┤ country_id  │    │ id (PK)     │
│ name        │    │ id (PK)     │◄───┤ network_id  │
│ code        │    │ tvmaze_id   │    │ tvmaze_id   │
│ timezone    │    │ name        │    │ name        │
└─────────────┘    │ official_site│    │ show_type   │
                   │ timezone    │    │ language    │
                   └─────────────┘    │ status      │
                                      │ runtime     │
                                      │ premiered   │
                                      │ ended       │
                                      │ official_site│
                                      │ summary     │
                                      │ image_url   │
                                      │ weight      │
                                      │ rating      │
                                      └─────────────┘
                                              │
                                              │
                    ┌─────────────┐    ┌─────────────┐
                    │ show_genres │    │  episodes   │
                    ├─────────────┤    ├─────────────┤
                    │ show_id     │    │ id (PK)     │
                    │ genre_id    │    │ tvmaze_id   │
                    └─────────────┘    │ show_id     │
                              │        │ name        │
                              │        │ season      │
                              │        │ number      │
                              │        │ episode_type│
                              │        │ airdate     │
                              │        │ airtime     │
                              │        │ airstamp    │
                              │        │ runtime     │
                              │        │ summary     │
                              │        │ image_url   │
                              │        │ rating      │
                              │        └─────────────┘
                              │
                    ┌─────────────┐
                    │   genres    │
                    ├─────────────┤
                    │ id (PK)     │
                    │ name        │
                    └─────────────┘
```

## Database Indexes

### Primary Indexes
- All tables have primary key indexes on `id`
- Unique indexes on `tvmaze_id` for shows, episodes, and networks
- Unique indexes on `code` and `name` for countries
- Unique indexes on `name` for genres

### Performance Indexes
- `episodes.airdate` - For date range filtering
- `episodes.airstamp` - For timestamp-based queries
- `episodes.show_id` - For joining episodes with shows
- `episodes.show_id, season, number` - For unique episode identification
- `shows.network_id` - For network-based filtering
- `shows.name` - For show name searches
- `shows.rating` - For rating-based filtering
- `shows.status` - For status-based filtering
- `shows.premiered` - For premiere date filtering
- `shows.tvmaze_updated_at` - For update tracking
- `networks.country_id` - For country-based filtering
- `networks.name` - For network name searches
- `show_genres.show_id, genre_id` - For genre relationships

### Index Rationale
- **Date-based indexes**: Support the core requirement of filtering by date ranges
- **Foreign key indexes**: Optimize joins between related tables
- **Composite indexes**: Support common query patterns (show + season + episode)
- **Text search indexes**: Enable efficient filtering by names and codes
- **Rating indexes**: Support rating-based filtering and sorting

## Analytical Queries

### 1. Shows with Episode Statistics (CTE)
```sql
WITH episode_stats AS (
  SELECT shows.id, COUNT(episodes.id) as episode_count, AVG(episodes.rating) as avg_episode_rating
  FROM shows
  JOIN episodes ON shows.id = episodes.show_id
  GROUP BY shows.id
)
SELECT shows.*, episode_stats.episode_count, episode_stats.avg_episode_rating
FROM shows
JOIN episode_stats ON shows.id = episode_stats.id;
```

### 2. Top Rated Shows by Genre (Window Function)
```sql
SELECT shows.*, genres.name as genre_name, 
       ROW_NUMBER() OVER (PARTITION BY genres.name ORDER BY shows.rating DESC) as rank_in_genre
FROM shows
JOIN show_genres ON shows.id = show_genres.show_id
JOIN genres ON show_genres.genre_id = genres.id
WHERE shows.rating IS NOT NULL;
```

### 3. Network Performance Analysis (Aggregates)
```sql
SELECT networks.name as network_name,
       COUNT(shows.id) as total_shows,
       AVG(shows.rating) as avg_show_rating,
       COUNT(CASE WHEN shows.status = 'Running' THEN 1 END) as active_shows,
       COUNT(CASE WHEN shows.status = 'Ended' THEN 1 END) as ended_shows
FROM shows
JOIN networks ON shows.network_id = networks.id
GROUP BY networks.id, networks.name
ORDER BY avg_show_rating DESC NULLS LAST;
```

## Trade-off Notes

### Database Design Decisions

1. **Normalization vs. Performance**
   - **Normalized**: Separate tables for countries, networks, genres to avoid data duplication
   - **Trade-off**: More joins required, but better data integrity and storage efficiency

2. **Indexing Strategy**
   - **Comprehensive indexing**: Added indexes on frequently queried columns
   - **Trade-off**: Slightly slower writes, but much faster reads for filtering and sorting

3. **Data Types**
   - **Decimal for ratings**: Precision of 3,1 for accurate rating storage
   - **Text for summaries**: Allows rich HTML content from TVMaze
   - **Date/time fields**: Proper temporal data types for efficient date operations

### API Design Decisions

1. **Pagination**
   - **Offset-based**: Simple and predictable for caching
   - **Trade-off**: Less efficient for large datasets, but suitable for current scale

2. **Filtering**
   - **Query parameters**: Simple and RESTful
   - **Trade-off**: Limited to simple equality/range filters, but covers main use cases

3. **Response Format**
   - **Nested JSON**: Includes related data in single request
   - **Trade-off**: Larger response size, but fewer API calls needed

4. **Authentication**
   - **HTTP Basic Auth**: Simple and widely supported
   - **Trade-off**: Credentials sent with each request, but easy to implement and use

### Performance Considerations

1. **Eager Loading**: Uses `includes` to prevent N+1 queries
2. **Database Indexes**: Comprehensive indexing strategy for common query patterns
3. **Rate Limiting**: Built-in delays in rake tasks to respect API limits
4. **Caching Ready**: Deterministic responses suitable for HTTP caching

## Deployment Plan

### AWS Services Required

1. **Compute**
   - **ECS Fargate**: Containerized application deployment
   - **Application Load Balancer**: HTTP traffic distribution

2. **Database**
   - **RDS PostgreSQL**: Managed database service
   - **ElastiCache Redis**: Session storage and caching

3. **Storage**
   - **S3**: Static assets and backups
   - **EFS**: Shared file storage (if needed)

4. **Monitoring**
   - **CloudWatch**: Logs, metrics, and alarms
   - **X-Ray**: Distributed tracing

5. **Security**
   - **IAM**: Access control
   - **Secrets Manager**: Database credentials and API passwords
   - **WAF**: Web application firewall

### CI/CD Pipeline

1. **Source Control**: GitHub repository
2. **Build**: GitHub Actions with Docker builds
3. **Test**: Automated testing in CI pipeline
4. **Deploy**: Blue-green deployment to ECS
5. **Monitoring**: Automated health checks and rollbacks

### Authentication/Authorization

1. **HTTP Basic Auth**: Username/password for API access
2. **Secrets Manager**: Store API credentials securely
3. **IAM**: Service-to-service authentication
4. **WAF**: IP-based access control

## Development

### Running Tests
```bash
bundle exec rspec
```

### Code Quality
```bash
bundle exec rubocop
bundle exec brakeman
```

### Database Migrations
```bash
rails generate migration MigrationName
rails db:migrate
```

### Data Ingestion
```bash
# Ingest today's data
rails runner "TvmazeIngestor.run"

# Backfill historical data
rails tvmaze:backfill
```

## Environment Variables

- `DATABASE_URL`: PostgreSQL connection string
- `TVMAZE_API_URL`: TVMaze API endpoint (default: https://api.tvmaze.com/schedule/web)
- `RAILS_ENV`: Application environment
- `API_USERNAME`: Username for API authentication (default: admin)
- `API_PASSWORD`: Password for API authentication (default: password)

## Assumptions

1. **Data Source**: TVMaze API is reliable and provides consistent data structure
2. **Scale**: Application handles moderate traffic (not enterprise-scale)
3. **Caching**: HTTP-level caching is sufficient for current requirements
4. **Security**: HTTP Basic Authentication is adequate for initial deployment but would use Doorkeeper gem to authenticate. 
5. **Monitoring**: Standard Rails logging and health checks are sufficient

## Future Enhancements

1. **GraphQL API**: More flexible querying capabilities
2. **Real-time Updates**: WebSocket support for live data
3. **Advanced Search**: Full-text search with Elasticsearch
4. **Caching Layer**: Redis for improved performance
5. **Background Jobs**: Sidekiq for async processing
6. **API Versioning**: Semantic versioning for API changes
7. **OAuth 2.0**: More sophisticated authentication
8. **API Keys**: Alternative authentication method
