defmodule LunchNinjaWeb.HomeLive do
  use LunchNinjaWeb, :live_view

  alias LunchNinja.{Organizations, Scheduling}

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    school_id = user.school_id

    # Load time slots for the user's school
    time_slots = Organizations.list_time_slots(school_id)

    # Get next 7 days starting from today
    today = Date.utc_today()
    dates = Enum.map(0..6, fn days -> Date.add(today, days) end)

    # Get user's current availability
    start_date = today
    end_date = Date.add(today, 6)
    availability = Scheduling.get_user_availability(user.id, start_date, end_date)

    # Get user's upcoming matches
    matches = Scheduling.list_matches(user.id, today, Date.add(today, 30))

    socket =
      socket
      |> assign(:time_slots, time_slots)
      |> assign(:dates, dates)
      |> assign(:availability, availability)
      |> assign(:matches, matches)
      |> assign(:selected_match, nil)

    {:ok, socket}
  end

  def handle_event(
        "toggle_availability",
        %{"date" => date_str, "time_slot_id" => time_slot_id},
        socket
      ) do
    user = socket.assigns.current_user
    date = Date.from_iso8601!(date_str)

    # Check if availability already exists
    existing =
      Enum.find(socket.assigns.availability, fn a ->
        a.time_slot_id == time_slot_id && a.date == date
      end)

    if existing do
      Scheduling.remove_availability(user.id, time_slot_id, date)
    else
      Scheduling.set_availability(user.id, time_slot_id, date)
    end

    # Refresh availability
    availability =
      Scheduling.get_user_availability(
        user.id,
        List.first(socket.assigns.dates),
        List.last(socket.assigns.dates)
      )

    {:noreply, assign(socket, :availability, availability)}
  end

  def handle_event("show_match", %{"match_id" => match_id}, socket) do
    match = Enum.find(socket.assigns.matches, &(&1.id == match_id))
    {:noreply, assign(socket, :selected_match, match)}
  end

  def handle_event("close_modal", _, socket) do
    {:noreply, assign(socket, :selected_match, nil)}
  end

  def handle_event("noop", _, socket) do
    {:noreply, socket}
  end

  def handle_event("cancel_match", %{"match_id" => match_id}, socket) do
    user = socket.assigns.current_user
    match = Scheduling.get_match!(match_id)

    case Scheduling.cancel_match(match, user.id) do
      {:ok, _updated_match} ->
        # Refresh matches
        today = Date.utc_today()
        matches = Scheduling.list_matches(user.id, today, Date.add(today, 30))

        socket =
          socket
          |> put_flash(:info, "Match cancelled successfully")
          |> assign(:matches, matches)
          |> assign(:selected_match, nil)

        {:noreply, socket}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to cancel match")}
    end
  end

  defp is_available?(availability, date, time_slot_id) do
    Enum.any?(availability, fn a ->
      a.date == date && a.time_slot_id == time_slot_id
    end)
  end

  defp get_partner(match, current_user_id) do
    if match.user1_id == current_user_id, do: match.user2, else: match.user1
  end

  defp past_date?(date) do
    Date.compare(date, Date.utc_today()) == :lt
  end

  defp format_date(date) do
    Calendar.strftime(date, "%a, %b %-d")
  end

  defp format_time_range(time_slot) do
    start_str = Calendar.strftime(time_slot.start_time, "%-I:%M %p")
    end_str = Calendar.strftime(time_slot.end_time, "%-I:%M %p")
    "#{start_str} - #{end_str}"
  end

  defp match_cancelled?(match, user_id) do
    (match.user1_id == user_id && match.status in [:cancelled_by_user1, :cancelled_by_both]) ||
      (match.user2_id == user_id && match.status in [:cancelled_by_user2, :cancelled_by_both])
  end

  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8 max-w-6xl">
      <div class="flex justify-between items-center mb-8">
        <div>
          <h1 class="text-3xl font-bold">Welcome, {@current_user.name}</h1>
          <p class="text-base-content/70">Set your availability for the next week</p>
        </div>
        <.form for={%{}} action={~p"/auth/logout"} method="post">
          <button type="submit" class="btn btn-ghost btn-sm">
            Sign Out
          </button>
        </.form>
      </div>

      <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
        <%!-- Availability Calendar --%>
        <div class="card bg-base-100 shadow-xl">
          <div class="card-body">
            <h2 class="card-title">Your Availability</h2>
            <p class="text-sm text-base-content/70 mb-4">
              Check the boxes when you're free for lunch
            </p>

            <div class="overflow-x-auto">
              <table class="table table-sm">
                <thead>
                  <tr>
                    <th>Time Slot</th>
                    <%= for date <- @dates do %>
                      <th class="text-center">
                        <div class="flex flex-col">
                          <span class="font-semibold">{Calendar.strftime(date, "%a")}</span>
                          <span class="text-xs">{Calendar.strftime(date, "%-m/%-d")}</span>
                        </div>
                      </th>
                    <% end %>
                  </tr>
                </thead>
                <tbody>
                  <%= for time_slot <- @time_slots do %>
                    <tr>
                      <td>
                        <div class="flex flex-col">
                          <span class="font-medium">{time_slot.name}</span>
                          <span class="text-xs text-base-content/60">
                            {format_time_range(time_slot)}
                          </span>
                        </div>
                      </td>
                      <%= for date <- @dates do %>
                        <td class="text-center">
                          <input
                            type="checkbox"
                            class="checkbox checkbox-primary"
                            checked={is_available?(@availability, date, time_slot.id)}
                            disabled={past_date?(date)}
                            phx-click="toggle_availability"
                            phx-value-date={Date.to_iso8601(date)}
                            phx-value-time_slot_id={time_slot.id}
                          />
                        </td>
                      <% end %>
                    </tr>
                  <% end %>
                </tbody>
              </table>
            </div>
          </div>
        </div>

        <%!-- Upcoming Matches --%>
        <div class="card bg-base-100 shadow-xl">
          <div class="card-body">
            <h2 class="card-title">Upcoming Lunches</h2>

            <%= if @matches == [] do %>
              <div class="text-center py-8">
                <p class="text-base-content/70">No upcoming lunches yet</p>
                <p class="text-sm text-base-content/50">Set your availability to get matched!</p>
              </div>
            <% else %>
              <div class="space-y-3">
                <%= for match <- @matches do %>
                  <% partner = get_partner(match, @current_user.id) %>
                  <% cancelled = match_cancelled?(match, @current_user.id) %>

                  <div class={"card bg-base-200 hover:bg-base-300 cursor-pointer transition-colors #{if cancelled, do: "opacity-50"}"}>
                    <div class="card-body p-4" phx-click="show_match" phx-value-match_id={match.id}>
                      <div class="flex justify-between items-start">
                        <div>
                          <p class="font-semibold">{partner.name}</p>
                          <p class="text-sm text-base-content/70">
                            {format_date(match.date)} · {match.time_slot.name}
                          </p>
                          <%= if cancelled do %>
                            <span class="badge badge-sm badge-error mt-1">Cancelled</span>
                          <% end %>
                        </div>
                        <.icon name="hero-chevron-right" class="w-5 h-5 text-base-content/50" />
                      </div>
                    </div>
                  </div>
                <% end %>
              </div>
            <% end %>
          </div>
        </div>
      </div>

      <%!-- Match Details Modal --%>
      <%= if @selected_match do %>
        <% partner = get_partner(@selected_match, @current_user.id) %>
        <% cancelled = match_cancelled?(@selected_match, @current_user.id) %>

        <div class="modal modal-open" phx-click="close_modal">
          <div class="modal-box" phx-click="noop">
            <h3 class="font-bold text-lg mb-4">Lunch Details</h3>

            <div class="space-y-4">
              <div>
                <p class="text-sm text-base-content/70">Lunch with</p>
                <p class="text-xl font-semibold">{partner.name}</p>
                <p class="text-sm text-base-content/60">{partner.email}</p>
              </div>

              <div>
                <p class="text-sm text-base-content/70">When</p>
                <p class="font-medium">{Calendar.strftime(@selected_match.date, "%A, %B %-d, %Y")}</p>
              </div>

              <div>
                <p class="text-sm text-base-content/70">Time</p>
                <p class="font-medium">{format_time_range(@selected_match.time_slot)}</p>
              </div>

              <%= if cancelled do %>
                <div class="alert alert-error">
                  <.icon name="hero-x-circle" class="w-5 h-5" />
                  <span>This lunch has been cancelled</span>
                </div>
              <% end %>
            </div>

            <div class="modal-action">
              <%= if !cancelled && !past_date?(@selected_match.date) do %>
                <button
                  type="button"
                  class="btn btn-error btn-sm"
                  phx-click="cancel_match"
                  phx-value-match_id={@selected_match.id}
                  data-confirm="Are you sure you want to cancel this lunch?"
                >
                  Cancel Lunch
                </button>
              <% end %>
              <button type="button" class="btn btn-sm" phx-click="close_modal">
                Close
              </button>
            </div>
          </div>
        </div>
      <% end %>
    </div>
    """
  end
end
