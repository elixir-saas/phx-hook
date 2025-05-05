defmodule DemoWeb.DemoLive.RightClickMenu do
  use DemoWeb, :live_view

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="bg-base-300 p-16 mb-16 flex items-center justify-center">
        <span class="text-sm text-base-content">
          Right click me.
        </span>
        <.right_click_menu :let={remove} id="menu_single">
          <.menu>
            <.menu_item phx-click={remove}>Do something</.menu_item>
            <.menu_item phx-click={remove}>Do something else</.menu_item>
            <.menu_item phx-click={remove}>Another action</.menu_item>
          </.menu>
        </.right_click_menu>
      </div>

      <.header>
        Customers
        <:subtitle>
          Right click any row, each has its own context menu.
        </:subtitle>
      </.header>

      <.table id="table" rows={@customers} row_id={&"customer_#{&1.id}"}>
        <:col :let={customer} label="ID">
          {customer.id}
        </:col>
        <:col :let={customer} label="Customer">
          {customer.name}
        </:col>
        <:col :let={customer} label="Latest message">
          {customer.message}
        </:col>
        <:col :let={customer}>
          <.icon :if={not customer.read} name="hero-eye-slash" class="size-4" />
        </:col>
        <:right_click :let={{remove, customer}}>
          <.menu>
            <.menu_item
              :if={not customer.read}
              phx-click={JS.push(remove, "mark_read", value: %{id: customer.id})}
            >
              <.icon name="hero-eye-slash" class="size-4" /> Mark as read
            </.menu_item>
            <.menu_item
              :if={customer.read}
              phx-click={JS.push(remove, "mark_unread", value: %{id: customer.id})}
            >
              <.icon name="hero-eye" class="size-4" /> Mark as unread
            </.menu_item>
            <.menu_item phx-click={
              remove
              |> JS.hide(to: "#customer_#{customer.id}")
              |> JS.push("delete", value: %{id: customer.id})
            }>
              <.icon name="hero-trash" class="size-4 text-red-500" /> Delete "{customer.name}"
            </.menu_item>
          </.menu>
        </:right_click>
      </.table>
    </Layouts.app>
    """
  end

  def mount(_params, _session, socket) do
    customers = [
      %{id: 1, name: "Adam", read: false, message: "Lorem ipsum doler sid ept dracun"},
      %{id: 2, name: "Betty", read: false, message: "Lorem ipsum doler sid ept dracun"},
      %{id: 3, name: "Charlie", read: false, message: "Lorem ipsum doler sid ept dracun"},
      %{id: 4, name: "Diane", read: false, message: "Lorem ipsum doler sid ept dracun"},
      %{id: 5, name: "Ethan", read: false, message: "Lorem ipsum doler sid ept dracun"}
    ]

    {:ok, assign(socket, :customers, customers)}
  end

  def handle_event("mark_read", %{"id" => id}, socket) do
    {:noreply, update_customer(socket, id, &Map.put(&1, :read, true))}
  end

  def handle_event("mark_unread", %{"id" => id}, socket) do
    {:noreply, update_customer(socket, id, &Map.put(&1, :read, false))}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    {:noreply, update_customer(socket, id, fn _ -> nil end)}
  end

  def update_customer(socket, id, fun) do
    update(socket, :customers, fn customers ->
      Enum.flat_map(customers, fn customer ->
        if customer.id == id do
          if result = fun.(customer), do: [result], else: []
        else
          [customer]
        end
      end)
    end)
  end

  ## Components

  slot :inner_block, required: true

  def menu(assigns) do
    ~H"""
    <ul class="menu bg-base-200 rounded-box ring ring-base-300">
      {render_slot(@inner_block)}
    </ul>
    """
  end

  attr :rest, :global, include: ~w(id phx-click phx-target title)
  slot :inner_block, required: true

  def menu_item(assigns) do
    ~H"""
    <li>
      <button {@rest} type="button">
        {render_slot(@inner_block)}
      </button>
    </li>
    """
  end
end
