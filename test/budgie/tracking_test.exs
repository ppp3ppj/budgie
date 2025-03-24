defmodule Budgie.TrackingTest do
  use Budgie.DataCase
  alias Budgie.Tracking

  import Budgie.TrackingFixtures

  describe "budgets" do
    alias Budgie.Tracking.Budget

    test "create_budget/2 with valid data creates budget" do
      user = Budgie.AccountsFixtures.user_fixture()

      valid_attrs = valid_budget_attributes(%{creator_id: user.id})

      assert {:ok, %Budget{} = budget} = Tracking.create_budget(valid_attrs)
      assert budget.name == "some name"
      assert budget.description == "some description"
      assert budget.start_date == ~D[2025-01-01]
      assert budget.end_date == ~D[2025-01-31]
      assert budget.creator_id == user.id
    end

    test "create_budget/2 with requires name" do
      attrs =
        valid_budget_attributes()
        |> Map.delete(:name)

      assert {:error, %Ecto.Changeset{} = changeset} = Tracking.create_budget(attrs)

      assert changeset.valid? == false
      assert %{name: ["can't be blank"]} = errors_on(changeset)
    end

    test "create_budget/2 with requires valid dates" do
      attrs =
        valid_budget_attributes()
        |> Map.merge(%{
          start_date: ~D[2025-01-31],
          end_date: ~D[2025-01-01]
        })

      assert {:error, %Ecto.Changeset{} = changeset} = Tracking.create_budget(attrs)
      assert %{end_date: ["must end after start date"]} = errors_on(changeset)

      assert changeset.valid? == false
      # dbg(changeset)
    end
  end
end
