defmodule DemoWeb.DemoLive.Resizable do
  use DemoWeb, :live_view

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.browser_mock>
        <button
          id="reveal_button"
          phx-click={show_sidebar()}
          class="hidden absolute top-4 left-4 bg-base-200 size-6 flex items-center justify-center z-10 rounded"
        >
          <.icon name="hero-chevron-right" class="size-3" />
        </button>
        <div
          id="resizable_1"
          style={"--resize-1: #{@resize_1}px;"}
          class="flex-1 flex"
          phx-hook="Resizable"
          data-resize-var="--resize-1"
          data-resize-target="#sidebar_1"
          data-resize-event="resize_1"
          data-resize-min="125"
          data-resize-max="300"
          data-on-snap={hide_sidebar()}
        >
          <.resize_bar
            id="sidebar_1"
            class={[
              "w-[var(--resize-1)] inset-y-0 left-0",
              "resizing:border-r will-snap:transition-all will-snap:scale-95 will-snap:border will-snap:rounded"
            ]}
          >
            <div class="flex gap-2 items-center justify-between p-2">
              <span />
              <span class="text-sm">Resize me</span>
              <.icon name="hero-chevron-right" class="size-4 text-white" />
            </div>
            <div class="absolute bottom-2">
              <span class="text-xs text-base-content/50">({@resize_1}px)</span>
            </div>
          </.resize_bar>
          <div id="container_1" class="flex-1 flex p-2 ml-[var(--resize-1)]">
            <div class="flex-1 border border-dashed border-base-content/50 rounded" />
          </div>
        </div>
      </.browser_mock>

      <.browser_mock>
        <.resize_bar
          id="resizable_2"
          class="inset-y-0 right-0 resizing:border-l"
          style={"width: #{@resize_2}px;"}
          phx-hook="Resizable"
          data-resize-from="left"
          data-resize-event="resize_2"
          data-resize-min="125"
          data-resize-max="300"
        >
          <div class="flex gap-2 items-center justify-between p-2">
            <.icon name="hero-chevron-left" class="size-4 text-white" />
            <span class="text-sm">Resize me</span>
            <span />
          </div>
          <div class="absolute bottom-2">
            <span class="text-xs text-base-content/50">({@resize_2}px)</span>
          </div>
        </.resize_bar>
      </.browser_mock>

      <.browser_mock>
        <.resize_bar
          id="resizable_3"
          class="inset-x-0 top-0 resizing:border-b"
          style={"height: #{@resize_3}px;"}
          phx-hook="Resizable"
          data-resize-from="bottom"
          data-resize-event="resize_3"
          data-resize-min="125"
          data-resize-max="250"
        >
          <div class="flex-1 flex flex-col gap-2 items-center justify-between p-2">
            <span />
            <span class="text-sm">Resize me</span>
            <.icon name="hero-chevron-down" class="size-4 text-white" />
          </div>
          <div class="absolute top-2">
            <span class="text-xs text-base-content/50">({@resize_3}px)</span>
          </div>
        </.resize_bar>
      </.browser_mock>

      <.browser_mock>
        <.resize_bar
          id="resizable_4"
          class="inset-x-0 bottom-0 resizing:border-t"
          style={"height: #{@resize_4}px;"}
          phx-hook="Resizable"
          data-resize-from="top"
          data-resize-event="resize_4"
          data-resize-min="125"
          data-resize-max="250"
        >
          <div class="flex-1 flex flex-col gap-2 items-center justify-between p-2">
            <.icon name="hero-chevron-up" class="size-4 text-white" />
            <span class="text-sm">Resize me</span>
            <span />
          </div>
          <div class="absolute bottom-2">
            <span class="text-xs text-base-content/50">({@resize_4}px)</span>
          </div>
        </.resize_bar>
      </.browser_mock>
    </Layouts.app>
    """
  end

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "@phx-hook/resizable")
     |> assign(resize_1: 150, resize_2: 150, resize_3: 150, resize_4: 150)}
  end

  def handle_event("resize_1", %{"width" => width}, socket) do
    {:noreply, assign(socket, :resize_1, width)}
  end

  def handle_event("resize_2", %{"width" => width}, socket) do
    {:noreply, assign(socket, :resize_2, width)}
  end

  def handle_event("resize_3", %{"height" => height}, socket) do
    {:noreply, assign(socket, :resize_3, height)}
  end

  def handle_event("resize_4", %{"height" => height}, socket) do
    {:noreply, assign(socket, :resize_4, height)}
  end

  ## JS

  def hide_sidebar() do
    %JS{}
    |> JS.show(to: "#reveal_button", display: "flex")
    |> JS.hide(
      to: "#sidebar_1",
      transition: {"transition-all ease-out", "opacity-100", "opacity-0 -left-32!"}
    )
    |> JS.transition(
      {"transition-all ease-out", "ml-[var(--resize-1)]", "ml-0"},
      to: "#container_1"
    )
  end

  def show_sidebar() do
    %JS{}
    |> JS.hide(to: "#reveal_button")
    |> JS.show(
      to: "#sidebar_1",
      display: "flex",
      transition: {"transition-all ease-out", "opacity-0 -left-32!", "opacity-100"}
    )
    |> JS.transition(
      {"transition-all ease-out", "ml-0", "ml-[var(--resize-1)]"},
      to: "#container_1"
    )
  end

  ## Components

  attr :class, :any, default: []
  attr :rest, :global, include: ~w(id)
  slot :inner_block

  def resize_bar(assigns) do
    ~H"""
    <div
      {@rest}
      class={[
        "absolute flex flex-col items-center justify-center h-full bg-base-200 border-primary"
        | List.wrap(@class)
      ]}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  slot :inner_block

  def browser_mock(assigns) do
    ~H"""
    <div class="mockup-browser border-base-300 border w-full">
      <div class="mockup-browser-toolbar">
        <div class="input">https://example.com</div>
      </div>
      <div class="flex border-t border-base-300 h-80 relative">
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end
end
