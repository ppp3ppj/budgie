defmodule Budgie.Tracking.Budget do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "budgets" do
    field :name, :string
    field :description, :string
    field :start_date, :date
    field :end_date, :date

    belongs_to :creator, Budgie.Accounts.User

    has_many :periods, Budgie.Tracking.BudgetPeriod

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(budget, attrs) do
    budget
    |> cast(attrs, [:name, :description, :start_date, :end_date, :creator_id])
    |> validate_required([:name, :start_date, :end_date, :creator_id])
    |> validate_length(:name, max: 100)
    |> validate_length(:description, max: 150)
    |> check_constraint(:end_date,
      name: :budget_end_after_start,
      message: "must end after start date"
    )
    |> unique_constraint([:buget_id, :start_date])
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

