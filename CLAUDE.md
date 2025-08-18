# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Puny Monitor is a batteries-included monitoring tool for single hosts, designed specifically for Kamal deployments and containerized setups. It's a Ruby gem built with Sinatra that provides system monitoring through a web interface.

## Development Commands

### Setup
```bash
bin/setup              # Install dependencies
```

### Testing & Quality
```bash
rake test              # Run all tests with Minitest
rake standard          # Run StandardRB linter
rake default           # Run both tests and linter
```

### Development Server
```bash
puny-monitor           # Start the server on port 4567
bin/console            # Interactive Ruby console
```

### Docker Development
```bash
rake docker:build     # Build Docker image
rake docker:run       # Run container locally
rake docker:shell     # Interactive shell in container
```

### Assets
```bash
rake assets           # Copy Chartkick JavaScript assets to public/
```

## Architecture

### Core Components

**Sinatra App** (`app/puny_monitor.rb`): Main web application with basic auth, JSON API endpoints for metrics data, and time-based data aggregation.

**Scheduler** (`app/scheduler.rb`): Background job system using Rufus Scheduler that collects system metrics every 5 seconds and cleans up old data hourly.

**SystemUtils** (`lib/system_utils.rb`): Core system monitoring utilities that read from `/proc` filesystem for CPU, memory, disk, and network stats. Uses 1-second sampling intervals for accurate measurements.

**Models** (`app/models/`): ActiveRecord models for each metric type (CpuUsage, MemoryUsage, etc.) with time-based aggregation methods using the Groupdate gem.

### Key Design Patterns

- **Environment-aware monitoring**: Uses `ROOT_PATH` environment variable to support Docker containers monitoring host system via mounted `/proc`
- **Time-series data**: All models store timestamped metrics with automatic cleanup after 1 month
- **API-driven frontend**: Web interface loads data via JSON endpoints with dynamic time range selection
- **Dockerized deployment**: Designed for containerized deployment with host filesystem access

### Dependencies

- **Sinatra**: Web framework with ActiveRecord integration
- **Rufus Scheduler**: Background job scheduling
- **SQLite3**: Database for metrics storage
- **Chartkick + Groupdate**: Chart rendering and time-based data grouping
- **Sys::Filesystem**: System filesystem statistics
- **StandardRB**: Ruby code style enforcement

### Database Schema

All metric models follow the same pattern with `created_at` timestamps and indexed columns for efficient time-range queries. Metrics are collected every 5 seconds and aggregated by minute/hour for different time ranges.

## Configuration

- **Database**: Uses SQLite3 with automatic migration support
- **Authentication**: Basic auth with credentials pulled from environment variables
- **Monitoring Intervals**: 5-second data collection
- **Data Retention**: 1 month automatic cleanup
