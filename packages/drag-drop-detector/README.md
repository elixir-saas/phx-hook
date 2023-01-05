# @phx-hook/drag-drop-detector

Change element classes on drag and drop events.

## Usage

```js
const hooks = {}
hooks['drag-drop-detector'] = require('@phx-hook/drag-drop-detector')({ activeClass: 'drop-active' })

let liveSocket = new LiveSocket("/live", Socket, { hooks, ... })
```

```html
<div phx-hook="drag-drop-detector">
  ...
</div>
```

## Options

* `activeClass`: Class to be added to the element when it is dragged over.

## Attributes

No attribute options.
