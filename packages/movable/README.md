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
