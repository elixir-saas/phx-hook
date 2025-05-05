# @phx-hook/drag-drop-detector

Change element classes on drag and drop events.

## Usage

```js
import DragDropDetectorHook from "@phx-hook/drag-drop-detector";

const hooks = {
  DragDropDetector: DragDropDetectorHook({ activeClass: 'drop-active' }),
};

let liveSocket = new LiveSocket("/live", Socket, { hooks, ... });
```

```html
<div id="drop_area" phx-hook="DragDropDetector">
  ...
</div>
```

## Options

* `activeClass`: Class to be added to the element when it is dragged over. Defaults to `"drop-active"`.

## Attributes

* `data-active-class`: Class to be added to the element when it is dragged over, overrides `activeClass`.

## TailwindCSS

You might find it helpful to add Tailwind variants for various drop states.

Using Tailwind v4:

```css
/* In assets/css/app.css */

@custom-variant drop-active (.drop-active&, .drop-active &);
```

Using Tailwind v3:

```js
// In assets/tailwind.config.js

plugins: [
  plugin(({addVariant}) => addVariant("drop-active", [".drop-active&", ".drop-active &"])),
]
```
