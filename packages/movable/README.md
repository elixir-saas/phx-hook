# @phx-hook/movable

Allow users to move and resize elements freely.

[See it in action (Demo).](https://phx-hook.elixir-saas.com/movable)

## Usage

```js
import MovableHook from "@phx-hook/movable";

const hooks = {
  Movable: MovableHook({ /* options */ }),
};

let liveSocket = new LiveSocket("/live", Socket, { hooks, ... });
```

```heex
<div
  id="movable"
  phx-hook="Movable"
  data-move-event="moved"
  data-move-handle="[data-handle]"
  data-resizable
  data-resize-event="resized"
  data-resize-min-height="150"
  data-resize-min-width="200"
>
  <div class={[
    "h-full bg-base-200 rounded-lg overflow-hidden",
    "moving:ring-2 moving:ring-base-300 moving:shadow-lg",
    "resizing:ring-2 resizing:ring-primary/50"
  ]}>
    <div data-handle class="h-8 bg-base-300" />
    <% # Contents %>
  </div>
</div>
```

The event pushed by `data-move-event` and `data-resize-event` includes the following params:

```elixir
%{
  "top" => integer(),   # The current `top` style property
  "left" => integer(),  # The current `left` style property
  "width" => integer(), # The current `width` style property
  "height" => integer() # The current `height` style property
}
```

You may store these values so that the position of the element is retained later on, for example by rendering the element with a `style` created from the position params:

```heex
<div
  id="movable"
  style={if @position, do: style_for_position(@position)}
  phx-hook="Movable"
  ...
>
  <% # Contents %>
</div>
```

```elixir
def style_for_position(position) do
  """
  position: absolute;
  top: #{position["top"]}px;
  left: #{position["left"]}px;
  width: #{position["width"]}px;
  height: #{position["height"]}px;
  """
end
```

## Options

* `activeClass`: Class to be added when the hook element is moving. Defaults to `"moving"`.
* `resizeClass`: Class to be added when the hook element is resizing. Defaults to `"resizing"`.
* `resizeSize`: Hitbox size of the corners of a resizable element. Defaults to `"8px"`.
* `resizeOffset`: Position offset of the corners of a resizable element. Defaults to `"-4px"`.

## Attributes

* `phx-target`: Target for events pushed from the hook element instance.
* `data-move-event`: Event to push to the LiveView after the element is moved. If not set, no event is sent.
* `data-move-handle`: Selector for a child element of the hook element to use as the handle for moving. By default, the entire element is treated as the handle.
* `data-resizable`: Set to make the element resizable. This attribute does not require a value.
* `data-resize-aspect`: An aspect ratio in the format `"w:h"` (i.e. `"16:9"`) that the element should preserve while resizing.
* `data-resize-aspect-offset`: A height offset value in pixels in the case that there is some fixed size UI that the ratio calculation should ignore (for example, the height of a handle element at the top of the hook element contents).
* `data-resize-event`: Event to push to the LiveView after the element is resized. If not set, no event is sent.
* `data-resize-max-height`: Maximum height the element may be resized to.
* `data-resize-max-width`: Maximum width the element may be resized to.
* `data-resize-min-height`: Minimum height the element may be resized to.
* `data-resize-min-width`: Minimum width the element may be resized to.

## TailwindCSS

You might find it helpful to add Tailwind variants for various moving and resizing states.

Using Tailwind v4:

```css
/* In assets/css/app.css */

/* Add variants for the class names used by @phx-hook/movable */
@custom-variant moving (.moving&, .moving &);
@custom-variant resizing (.resizing&, .resizing &);
```

Using Tailwind v3:

```js
// In assets/tailwind.config.js

plugins: [
  /* Add variants for the class names used by @phx-hook/movable */
  plugin(({addVariant}) => addVariant("moving", [".moving&", ".moving &"])),
  plugin(({addVariant}) => addVariant("resizing", [".resizing&", ".resizing &"])),
]
```

## HEEx Component

A ready-to-use component that wraps this hook, just copy into your project:

```ex
@doc """
A freely movable and resizable component.
"""
attr :id, :string, required: true
attr :class, :string, default: nil
attr :move_event, :string, default: nil, doc: "Event to send after moving"
attr :resizable, :boolean, default: false, doc: "Set to true to make resizable"
attr :resize_aspect, :string, default: nil, doc: "Aspect ratio to maintain while resizing"
attr :resize_aspect_offset, :string, default: nil, doc: "Vertical offset to apply to aspect ratio"
attr :resize_event, :string, default: nil, doc: "Event to send after resizing"
attr :resize_max_height, :integer, default: nil, doc: "Max height to resize to"
attr :resize_max_width, :integer, default: nil, doc: "Max width to resize to"
attr :resize_min_height, :integer, default: nil, doc: "Min height to resize to"
attr :resize_min_width, :integer, default: nil, doc: "Min width to resize to"
attr :rest, :global, include: ~w(style)

slot :inner_block, required: true
slot :move_handle

def movable(assigns) do
  ~H"""
  <div
    id={@id}
    class={[
      @class,
      "bg-base-200 rounded-lg overflow-hidden",
      "moving:ring-2 moving:ring-base-300 moving:shadow-lg",
      "resizing:ring-2 resizing:ring-primary/50"
    ]}
    phx-hook="Movable"
    data-move-event={@move_event}
    data-move-handle={if @move_handle != [], do: "[data-handle]"}
    data-resizable={@resizable}
    data-resize-aspect={@resize_aspect}
    data-resize-aspect-offset={@resize_aspect_offset}
    data-resize-event={@resize_event}
    data-resize-max-height={@resize_max_height}
    data-resize-max-width={@resize_max_width}
    data-resize-min-height={@resize_min_height}
    data-resize-min-width={@resize_min_width}
    {@rest}
  >
    <div :if={@move_handle != []} data-handle>
      {render_slot(@move_handle)}
    </div>
    {render_slot(@inner_block)}
  </div>
  """
end
```
