defmodule DemoWeb.DemoLive.OpenWindow do
  use DemoWeb, :live_view

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div>
        Window state: {render_state(@state)}
      </div>
      <div>
        <.button
          variant="primary"
          id="window_opener"
          phx-click={JS.push("opened") |> JS.dispatch("phx:open")}
          phx-hook="OpenWindow"
          data-window-url={url(~p"/open-window")}
          data-window-name={@window_name}
          data-window-dimensions="1080:720:center"
          data-on-window-close={JS.push("closed")}
        >
          Open window
        </.button>
        <.button
          :if={@state == :opened}
          phx-click={JS.dispatch("phx:close", to: "#window_opener", detail: %{name: @window_name})}
        >
          Close window
        </.button>
      </div>
    </Layouts.app>
    """
  end

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "@phx-hook/open-window")
     |> assign(:window_name, "Example #{:os.system_time()}")
     |> assign(:state, nil)}
  end

  def handle_event("opened", _params, socket) do
    {:noreply, assign(socket, :state, :opened)}
  end

  def handle_event("closed", _params, socket) do
    {:noreply, assign(socket, :state, :closed)}
  end

  def render_state(state) do
    case state do
      nil -> "No window."
      :opened -> "Window is open!"
      :closed -> "Window was closed."
    end
  end
end
