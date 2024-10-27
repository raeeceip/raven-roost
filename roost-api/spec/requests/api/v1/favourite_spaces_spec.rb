require 'swagger_helper'

RSpec.describe 'api/v1/favorite_spaces', type: :request do
  path '/api/v1/favorite_spaces' do
    get('list favorite spaces') do
      tags 'FavoriteSpaces'
      produces 'application/json'

      response(200, 'successful') do
        run_test!
      end
    end

    post('create favorite space') do
      tags 'FavoriteSpaces'
      consumes 'application/json'
      parameter name: :favorite_space, in: :body, schema: {
        type: :object,
        properties: {
          space_id: { type: :integer }
        },
        required: %w[space_id]
      }

      response(201, 'created') do
        let(:favorite_space) { { space_id: 1 } }
        run_test!
      end
    end
  end

  path '/api/v1/favorite_spaces/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    delete('delete favorite space') do
      tags 'FavoriteSpaces'
      response(204, 'no content') do
        let(:id) { '1' }
        run_test!
      end
    end
  end
end