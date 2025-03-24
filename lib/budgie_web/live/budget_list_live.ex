defmodule BudgieWeb.BudgetListLive do
  alias Budgie.Tracking
  use BudgieWeb, :live_view

  def mount(_params, _session, socket) do
    budgets = Tracking.list_budgets()
      |> Budgie.Repo.preload(:creator)

    socket = assign(socket, budgets: budgets)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.table id="budgets" rows={@budgets}>
      <:col :let={budget} label="Name">{budget.name}</:col>
      <:col :let={budget} label="Description">{budget.description}</:col>
      <:col :let={budget} label="Start Date">{budget.start_date}</:col>
      <:col :let={budget} label="End date">{budget.end_date}</:col>
      <:col :let={budget} label="Creator ID">{budget.creator.name}</:col>
    </.table>
    """
  end
end
