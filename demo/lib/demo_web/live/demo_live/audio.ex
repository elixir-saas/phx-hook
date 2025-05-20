defmodule DemoWeb.DemoLive.Audio do
  use DemoWeb, :live_view

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div
        id="audio_1"
        phx-hook="Audio"
        data-preload={@click_audio}
        data-active-element="dispatcher"
        class="mb-12"
      >
        <.header>
          Clicky Buttons
        </.header>
        <div class="grid gap-3 grid-cols-3">
          <div :for={_ <- 1..9} class="h-16">
            <.clicky_button on_click={
              JS.hide(transition: {"transition-opacity", "opacity-100", "opacity-0"})
            }>
              Click
            </.clicky_button>
          </div>
        </div>
      </div>

      <div id="audio_2" phx-hook="Audio" data-preload={@click_audio} class="mb-12">
        <.header>
          Clicky Input
        </.header>
        <div class="transition-all duration-50 playing:scale-105">
          <.input
            name="clicky_input"
            value=""
            phx-keydown={play_audio(@click_audio, id: "input", restart: true)}
          />
        </div>
      </div>

      <div id="audio_3" phx-hook="Audio" data-preload={@rising_tone_audio} class="mb-12">
        <.header>
          Play & Pause
        </.header>
        <.button phx-click={play_audio(@rising_tone_audio, id: "rising_tone")}>
          <.icon name="hero-speaker-x-mark" class="size-4 playing:hidden" />
          <.icon name="hero-speaker-wave" class="size-4 playing:inline hidden" />
          <span class="playing:hidden">Play</span>
          <span class="playing:inline hidden">Playing...</span>
        </.button>
        <div class="hidden playing:inline">
          <.button phx-click={pause_audio(id: "rising_tone")}>
            <.icon name="hero-pause" /> Pause
          </.button>
        </div>
      </div>
    </Layouts.app>
    """
  end

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:click_audio, ~p"/audio/click.wav")
     |> assign(:rising_tone_audio, ~p"/audio/rising-tone.mp3")}
  end

  ## JS

  def play_audio(%JS{} = js, audio_path),
    do: play_audio(js, audio_path, [])

  def play_audio(audio_path, opts) when is_list(opts),
    do: play_audio(%JS{}, audio_path, opts)

  def play_audio(js, audio_path, opts) do
    detail = %{id: opts[:id], restart: opts[:restart], audio: audio_path}
    JS.dispatch(js, "phx:play", detail: detail)
  end

  def pause_audio(%JS{} = js),
    do: pause_audio(js, [])

  def pause_audio(opts) when is_list(opts),
    do: pause_audio(%JS{}, opts)

  def pause_audio(js, opts) do
    detail = %{id: opts[:id]}
    JS.dispatch(js, "phx:pause", detail: detail)
  end

  ## Components

  attr :on_click, JS, default: %JS{}
  slot :inner_block

  def clicky_button(assigns) do
    ~H"""
    <.button phx-click={play_audio(@on_click, ~p"/audio/click.wav")}>
      <span class="playing:hidden">{render_slot(@inner_block)}</span>
      <span class="playing:inline hidden">Playing...</span>
    </.button>
    """
  end
end
