# Roost API

The Roost API is a Rails application that provides backend services for the Roost project. It includes user authentication, space management, booking management, and more.

## Table of Contents

- [Setup](#setup)
- [Running the Server](#running-the-server)
- [Testing](#testing)
- [API Documentation](#api-documentation)
- [Endpoints](#endpoints)
- [Contributing](#contributing)
- [License](#license)

## Setup

### Ruby Version

Ensure you have Ruby installed. This project uses Ruby version `3.2.2`. You can use a version manager like `rvm` or `rbenv` to install and manage Ruby versions.

### System Dependencies

- Ruby `3.2.2`
- Rails `7.1.4.2`
- PostgreSQL (or your preferred database)

### Configuration

1. **Clone the repository**:
   ```sh
   git clone https://github.com/yourusername/roost-api.git
   cd roost-api
   ```
2. Install Bundler and project dependencies:

   ```sh
   gem install bundler
   bundle install
   ```

3. Database Creation

- Create the database:
  ```sh
  rails db:create
  ```
- Run the migrations:

  ```sh
  rails db:migrate
  ```

  - Seed the database (optional):
    ```sh
    rails db:seed
    ```

4. Running the Server
   To start the Rails server, run:

```sh
rails s
```

The server will be available at [http://localhost:3000](http://localhost:3000).

5. Testing
   To run the tests, use:

```sh
rspec
```

6. API Documentation
   The API documentation is generated using Swagger. To view the API docs, start the Rails server and navigate to:
   [http://localhost:3000/api-docs](http://localhost:3000/api-docs)

7. Endpoints

- Authentication
  - POST /api/v1/auth/login: Login a user.
  - POST /api/v1/auth/register: Register a new user.
- Users

  - GET /api/v1/users: List all users.
  - GET /api/v1/users/:id: Show a specific user.
  - POST /api/v1/users: Create a new user.
  - PATCH/PUT /api/v1/users/:id: Update a user.
  - DELETE /api/v1/users/:id: Delete a user.

- Spaces

  - GET /api/v1/spaces: List all spaces.
  - GET /api/v1/spaces/:id: Show a specific space.
  - POST /api/v1/spaces: Create a new space.
  - PATCH/PUT /api/v1/spaces/:id: Update a space.
  - DELETE /api/v1/spaces/:id: Delete a space.
  - POST /api/v1/spaces/:id/update_occupancy: Update the occupancy of a space.

- Favorite Spaces

  - GET /api/v1/favorite_spaces: List all favorite spaces.
  - POST /api/v1/favorite_spaces: Create a new favorite space.
  - DELETE /api/v1/favorite_spaces/:id: Delete a favorite space.

8. Contributing
   If you would like to contribute to this project, please fork the repository and submit a pull request.

9. License
   This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
