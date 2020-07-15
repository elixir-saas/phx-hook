# @phx-hook/open-window

Binds a click handler to an element that opens a new window.

## Usage

```js
const hooks = {}
hooks['open-window'] = require('@phx-hook/open-window')({ defaults: {} })

let liveSocket = new LiveSocket("/live", Socket, { hooks, ... })
```

```html
<button phx-hook="open-window"
  data-event="opened_window"
  data-window-url="https://example.com"
  data-window-name="Example"
  data-window-dimensions="1080:720:center">
  Open a new window
</button>
```

## Options

* `defaults`: An object of default window options (third argument of [window.open](https://developer.mozilla.org/en-US/docs/Web/API/Window/open))

## Attributes

* `data-window-url`: URL to open in the new window (first argument of [window.open](https://developer.mozilla.org/en-US/docs/Web/API/Window/open))
* `data-window-name`: Name to give to the new window (second argument of [window.open](https://developer.mozilla.org/en-US/docs/Web/API/Window/open))
* `data-window-dimensions`: Options helper for applying window dimensions, can be a string in one of the following formats: `center`, `w:h`, `w:h:center`, `w:h:x:y`
* `data-event`: Name of event to send to the LiveView when the hook is triggered
