defmodule DemoWeb.Router do
  use DemoWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {DemoWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", DemoWeb do
    pipe_through :browser

    get "/", PageController, :home

    live "/audio", DemoLive.Audio
    live "/copy-to-clipboard", DemoLive.CopyToClipboard
    live "/drag-drop-detector", DemoLive.DragDropDetector
    live "/focus-list", DemoLive.FocusList
    live "/movable", DemoLive.Movable
    live "/open-window", DemoLive.OpenWindow
    live "/prevent-unsaved-changes", DemoLive.PreventUnsavedChanges
    live "/sortable", DemoLive.Sortable
    live "/resizable", DemoLive.Resizable
    live "/right-click-menu", DemoLive.RightClickMenu
  end

  # Other scopes may use custom stacks.
  # scope "/api", DemoWeb do
  #   pipe_through :api
  # end
end
