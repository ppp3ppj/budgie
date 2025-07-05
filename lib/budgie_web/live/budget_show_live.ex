defmodule BudgieWeb.BudgetShowLive do
  use BudgieWeb, :live_view

  alias Budgie.Tracking
  alias Budgie.Tracking.BudgetTransaction

  def handle_event("delete_transaction", %{"id" => transaction_id}, socket) do
    transaction = Enum.find(socket.assigns.transactions, &(&1.id == transaction_id))

    if transaction do
      case Tracking.delete_transaction(transaction) do
        {:ok, _} ->
          socket =
            socket
            |> put_flash(:info, "Transaction deleted")
            |> redirect(to: ~p"/budgets/#{socket.assigns.budget.id}", replace: true)

          {:noreply, socket}

        {:error, _} ->
          {:noreply, put_flash(socket, :error, "Failed to delete transaction")}
      end
    else
      {:noreply, put_flash(socket, :error, "Transaction not found")}
    end
  end

  @impl true
  def mount(%{"budget_id" => id} = params, _session, socket) when is_uuid(id) do
    budget =
      Tracking.get_budget(id,
        user: socket.assigns.current_user,
        preload: [:creator, :periods]
      )

    if budget do
      transactions =
        Tracking.list_transactions(budget)

      summary = Tracking.summarize_budget_transaction(budget)

      {:ok,
       assign(socket, budget: budget, transactions: transactions, summary: summary)
       |> apply_action(params)}
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

  def apply_action(%{assigns: %{live_action: :edit_transaction}} = socket, %{
        "transaction_id" => transaction_id
      }) do
    transaction = Enum.find(socket.assigns.transactions, &(&1.id == transaction_id))

    if transaction do
      assign(socket, transaction: transaction)
    else
      socket
      |> put_flash(:error, "Transaction not found")
      |> redirect(to: ~p"/budgets/#{socket.assigns.budget}")
    end
  end

  def apply_action(socket, _), do: socket

  defp default_transaction do
    %BudgetTransaction{
      effective_date: Date.utc_today()
    }
  end

  @doc """
  Renders a transaction amount as a currency value, considering the type of the transaction.
  ## Example
  <.transaction_amount transaction={%BudgetTransaction{type: :spending, amount: Decimal.new("24.05")}} />
  Output:
  <span class="tabular-nums text-red-500">-24.05</span>
  """

  attr :transaction, BudgetTransaction, required: true

  def transaction_amount(%{transaction: %{type: :spending, amount: amount}}),
    do: currency(%{amount: Decimal.negate(amount)})

  def transaction_amount(%{transaction: %{type: :funding, amount: amount}}),
    do: currency(%{amount: amount})

end
