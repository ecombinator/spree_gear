# frozen_string_literal: true

module Spree
  module Admin
    class SlidesController < ResourceController
      def destroy
        @slide = Spree::Slide.find(params[:id])
        @slide_title = @slide.title
        respond_to do |format|
          format.js {}
        end
      end
    end
  end
end
