defmodule DemoWeb.DemoLive.Sortable do
  use DemoWeb, :live_view

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Customers
        <:subtitle>
          Drag to sort rows. Current order: {Enum.map_join(@customers, ", ", & &1.name)}.
        </:subtitle>
      </.header>

      <.table
        id="table"
        rows={@customers}
        row_id={&"customer_#{&1.id}"}
        sortable
        sortable_item_id={& &1.id}
        sortable_on_end="sort"
      >
        <:col :let={customer} label="ID">
          {customer.id}
        </:col>
        <:col :let={customer} label="Customer">
          {customer.name}
        </:col>
        <:col :let={customer} label="Latest message">
          {customer.message}
        </:col>
      </.table>
    </Layouts.app>
    """
  end

  def mount(_params, _session, socket) do
    customers = [
      %{id: 1, name: "Adam", message: "Lorem ipsum doler sid ept dracun"},
      %{id: 2, name: "Betty", message: "Lorem ipsum doler sid ept dracun"},
      %{id: 3, name: "Charlie", message: "Lorem ipsum doler sid ept dracun"},
      %{id: 4, name: "Diane", message: "Lorem ipsum doler sid ept dracun"},
      %{id: 5, name: "Ethan", message: "Lorem ipsum doler sid ept dracun"}
    ]

    {:ok, assign(socket, :customers, customers)}
  end

  def handle_event("sort", %{"item_id" => id} = params, socket) do
    id = String.to_integer(id)
    prev_id = if p = params["prev_item_id"], do: String.to_integer(p)
    next_id = if n = params["next_item_id"], do: String.to_integer(n)

    customers = socket.assigns.customers
    current_index = Enum.find_index(customers, &(&1.id == id))

    customer = Enum.at(customers, current_index)
    customers = List.delete_at(customers, current_index)

    next_index =
      cond do
        prev_id -> Enum.find_index(customers, &(&1.id == prev_id)) + 1
        next_id -> Enum.find_index(customers, &(&1.id == next_id))
      end

    customers = List.insert_at(customers, next_index, customer)

    {:noreply, assign(socket, :customers, customers)}
  end
end
