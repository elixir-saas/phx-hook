defmodule DemoWeb.PageController do
  use DemoWeb, :controller

  def home(conn, _params) do
    hooks = [
      %{name: "audio", description: "Play audio following a user interaction."},
      %{name: "copy-to-clipboard", description: "Copy values to the clipboard."},
      %{name: "crop-image", description: "Crop images to a specified size for upload."},
      %{name: "drag-drop-detector", description: "Add classes for drag and drop events."},
      %{name: "focus-list", description: "Focus items in a list with keyboard shortcuts."},
      %{name: "movable", description: "Allow users to move and resize elements freely."},
      %{name: "open-window", description: "Open new, configurable windows on click."},
      %{
        name: "prevent-unsaved-changes",
        description: "Prompt users to prevent losing unsaved changes."
      },
      %{name: "resizable", description: "Resize the width or height of elements."},
      %{name: "right-click-menu", description: "Open custom context menus on right click."},
      %{name: "sortable", description: "Easy drag-and-drop sorting with Sortable.js."}
    ]

    render(conn, :home, hooks: hooks)
  end
end
