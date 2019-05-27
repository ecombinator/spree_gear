module Spree
  module Admin
    class MailingsController < ResourceController
      before_action :set_mailing, only: [:show, :edit, :update, :destroy, :send]

      # GET /mailings
      # GET /mailings.json
      def index
        @mailings = Spree::Mailing.where(archived: false).order("created_at DESC")
      end

      # GET /mailings/1
      # GET /mailings/1.json
      def show
      end

      # GET /mailings/new
      def new
        @mailing = Spree::Mailing.new
        @mailing.from = Rails.application.config.default_mailing_list_email || Rails.application.config.contact_notification_email
      end

      # GET /mailings/1/edit
      def edit; end

      # GET /mailings/1/send
      def prepare; end

      # POST /mailings
      # POST /mailings.json
      def create
        @mailing = Spree::Mailing.new(mailing_params)

        respond_to do |format|
          if @mailing.save
            format.html { redirect_to admin_mailings_url, notice: 'Mailing was successfully created.' }
            format.json { render :show, status: :created, location: @mailing }
          else
            format.html { render :new }
            format.json { render json: @mailing.errors, status: :unprocessable_entity }
          end
        end
      end

      # PATCH/PUT /mailings/1
      # PATCH/PUT /mailings/1.json
      def update
        respond_to do |format|
          if @mailing.update(mailing_params)
            notice = @mailing.deliver_now ? "Mailing was sent!" : "Mailing was successfully updated."
            format.html { redirect_to admin_mailings_url, notice: notice }
            format.json { render :show, status: :ok, location: @mailing }
          else
            format.html { render params[:mailing].has_key?(:csv) ? :prepare : :edit }
            format.json { render json: @mailing.errors, status: :unprocessable_entity }
          end
        end
      end

      # DELETE /mailings/1
      # DELETE /mailings/1.json
      def destroy
        @mailing.destroy
        respond_to do |format|
          format.html { redirect_to admin_mailings_url, notice: 'Mailing was successfully destroyed.' }
          format.json { head :no_content }
        end
      end

      private
      # Use callbacks to share common setup or constraints between actions.
      def set_mailing
        @mailing = Spree::Mailing.find(params[:id])
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def mailing_params
        params.require(:mailing).permit(:name, :from, :subject, :csv, :archived, :deliver_now, :deliver_to_users, :deliver_to_non_users)
      end
    end
  end
end

