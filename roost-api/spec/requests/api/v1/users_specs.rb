require 'swagger_helper'

RSpec.describe 'api/v1/users', type: :request do
  path '/api/v1/users' do
    get('list users') do
      tags 'Users'
      produces 'application/json'

      response(200, 'successful') do
        run_test!
      end
    end

    post('create user') do
      tags 'Users'
      consumes 'application/json'
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          email: { type: :string },
          password: { type: :string }
        },
        required: %w[name email password]
      }

      response(201, 'created') do
        let(:user) { { name: 'John Doe', email: 'john@example.com', password: 'password' } }
        run_test!
      end
    end
  end

  path '/api/v1/users/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show user') do
      tags 'Users'
      produces 'application/json'

      response(200, 'successful') do
        let(:id) { '1' }
        run_test!
      end
    end

    patch('update user') do
      tags 'Users'
      consumes 'application/json'
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          email: { type: :string }
        }
      }

      response(200, 'successful') do
        let(:id) { '1' }
        let(:user) { { name: 'Jane Doe' } }
        run_test!
      end
    end

    delete('delete user') do
      tags 'Users'
      response(204, 'no content') do
        let(:id) { '1' }
        run_test!
      end
    end
  end
end