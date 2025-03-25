defmodule BudgieWeb.Live.BudgetListLiveTest do
  use BudgieWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Budgie.TrackingFixtures

  setup do
    user = Budgie.AccountsFixtures.user_fixture()

    %{user: user}
  end

  describe "Index view" do
    test "show budget when one exists", %{conn: conn, user: user} do
      budget = budget_fixture(%{creator_id: user.id})

      conn = log_in_user(conn, user)
      {:ok, _lv, html} = live(conn, ~p"/budgets")

      # open_browser(lv) # open the browser here --

      assert html =~ budget.name
      assert html =~ budget.description
    end
  end

  describe "Create budget model" do
    test "message", %{conn: conn, user: user} do
      conn = log_in_user(conn, user)
      {:ok, lv, _html} = live(conn, ~p"/budgets/new")

      assert has_element?(lv, "#create-budget-modal")
    end

    test "validation errors are presented when form is changed with invalid input", %{
      conn: conn,
      user: user
    } do
      conn = log_in_user(conn, user)
      {:ok, lv, _html} = live(conn, ~p"/budgets/new")

      form = element(lv, "#create-budget-modal form")

      html =
        render_change(form, %{
          "budget" => %{"name" => ""}
        })

      assert html =~ html_escape("can't be blank")
    end
  end
end
