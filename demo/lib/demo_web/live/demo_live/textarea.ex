defmodule DemoWeb.DemoLive.Textarea do
  use DemoWeb, :live_view

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Textarea
        <:subtitle>
          Resize a textarea to its contents as a user types.
          <.source_link source_url={demo_source_url()} />
        </:subtitle>
      </.header>

      <div :if={@messages != []} class="flex flex-col-reverse gap-4">
        <div :for={message <- @messages} class="bg-base-200 p-4 rounded">
          <p :for={line <- String.split(message, "\n")} class="text-sm min-h-[1lh] break-all">
            {line}
          </p>
        </div>
      </div>

      <.form for={@form} phx-submit="submit" phx-change="validate">
        <.input
          type="textarea"
          field={@form[:message]}
          placeholder="Type here, I'll adapt to my contents!"
          phx-hook="Textarea"
          data-max-height="250"
          data-submit-on-enter={@form[:submit_on_enter].value == "true"}
        />
        <.button type="submit" variant="primary">
          Send
        </.button>
        <div class="mt-4">
          <.input
            type="checkbox"
            field={@form[:submit_on_enter]}
            label="Submit on enter (data-submit-on-enter)"
          />
        </div>
      </.form>
    </Layouts.app>
    """
  end

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:messages, [])
     |> put_form(%{"submit_on_enter" => "false"})}
  end

  def handle_event("validate", %{"form" => params}, socket) do
    {:noreply, put_form(socket, params)}
  end

  def handle_event("submit", %{"form" => params}, socket) do
    case Ecto.Changeset.apply_action(changeset(params), :insert) do
      {:ok, %{message: message}} ->
        {:noreply,
         socket
         |> update(:messages, &[message | &1])
         |> put_form(%{"submit_on_enter" => params["submit_on_enter"]})}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, put_form(socket, changeset)}
    end
  end

  def put_form(socket, params \\ %{})

  def put_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset, as: :form))
  end

  def put_form(socket, params) do
    put_form(socket, changeset(params))
  end

  def changeset(params) do
    {%{}, %{message: :string, submit_on_enter: :boolean}}
    |> Ecto.Changeset.cast(params, [:message])
    |> Ecto.Changeset.validate_required([:message])
  end
end
