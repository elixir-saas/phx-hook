defmodule DemoWeb.DemoLive.PreventUnsavedChanges do
  use DemoWeb, :live_view

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.button variant="primary" phx-click={JS.patch(~p"/prevent-unsaved-changes?view=new")}>
        Open modal (new user)
      </.button>

      <.button variant="primary" phx-click={JS.patch(~p"/prevent-unsaved-changes?view=existing")}>
        Open modal (existing user)
      </.button>

      <.modal
        id="demo_modal"
        open={@user != nil}
        on_close={JS.dispatch("phx:cancel", to: "##{@user_form.id}")}
      >
        <.header>
          Edit user
          <:subtitle>
            Unsaved changes will be prevented.
          </:subtitle>
        </.header>

        <.form
          id={@user_form.id}
          for={@user_form}
          phx-change="validate"
          phx-submit="submit"
          phx-hook="PreventUnsavedChanges"
          data-has-unsaved-changes={@user_form.source.changes != %{}}
          data-on-cancel={JS.patch(~p"/prevent-unsaved-changes")}
          data-confirm-message="u sure?"
        >
          <.input field={@user_form[:username]} label="Username" />
          <.input field={@user_form[:first_name]} label="First name" />
          <.input field={@user_form[:last_name]} label="Last name" />
        </.form>

        <:actions>
          <.button variant="primary" form={@user_form.id}>Submit</.button>
        </:actions>
      </.modal>
    </Layouts.app>
    """
  end

  def handle_params(params, _uri, socket) do
    user =
      case params do
        %{"view" => "new"} -> %{}
        %{"view" => "existing"} -> %{username: "userjohn12", first_name: "John"}
        _otherwise -> nil
      end

    {:noreply, socket |> assign(:user, user) |> put_form()}
  end

  def handle_event("validate", %{"user" => params}, socket) do
    changeset = Map.put(changeset(%{}, params), :action, :validate)
    {:noreply, put_form(socket, changeset)}
  end

  def handle_event("submit", %{"user" => params}, socket) do
    changeset = changeset(%{}, params)

    case Ecto.Changeset.apply_action(changeset, :insert) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Saved changes to user.")
         |> push_patch(to: ~p"/prevent-unsaved-changes")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, put_form(socket, changeset)}
    end
  end

  def put_form(socket, changeset \\ nil) do
    user = socket.assigns.user || %{}
    changeset = changeset || changeset(user, %{})
    assign(socket, :user_form, to_form(changeset, as: :user))
  end

  def changeset(data, params) do
    import Ecto.Changeset

    schema = %{
      username: :string,
      first_name: :string,
      last_name: :string
    }

    {data, schema}
    |> cast(params, [:username, :first_name, :last_name])
    |> validate_required([:username])
    |> validate_length(:username, max: 12)
  end

  ## Components

  attr :id, :string, required: true
  attr :open, :boolean, default: false
  attr :on_close, JS, default: nil

  slot :inner_block
  slot :actions

  def modal(assigns) do
    ~H"""
    <dialog id={@id} class={["modal", if(@open, do: "modal-open")]}>
      <div class="modal-box">
        <form method="dialog">
          <button phx-click={@on_close} class="btn btn-sm btn-circle btn-ghost absolute right-2 top-2">
            <.icon name="hero-x-mark" class="size-4" />
          </button>
        </form>
        {render_slot(@inner_block)}
        <div :if={@actions != []} class="modal-action">
          {render_slot(@actions)}
        </div>
      </div>
      <form method="dialog" class="modal-backdrop">
        <button phx-click={@on_close} class="!cursor-default">Close</button>
      </form>
    </dialog>
    """
  end
end
