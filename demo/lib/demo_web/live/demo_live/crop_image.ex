defmodule DemoWeb.DemoLive.CropImage do
  use DemoWeb, :live_view

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.test />
      <div
        id="crop_example"
        class="flex gap-8"
        phx-hook="CropImage"
        data-crop-image-src={~p"/images/phx-hook.png"}
        data-crop-container-id="crop_example_preview"
      >
        <div class="p-3 bg-base-200 rounded-xl">
          <div
            id="crop_example_preview"
            phx-update="ignore"
            class="size-64 relative bg-base-100 mb-3 rounded-lg"
          />
          <.form for={@form_example} phx-submit="submit_example" phx-change="validate">
            <.inputs_for_crop form={@form_example} />
            <.button variant="primary" type="submit" class="w-full">
              Crop image
            </.button>
          </.form>
        </div>
        <div :if={@path_example}>
          <div class="p-3 bg-base-200 rounded-xl">
            <img src={@path_example} class="rounded-lg overflow-hidden" />
          </div>
        </div>
      </div>

      <div
        id="crop_profile"
        class="flex gap-8"
        phx-hook="CropImage"
        data-crop-aspect="square"
        data-crop-file-input-id={@uploads.profile.ref}
        data-crop-container-id="crop_profile_preview"
      >
        <div class="p-3 bg-base-200 rounded-xl">
          <div
            id="crop_profile_preview"
            phx-update="ignore"
            class="size-64 relative bg-base-100 mb-3 rounded-lg"
          />
          <.form for={@form_profile} phx-submit="submit_profile" phx-change="validate">
            <.inputs_for_crop form={@form_profile} />
            <label id="profile_label" for={@uploads.profile.ref}>
              <.live_file_input upload={@uploads.profile} class="sr-only" />
            </label>
            <div class="block cropping:hidden">
              <.button variant="primary" type="button" class="w-full" onclick="profile_label.click()">
                Upload profile
              </.button>
            </div>
            <div class="hidden cropping:block">
              <.button variant="primary" type="submit" class="w-full">
                Crop image
              </.button>
            </div>
          </.form>
        </div>
        <div :if={@path_profile}>
          <div class="p-3 bg-base-200 rounded-xl">
            <img src={@path_profile} class="size-32 rounded-lg overflow-hidden" />
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "@phx-hook/image-crop")
     |> put_form(:example)
     |> put_form(:profile)
     |> assign(:path_example, nil)
     |> assign(:path_profile, nil)
     |> allow_upload(:profile,
       accept: ~w(.png .jpg),
       max_file_size: 10_000_000,
       max_entries: 1
     )}
  end

  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("submit_example", %{"example" => %{"crop" => params}}, socket) do
    path = priv_path("static/images", "phx-hook.png")
    file = "phx-hook-#{:os.system_time()}.png"
    dest = priv_path("static/uploads", file)

    resize_as_png(path, dest,
      x: String.to_integer(params["left"]),
      y: String.to_integer(params["top"]),
      w: String.to_integer(params["width"]),
      h: String.to_integer(params["height"])
    )

    file_path = Path.join("uploads", file)

    {:noreply, socket |> assign(:path_example, file_path) |> put_form(:example)}
  end

  def handle_event("submit_profile", %{"profile" => %{"crop" => params}}, socket) do
    {entries, []} = uploaded_entries(socket, :profile)

    [file] =
      for entry <- entries do
        consume_uploaded_entry(socket, entry, fn %{path: path} ->
          file = "#{Path.basename(path)}.png"
          dest = priv_path("static/uploads", file)

          resize_as_png(path, dest,
            x: String.to_integer(params["left"]),
            y: String.to_integer(params["top"]),
            w: String.to_integer(params["width"]),
            h: String.to_integer(params["height"]),
            size: {512, 512}
          )

          {:ok, file}
        end)
      end

    file_path = Path.join("uploads", file)

    {:noreply, socket |> assign(:path_profile, file_path) |> put_form(:profile)}
  end

  def put_form(socket, as) do
    assign(socket, :"form_#{as}", to_form(%{}, as: as))
  end

  def priv_path(path, file) do
    Path.join([:code.priv_dir(:demo), path, file])
  end

  def resize_as_png(input, output, opts) do
    {w, h} = opts[:size] || {opts[:w], opts[:h]}
    filter_part = "crop=#{opts[:w]}:#{opts[:h]}:#{opts[:x]}:#{opts[:y]},scale=#{w}:#{h}"
    {_out, 0} = System.cmd("ffmpeg", ["-i", input, "-vf", filter_part, output])
  end

  ## Components

  attr :form, Phoenix.HTML.Form, required: true

  def inputs_for_crop(assigns) do
    ~H"""
    <.inputs_for :let={f_crop} field={@form[:crop]}>
      <div class="hidden cropping:block">
        <.input data-crop-field="left" type="number" field={f_crop[:left]} readonly label="Left" />
        <.input data-crop-field="top" type="number" field={f_crop[:top]} readonly label="Top" />
        <.input data-crop-field="width" type="number" field={f_crop[:width]} readonly label="Width" />
        <.input
          data-crop-field="height"
          type="number"
          field={f_crop[:height]}
          readonly
          label="Height"
        />
      </div>
    </.inputs_for>
    """
  end

  attr :x, :string, values: [nil, "square"], default: nil

  def test(assigns) do
    ~H"""
    {@x}
    """
  end
end
