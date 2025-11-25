# LunchNinja 🥷

A simple yet powerful lunch matching application that randomly pairs students and professors for meaningful lunch conversations.

## Features

- **Magic Link Authentication** - Passwordless login via email
- **Multi-School Support** - Fully isolated multi-tenant architecture
- **Flexible Scheduling** - Users set their availability, system handles the rest
- **Automated Matching** - Daily matching algorithm pairs people fairly
- **Admin Dashboard** - Manage users, time slots, and view match history
- **Modern UI** - Clean, professional interface built with LiveView and daisyUI
- **Email Notifications** - Automatic match confirmations and cancellation notices

## Tech Stack

- **Phoenix 1.8** - Web framework
- **LiveView 1.1** - Real-time user interface
- **PostgreSQL** - Database
- **Oban 2.18** - Background job processing
- **Tailwind CSS + daisyUI** - Styling
- **Swoosh + Resend** - Email delivery

## Quick Start

### Prerequisites

- Elixir 1.15+ and Erlang 26+
- PostgreSQL 14+
- Node.js 18+ (for asset compilation)

### Development Setup

```bash
# Install dependencies
mix deps.get

# Set up database
mix ecto.setup

# Install frontend dependencies and compile assets
mix assets.setup
mix assets.build

# Start the server
mix phx.server
```

Visit `http://localhost:4000` to see the application.

### Development Credentials

The seeds file creates test users at two schools (Stanford and MIT):

**Admins:**
- `admin@stanford.edu`
- `admin@mit.edu`

Use `/dev/mailbox` to view magic link emails in development.

## Deployment

See the comprehensive [DEPLOYMENT.md](DEPLOYMENT.md) guide for production setup with:
- Server configuration
- SSL certificates
- Nginx reverse proxy
- Resend email integration
- Database backups
- Monitoring

## License

Proprietary - All rights reserved

## Contact

For questions: mike@lunchninja.org
