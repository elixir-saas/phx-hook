# @phx-hook/resizable

Resize the width or height of elements.

[See it in action (Demo).](https://phx-hook.elixir-saas.com/resizable)

## Usage

```js
import ResizableHook from "@phx-hook/resizable";

const hooks = {
  Resizable: ResizableHook({ /* options */ }),
};

let liveSocket = new LiveSocket("/live", Socket, { hooks, ... });
```

```heex
<div
  id="resizable"
  style="width: 200px;"
  data-resize-from="right"
  data-resize-event="resized"
  data-resize-min="150"
  data-resize-max="300"
>
  <% # Contents %>
</div>
```

The event pushed by `data-resize-event` includes the following params:

```elixir
%{
  "width" => integer(),  # When `data-resize-from` is set to "right" or "left"
  "height" => integer(), # When `data-resize-from` is set to "bottom" or "top"
}
```

You may this value so that the size of the element is retained later on, for example by rendering the element with a `style` created from the stored value:

```heex
<div
  id="resizable"
  style={if @size, do: "width: #{@size}px;"}
  phx-hook="Resizable"
  ...
>
  <% # Contents %>
</div>
```

This will also work when using `data-resize-var`, just set the initial CSS variable to the value you have saved:

```heex
<div
  id="resizable"
  style={if @size, do: "--sidebar-size: #{@size}px;"}
  phx-hook="Resizable"
  data-resize-var="--sidebar-size"
  data-resize-target="#sidebar"
  ...
>
  <div id="sidebar" class="w-[var(--sidebar-size)]">
    <% # Sidebar contents %>
  </div>
  <div id="main" class="ml-[var(--sidebar-size)]">
    <% # Main contents %>
  </div>
</div>
```

The above example shows why you might want to use a CSS variable instead of manipulating the width and height of an element directly, it's an elegant way to position multiple elements from the same source of truth. In the case of the example, it controls the width of the sidebar and the left margin of the main container.

## Options

* `activeClass`: Class to be added when the element is resizing. Defaults to `"resizing"`.
* `willSnapClass`: Class to be added when the element will "snap" on mouseup. Defaults to `"will-snap"`.
* `resizeSize`: Hitbox size of the edge of the resizable element. Defaults to `"4px"`.
* `resizeOffset`: Position offset of the edge of the resizable element. Defaults to `"-2px"`.

## Attributes

* `data-on-snap`: A JS command that will be executed when the resizable element "snaps" (the user lifts their mouse after dragging the element to its minimum width), Requires `data-resize-min` to be set.
* `data-resize-event`: Event to push to the LiveView after the element is resized. If not set, no event is sent.
* `data-resize-from`: Direction to place the handle for resizing the element, one of `"right"`, `"left"`, `"bottom"`, `"top"`. Defaults to `"right"`.
* `data-resize-max`: Maximum width or height the element may be resized to.
* `data-resize-min`: Minimum width or height the element may be resized to.
* `data-resize-target`: Selector of a child element that should be treated as the resizable element. By default, the hook element is the resizable element.
* `data-resize-var`: Name of a CSS variable to store the size value, instead of setting the width or height of the element directly. Useful for when other elements depend on this value. It is recommended that you render the element with an initial value for this variable when used, for example: `style="--resize-size: 150px;"`.

## TailwindCSS

You might find it helpful to add Tailwind variants for resizing states.

Using Tailwind v4:

```css
/* In assets/css/app.css */

/* Add variants for the class names used by @phx-hook/resizable */
@custom-variant resizing (.resizing&, .resizing &);
@custom-variant will-snap (.will-snap&, .will-snap &);
```

Using Tailwind v3:

```js
// In assets/tailwind.config.js

plugins: [
  /* Add variants for the class names used by @phx-hook/resizable */
  plugin(({addVariant}) => addVariant("resizing", [".resizing&", ".resizing &"])),
  plugin(({addVariant}) => addVariant("will-snap", [".will-snap&", ".will-snap &"])),
]
```
