# @phx-hook/textarea

Adapt the height of a textarea to its contents.

[See it in action (Demo).](https://phx-hook.elixir-saas.com/textarea)

## Usage

```js
import TextareaHook from "@phx-hook/textarea";

const hooks = {
  Textarea: TextareaHook({ /* options */ }),
};

let liveSocket = new LiveSocket("/live", Socket, { hooks, ... });
```

```heex
<.form for={@form} phx-submit="submit" phx-change="validate">
  <.input
    type="textarea"
    field={@form[:text]}
    phx-hook="Textarea"
    data-max-height="250"
    data-on-submit={JS.dispatch("scroll-to-bottom")}
    data-submit-on-enter
  />
</.form>
```

## Options

* `defaultMaxHeight`: An integer value in pixels to use as the max height for textareas with this hook. Defaults to `Infinity`.

## Attributes

* `data-max-height`: An integer value in pixels used to constrain the height of the textarea. Overrides `defaultMaxHeight`.
* `data-on-submit`: A `Phoenix.LiveView.JS` command to execute when Enter triggers form submission. Useful for performing additional actions like scrolling or hiding elements after submit.
* `data-submit-on-enter`: If present, the form containing the textarea will be submitted when the `"Enter"` key is pressed.

## TailwindCSS

By default, textareas are resizable. To disable resizing using Tailwind, add a `resize-none` class to your textarea element.

## HEEx Component

Phoenix projects come with a `input/1` component already included. You can apply this hook to all of your textareas by adding it this function component, where the function head matches on `%{type: "textarea"} = assigns`. Consider also adding `resize="none"` to disable manual resizing.
