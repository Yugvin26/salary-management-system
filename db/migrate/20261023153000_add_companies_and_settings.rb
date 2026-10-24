# frozen_string_literal: true

class AddCompaniesAndSettings < ActiveRecord::Migration[8.0]
  def up
    create_table :companies do |t|
      t.string :name, null: false
      t.timestamps
    end
    add_index :companies, "lower((name)::text)", unique: true, name: "index_companies_on_lower_name"

    create_table :company_settings do |t|
      t.references :company, null: false, foreign_key: true, index: { unique: true }
      t.string :primary_color, null: false, default: "#0f3d4c"
      t.string :accent_color, null: false, default: "#b8612d"
      t.string :background_color, null: false, default: "#f4f1ea"
      t.timestamps
    end

    add_reference :users, :company, foreign_key: true
    add_reference :departments, :company, foreign_key: true
    add_reference :locations, :company, foreign_key: true

    company_id = insert_company("ACME")
    insert_default_company_settings(company_id)
    execute "UPDATE users SET company_id = #{company_id}"
    execute "UPDATE departments SET company_id = #{company_id}"
    execute "UPDATE locations SET company_id = #{company_id}"

    change_column_null :departments, :company_id, false
    change_column_null :locations, :company_id, false

    remove_index :users, name: "index_users_on_lower_email"
    remove_index :users, name: "index_users_on_employee_id"
    remove_index :departments, name: "index_departments_on_lower_name"

    add_index :users, "lower((email)::text), company_id", unique: true, where: "company_id IS NOT NULL", name: "index_users_on_company_and_lower_email"
    add_index :users, "lower((email)::text)", unique: true, where: "company_id IS NULL", name: "index_super_admins_on_lower_email"
    add_index :users, %i[company_id employee_id], unique: true, where: "employee_id IS NOT NULL", name: "index_users_on_company_and_employee_id"
    add_index :departments, "company_id, lower((name)::text)", unique: true, name: "index_departments_on_company_and_lower_name"

    User.reset_column_information
    Company.reset_column_information
    company = Company.find_by!(name: "ACME")
    create_login("superadmin@acme.local", "Super", "Admin", :super_admin, nil)
    create_login("admin@acme.local", "Company", "Admin", :company_admin, company)
  end

  def down
    remove_reference :locations, :company, foreign_key: true
    remove_reference :departments, :company, foreign_key: true
    remove_reference :users, :company, foreign_key: true
    drop_table :company_settings
    drop_table :companies

    add_index :users, "lower((email)::text)", unique: true, name: "index_users_on_lower_email"
    add_index :users, :employee_id, unique: true, where: "employee_id IS NOT NULL", name: "index_users_on_employee_id"
    add_index :departments, "lower((name)::text)", unique: true, name: "index_departments_on_lower_name"
  end

  private

  def create_login(email, first_name, last_name, role, company)
    return if User.exists?(email: email)

    User.create!(
      email: email,
      password: "password",
      password_confirmation: "password",
      first_name: first_name,
      last_name: last_name,
      role: role,
      company: company,
      active: true
    )
  end

  def insert_company(name)
    now = connection.quote(Time.current)
    connection.select_value(<<~SQL.squish)
      INSERT INTO companies (name, created_at, updated_at)
      VALUES (#{connection.quote(name)}, #{now}, #{now})
      RETURNING id
    SQL
  end

  def insert_default_company_settings(company_id)
    execute <<~SQL.squish
      INSERT INTO company_settings
        (company_id, primary_color, accent_color, background_color, created_at, updated_at)
      VALUES (#{company_id}, '#0f3d4c', '#b8612d', '#f4f1ea', NOW(), NOW())
    SQL
  end
end
