defmodule DemoWeb.DemoLive.DragDropDetector do
  use DemoWeb, :live_view

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.form for={@form} phx-change="change">
        <.input
          type="checkbox"
          class="toggle"
          field={@form[:global]}
          label="Enable global drag & drop"
        />

        <% # Inline demo %>
        <%= if @form[:global].value == "false" do %>
          <.inline_file_upload id="inline_file_upload" upload={@uploads.file} />
        <% end %>

        <% # Global demo %>
        <%= if @form[:global].value == "true" do %>
          <span class="text-sm">
            Drag a file into your browser window to reveal the drop area.
          </span>
          <.global_file_upload id="global_file_upload" upload={@uploads.file} />
        <% end %>
      </.form>
    </Layouts.app>
    """
  end

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "@phx-hook/drag-drop-detector")
     |> put_form(%{"global" => "false"})
     |> allow_upload(:file,
       accept: ~w(.png .jpg .pdf),
       max_file_size: 10_000_000,
       max_entries: 10
     )}
  end

  def handle_event("change", %{"form" => form_params}, socket) do
    {:noreply, put_form(socket, form_params)}
  end

  def put_form(socket, params) do
    assign(socket, :form, to_form(params, as: :form))
  end

  ## Components

  @doc """
  Renders a custom file upload input with drag-and-drop detection.
  """
  attr :id, :string, required: true
  attr :upload, Phoenix.LiveView.UploadConfig, required: true

  def inline_file_upload(assigns) do
    ~H"""
    <div class="space-y-2 rounded-2xl bg-base-200 p-2">
      <label
        id={@id}
        for={@upload.ref}
        phx-hook="DragDropDetector"
        phx-drop-target={@upload.ref}
        class={[
          "relative h-48",
          "flex flex-col items-center justify-center rounded-lg",
          "text-sm border-2 border-dashed",
          "border-primary/50 text-base-content",
          "hover:border-primary/70",
          "drag-active:border-primary drag-active:text-primary"
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
  Renders a custom file upload input with global drag-and-drop detection.
  """
  attr :id, :string, required: true
  attr :upload, Phoenix.LiveView.UploadConfig, required: true

  def global_file_upload(assigns) do
    ~H"""
    <label
      id={@id}
      for={@upload.ref}
      phx-hook="DragDropDetector"
      phx-drop-target={@upload.ref}
      data-drag-target="window"
      class={[
        "hidden fixed inset-2 bg-base-100/90 z-50",
        "drag-active:flex flex-col items-center justify-center rounded-lg",
        "text-sm border-2 border-dashed",
        "border-primary/50 text-base-content",
        "hover:border-primary/70",
        "drag-active:border-primary drag-active:text-primary"
      ]}
    >
      <p class="text-center">
        Drag & drop files here.
      </p>
      <.live_file_input upload={@upload} class="sr-only" />
    </label>

    <div :if={@upload.entries != []} class="absolute right-4 bottom-4">
      <div class="space-y-2 rounded-xl bg-base-200 p-2">
        <div class="px-2 flex gap-2 items-center text-sm text-content-base font-semibold">
          <.icon name="hero-cloud-arrow-up-mini" class="size-4" /> Uploads
        </div>
        <.file_upload_entry
          :for={entry <- @upload.entries}
          entry={entry}
          errors={upload_errors(@upload, entry)}
        />
      </div>
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
    <div class="flex flex-col gap-1 justify-between rounded-lg bg-base-300 border border-base-100 p-2">
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
