# @phx-hook/drag-drop-detector

Change element classes on drag and drop events.

[See it in action (Demo).](https://phx-hook.elixir-saas.com/drag-drop-detector)

## Usage

```js
import DragDropDetectorHook from "@phx-hook/drag-drop-detector";

const hooks = {
  DragDropDetector: DragDropDetectorHook({ activeClass: "drag-active" }),
};

let liveSocket = new LiveSocket("/live", Socket, { hooks, ... });
```

```html
<div id="drop_area" phx-hook="DragDropDetector">
  ...
</div>
```

## Options

* `activeClass`: Class to be added to the element when it is dragged over. Defaults to `"drag-active"`.

## Attributes

* `data-drag-target`: Set to `"window"` to detect dragging anywhere in the window, instead of just over the hook element. Useful for creating a global drag & drop upload experience.

## TailwindCSS

You might find it helpful to add Tailwind variants for various drop states.

Using Tailwind v4:

```css
/* In assets/css/app.css */

@custom-variant drag-active (.drag-active&, .drag-active &);
```

Using Tailwind v3:

```js
// In assets/tailwind.config.js

plugins: [
  plugin(({addVariant}) => addVariant("drag-active", [".drag-active&", ".drag-active &"])),
]
```
