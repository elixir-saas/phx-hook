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

* `activeClass`: Class to be added to the element when it is dragged over.

## Attributes

* `data-active-class`: Class to be added to the element when it is dragged over, overrides `activeClass`.
