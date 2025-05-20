defmodule DemoWeb.DemoLive.FocusList do
  use DemoWeb, :live_view

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Focus List
      </.header>

      <div class="mb-12">
        <ul
          id="focus_list_1"
          class="menu bg-base-200 rounded-box ring ring-base-300"
          phx-hook="FocusList"
          data-focus-selector="button"
        >
          <li :for={i <- 1..10}>
            <button
              type="button"
              class="focus:bg-base-100"
              phx-click="flash"
              phx-value-message={"Selected #{i}"}
            >
              Item {i}
            </button>
          </li>
        </ul>
      </div>

      <.header>
        Focus List with Search
      </.header>

      <div
        id="focus_list_2"
        class="w-64 mb-12"
        phx-hook="FocusList"
        data-home-selector="form input"
        data-items-selector="[data-result]"
        data-focus-selector="button"
      >
        <.form for={@search_form} phx-submit="search" phx-change="search">
          <.input
            field={@search_form[:query]}
            placeholder="Search..."
            autocomplete="off"
            phx-key="Escape"
            phx-keydown="clear_search"
          />
        </.form>
        <ul :if={@search_results != []} class="w-full menu bg-base-200 rounded-box ring ring-base-300">
          <li :for={result <- @search_results} data-result>
            <button
              type="button"
              class="focus:bg-base-100"
              phx-click="flash"
              phx-value-message={"Selected #{result}"}
            >
              {result}
            </button>
          </li>
        </ul>
      </div>

      <.header>
        Focus List in Right Click Menu
      </.header>

      <div class="mb-12 bg-base-300 p-16 mb-16 flex items-center justify-center">
        <span class="text-sm text-base-content">
          Right click me.
        </span>
        <.right_click_menu id="focus_list_3_menu" on_show={JS.focus(to: "#focus_list_3_close")}>
          <div
            id="focus_list_3"
            class="menu bg-base-200 rounded-box ring ring-base-300"
            phx-hook="FocusList"
            data-home-selector="#focus_list_3_close"
            data-items-selector="ul li"
            data-focus-selector="button"
          >
            <button
              id="focus_list_3_close"
              type="button"
              class="sr-only"
              phx-click={JS.exec("phx-remove", to: "#focus_list_3_menu")}
            >
              Close
            </button>
            <ul>
              <li :for={i <- 1..6}>
                <button
                  type="button"
                  class="focus:bg-base-100"
                  phx-click="flash"
                  phx-value-message={"Selected #{i}"}
                >
                  Item {i}
                </button>
              </li>
            </ul>
          </div>
        </.right_click_menu>
      </div>

      <.header>
        Focus List in "Jump Menu"
      </.header>

      <div
        id="focus_list_4"
        class="dropdown"
        phx-hook="FocusList"
        data-items-selector="ul li"
        data-focus-selector="a"
      >
        <button type="button" class="btn m-1">
          Jump <.icon name="hero-arrow-uturn-down" />
        </button>
        <ul class="dropdown-content menu bg-base-200 rounded-box z-1 w-52 p-2 shadow-sm">
          <li :for={i <- 1..@jump_items}>
            <.link
              href={"#jump-#{i}"}
              class="focus:bg-base-100 flex items-center justify-between"
              data-jump-key={jump_key(i, @jump_items)}
            >
              Item {i}
              <span
                :if={jump_key = jump_key(i, @jump_items)}
                class="size-6 flex items-center justify-center bg-base-100 border border-base-300 rounded"
              >
                <span class="text-xs">{jump_key}</span>
              </span>
            </.link>
          </li>
        </ul>
      </div>

      <div
        :for={i <- 1..@jump_items}
        id={"jump-#{i}"}
        class="h-64 px-6 pt-4 scroll-m-4 bg-base-300 rounded"
      >
        <.header>Item {i}</.header>
      </div>
    </Layouts.app>
    """
  end

  @items ~w"Alpha Beta Gamma Delta Epsilon Zeta Eta Theta Iota"

  def mount(_params, _session, socket) do
    {:ok, assign(socket, jump_items: 12) |> put_search()}
  end

  def handle_event("flash", %{"message" => message}, socket) do
    {:noreply, put_flash(socket, :info, message)}
  end

  def handle_event("search", %{"search" => %{"query" => query}}, socket) do
    {:noreply, put_search(socket, query)}
  end

  def handle_event("clear_search", _params, socket) do
    {:noreply, put_search(socket)}
  end

  def put_search(socket, query \\ "") do
    params = %{"query" => query}
    query = String.downcase(query)

    results =
      case query do
        "" -> []
        query -> Enum.filter(@items, &(String.downcase(&1) =~ query))
      end

    socket
    |> assign(:search_form, to_form(params, as: :search))
    |> assign(:search_results, results)
  end

  def jump_key(i, jump_items) do
    cond do
      i < 10 -> i
      i == jump_items -> "k"
      true -> nil
    end
  end
end
