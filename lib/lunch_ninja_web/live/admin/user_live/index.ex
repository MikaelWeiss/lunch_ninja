defmodule LunchNinjaWeb.Admin.UserLive.Index do
  use LunchNinjaWeb, :live_view

  alias LunchNinja.Accounts
  alias LunchNinja.Accounts.User

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    school_id = user.school_id

    users = Accounts.list_users(school_id)

    socket =
      socket
      |> assign(:users, users)
      |> assign(:school_id, school_id)
      |> assign(:show_modal, false)
      |> assign(:form_user, nil)
      |> assign(:form, nil)

    {:ok, socket}
  end

  def handle_event("new_user", _params, socket) do
    changeset = Accounts.change_user(%User{})

    socket =
      socket
      |> assign(:show_modal, true)
      |> assign(:form_user, nil)
      |> assign(:form, to_form(changeset))

    {:noreply, socket}
  end

  def handle_event("edit_user", %{"id" => id}, socket) do
    user = Accounts.get_user!(id)
    changeset = Accounts.change_user(user)

    socket =
      socket
      |> assign(:show_modal, true)
      |> assign(:form_user, user)
      |> assign(:form, to_form(changeset))

    {:noreply, socket}
  end

  def handle_event("close_modal", _params, socket) do
    {:noreply, assign(socket, :show_modal, false)}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    user_params = Map.put(user_params, "school_id", socket.assigns.school_id)

    result =
      if socket.assigns.form_user do
        Accounts.update_user(socket.assigns.form_user, user_params)
      else
        Accounts.create_user(user_params)
      end

    case result do
      {:ok, _user} ->
        users = Accounts.list_users(socket.assigns.school_id)

        socket =
          socket
          |> put_flash(:info, "User saved successfully")
          |> assign(:users, users)
          |> assign(:show_modal, false)

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  def handle_event("delete_user", %{"id" => id}, socket) do
    user = Accounts.get_user!(id)

    case Accounts.delete_user(user) do
      {:ok, _user} ->
        users = Accounts.list_users(socket.assigns.school_id)

        socket =
          socket
          |> put_flash(:info, "User deleted successfully")
          |> assign(:users, users)

        {:noreply, socket}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to delete user")}
    end
  end

  defp role_badge_class(:admin), do: "badge-primary"
  defp role_badge_class(:teacher), do: "badge-secondary"
  defp role_badge_class(:student), do: "badge-accent"

  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8 max-w-6xl">
      <div class="flex justify-between items-center mb-8">
        <div>
          <h1 class="text-3xl font-bold">User Management</h1>
          <p class="text-base-content/70">Manage users in your school</p>
        </div>
        <div class="flex gap-2">
          <.link navigate={~p"/admin"} class="btn btn-ghost btn-sm">
            <.icon name="hero-arrow-left" class="w-4 h-4" /> Back to Dashboard
          </.link>
        </div>
      </div>

      <div class="card bg-base-100 shadow-xl">
        <div class="card-body">
          <div class="flex justify-between items-center mb-4">
            <h2 class="card-title">All Users</h2>
            <button class="btn btn-primary btn-sm" phx-click="new_user">
              <.icon name="hero-plus" class="w-4 h-4" /> Add User
            </button>
          </div>

          <div class="overflow-x-auto">
            <table class="table table-zebra">
              <thead>
                <tr>
                  <th>Name</th>
                  <th>Email</th>
                  <th>Role</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                <%= for user <- @users do %>
                  <tr>
                    <td>{user.name}</td>
                    <td>{user.email}</td>
                    <td>
                      <span class={"badge #{role_badge_class(user.role)}"}>
                        {user.role}
                      </span>
                    </td>
                    <td>
                      <div class="flex gap-2">
                        <button
                          class="btn btn-ghost btn-xs"
                          phx-click="edit_user"
                          phx-value-id={user.id}
                        >
                          <.icon name="hero-pencil" class="w-4 h-4" />
                        </button>
                        <button
                          class="btn btn-ghost btn-xs text-error"
                          phx-click="delete_user"
                          phx-value-id={user.id}
                          data-confirm="Are you sure you want to delete this user?"
                        >
                          <.icon name="hero-trash" class="w-4 h-4" />
                        </button>
                      </div>
                    </td>
                  </tr>
                <% end %>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <%!-- User Form Modal --%>
      <%= if @show_modal do %>
        <div class="modal modal-open" phx-click="close_modal">
          <div class="modal-box" phx-click="noop">
            <h3 class="font-bold text-lg mb-4">
              {if @form_user, do: "Edit User", else: "Add New User"}
            </h3>

            <.form for={@form} phx-submit="save" class="space-y-4">
              <div class="form-control">
                <label class="label">
                  <span class="label-text">Name</span>
                </label>
                <.input field={@form[:name]} type="text" required />
              </div>

              <div class="form-control">
                <label class="label">
                  <span class="label-text">Email</span>
                </label>
                <.input field={@form[:email]} type="email" required />
              </div>

              <div class="form-control">
                <label class="label">
                  <span class="label-text">Role</span>
                </label>
                <.input
                  field={@form[:role]}
                  type="select"
                  options={[{"Student", "student"}, {"Teacher", "teacher"}, {"Admin", "admin"}]}
                  required
                />
              </div>

              <div class="modal-action">
                <button type="button" class="btn btn-ghost" phx-click="close_modal">
                  Cancel
                </button>
                <button type="submit" class="btn btn-primary">
                  Save
                </button>
              </div>
            </.form>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  def handle_event("noop", _params, socket) do
    {:noreply, socket}
  end
end
