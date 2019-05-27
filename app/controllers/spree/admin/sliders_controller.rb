# frozen_string_literal: true

module Spree
  module Admin
    class SlidersController < ResourceController
      before_action :set_slider, only: [:edit, :update, :destroy, :activate, :deactivate]
      before_action :set_slider_params, only: [:create]

      def index
        @new_slider = Spree::Slider.new
        @sliders = Spree::Slider.all
      end

      def create
        if @slider.save
          flash_and_redirect(:info, "Successfully saved!")
        else
          flash_and_redirect(:danger, "There were errors")
        end
      end

      def update
        if @slider.update_attributes(slider_params)
          redirect_to edit_admin_slider_path(@slider)
        else
          render "edit"
        end
      end

      def edit; end

      def destroy
        @slider.destroy
        respond_to do |format|
          format.html do
            flash_and_redirect(:info, "Destroyed slider")
          end
          format.js {}
        end
      end

      def activate
        @slider.activate
        respond_to do |format|
          format.html do
            redirect_to admin_sliders_path
          end
          format.js {}
        end
      end

      def deactivate
        @slider.deactivate
        respond_to do |format|
          format.html do
            redirect_to admin_sliders_path
          end
          format.js {}
        end
      end

      private

      def set_slider
        @slider = Spree::Slider.find(params[:id])
      end

      def set_slider_params
        @slider = Spree::Slider.new(slider_params)
      end

      def slider_params
        params.require(:slider).permit(:title, :active, :max_height,
                                       slides_attributes: [ :id, :title, :picture,:activate, :_destroy
                                       ])
      end

      def flash_and_redirect(alert, message)
        flash[alert] = message
        redirect_to(admin_sliders_path) && return
      end
    end
  end
end
