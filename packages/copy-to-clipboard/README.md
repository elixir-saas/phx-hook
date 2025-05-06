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
<div
  id="copy_plain"
  phx-hook="CopyToClipboard"
  data-copy-format="plain"
  data-copy-value="This text was copied!"
>
  <.button variant="primary" phx-click={JS.dispatch("phx:copy")}>
    <span class="group-data-copied:hidden">Copy</span>
    <span class="hidden group-data-copied:inline">Copied!</span>
  </.button>
</div>
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
    <span class="group-data-copied:hidden">Copy</span>
    <span class="hidden group-data-copied:inline">Copied!</span>
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

A copy is triggered by a `"phx:copy"` event, by default. When dispatched by a `<button>` element, it will propagate up through the DOM until it is caught and handled by the hook element. For this reason, your button should either be inside the hook element, or dispatch to it via `JS.dispatch/3`'s `:to` opt.

After a successful write to the clipboard, a `data-copied="copied"` attribute will be added to the dispatching element (if available, otherwise it will be added to the hook element itself). This can be used to modify the appearance of your copy button.

For example, if you add a `"group"` TailwindCSS class to the button element, you may show and hide contents of the button conditionally with group variant classes:

```heex
<button class="btn btn-primary group">
  <.icon name="hero-clipboard-document" class="size-4 group-data-copied:hidden" />
  <.icon name="hero-clipboard-document-check" class="size-4 hidden group-data-copied:inline" />
</button>
```

## Options

* `copyEvent`: The event to listen for when a copy action is made. Defaults to `"phx:copy"`.

## Attributes

* `data-copy-contents`: Use in place of `data-copy-value` to copy the contents of a DOM element. Leave blank to copy the contents of the hook element, or set to a query selector to copy the contents of a child of the hook element. Works with both `"plain"` and `"html"` as the copy format.
* `data-copy-format`: The format to use for the copy, may be either `"plain"` or `"html"`. Defaults to `"plain"`.
* `data-copy-value`: A value to copy. May be either plain text or an HTML string, for when the copy format is set to `"html"`. This attribute takes preference over `data-copy-contents`.
