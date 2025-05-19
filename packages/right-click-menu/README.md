# @phx-hook/right-click-menu

Open custom context menus on right click in your Phoenix LiveView app.

[See it in action (Demo).](https://phx-hook.elixir-saas.com/right-click-menu)

## Usage

```js
import RightClickMenuHook from "@phx-hook/right-click-menu";

const hooks = {
  RightClickMenu: RightClickMenuHook(),
};

let liveSocket = new LiveSocket("/live", Socket, { hooks, ... });
```

```heex
<div
  :for={item <- @items}
  id={"menu_#{item.id}"}
  class="hidden"
  phx-hook="RightClickMenu"
  phx-remove={JS.hide(transition: {"transition-opacity", "opacity-100", "opacity-0"})}
  data-container-id={"item_#{@item.id}"}
  data-on-show={JS.focus()}
>
  <.item_options_menu
    on_mark_read={
      JS.push("mark_read", value: %{id: item.id})
      |> JS.exec("phx-remove", to: "#menu_#{item.id}")
    }
    on_delete={
      JS.push("delete", value: %{id: item.id})
      |> JS.exec("phx-remove", to: "#menu_#{item.id}")
    }
  />
</div>
```

Render the hook element immediately *inside* of the element on which it should listen for right clicks. When a right click occurs, the hook element will be made visible and positioned absolutely where the cursor is on the page.

If you have many right-clickable items, say, in a list, then render an element with a `RightClickMenu` hook immediately inside each of the items, each with a distinct ID. Each menu rendered then may take actions or push events specific to that item.

In the case of a `<table>` element, render the hook elements elsewhere and specify a `data-container-id` on each that refers to its corresponding row. This is required since direct children of `<tr>` elements must be `<td>` elements.

## Options

This hook does not have any options.

## Attributes

* `phx-remove`: A JS command that will be executed when the user clicks away from the menu while it is open.
* `data-container-id`: By default, the menu will show when immediate parent of the hook element is right-clicked. Set this attribute to instead open it when a specific container element or any of its children are the target of the event. Use when you are not able to render the hook element as a direct child, for example if it is a `<tr>` element.
* `data-on-show`: A JS command that will be executed whenever the menu is shown. Useful for applying focus to a default element in the menu.

## HEEx Component

A ready-to-use component that wraps this hook, just copy into your project:

```ex
@doc """
A component that reveals on right click.
"""
attr :id, :string, required: true
attr :container_id, :string, default: nil, doc: "Container to watch for right click events"
attr :on_show, JS, default: nil, doc: "JS command that runs when the menu appears"
attr :rest, :global, include: ~w(class)

slot :inner_block, required: true

def right_click_menu(assigns) do
  ~H"""
  <div
    id={@id}
    phx-hook="RightClickMenu"
    data-container-id={@container_id}
    data-on-show={@on_show}
    {@rest}
  >
    {render_slot(@inner_block)}
  </div>
  """
end
```
