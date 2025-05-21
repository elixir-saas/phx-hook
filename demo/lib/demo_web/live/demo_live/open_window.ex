defmodule DemoWeb.DemoLive.OpenWindow do
  use DemoWeb, :live_view

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.button
        variant="primary"
        id="window_opener"
        phx-click={JS.dispatch("phx:open")}
        phx-hook="OpenWindow"
        data-window-url={url(~p"/open-window")}
        data-window-name={"Window #{:os.system_time()}"}
        data-window-dimensions="1080:720:center"
      >
        Open window
      </.button>
    </Layouts.app>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :page_title, "@phx-hook/open-window")}
  end
end
