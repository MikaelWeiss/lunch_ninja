defmodule LunchNinjaWeb.Admin.TimeSlotLive.Index do
  use LunchNinjaWeb, :live_view

  alias LunchNinja.Organizations
  alias LunchNinja.Organizations.TimeSlot

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    school_id = user.school_id

    time_slots = Organizations.list_all_time_slots(school_id)

    socket =
      socket
      |> assign(:time_slots, time_slots)
      |> assign(:school_id, school_id)
      |> assign(:show_modal, false)
      |> assign(:form_time_slot, nil)
      |> assign(:form, nil)

    {:ok, socket}
  end

  def handle_event("new_time_slot", _params, socket) do
    changeset = Organizations.change_time_slot(%TimeSlot{})

    socket =
      socket
      |> assign(:show_modal, true)
      |> assign(:form_time_slot, nil)
      |> assign(:form, to_form(changeset))

    {:noreply, socket}
  end

  def handle_event("edit_time_slot", %{"id" => id}, socket) do
    time_slot = Organizations.get_time_slot!(id)
    changeset = Organizations.change_time_slot(time_slot)

    socket =
      socket
      |> assign(:show_modal, true)
      |> assign(:form_time_slot, time_slot)
      |> assign(:form, to_form(changeset))

    {:noreply, socket}
  end

  def handle_event("close_modal", _params, socket) do
    {:noreply, assign(socket, :show_modal, false)}
  end

  def handle_event("save", %{"time_slot" => time_slot_params}, socket) do
    time_slot_params = Map.put(time_slot_params, "school_id", socket.assigns.school_id)

    result =
      if socket.assigns.form_time_slot do
        Organizations.update_time_slot(socket.assigns.form_time_slot, time_slot_params)
      else
        Organizations.create_time_slot(time_slot_params)
      end

    case result do
      {:ok, _time_slot} ->
        time_slots = Organizations.list_all_time_slots(socket.assigns.school_id)

        socket =
          socket
          |> put_flash(:info, "Time slot saved successfully")
          |> assign(:time_slots, time_slots)
          |> assign(:show_modal, false)

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  def handle_event("toggle_active", %{"id" => id}, socket) do
    time_slot = Organizations.get_time_slot!(id)

    result =
      if time_slot.active do
        Organizations.deactivate_time_slot(time_slot)
      else
        Organizations.activate_time_slot(time_slot)
      end

    case result do
      {:ok, _time_slot} ->
        time_slots = Organizations.list_all_time_slots(socket.assigns.school_id)

        socket =
          socket
          |> put_flash(:info, "Time slot updated successfully")
          |> assign(:time_slots, time_slots)

        {:noreply, socket}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to update time slot")}
    end
  end

  def handle_event("delete_time_slot", %{"id" => id}, socket) do
    time_slot = Organizations.get_time_slot!(id)

    case Organizations.delete_time_slot(time_slot) do
      {:ok, _time_slot} ->
        time_slots = Organizations.list_all_time_slots(socket.assigns.school_id)

        socket =
          socket
          |> put_flash(:info, "Time slot deleted successfully")
          |> assign(:time_slots, time_slots)

        {:noreply, socket}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to delete time slot")}
    end
  end

  defp format_time(time) do
    Calendar.strftime(time, "%-I:%M %p")
  end

  defp format_time_range(time_slot) do
    "#{format_time(time_slot.start_time)} - #{format_time(time_slot.end_time)}"
  end

  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8 max-w-6xl">
      <div class="flex justify-between items-center mb-8">
        <div>
          <h1 class="text-3xl font-bold">Time Slot Configuration</h1>
          <p class="text-base-content/70">Manage lunch time slots for your school</p>
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
            <h2 class="card-title">Time Slots</h2>
            <button class="btn btn-primary btn-sm" phx-click="new_time_slot">
              <.icon name="hero-plus" class="w-4 h-4" /> Add Time Slot
            </button>
          </div>

          <div class="overflow-x-auto">
            <table class="table table-zebra">
              <thead>
                <tr>
                  <th>Name</th>
                  <th>Time Range</th>
                  <th>Status</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                <%= for time_slot <- @time_slots do %>
                  <% deleted = !is_nil(time_slot.deleted_at) %>
                  <tr class={if deleted, do: "opacity-50"}>
                    <td>{time_slot.name}</td>
                    <td>{format_time_range(time_slot)}</td>
                    <td>
                      <%= cond do %>
                        <% deleted -> %>
                          <span class="badge badge-error">Deleted</span>
                        <% time_slot.active -> %>
                          <span class="badge badge-success">Active</span>
                        <% true -> %>
                          <span class="badge badge-warning">Inactive</span>
                      <% end %>
                    </td>
                    <td>
                      <div class="flex gap-2">
                        <%= if !deleted do %>
                          <button
                            class="btn btn-ghost btn-xs"
                            phx-click="edit_time_slot"
                            phx-value-id={time_slot.id}
                          >
                            <.icon name="hero-pencil" class="w-4 h-4" />
                          </button>
                          <button
                            class="btn btn-ghost btn-xs"
                            phx-click="toggle_active"
                            phx-value-id={time_slot.id}
                          >
                            <%= if time_slot.active do %>
                              <.icon name="hero-pause" class="w-4 h-4" />
                            <% else %>
                              <.icon name="hero-play" class="w-4 h-4" />
                            <% end %>
                          </button>
                          <button
                            class="btn btn-ghost btn-xs text-error"
                            phx-click="delete_time_slot"
                            phx-value-id={time_slot.id}
                            data-confirm="Are you sure you want to delete this time slot?"
                          >
                            <.icon name="hero-trash" class="w-4 h-4" />
                          </button>
                        <% end %>
                      </div>
                    </td>
                  </tr>
                <% end %>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <%!-- Time Slot Form Modal --%>
      <%= if @show_modal do %>
        <div class="modal modal-open" phx-click="close_modal">
          <div class="modal-box" phx-click="noop">
            <h3 class="font-bold text-lg mb-4">
              {if @form_time_slot, do: "Edit Time Slot", else: "Add New Time Slot"}
            </h3>

            <.form for={@form} phx-submit="save" class="space-y-4">
              <div class="form-control">
                <label class="label">
                  <span class="label-text">Name</span>
                </label>
                <.input field={@form[:name]} type="text" placeholder="e.g., Early Lunch" required />
              </div>

              <div class="grid grid-cols-2 gap-4">
                <div class="form-control">
                  <label class="label">
                    <span class="label-text">Start Time</span>
                  </label>
                  <.input field={@form[:start_time]} type="time" required />
                </div>

                <div class="form-control">
                  <label class="label">
                    <span class="label-text">End Time</span>
                  </label>
                  <.input field={@form[:end_time]} type="time" required />
                </div>
              </div>

              <div class="form-control">
                <label class="label cursor-pointer">
                  <span class="label-text">Active</span>
                  <.input field={@form[:active]} type="checkbox" />
                </label>
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
