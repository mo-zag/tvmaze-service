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

# TVMaze Service

A Rails API service that ingests TV show data from TVMaze API and provides a RESTful interface for querying upcoming releases.

## 🚀 Quick Start

### Prerequisites
- Ruby 3.2+
- PostgreSQL
- Docker (optional)

### Setup
1. **Clone and install dependencies:**
   ```bash
   bundle install
   ```

2. **Database setup:**
   ```bash
   rails db:create
   rails db:migrate
   ```

3. **Start the server:**
   ```bash
   rails server
   ```

4. **Test the API:**
   ```bash
   curl http://localhost:3000/up
   ```

## 📊 Database Schema

### Core Entities
- **Shows**: Main TV show information
- **Episodes**: Individual episodes with air dates
- **Networks**: Distributors/channels (e.g., Tencent QQ) **Note**: The associated country for a network can sometimes be null in the API data, so the country relation is optional in the database.
- **Countries**: Geographic information
- **Genres**: Show categories

### Schema Diagram
