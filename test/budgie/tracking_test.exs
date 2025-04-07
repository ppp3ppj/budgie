defmodule Budgie.TrackingTest do
  use Budgie.DataCase
  alias Budgie.Tracking

  describe "budgets" do
    alias Budgie.Tracking.Budget

    test "create_budget/1 with valid data creates budget" do
      attrs = params_with_assocs(:budget)

      assert {:ok, %Budget{} = budget} = Tracking.create_budget(attrs)
      assert budget.name == attrs.name
      assert budget.description == attrs.description
      assert budget.start_date == attrs.start_date
      assert budget.end_date == attrs.end_date
      assert budget.creator_id == attrs.creator_id
    end

    test "create_budget/1 with requires name" do
      attrs =
        params_with_assocs(:budget)
        |> Map.delete(:name)

      assert {:error, %Ecto.Changeset{} = changeset} = Tracking.create_budget(attrs)

      assert changeset.valid? == false
      assert %{name: ["can't be blank"]} = errors_on(changeset)
    end

    test "create_budget/1 requires name" do
      attrs =
        params_with_assocs(:budget)
        |> Map.delete(:name)
      assert {:error, %Ecto.Changeset{} = changeset} = Tracking.create_budget(attrs)

      assert changeset.valid? == false
      assert %{name: ["can't be blank"]} = errors_on(changeset)
    end

    test "create_budget/1 with requires valid dates" do
      attrs =
        params_with_assocs(:budget,
          start_date: ~D[2025-01-31],
          end_date: ~D[2025-01-01]
        )

      assert {:error, %Ecto.Changeset{} = changeset} = Tracking.create_budget(attrs)
      assert %{end_date: ["must end after start date"]} = errors_on(changeset)

      assert changeset.valid? == false
      # dbg(changeset)
    end

    test "list_budgets/0 returns all budgets" do
      budgets = insert_pair(:budget)

      assert Tracking.list_budgets() == without_preloads(budgets)
    end

    test "list_budget/1 scopes to the provided user" do
      [budget, _other_budget] = insert_pair(:budget)

      assert Tracking.list_budgets(user: budget.creator) == [without_preloads(budget)]
    end

    test "get_budget/1 returns nil when budget doesn't exist" do
      _unrelated_budget = insert(:budget)
      assert is_nil(Tracking.get_budget("74984201-e309-4408-b731-197c6ee5eeb1"))
    end
  end
end
