# @phx-hook/right-click-menu

Open custom context menus on right click in your Phoenix LiveView app.

## Usage

```js
import RightClickMenuHook from "@phx-hook/right-click-menu";

const hooks = {
  RightClickMenu: RightClickMenuHook(),
};

let liveSocket = new LiveSocket("/live", Socket, { hooks, ... });
```

```html
<div
  id="menu"
  class="hidden"
  phx-hook="RightClickMenu"
  phx-remove={JS.hide(transition: {"transition-opacity", "opacity-100", "opacity-0"})}
>
  <.context_menu
    on_mark_read={
      JS.push("mark_read")
      |> JS.exec("phx-remove", to: "#menu")
    }
    on_delete={
      JS.push("delete")
      |> JS.exec("phx-remove", to: "#menu")
    }
  />
</div>
```

Render the hook element *inside* of the element on which it should listen for right clicks. When a right click occurs, the hook element will be made visible and positioned where the cursor is.

If you have many right-clickable items, say, in a table, then render an element with a `RightClickMenu` hook immediately inside each of the rows with distinct IDs. Each menu rendered then may take actions or push events specific to that row.

## Options

This hook does not have any options.

## Attributes

* `phx-remove`: A JS command that will be executed when the user clicks away from the menu when it is open.
