defmodule Budgie.TrackingTest do
  alias Budgie.Tracking.Budget
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
          start_date: ~D[2025-12-01],
          end_date: ~D[2025-01-31]
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

  describe "budget transactions" do
    alias Budgie.Tracking.BudgetTransaction

    @invalid_attrs %{description: nil, effective_date: nil, amount: nil, creator_id: nil}

    test "list_transaction/1 returns all transactions in the budget, by id" do
      budget = insert(:budget)

      transactions = insert_pair(:budget_transaction, budget: budget)
      _other_transactions = insert_pair(:budget_transaction)

      assert Tracking.list_transactions(budget.id) == without_preloads(transactions)
    end

    test "list_transaction/1 return all transactions in the budget, by reference" do
      budget = insert(:budget)

      transactions = insert_pair(:budget_transaction, budget: budget)
      _other_transactions = insert_pair(:budget_transaction)

      assert Tracking.list_transactions(budget) == without_preloads(transactions)
    end

    test "list_transactions/2 returns transactions with preloads" do
      budget = insert(:budget)

      transactions = insert_pair(:budget_transaction, budget: budget)

      assert Tracking.list_transactions(budget, preload: [budget: :creator]) == transactions
    end

    test "list_transaction/2 returns sorted transactions" do
      budget = insert(:budget)

      late_transaction =
        insert(:budget_transaction, budget: budget, effective_date: ~D[2025-12-31])

      early_transaction =
        insert(:budget_transaction, budget: budget, effective_date: ~D[2025-01-01])

      mid_transaction =
        insert(:budget_transaction, budget: budget, effective_date: ~D[2025-06-15])

      expected_transactions =
        [
          late_transaction,
          mid_transaction,
          early_transaction
        ]
        |> without_preloads()

      assert Tracking.list_transactions(budget, order_by: [desc: :effective_date]) ==
               expected_transactions
    end

    test "create_transaction/1 with valid data creates a transaction" do
      budget = insert(:budget)

      valid_params = params_with_assocs(:budget_transaction, budget: budget)

      assert {:ok, %BudgetTransaction{} = transaction} = Tracking.create_transaction(valid_params)

      assert transaction.type == valid_params.type
      assert transaction.description == valid_params.description
      assert transaction.effective_date == valid_params.effective_date
      assert transaction.amount == valid_params.amount
      assert transaction.budget_id == budget.id
    end

    test "change_transaction/1 with invalid data returns an valid changeset" do
      assert %Ecto.Changeset{valid?: false} =
               Tracking.change_transaction(%BudgetTransaction{}, @invalid_attrs)
    end

    test "change_transaction/1 with negative amount returns an error" do
      params =
        params_with_assocs(:budget_transaction)
        |> Map.put(:amount, Decimal.new("-1"))

      assert %Ecto.Changeset{valid?: false} =
               Tracking.change_transaction(%BudgetTransaction{}, params)
    end

    test "change_transaction/1 with HUGE amount returns an error" do
      params =
        params_with_assocs(:budget_transaction)
        |> Map.put(:amount, Decimal.new("9999999"))

      assert %Ecto.Changeset{valid?: false} =
               Tracking.change_transaction(%BudgetTransaction{}, params)
    end

    test "summarize_budget_transactions/1 doesn't fail without transactions" do
      budget = insert(:budget)

      assert Tracking.summarize_budget_transaction(budget) == %{}
    end

    test "returns a summary with funding and spending" do
      budget = insert(:budget)

      spending_transactions = [
        insert(:budget_transaction, budget: budget, type: :spending, amount: Decimal.new("2")),
        insert(:budget_transaction, budget: budget, type: :spending, amount: Decimal.new("3"))
      ]

      funding_transactions = [
        insert(:budget_transaction, budget: budget, type: :funding, amount: Decimal.new("5")),
        insert(:budget_transaction, budget: budget, type: :funding, amount: Decimal.new("7"))
      ]

      assert Tracking.summarize_budget_transaction(budget.id) == %{
               spending:
                 Enum.reduce(spending_transactions, Decimal.new("0"), &Decimal.add(&1.amount, &2)),
               funding:
                 Enum.reduce(funding_transactions, Decimal.new("0"), &Decimal.add(&1.amount, &2))
             }
    end
  end
end
