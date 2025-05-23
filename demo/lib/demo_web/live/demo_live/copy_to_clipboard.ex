defmodule DemoWeb.DemoLive.CopyToClipboard do
  use DemoWeb, :live_view

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.copy_button
        id="copy_1"
        phx-hook="CopyToClipboard"
        data-copy-format="plain"
        data-copy-value="This text was copied!"
      >
        Copy plain value
      </.copy_button>

      <.copy_button
        id="copy_2"
        phx-hook="CopyToClipboard"
        data-copy-format="html"
        data-copy-value={@html_value}
      >
        Copy HTML value
      </.copy_button>

      <div class="space-y-2 text-sm">
        <.copy_button dispatch_to="#copy_3">
          Copy plain contents via dispatch
        </.copy_button>

        <div id="copy_3" phx-hook="CopyToClipboard" data-copy-format="plain" data-copy-contents>
          Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
        </div>
      </div>

      <div class="space-y-2 text-sm">
        <.copy_button dispatch_to="#copy_4">
          Copy HTML contents via dispatch
        </.copy_button>

        <div id="copy_4" phx-hook="CopyToClipboard" data-copy-format="html" data-copy-contents>
          <ol>
            <li>Lorem ipsum dolor sit amet, consectetur</li>
            <li>adipiscing elit, sed do eiusmod tempor incididunt</li>
            <li>ut labore et dolore magna aliqua.</li>
          </ol>
        </div>
      </div>

      <div
        id="copy_5"
        class="space-y-2 text-sm"
        phx-hook="CopyToClipboard"
        data-copy-format="plain"
        data-copy-contents="[data-copy-container]"
      >
        <.copy_button>
          Copy plain value via selector
        </.copy_button>

        <div data-copy-container>
          Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
        </div>
      </div>

      <div
        id="copy_6"
        class="space-y-2 text-sm"
        phx-hook="CopyToClipboard"
        data-copy-format="html"
        data-copy-contents="[data-copy-container]"
      >
        <.copy_button>
          Copy HTML value via selector
        </.copy_button>

        <div data-copy-container>
          <ol>
            <li>Lorem ipsum dolor sit amet, consectetur</li>
            <li>adipiscing elit, sed do eiusmod tempor incididunt</li>
            <li>ut labore et dolore magna aliqua.</li>
          </ol>
        </div>
      </div>

      <div class="mt-12">
        <.input name="pastebox" type="textarea" value="" rows={10} placeholder="Try pasting here!" />
      </div>
    </Layouts.app>
    """
  end

  def mount(_params, _session, socket) do
    html_value =
      """
      <ol>
        <li>1st</li>
        <li>2nd</li>
        <li>3rd</li>
      </ol>
      """

    {:ok,
     socket
     |> assign(:page_title, "@phx-hook/copy-to-clipboard")
     |> assign(:html_value, html_value)}
  end

  ## Components

  attr :dispatch_to, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def copy_button(assigns) do
    ~H"""
    <.button {@rest} variant="primary" phx-click={JS.dispatch("phx:copy", to: @dispatch_to)}>
      <span class="copied:hidden">{render_slot(@inner_block)}</span>
      <span class="copied:inline hidden">Copied!</span>
    </.button>
    """
  end
end
