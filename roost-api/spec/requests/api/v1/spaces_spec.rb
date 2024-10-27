require 'swagger_helper'

RSpec.describe 'api/v1/spaces', type: :request do
  path '/api/v1/spaces' do
    get('list spaces') do
      tags 'Spaces'
      produces 'application/json'

      response(200, 'successful') do
        run_test!
      end
    end

    post('create space') do
      tags 'Spaces'
      consumes 'application/json'
      parameter name: :space, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          building: { type: :string },
          capacity: { type: :integer }
        },
        required: %w[name building capacity]
      }

      response(201, 'created') do
        let(:space) { { name: 'Conference Room', building: 'Main Building', capacity: 50 } }
        run_test!
      end
    end
  end

  path '/api/v1/spaces/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show space') do
      tags 'Spaces'
      produces 'application/json'

      response(200, 'successful') do
        let(:id) { '1' }
        run_test!
      end
    end

    patch('update space') do
      tags 'Spaces'
      consumes 'application/json'
      parameter name: :space, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          building: { type: :string },
          capacity: { type: :integer }
        }
      }

      response(200, 'successful') do
        let(:id) { '1' }
        let(:space) { { name: 'Updated Room' } }
        run_test!
      end
    end

    delete('delete space') do
      tags 'Spaces'
      response(204, 'no content') do
        let(:id) { '1' }
        run_test!
      end
    end
  end

  path '/api/v1/spaces/{id}/update_occupancy' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    post('update occupancy') do
      tags 'Spaces'
      consumes 'application/json'
      parameter name: :occupancy, in: :body, schema: {
        type: :object,
        properties: {
          occupancy: { type: :integer }
        },
        required: %w[occupancy]
      }

      response(200, 'successful') do
        let(:id) { '1' }
        let(:occupancy) { { occupancy: 30 } }
        run_test!
      end
    end
  end
end