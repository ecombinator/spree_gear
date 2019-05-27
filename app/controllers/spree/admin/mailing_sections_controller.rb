module Spree
  module Admin
    class MailingSectionsController < ResourceController
      before_action :set_mailing_section, only: [:show, :edit, :update, :destroy]
      before_action :set_mailing, only: [:new, :index, :edit]

      # GET /mailing_sections
      # GET /mailing_sections.json
      def index
        @mailing_sections = MailingSection.where(spree_mailing_id: @mailing.id)
      end

      # GET /mailing_sections/1
      # GET /mailing_sections/1.json
      def show
      end

      # GET /mailing_sections/new
      def new
        @mailing_section = Spree::MailingSection.new
        @mailing_section.spree_mailing_id = @mailing.id
        @mailing_section.url = current_store.url
      end

      # GET /mailing_sections/1/edit
      def edit
      end

      # POST /mailing_sections
      # POST /mailing_sections.json
      def create
        @mailing_section = Spree::MailingSection.new(mailing_section_params)

        respond_to do |format|
          if @mailing_section.save
            format.html { redirect_to admin_mailing_sections_path(spree_mailing_id: @mailing_section.spree_mailing_id), notice: 'Mailing section was successfully created.' }
            format.json { render :show, status: :created, location: @mailing_section }
          else
            format.html { render :new }
            format.json { render json: @mailing_section.errors, status: :unprocessable_entity }
          end
        end
      end

      # PATCH/PUT /mailing_sections/1
      # PATCH/PUT /mailing_sections/1.json
      def update
        respond_to do |format|
          if @mailing_section.update(mailing_section_params)
            format.html { redirect_to admin_mailing_sections_path(spree_mailing_id: @mailing_section.spree_mailing_id), notice: 'Mailing section was successfully updated.' }
            format.json { render :show, status: :ok, location: @mailing_section }
          else
            format.html { render :edit }
            format.json { render json: @mailing_section.errors, status: :unprocessable_entity }
          end
        end
      end

      # DELETE /mailing_sections/1
      # DELETE /mailing_sections/1.json
      def destroy
        mailing_id =  @mailing_section.spree_mailing_id
        @mailing_section.destroy
        respond_to do |format|
          format.html { redirect_to admin_mailing_sections_url(spree_mailing_id: mailing_id), notice: 'Mailing section was successfully destroyed.' }
          format.json { head :no_content }
        end
      end

      private
      # Use callbacks to share common setup or constraints between actions.
      def set_mailing_section
        @mailing_section = Spree::MailingSection.find(params[:id])
      end

      def set_mailing
        if params[:spree_mailing_id].to_s.empty?
          redirect_to(admin_mailings_path)
        else
          @mailing = Spree::Mailing.find(params[:spree_mailing_id])
        end
      end


      # Never trust parameters from the scary internet, only allow the white list through.
      def mailing_section_params
        params.require(:mailing_section).permit(:spree_mailing_id, :url, :image)
      end
    end
  end
end

