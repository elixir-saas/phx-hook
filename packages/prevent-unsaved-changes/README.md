# @phx-hook/prevent-unsaved-changes

Prompt users to prevent losing unsaved changes.

[See it in action (Demo).](https://phx-hook.elixir-saas.com/prevent-unsaved-changes)

## Usage

```js
import PreventUnsavedChangesHook from "@phx-hook/prevent-unsaved-changes";

const hooks = {
  PreventUnsavedChanges: PreventUnsavedChangesHook(),
};

let liveSocket = new LiveSocket("/live", Socket, { hooks, ... });
```

```heex
<.modal ... on_close={JS.dispatch("phx:cancel", to: "##{@form.id}")}>
  <.form
    id={@form.id}
    for={@form}
    phx-change="validate"
    phx-submit="submit"
    phx-hook="PreventUnsavedChanges"
    data-has-unsaved-changes={@form.source.changes != %{}}
    data-on-cancel={JS.patch(~p"/")}
    data-confirm-message="Leave without saving?"
  >
    <% # Form inputs... %>
  </.form>
</.modal>
```

This hook does not have to be used with a `<form>` element, however it is the most common use case.

## Options

* `cancelEvent`: The event to listen for when a cancellation attempt is made. Defaults to `"phx:cancel"`.

## Attributes

* `data-confirm-message`: Override the default confirm message with your own.
* `data-has-unsaved-changes`: Set when there are unsaved changes, so that the hook knows to prevent the page from unloading.
* `data-on-cancel`: A JS command that will run after a cancel event is received and the user has confirmed the action. Will also run if there are no currently unsaved changes.
