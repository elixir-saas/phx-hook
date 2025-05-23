defmodule DemoWeb.DemoLive.CropImage do
  use DemoWeb, :live_view

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Crop Existing Image
        <:subtitle>
          Start cropping, then submit to see the result.
        </:subtitle>
      </.header>

      <div
        id="crop_example"
        class="flex gap-8 mb-12"
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

      <.header>
        Crop Image For Upload
        <:subtitle>
          Click on the profile image icon to upload & crop.
        </:subtitle>
      </.header>

      <div
        id="crop_profile"
        class="flex gap-8 mb-12"
        phx-hook="CropImage"
        data-crop-aspect="square"
        data-crop-file-input-id={@uploads.profile.ref}
        data-crop-container-id="crop_profile_preview"
        data-on-has-file={JS.exec("data-show", to: "#crop_profile_popup")}
      >
        <div class="relative h-12 p-1 pl-16 pr-10 bg-base-300 rounded-full flex items-center">
          <img
            :if={@path_profile}
            src={@path_profile}
            class="absolute left-1 size-10 ring-2 ring-primary rounded-full overflow-hidden"
          />
          <.form
            :if={@path_profile == nil}
            for={@form_profile}
            class="absolute left-1"
            phx-submit="submit_profile"
            phx-change="validate"
            phx-remove={JS.exec("data-hide", to: "#crop_profile_popup")}
          >
            <label id="profile_label" for={@uploads.profile.ref} class="cursor-pointer">
              <div class="size-10 bg-base-100 rounded-full flex items-center justify-center">
                <.icon name="hero-user-circle-mini" class="size-8" />
              </div>
              <.live_file_input upload={@uploads.profile} class="sr-only" />
            </label>
            <div
              id="crop_profile_popup"
              data-show={
                JS.show(
                  transition:
                    {"transition-all ease-out", "opacity-0 scale-95", "opacity-100 scale-100"}
                )
              }
              data-hide={
                JS.hide(
                  transition:
                    {"transition-all ease-out", "opacity-100 scale-100", "opacity-0 scale-95"}
                )
              }
              class="hidden absolute -left-4 top-6 -translate-x-[100%] -translate-y-[50%] p-3 bg-base-200 rounded-xl"
            >
              <div
                id="crop_profile_preview"
                phx-update="ignore"
                class="size-64 relative bg-base-100 mb-3 rounded-lg"
              />
              <.inputs_for_crop form={@form_profile} type="hidden" />
              <.button variant="primary" type="submit" class="w-full">
                Save profile image
              </.button>
            </div>
          </.form>
          <span class="font-semibold">
            @username
          </span>
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
  attr :type, :string, default: "number"

  def inputs_for_crop(assigns) do
    ~H"""
    <.inputs_for :let={f_crop} field={@form[:crop]}>
      <div class={["hidden", if(@type != "hidden", do: "cropping:block")]}>
        <.input data-crop-field="left" type={@type} field={f_crop[:left]} readonly label="Left" />
        <.input data-crop-field="top" type={@type} field={f_crop[:top]} readonly label="Top" />
        <.input data-crop-field="width" type={@type} field={f_crop[:width]} readonly label="Width" />
        <.input data-crop-field="height" type={@type} field={f_crop[:height]} readonly label="Height" />
      </div>
    </.inputs_for>
    """
  end
end
