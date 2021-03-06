class SpheresController < ApplicationController
  before_action :authenticate_user!

  rescue_from(ActionController::ParameterMissing) do |exception|
    render json: { message: "#{exception.param} is required" }, status: :unprocessable_entity
  end

  def create
    memory = current_user.memories.find_by(id: params[:memory_id])

    if memory.blank?
      render_not_found
      return
    end

    sphere = memory.spheres.build
    sphere.caption = sanitize(create_params[:caption])
    sphere.panorama = create_params[:panorama]

    guid = SecureRandom.hex
    sphere.guid = guid

    if sphere.valid?
      render json: { guid: guid }, status: :accepted
      sphere.save!
    else
      render_model_errors(sphere)
    end
  end

  def show
    sphere = current_user.spheres.find_by(guid: params[:id])

    if sphere.blank?
      render_not_found
      return
    end

    if sphere.processing?
      render json: { guid: sphere.guid }, status: :accepted
      return
    end

    render json: sphere.to_builder.target!, status: :created
  end

  def destroy
    sphere = current_user.spheres.find_by(id: params[:id])

    if sphere.blank?
      render_not_found
      return
    end

    if sphere.destroy
      render json: sphere.to_builder.target!, status: :ok
    else
      render json: sphere.errors, status: :not_found
    end
  end

  def zoom
    sphere = current_user.spheres.find_by(id: params[:id])

    if sphere.blank?
      render_not_found
      return
    end

    sphere.default_zoom = params[:default_zoom]

    if sphere.save
      render json: sphere.to_builder.target!, status: :created
    else
      render_model_errors(sphere)
    end
  end

  private

  def create_params
    params.require(:sphere).permit(:caption, :panorama)
  end
end
