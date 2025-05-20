<p align="center">
  <img src="demo/priv/logo.png" height="150" />
</p>

---

# phx-hook

A collection of useful hooks for Phoenix LiveView JavaScript interop.

## Hooks

* [`@phx-hook/audio`](./packages/audio) - Play audio following a user interaction.
* [`@phx-hook/copy-to-clipboard`](./packages/copy-to-clipboard) - Copy values to the clipboard.
* [`@phx-hook/drag-drop-detector`](./packages/drag-drop-detector) - Add classes for drag and drop events.
* [`@phx-hook/movable`](./packages/movable) - Allow users to move and resize elements freely.
* [`@phx-hook/open-window`](./packages/open-window) - Open new, configurable windows on click.
* [`@phx-hook/prevent-unsaved-changes`](./packages/prevent-unsaved-changes) - Prompt users to prevent losing unsaved changes.
* [`@phx-hook/resizable`](./packages/resizable) - Resize the width or height of elements.
* [`@phx-hook/right-click-menu`](./packages/right-click-menu) - Open custom context menus on right click.
* [`@phx-hook/sortable`](./packages/sortable) - Easy drag-and-drop sorting with [Sortable.js](https://sortablejs.github.io/Sortable/).

## Installation

To install a `phx-hook` from the root of your Phoenix project, run:

```sh
npm i --save @phx-hook/package --prefix assets
```

Then, import it in your `app.js` file and configure it in your LiveSocket hooks:

```js
import PackageHook from "@phx-hook/package";

const hooks = {
  Package: PackageHook(),
};

let liveSocket = new LiveSocket("/live", Socket, { hooks, ... });
```

Additional installation instructions and documentation for each package can be found in the package directories in this repo.

## Modification

These hooks are designed to be concise, to be easy to understand, and to have zero npm package dependencies. If a hook doesn't quite work for you and requires modificaiton, I encourage you to copy it into your own project and develop it from there.

Vendoring a hook is easy, just copy the source file from this repo. For example, you might copy from `packages/sortable/src/index.js` to `assets/js/hooks/sortable.js` in your Phoenix project. Then, change the import path to your local path in your `app.js` file:

```diff
- import SortableHook from "@phx-hook/sortable";
+ import SortableHook from "./hooks/sortable";
```

Contributions back to `@phx-hook` are also welcome!

## Development

Run `lerna run format` to run [Prettier](https://prettier.io/) across all packages.

Run `lerna create [package]` and follow prompts to create a new package.

## Publishing

Run `lerna publish` and follow prompts.
