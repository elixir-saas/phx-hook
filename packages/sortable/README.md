# @phx-hook/sortable

Integrate [Sortable.js](https://sortablejs.github.io/Sortable/) with Phoenix LiveView.

This package does not come with Sortable.js included, instead it is recommended that you download Sortable from their [releases](https://github.com/SortableJS/Sortable/releases) and add it directly to your `assets/vendor` directory.

## Usage

```js
import Sortable from "../vendor/Sortable";
import SortableHook from "@phx-hook/sortable";

const defaultSortableOpts = { ... };

const hooks = {
  Sortable: SortableHook(Sortable, defaultSortableOpts);
};

let liveSocket = new LiveSocket("/live", Socket, { hooks, ... });
```

```html
<div
  id="sortable_list"
  phx-hook="Sortable"
  data-on-end="move_item"
  data-animation="150"
  data-delay="300"
  data-delay-on-touch-only
  data-ghost-class="drag-ghost"
  data-force-fallback
>
  <div
    :for={item <- @items}
    data-item-id={item.id}
    class="drag-ghost:invisible"
  >
    ...
  </div>
</div>
```

## Options

All Sortable.js options are supported.

## Attributes

All Sortable.js options are supported as attributes, for example:

`swapThreshold: 1` becomes `data-swap-threshold="1"`.
