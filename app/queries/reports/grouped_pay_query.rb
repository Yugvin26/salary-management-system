# frozen_string_literal: true

module Reports
  class GroupedPayQuery
    GROUPS = {
      department: { sql: "departments.name", key: :department },
      job_title: { sql: "users.job_title", key: :job_title },
      country: { sql: "locations.country", key: :country }
    }.freeze

    def initialize(group, company_id: nil)
      @group = GROUPS.fetch(group)
      @company_id = company_id
    end

    def call
      rows.map do |name, currency, total, average, headcount|
        {
          @group[:key] => name,
          currency: currency,
          headcount: headcount,
          **Salary.money_fields(total, currency, :total),
          **Salary.money_fields(average, currency, :average)
        }
      end
    end

    private

    def rows
      Salary.current_base.joins(employee: %i[department location])
            .where(users: { active: true, role: User.roles[:employee] })
            .then { |scope| @company_id ? scope.where(users: { company_id: @company_id }) : scope }
            .group(Arel.sql(@group[:sql]), "salaries.currency")
            .order(Arel.sql(@group[:sql]), "salaries.currency")
            .pluck(
              Arel.sql(@group[:sql]),
              Arel.sql("salaries.currency"),
              Arel.sql("SUM(salaries.amount_cents)"),
              Arel.sql("AVG(salaries.amount_cents)"),
              Arel.sql("COUNT(DISTINCT users.id)")
            )
    end
  end
end
