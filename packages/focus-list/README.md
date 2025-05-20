# @phx-hook/focus-list

Focus items in a list with keyboard shortcuts

[See it in action (Demo).](https://phx-hook.elixir-saas.com/focus-list)

## Usage

```js
import FocusListHook from "@phx-hook/focus-list";

const hooks = {
  FocusList: FocusListHook(),
};

let liveSocket = new LiveSocket("/live", Socket, { hooks, ... });
```

```heex
<div
  id="focus_list"
  class="w-64"
  phx-hook="FocusList"
  data-home-selector="form input"
  data-items-selector="ul li"
  data-focus-selector="button"
>
  <.form for={@search_form} phx-submit="search" phx-change="search">
    <.input field={@search_form[:query]} placeholder="Search..." autocomplete="off" />
  </.form>
  <ul :if={@search_results != []} class="w-full menu bg-base-200 rounded-box ring ring-base-300">
    <li :for={result <- @search_results}>
      <button type="button" class="focus:bg-base-100" phx-click={...}>
        {result}
      </button>
    </li>
  </ul>
</div>
```

## Options

This hook does not have any options.

## Attributes

* `data-focus-selector`: Query selector that targets the element to focus within the current item element. If not provided, focus is given to the item element itself.
* `data-home-selector`: Query selector for a "home" element to focus. The home element is an element outside of the list of item elements, it will gain focus when navigating beyond the start or end of the item elements list. Useful for targeting a hidden close button or a search input. By default, there is no home element.
* `data-items-selector`: Query selector that targets the list of items that can be navigated. If not provided, the direct children of the hook element are used.

## Child Attributes

* `data-jump-key`: Set to the value of a key on any child element. When that key is pressed while the hook element has focus, a click event will trigger on the child element. Useful for adding shortcuts to dropdown menu items. Avoid when the hook element contains an input element, as it could mistakenly trigger a jump. This is an alternative to [LiveView Key Events](https://hexdocs.pm/phoenix_live_view/bindings.html#key-events).

## TailwindCSS

To visually distinguish focused items from its peers, you can add a Tailwind class with the focus variant. For example: `focus:bg-base-100`.

## HEEx Component

A ready-to-use component that wraps this hook, just copy into your project:

```ex
@doc """
A menu with items that change focus with keyboard navigation.
"""
attr :id, :string, required: true
attr :rest, :global, include: ~w(class)

slot :inner_block
slot :item, required: true

def focus_menu(assigns) do
  ~H"""
  <div
    id={@id}
    phx-hook="FocusList"
    data-home-selector={if @inner_block != [], do: "[data-focus-home]"}
    data-items-selector="[data-focus-item]"
    data-focus-selector="button"
    {@rest}
  >
    <div :if={@inner_block != []}>
      {render_slot(@inner_block)}
    </div>
    <ul :if={@item != []} class="menu bg-base-200 rounded-box ring ring-base-300">
      <li :for={item <- @item>} data-focus-item>
        {render_slot(item)}
      </li>
    </ul>
  </div>
  """
end
```
