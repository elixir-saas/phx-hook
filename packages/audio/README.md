# @phx-hook/audio

Play audio following a user interaction.

[See it in action (Demo).](https://phx-hook.elixir-saas.com/audio)

Find free sound effects on [Freesound](https://freesound.org/).

## Usage

```js
import AudioHook from "@phx-hook/audio";

const hooks = {
  Audio: AudioHook(),
};

let liveSocket = new LiveSocket("/live", Socket, { hooks, ... });
```

```heex
<div
  id="audio"
  phx-hook="Audio"
  data-preload={Enum.join([~p"/audio/click.wav", ~p"/audio/trill.wav"], ",")}
  data-active-element="dispatcher"
>
  <.button phx-click={JS.dispatch("phx:play", detail: %{audio: ~p"/audio/click.wav"})}>
    <span class="playing:hidden">Play "click.wav"</span>
    <span class="playing:inline hidden">Playing...</span>
  </.button>
  <.button phx-click={JS.dispatch("phx:play", detail: %{audio: ~p"/audio/trill.wav"})}>
    <span class="playing:hidden">Play "trill.wav"</span>
    <span class="playing:inline hidden">Playing...</span>
  </.button>
</div>
```

Fields supported in the event `:detail` map for the `phx:play` event:

* `:audio`: The path or URL where the audio file to play is located (required).
* `:id`: An identifer to give the audio object, in case it should be reused across interactions.
* `:restart`: When `true`, starts the audio from the beginning with each play.

Fields supported in the event `:detail` map for the `phx:pause` event:

* `:id`: The identifer of the audio object that should be paused (required).

## Options

* `activeClass`: Class to be added when the hook element is moving. Defaults to `"playing"`.
* `playEvent`: The event to listen for playing audio. Defaults to `"phx:play"`.
* `pauseEvent`: The event to listen for pausing audio. Defaults to `"phx:pause"`.

## Attributes

* `data-active-element`: When set to `"dispatcher"`, the dispatching element is given the active class while audio is playing instead of the hook element. Useful for when multiple elements may play audio inside of the same hook.
* `data-preload`: A comma-separated list of paths or URLs of audio files that will be preloaded when the hook mounts. Avoids waiting on network requests the first time an audio file is played.

## TailwindCSS

You might find it helpful to add Tailwind variants for various moving and resizing states.

Using Tailwind v4:

```css
/* In assets/css/app.css */

/* Add variants for the class names used by @phx-hook/audio */
@custom-variant playing (.playing&, .playing &);
```

Using Tailwind v3:

```js
// In assets/tailwind.config.js

plugins: [
  /* Add variants for the class names used by @phx-hook/audio */
  plugin(({addVariant}) => addVariant("playing", [".playing&", ".playing &"])),
]
```

## HEEx Component

A ready-to-use component that wraps this hook, just copy into your project:

```ex
@doc """
A button that will play & pause audio.
"""
attr :id, :string, required: true
attr :audio, :string, required: true, doc: "Path to audio file to play on click"
attr :on_play, JS, default: %JS{}, doc: "JS command to execute on click play"
attr :on_pause, JS, default: %JS{}, doc: "JS command to execute on click pause"
attr :rest, :global, include: ~w(variant)

def audio(assigns) do
  ~H"""
  <div id={@id} phx-hook="Audio" data-preload={@audio} class="inline">
    <div class="playing:hidden inline">
      <.button {@rest} phx-click={JS.dispatch(@on_play, "phx:play", detail: %{id: @id, audio: @audio})}>
        <.icon name="hero-play" />
      </.button>
    </div>
    <div class="playing:inline hidden">
      <.button {@rest} phx-click={JS.dispatch(@on_pause, "phx:pause", detail: %{id: @id})}>
        <.icon name="hero-pause" />
      </.button>
    </div>
  </div>
  """
end
```
