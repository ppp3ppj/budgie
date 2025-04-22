defmodule Budgie.Tracking.BudgetPeriod do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "budget_periods" do
    field :start_date, :date
    field :end_date, :date
    belongs_to :budget, Budgie.Tracking.Budget

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(budget_period, attrs) do
    budget_period
    |> cast(attrs, [:start_date, :end_date, :budget_id])
    |> validate_required([:start_date, :end_date, :budget_id])
    |> check_constraint(:end_date,
      name: :end_after_start,
      message: "must end after start date"
    )
    |> unique_constraint([:budget_id, :start_date])
    |> validate_date_month_boundaries()
  end

  def validate_date_month_boundaries(%Ecto.Changeset{valid?: false} = cs), do: cs

  def validate_date_month_boundaries(%Ecto.Changeset{} = cs) do
    start_date = get_field(cs, :start_date)
    end_date = get_field(cs, :end_date)

    cs =
      if start_date != Date.beginning_of_month(start_date) do
        add_error(cs, :start_date, "must be the beginning of a month")
      else
        cs
      end

    if end_date != Date.end_of_month(end_date) do
      add_error(cs, :end_date, "must be the end of a month")
    else
      cs
    end
  end
end
