# @phx-hook/copy-to-clipboard

Copy values as plain text or rich text (via HTML) to the clipboard.

[See it in action (Demo).](https://phx-hook.elixir-saas.com/copy-to-clipboard)

## Usage

```js
import CopyToClipboardHook from "@phx-hook/copy-to-clipboard";

const hooks = {
  CopyToClipboard: CopyToClipboardHook(),
};

let liveSocket = new LiveSocket("/live", Socket, { hooks, ... });
```

Specify the value you want copied as a data attribute:

```heex
<.button
  id="copy_plain"
  variant="primary"
  phx-click={JS.dispatch("phx:copy")}
  phx-hook="CopyToClipboard"
  data-copy-format="plain"
  data-copy-value="This text was copied!"
>
  <span class="on-copy-hide">Copy</span>
  <span class="on-copy-show">Copied!</span>
</.button>
```

Or, copy plain text and HTML directly from the DOM:

```heex
<div
  id="copy_html"
  phx-hook="CopyToClipboard"
  data-copy-format="html"
  data-copy-contents="[data-copy-container]"
>
  <.button variant="primary" phx-click={JS.dispatch("phx:copy")}>
    <span class="on-copy-hide">Copy</span>
    <span class="on-copy-show">Copied!</span>
  </.button>

  <div data-copy-container>
    <ol>
      <li>Lorem ipsum dolor sit amet, consectetur</li>
      <li>adipiscing elit, sed do eiusmod tempor incididunt</li>
      <li>ut labore et dolore magna aliqua.</li>
    </ol>
  </div>
</div>
```

A copy is triggered by a `"phx:copy"` event, by default. When dispatched by a `<button>` element, it will propagate up through the DOM until it is caught and handled by the hook element. For this reason, your button should either be the hook element, be inside the hook element, or dispatch to the hook element via `JS.dispatch/3`'s `:to` opt.

## Options

* `copyEvent`: The event to listen for when a copy action is made. Defaults to `"phx:copy"`.

## Attributes

* `data-copy-contents`: Use in place of `data-copy-value` to copy the contents of a DOM element. Leave blank to copy the contents of the hook element, or set to a query selector to copy the contents of a child of the hook element. Works with both `"plain"` and `"html"` as the copy format.
* `data-copy-format`: The optional format to use for the copy, may be either `"plain"` or `"html"`. Defaults to `"plain"`.
* `data-copy-value`: A value to copy. May be either plain text or an HTML string, for when the copy format is set to `"html"`. This attribute takes precedence over `data-copy-contents`.

## TailwindCSS

After a successful write to the clipboard, a `data-copied="copied"` attribute will be added to the dispatching element (if available, otherwise it will be added to the hook element itself). This can be used to modify the appearance of your copy button after a copy action takes place.

For example, if you add a `"group"` TailwindCSS class to the button element, you may show and hide contents of the button conditionally with group variant classes:

```heex
<button class="btn btn-primary group">
  <.icon name="hero-clipboard-document" class="size-4 group-data-copied:hidden" />
  <.icon name="hero-clipboard-document-check" class="size-4 hidden group-data-copied:inline" />
</button>
```

If the `group-data-copied:` variant is too cumbersome, you might find it helpful to add a Tailwind variant for the copied state.

Using Tailwind v4:

```css
/* In assets/css/app.css */

/* Add variants for the class names used by @phx-hook/copy-to-clipboard */
@custom-variant copied ([data-copied]&, [data-copied] &);
```

Using Tailwind v3:

```js
// In assets/tailwind.config.js

plugins: [
  /* Add variants for the class names used by @phx-hook/copy-to-clipboard */
  plugin(({addVariant}) => addVariant("copied", ["[data-copied]&", "[data-copied] &"])),
]
```

You can also achieve this without Tailwind, by defining custom utility classes instead:

```css
/* In assets/css/app.css */

/* Utility classes for displaying elements based on data-copied attribute */
[data-copied] > .on-copy-hide { display: none; }
[data-copied] > .on-copy-show { display: inline; }
:not([data-copied]) > .on-copy-show { display: none; }
```

## HEEx Component

A ready-to-use component that wraps this hook, just copy into your project:

```ex
@doc """
A button that copies to the users clipboard.
"""
attr :id, :string, required: true
attr :copy_value, :string, required: true, doc: "Value to copy to the clipboard"
attr :rest, :global, include: ~w(class variant)

slot :inner_block, required: true

def copy_button(assigns) do
  ~H"""
  <.button
    id={@id}
    phx-hook="CopyToClipboard"
    data-copy-format="plain"
    data-copy-value={@copy_value}
    phx-click={JS.dispatch("phx:copy")}
    {@rest}
  >
    <span class="copied:hidden">{render_slot(@inner_block)}</span>
    <span class="copied:inline hidden">Copied!</span>
  </.button>
  """
end
```
