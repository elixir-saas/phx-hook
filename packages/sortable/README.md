# @phx-hook/sortable

Integrate [Sortable.js](https://sortablejs.github.io/Sortable/) with Phoenix LiveView.

This package does not come with Sortable.js included, instead it is recommended that you download Sortable from their [releases](https://github.com/SortableJS/Sortable/releases) and add it directly to your `assets/vendor` directory.

Use with [`:ecto_orderable`](https://github.com/elixir-saas/ecto_orderable) for syncing sorted items to your database.

## Usage

```js
import Sortable from "../vendor/Sortable";
import SortableHook from "@phx-hook/sortable";

const defaultSortableOpts = { ... };

const hooks = {
  Sortable: SortableHook(Sortable, defaultSortableOpts),
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
  data-force-fallback
>
  <div
    :for={item <- @items}
    data-item-id={item.id}
    class="sortable-ghost:invisible"
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

## TailwindCSS

You might find it helpful to add Tailwind variants for various drag states.

Using Tailwind v4:

```css
/* In assets/css/app.css */
/* These reflect the default class names used by Sortable.js */

@custom-variant sortable-ghost (.sortable-ghost&, .sortable-ghost &);
@custom-variant sortable-chosen (.sortable-chosen&, .sortable-chosen &);
@custom-variant sortable-drag (.sortable-drag&, .sortable-drag &);
```


Using Tailwind v3:

```js
// In assets/tailwind.config.js
// These reflect the default class names used by Sortable.js

plugins: [
  plugin(({addVariant}) => addVariant("sortable-ghost", [".sortable-ghost&", ".sortable-ghost &"])),
  plugin(({addVariant}) => addVariant("sortable-chosen", [".sortable-chosen&", ".sortable-chosen &"])),
  plugin(({addVariant}) => addVariant("sortable-drag", [".sortable-drag&", ".sortable-drag &"])),
]
```
