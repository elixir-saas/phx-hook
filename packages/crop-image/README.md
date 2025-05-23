# @phx-hook/crop-image

🚧 Experimental 🚧

Crop images to a specified size for upload.

[See it in action (Demo).](https://phx-hook.elixir-saas.com/crop-image)

## Usage

```js
import CropImageHook from "@phx-hook/crop-image";

const hooks = {
  CropImage: CropImageHook({ /* options */ }),
};

let liveSocket = new LiveSocket("/live", Socket, { hooks, ... });
```

Submit cropped dimensions for an image that is already stored:

```heex
<div
  id="crop_image"
  phx-hook="CropImage"
  data-crop-image-src={@image_src}
  data-crop-container-id="crop_preview"
>
  <div id="crop_preview" phx-update="ignore" class="size-64 bg-base-100" />
  <.form for={@form} phx-submit="crop" phx-change="validate">
    <.inputs_for :let={f_crop} field={@form[:crop]}>
      <.input type="hidden" field={f_crop[:left]} data-crop-field="left" />
      <.input type="hidden" field={f_crop[:top]} data-crop-field="top" />
      <.input type="hidden" field={f_crop[:width]} data-crop-field="width" />
      <.input type="hidden" field={f_crop[:height]} data-crop-field="height" />
    </.inputs_for>
    <.button variant="primary" type="submit" class="w-full">
      Crop image
    </.button>
  </.form>
</div>
```

Submit cropped dimensions for an image that a user is uploading:

```heex
<div
  id="crop_image"
  phx-hook="CropImage"
  data-crop-aspect="square"
  data-crop-file-input-id={@uploads.profile.ref}
  data-crop-container-id="crop_preview"
>
  <div id="crop_preview" phx-update="ignore" class="size-64 bg-base-100" />
  <.form for={@form} phx-submit="crop" phx-change="validate">
    <.inputs_for :let={f_crop} field={@form[:crop]}>
      <% # Crop input fields here... %>
    </.inputs_for>

    <% # Image will be taken from the file input %>
    <label id="profile_label" for={@uploads.profile.ref}>
      <.live_file_input upload={@uploads.profile} class="sr-only" />
    </label>

    <% # Show button to select a profile picture %>
    <div class="block cropping:hidden">
      <.button variant="primary" type="button" class="w-full" onclick="profile_label.click()">
        Select profile
      </.button>
    </div>

    <% # Show button to upload picture and crop dimensions %>
    <div class="hidden cropping:block">
      <.button variant="primary" type="submit" class="w-full">
        Crop image
      </.button>
    </div>
  </.form>
</div>
```

Once you have both an image and the crop dimensions, you can use `ffmpeg` (or similar) to perform the crop:

```elixir
defmodule Ffmpeg do
  def resize_as_png(input, output, opts) do
    x = Keyword.fetch!(opts, :x)
    y = Keyword.fetch!(opts, :y)
    w = Keyword.fetch!(opts, :w)
    h = Keyword.fetch!(opts, :h)

    {iw, ih} = opts[:size] || {w, h}

    filter_part = "crop=#{w}:#{h}:#{x}:#{y},scale=#{iw}:#{ih}"

    {_out, 0} = System.cmd("ffmpeg", ["-i", input, "-vf", filter_part, output])
  end
end
```

## Options

* `activeClass`: Class to be added when an image is loaded and ready to crop. Defaults to `"cropping"`.
* `minSize`: Mimimum width and height in pixels of the crop area. Defaults to `50`.
* `threshold`: Hitbox size in pixels of the crop area resize handles. Defaults to `10`.

## Attributes

* `data-crop-aspect`: If set to `"square"`, the crop area will maintain a one-to-one aspect ratio.
* `data-crop-container-id`: ID of the container element that will contain the crop canvas. Required.
* `data-crop-file-input-id`: ID of a file input element, an image added to the input will be added to the crop canvas.
* `data-crop-image-src`: Source URL or path of the image to crop.

You should only specify one of `data-crop-file-input-id` and `data-crop-image-src`.

## Child Attributes

* `data-crop-field`: Add to an input element that should receive the value of a crop dimension property. May be one of `"top"`, `"left"`, `"width"`, `"height"`. Use this data in your LiveView after the form is submitted to perform the actual image crop on the server.

## TailwindCSS

You might find it helpful to add Tailwind variants for cropping states.

Using Tailwind v4:

```css
/* In assets/css/app.css */

/* Add variants for the class names used by @phx-hook/crop-image */j
@custom-variant cropping (.cropping&, .cropping &);
```

Using Tailwind v3:

```js
// In assets/tailwind.config.js

plugins: [
  /* Add variants for the class names used by @phx-hook/crop-image */
  plugin(({addVariant}) => addVariant("cropping", [".cropping&", ".cropping &"])),
]
```

## HEEx Component

A ready-to-use component that wraps this hook, just copy into your project:

```ex
@doc """
A form that allows cropping an image, the crop dimensions are then sent on submit.
"""
attr :id, :string, required: true
attr :form, Phoenix.HTML.Form, required: true
attr :upload, Phoenix.LiveView.UploadConfig, default: nil
attr :crop_aspect, :atom, values: [nil, :square], default: nil
attr :crop_image_src, :string, default: nil
attr :rest, :global, include: ~w(class)

slot :inner_block, required: true

def crop_image(assigns) do
  ~H"""
  <div
    id={@id}
    phx-hook="CropImage"
    data-crop-aspect={@crop_aspect}
    data-crop-container-id={"#{@id}_crop_container"}
    data-crop-file-input-id={if @upload, do: @upload.ref}
    data-crop-image-src={@crop_image_src}
  >
    <div id={"#{@id}_crop_container"} phx-update="ignore" class="size-64 bg-base-100" />
    <.form {@rest} for={@form}>
      <.inputs_for :let={f_crop} field={@form[:crop]}>
        <.input type="hidden" field={f_crop[:left]} data-crop-field="left" />
        <.input type="hidden" field={f_crop[:top]} data-crop-field="top" />
        <.input type="hidden" field={f_crop[:width]} data-crop-field="width" />
        <.input type="hidden" field={f_crop[:height]} data-crop-field="height" />
      </.inputs_for>
      <label :if={@upload} id={"#{@id}_crop_file_input"} for={@upload.ref}>
        <.live_file_input upload={@upload} class="sr-only" />
      </label>
      {render_slot(@inner_block)}
    </.form>
  </div>
  """
end
