defmodule DemoWeb.DemoLive.Movable do
  use DemoWeb, :live_view

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Move
        <:subtitle>
          Move an element, send an event with the new position on move end.
          <.source_link source_url={demo_source_url()} />
        </:subtitle>
      </.header>

      <div class="relative h-64 mb-12">
        <div
          id="movable_0"
          class="size-64"
          phx-hook="Movable"
          data-move-event="moved"
          data-z-group="movables"
        >
          <.card>
            Move me!
            <div :if={@top && @left}>
              top: {@top}px, left: {@left}px
            </div>
          </.card>
        </div>
      </div>

      <.header>
        Move With Handle
        <:subtitle>
          Move an element using a specified handle element.
          <.source_link source_url={demo_source_url()} />
        </:subtitle>
      </.header>

      <div class="relative h-64 mb-12">
        <div
          id="movable_1"
          class="size-64"
          phx-hook="Movable"
          data-move-handle="[data-handle]"
          data-z-group="movables"
        >
          <.card handle>
            Move me with a handle!
          </.card>
        </div>
      </div>

      <.header>
        Move & Resize
        <:subtitle>
          Move an element using a handle element, resize from the corners with a minimum size.
          <.source_link source_url={demo_source_url()} />
        </:subtitle>
      </.header>

      <div class="relative h-64 mb-12">
        <div
          id="movable_2"
          class="size-64"
          phx-hook="Movable"
          data-move-handle="[data-handle]"
          data-resizable
          data-resize-min-width="200"
          data-resize-min-height="150"
          data-resize-event="resized"
          data-z-group="movables"
        >
          <.card handle>
            Move & resize me!
            <div :if={@width && @height}>
              {@width}px x {@height}px
            </div>
          </.card>
        </div>
      </div>

      <.header>
        Move & Resize With Aspect
        <:subtitle>
          Constrain element resizing to maintain an aspect ratio (useful for video players).
          <.source_link source_url={demo_source_url()} />
        </:subtitle>
      </.header>

      <div class="relative h-64 mb-12">
        <div
          id="movable_3"
          class="w-[400px] h-[calc(400px/16*9+32px)]"
          phx-hook="Movable"
          data-move-handle="[data-handle]"
          data-resizable
          data-resize-aspect="16:9"
          data-resize-aspect-offset="32"
          data-resize-min-width="400"
          data-resize-min-height={400 / 16 * 9 + 32}
          data-z-group="movables"
        >
          <.card handle>
            Move & resize me! (Fixed aspect)
          </.card>
        </div>
      </div>
    </Layouts.app>
    """
  end

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "@phx-hook/movable")
     |> assign(top: nil, left: nil, width: nil, height: nil)}
  end

  def handle_event("moved", %{"top" => top, "left" => left}, socket) do
    {:noreply, assign(socket, top: top, left: left)}
  end

  def handle_event("resized", %{"width" => width, "height" => height}, socket) do
    {:noreply, assign(socket, width: width, height: height)}
  end

  ## Components

  attr :handle, :boolean, default: false
  slot :inner_block, required: true

  def card(assigns) do
    ~H"""
    <div class={[
      "h-full flex flex-col bg-base-200 rounded-lg overflow-hidden",
      "moving:ring-2 moving:ring-base-300 moving:shadow-lg",
      "resizing:ring-2 resizing:ring-primary/50"
    ]}>
      <div :if={@handle} data-handle class="h-8 bg-base-300" />
      <div class="flex-1 flex items-center justify-center">
        <div class="text-sm text-center px-2">
          {render_slot(@inner_block)}
        </div>
      </div>
    </div>
    """
  end
end
