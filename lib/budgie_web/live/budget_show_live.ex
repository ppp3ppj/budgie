defmodule BudgieWeb.BudgetShowLive do
  use BudgieWeb, :live_view

  alias Budgie.Tracking

  @impl true
  def mount(%{"budget_id" => id}, _session, socket) when is_uuid(id) do
    budget =
      Tracking.get_budget(id,
        user: socket.assigns.current_user,
        preload: :creator
      )

    if budget do
      {:ok, assign(socket, budget: budget)}
    else
      socket =
        socket
        |> put_flash(:error, "Budget not found")
        |> redirect(to: ~p"/budgets")

      {:ok, socket}
    end
  end

  def mount(_invalid_id, _session, socket) do
    socket =
      socket
      |> put_flash(:error, "Budgie not found")
      |> redirect(to: ~p"/budgets")

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.modal
      :if={@live_action == :new_transaction}
      id="create-transaction-modal"
      on_cancel={JS.navigate(~p"/budgets/#{@budget}", replace: true)}
      show
    >
      <.live_component
        module={BudgieWeb.CreateTransactionDialog}
        id="create-transaction"
        budget={@budget}
      />
    </.modal>

    <div class="flex justify-between items-center">
      <div>{@budget.name} by {@budget.creator.name}</div>
      <.link
        navigate={~p"/budgets/#{@budget}/new-transaction"}
        class="bg-blue-100 text-blue-800 hover:bg-blue-200 px-3 py-2 rounded-lg inline-flex items-center gap-2"
      >
        <.icon name="hero-plus" class="h-5 w-5" />
        <span>New Transaction</span>
      </.link>
    </div>
    """
  end
end
