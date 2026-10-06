# MDM API (Mobile Devices Management)

A small RESTful API for managing users and their mobile devices (Mobile Device Management),
built for the Senior Ruby on Rails live coding challenge.

The focus is on **clean structure, maintainability and explicit trade-offs** rather than feature completeness.

## Tech stack

| | |
|---|---|
| Ruby | 3.3.6 |
| Rails | 8.1 (API-only) |
| Database | PostgreSQL 18 |
| Tests | RSpec, FactoryBot, shoulda-matchers |
| CI | GitHub Actions (Brakeman, RuboCop, RSpec) |

## Getting started

```bash
bundle install
bin/rails db:prepare
bin/rails server
```

The API is served at `http://localhost:3000/api/v1`.

### Running the checks

```bash
bundle exec rspec   # test suite
bin/rubocop         # style
bin/brakeman        # security scan
```

## Data model

```
users                         devices
-----                         -------
id                            id
name          NOT NULL        user_id        NOT NULL, FK → users
email         NOT NULL,       name           NOT NULL
              UNIQUE          platform       NOT NULL, CHECK IN (ios, android, windows)
                              serial_number  NOT NULL, UNIQUE
                              status         NOT NULL, DEFAULT 'active',
                                             CHECK IN (active, inactive)
```

- A user **has many** devices; a device **belongs to** a user.
- `email` is normalized to lowercase, `serial_number` to uppercase (both stripped).

## API

All endpoints are under `/api/v1` and return JSON.

| Method | Path | Description | Success |
|---|---|---|---|
| `GET` | `/users` | List users | 200 |
| `POST` | `/users` | Create a user | 201 |
| `GET` | `/devices` | List devices (filters: `user_id`, `status`, `platform`) | 200 |
| `POST` | `/devices` | Create a device (always starts `active`) | 201 |
| `PATCH` | `/devices/:device_id/status` | Change a device's status | 200 |
| `DELETE` | `/devices/:id` | Delete a device and trigger a notification | 204 |

### Examples

Create a user:

```bash
curl -X POST localhost:3000/api/v1/users \
  -H "Content-Type: application/json" \
  -d '{"user":{"name":"Alice","email":"alice@example.com"}}'
```

```json
{ "data": { "id": 1, "name": "Alice", "email": "alice@example.com", "created_at": "2026-10-07T09:00:00Z" } }
```

Create a device:

```bash
curl -X POST localhost:3000/api/v1/devices \
  -H "Content-Type: application/json" \
  -d '{"device":{"user_id":1,"name":"iPhone 16","platform":"ios","serial_number":"abc123"}}'
```

List a user's active devices:

```bash
curl "localhost:3000/api/v1/devices?user_id=1&status=active"
```

Deactivate a device:

```bash
curl -X PATCH localhost:3000/api/v1/devices/1/status \
  -H "Content-Type: application/json" \
  -d '{"status":"inactive"}'
```

Delete a device:

```bash
curl -i -X DELETE localhost:3000/api/v1/devices/1
# HTTP/1.1 204 No Content
```

### Error format

Every error has the same shape, so clients only parse one structure:

```json
{
  "error": {
    "code": "validation_failed",
    "message": "Validation failed",
    "details": { "serial_number": ["has already been taken"] }
  }
}
```

| Status | `code` | When |
|---|---|---|
| 400 | `bad_request` | Missing or malformed parameters |
| 404 | `not_found` | Record does not exist |
| 422 | `validation_failed` | Validation error (e.g. unknown platform, duplicate serial) |

## Project structure

```
app/
  controllers/api/v1/
    base_controller.rb            # centralized error handling (rescue_from)
    users_controller.rb
    devices_controller.rb
    device_statuses_controller.rb # status as a sub-resource
  models/
    user.rb
    device.rb                     # enums, normalization, filter scopes
  serializers/                    # PORO serializers (explicit public contract)
  services/devices/destroy.rb     # delete + publish event
  jobs/device_deleted_notification_job.rb
config/initializers/device_events.rb  # event subscriber
```

## Device deletion & notification hook

```
DELETE /api/v1/devices/:id
  → DevicesController#destroy
    → Devices::Destroy
        1. device.destroy!
        2. after commit → publish "device.deleted" (ActiveSupport::Notifications)
    → subscriber → DeviceDeletedNotificationJob.perform_later
  ← 204 No Content
```

The job currently **logs** the notification; it is the place to plug in push / email / webhook delivery.

## Design decisions

- **API-only Rails, versioned under `/api/v1`**: no views, cookies or sessions; v2 can ship without breaking mobile clients.
- **Validation in two layers**: model validations give clear 422 messages; `NOT NULL`, unique indexes and check constraints guarantee integrity even under race conditions.
- **String-backed enums with `validate: true`**: readable in the DB, safe to reorder, and invalid values become 422s instead of 500s.
- **Thin controllers + centralized errors**: controllers use `create!` / `update!` / `find`, and `BaseController` maps exceptions to HTTP statuses. Unexpected errors are not rescued so they surface and get reported.
- **Rails 8 `params.expect`**: strict strong parameters; malformed payloads return 400.
- **PORO serializers**: the JSON contract is explicit and decoupled from models, with no gem dependency.
- **Status change as its own endpoint**: a business action that may later need auditing or permissions, and it prevents editing `serial_number` through a generic update.
- **Service object over model callback for deletion**: explicit, testable, does not fire from consoles or seeds. Trade-off: deletions must go through the service; `restrict_with_error` on `user.devices` prevents silent cascades.
- **Pub/sub + after-commit + background job**: the service does not know its listeners, the event is never sent if the transaction rolls back, and delivery does not slow the request.

## Assumptions

- No authentication / authorization (out of scope for the exercise).
- The requirements mention a hook "when a device is deleted" but no delete endpoint, so `DELETE /devices/:id` was added.
- `status` cannot be set on create; new devices are always `active`.
- Deleting a user with devices is rejected rather than cascading.

## What I would do next

- Authentication (e.g. token-based) and per-user authorization
- Pagination on list endpoints (cursor-based for large tables)
- Real notification delivery with retries and dead-letter handling
- Soft delete (`discarded_at`) to keep an audit trail of removed devices
- Outbox pattern if events must survive a crash between commit and enqueue
- OpenAPI / Swagger documentation (e.g. rswag)
- Composite index on `(user_id, status)` if that filter becomes a hot path
