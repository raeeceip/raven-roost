class PagesController < ApplicationController
  include Astro

  def home
    @featured_spaces = StudySpace.where(status: 'available')
      .limit(3)
      .includes(:building)
    
    @props = {
      featured_spaces: @featured_spaces.as_json(
        include: { building: { only: [:id, :name, :code] } }
      ),
      message: "Welcome to Roost!"
    }

    response.headers['X-Astro-View'] = 'pages/home'
    respond_to do |format|
      format.html
      format.json { render json: @props }
    end
  end

  def handle_astro_request
    # Extract the view path from the request path
    view_path = request.path.sub(/^\//, '')  # Remove leading slash
    
    # Map the path to the corresponding action
    action = case view_path
      when '', 'home' then :home
      when 'search' then :search
      when 'map' then :map
      when 'about' then :about
      else :not_found
    end

    # Call the appropriate action
    if action != :not_found && respond_to?(action, true)
      send(action)
    else
      render json: { error: 'Not Found' }, status: :not_found
    end
  end

  private

  def search
    response.headers['X-Astro-View'] = 'pages/search'
    @props = {
      title: "Search Study Spaces"
    }
    render json: @props
  end

  def map
    response.headers['X-Astro-View'] = 'pages/map'
    @props = {
      title: "Campus Map"
    }
    render json: @props
  end

  def about
    response.headers['X-Astro-View'] = 'pages/about'
    @props = {
      title: "About Roost"
    }
    render json: @props
  end
end