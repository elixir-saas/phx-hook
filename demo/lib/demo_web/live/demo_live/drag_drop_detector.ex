defmodule DemoWeb.DemoLive.DragDropDetector do
  use DemoWeb, :live_view

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.form for={%{}} as={:f} phx-change="change">
        <.file_upload id="demo_file_upload" upload={@uploads.file} />
      </.form>
    </Layouts.app>
    """
  end

  def mount(_params, _session, socket) do
    {:ok,
     allow_upload(socket, :file,
       accept: ~w(.png .jpg .pdf),
       max_file_size: 10_000_000,
       max_entries: 10
     )}
  end

  def handle_event("change", _params, socket) do
    {:noreply, socket}
  end

  ## Components

  @doc """
  Renders a custom file upload input with drag-and-drop detection.
  """
  attr :id, :string, required: true
  attr :upload, Phoenix.LiveView.UploadConfig, required: true

  def file_upload(assigns) do
    ~H"""
    <div class="gap-2 rounded-2xl bg-base-200 p-2">
      <label
        id={@id}
        for={@upload.ref}
        phx-hook="DragDropDetector"
        phx-drop-target={@upload.ref}
        data-active-class="drop-active"
        class={[
          "relative h-48",
          "flex flex-col items-center justify-center rounded-lg",
          "text-sm border-2 border-dashed",
          "border-primary/50 text-base-content",
          "hover:border-primary/70",
          "drop-active:border-primary drop-active:text-primary"
        ]}
      >
        <p class="text-center">
          <%= if @upload.entries != [] do %>
            Drag & drop to add more files.
          <% else %>
            Drag & drop files here.
          <% end %>
        </p>
        <div class="absolute right-2 bottom-2">
          <.button
            type="button"
            variant="primary"
            onclick={"document.getElementById('#{@id}').click()"}
          >
            <.icon name="hero-cloud-arrow-up-mini" class="size-4" /> Browse files
          </.button>
        </div>
        <.live_file_input upload={@upload} class="sr-only" />
      </label>
      <.file_upload_entry
        :for={entry <- @upload.entries}
        entry={entry}
        errors={upload_errors(@upload, entry)}
      />
    </div>
    """
  end

  @doc """
  Renders a file upload entry.
  """
  attr :entry, Phoenix.LiveView.UploadEntry, required: true
  attr :errors, :list, default: []

  def file_upload_entry(assigns) do
    ~H"""
    <div class="mt-2 flex flex-col gap-1 justify-between rounded-lg bg-base-300 border border-base-100 p-2">
      <div class="flex gap-2 items-center text-sm text-base-content">
        <.icon name="hero-document" class="size-4" />
        <div class="flex-1 truncate">
          <span>{@entry.client_name}</span>
        </div>
        <div class="whitespace-nowrap">
          <span>{@entry.client_size} bytes</span>
        </div>
      </div>
      <span :for={error <- @errors} class="text-xs text-error">{error_for(error)}</span>
    </div>
    """
  end

  def error_for(:too_large), do: "File is too large."
  def error_for(:not_accepted), do: "File type not allowed."
  def error_for(:too_many_files), do: "Too many files."
  def error_for(error), do: to_string(error)
end
