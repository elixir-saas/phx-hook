# @phx-hook/open-window

Binds a click handler to an element that opens a new window.

[See it in action (Demo).](https://phx-hook.elixir-saas.com/open-window)

## Usage

```js
import OpenWindowHook from "@phx-hook/open-window";

const hooks = {
  OpenWindow: OpenWindowHook({ defaults: {} }),
};

let liveSocket = new LiveSocket("/live", Socket, { hooks, ... });
```

```heex
<button
  id="window_opener"
  phx-click={JS.dispatch("phx:open")}
  phx-hook="OpenWindow"
  data-window-url="https://example.com"
  data-window-name="Example"
  data-window-dimensions="1080:720:center"
>
  Open a new window
</button>
```

## Options

* `defaults`: An object of default window options (third argument of [window.open](https://developer.mozilla.org/en-US/docs/Web/API/Window/open)).
* `openEvent`: The event to listen for to open the new window. Defaults to `"phx:open"`.

## Attributes

* `data-window-url`: URL to open in the new window (first argument of [window.open](https://developer.mozilla.org/en-US/docs/Web/API/Window/open)).
* `data-window-name`: Name to give to the new window (second argument of [window.open](https://developer.mozilla.org/en-US/docs/Web/API/Window/open)).
* `data-window-dimensions`: Options helper for applying window dimensions, can be a string in one of the following formats: `center`, `w:h`, `w:h:center`, `w:h:x:y`.

## HEEx Component

A ready-to-use component that wraps this hook, just copy into your project:

```ex
@doc """
A button that opens a new window.
"""
attr :id, :string, required: true
attr :window_url, :string, required: true, doc: "URL of the window to open"
attr :window_name, :string, default: nil, doc: "Name of the new window"
attr :window_dimensions, :string, default: nil, doc: "Dimensions of the new window, i.e. 1080:720"
attr :rest, :global, include: ~w(class variant)

slot :inner_block, required: true

def open_window_button(assigns) do
  ~H"""
  <.button
    id={@id}
    phx-click={JS.dispatch("phx:open")}
    phx-hook="OpenWindow"
    data-window-url={@window_url}
    data-window-name={@window_name}
    data-window-dimensions={@window_dimensions}
    {@rest}
  >
    {render_slot(@inner_block)}
  </.button>
  """
end
```
