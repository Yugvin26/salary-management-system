# frozen_string_literal: true

module Api
  module SiteAdmin
    class CompaniesController < BaseController
      def index
        authorize Company
        pagy, companies = pagy(policy_scope(Company).includes(:setting, :admins).order(:name))
        render_data companies.map { |company| company_payload(company) }, meta: pagination_meta(pagy)
      end

      def create
        authorize Company
        company = Company.new(name: company_params[:name])
        Company.transaction do
          company.save!
          company.users.create!(admin_attributes)
        end
        render_data company_payload(company.reload), status: :created
      rescue ActiveRecord::RecordInvalid => e
        render_errors(e.record)
      end

      def update
        company = authorized_company
        Company.transaction do
          company.update!(name: company_params[:name]) if company_params[:name].present?
          update_admin(company) if admin_params_present?
        end
        render_data company_payload(company.reload)
      rescue ActiveRecord::RecordInvalid => e
        render_errors(e.record)
      end

      def destroy
        company = authorized_company
        company.destroy!
        render_data({ id: company.id, deleted: true })
      end

      private

      def authorized_company
        policy_scope(Company).find(params[:id]).tap { |company| authorize company }
      end

      def company_params
        params.require(:company).permit(:name, :admin_email, :admin_password, :admin_first_name, :admin_last_name)
      end

      def admin_params_present?
        %i[admin_email admin_password admin_first_name admin_last_name].any? { |key| company_params[key].present? }
      end

      def admin_attributes
        {
          email: company_params[:admin_email],
          password: company_params[:admin_password],
          password_confirmation: company_params[:admin_password],
          first_name: company_params[:admin_first_name],
          last_name: company_params[:admin_last_name],
          role: :company_admin,
          active: true
        }
      end

      def update_admin(company)
        admin = company.admins.order(:id).first || company.users.build(role: :company_admin, active: true)
        assign_admin_profile(admin)
        assign_admin_password(admin)
        admin.save!
      end

      def assign_admin_profile(admin)
        admin.email = company_params[:admin_email] if company_params[:admin_email].present?
        admin.first_name = company_params[:admin_first_name] if company_params[:admin_first_name].present?
        admin.last_name = company_params[:admin_last_name] if company_params[:admin_last_name].present?
      end

      def assign_admin_password(admin)
        return if company_params[:admin_password].blank?

        admin.password = company_params[:admin_password]
        admin.password_confirmation = company_params[:admin_password]
      end

      def company_payload(company)
        admin = company.admins.order(:id).first
        {
          id: company.id,
          name: company.name,
          setting: company.setting && {
            primary_color: company.setting.primary_color,
            accent_color: company.setting.accent_color,
            background_color: company.setting.background_color
          },
          admin: admin && { id: admin.id, email: admin.email, name: admin.name, active: admin.active }
        }
      end
    end
  end
end
