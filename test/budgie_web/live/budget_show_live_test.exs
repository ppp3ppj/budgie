defmodule BudgieWeb.Live.BudgetShowLiveTest do
  use BudgieWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  setup do
    budget = insert(:budget)

    %{budget: budget, user: budget.creator}
  end

  describe "Show budget" do
    test "show budget when it exists", %{conn: conn, user: user, budget: budget} do
      conn = log_in_user(conn, user)
      {:ok, _lv, html} = live(conn, ~p"/budgets/#{budget}")

      assert html =~ budget.name
    end

    test "redirects to budget list page when budget does not exit", %{conn: conn, user: user} do
      fake_budget_id = Ecto.UUID.generate()

      conn = log_in_user(conn, user)

      {:ok, conn} =
        live(conn, ~p"/budgets/#{fake_budget_id}")
        |> follow_redirect(conn, ~p"/budgets")

      assert %{"error" => "Budget not found"} = conn.assigns.flash
    end

    test "redirects to budget list page when budget is hidden from the user", %{
      conn: conn,
      budget: budget
    } do
      other_user = Budgie.AccountsFixtures.user_fixture()

      conn = log_in_user(conn, other_user)

      {:ok, conn} =
        live(conn, ~p"/budgets/#{budget}")
        |> follow_redirect(conn, ~p"/budgets")

      assert %{"error" => "Budget not found"} = conn.assigns.flash
    end
  end

  describe "Create transaction modal" do
    test "modal is presented", %{conn: conn, user: user, budget: budget} do
      conn = log_in_user(conn, user)
      {:ok, lv, _html} = live(conn, ~p"/budgets/#{budget}/new-transaction")

      assert has_element?(lv, "#create-transaction-modal")
    end
 test "creates a transaction", %{
      conn: conn,
      user: user,
      budget: budget
    } do
      conn = log_in_user(conn, user)
      {:ok, lv, _html} = live(conn, ~p"/budgets/#{budget}/new-transaction")

      params = params_for(:budget_transaction)

      form =
        form(lv, "#create-transaction-modal form", %{
          "transaction" => params
        })

      {:ok, _lv, html} =
        render_submit(form)
        |> follow_redirect(conn)

      assert html =~ "Transaction created"
      assert html =~ params.description
    end

    test "validation errors are presented when form is changed with invalid input", %{
      conn: conn,
      user: user,
      budget: budget
    } do
      conn = log_in_user(conn, user)
      {:ok, lv, _html} = live(conn, ~p"/budgets/#{budget}/new-transaction")

      params = params_for(:budget_transaction, amount: Decimal.new("-42"))

      form =
        form(lv, "#create-transaction-modal form", %{
          "transaction" => params
        })

      html = render_change(form)

      assert html =~ "must be greater than 0"
    end

    test "validation errors are presented when form is submitted with invalid input", %{
      conn: conn,
      user: user,
      budget: budget
    } do
      conn = log_in_user(conn, user)
      {:ok, lv, _html} = live(conn, ~p"/budgets/#{budget}/new-transaction")

      params = params_for(:budget_transaction, amount: Decimal.new("-42"))

      form =
        form(lv, "#create-transaction-modal form", %{
          "transaction" => params
        })

      html = render_submit(form)

      assert html =~ "must be greater than 0"
    end


  end
end
