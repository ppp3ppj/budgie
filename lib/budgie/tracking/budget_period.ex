defmodule Budgie.Tracking.BudgetPeriod do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "budget_periods" do
    field :start_date, :date
    field :end_date, :date
    field :budget_id, :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(budget_period, attrs) do
    budget_period
    |> cast(attrs, [:start_date, :end_date])
    |> validate_required([:start_date, :end_date])
  end
end
