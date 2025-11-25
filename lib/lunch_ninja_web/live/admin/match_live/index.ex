defmodule LunchNinjaWeb.Admin.MatchLive.Index do
  use LunchNinjaWeb, :live_view

  alias LunchNinja.{Accounts, Scheduling}

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    school_id = user.school_id

    # Get all users in the school
    users = Accounts.list_users(school_id)

    # Get matches for the next 30 days
    today = Date.utc_today()
    start_date = Date.add(today, -30)
    end_date = Date.add(today, 30)

    # Collect all matches for users in this school
    matches =
      users
      |> Enum.flat_map(fn user ->
        Scheduling.list_matches(user.id, start_date, end_date)
      end)
      |> Enum.uniq_by(& &1.id)
      |> Enum.sort_by(& &1.date, {:desc, Date})

    socket =
      socket
      |> assign(:matches, matches)
      |> assign(:filter, "all")

    {:ok, socket}
  end

  def handle_event("filter", %{"filter" => filter}, socket) do
    {:noreply, assign(socket, :filter, filter)}
  end

  defp filter_matches(matches, "all"), do: matches

  defp filter_matches(matches, "upcoming") do
    today = Date.utc_today()

    Enum.filter(matches, fn match ->
      Date.compare(match.date, today) in [:gt, :eq]
    end)
  end

  defp filter_matches(matches, "past") do
    today = Date.utc_today()

    Enum.filter(matches, fn match ->
      Date.compare(match.date, today) == :lt
    end)
  end

  defp filter_matches(matches, "cancelled") do
    Enum.filter(matches, fn match ->
      match.status in [:cancelled_by_user1, :cancelled_by_user2, :cancelled_by_both]
    end)
  end

  defp status_badge_class(:scheduled), do: "badge-success"
  defp status_badge_class(:completed), do: "badge-info"
  defp status_badge_class(_), do: "badge-error"

  defp format_status(:scheduled), do: "Scheduled"
  defp format_status(:completed), do: "Completed"
  defp format_status(:cancelled_by_user1), do: "Cancelled"
  defp format_status(:cancelled_by_user2), do: "Cancelled"
  defp format_status(:cancelled_by_both), do: "Cancelled"

  defp format_date(date) do
    Calendar.strftime(date, "%a, %b %-d, %Y")
  end

  defp format_time_range(time_slot) do
    start_str = Calendar.strftime(time_slot.start_time, "%-I:%M %p")
    end_str = Calendar.strftime(time_slot.end_time, "%-I:%M %p")
    "#{start_str} - #{end_str}"
  end

  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8 max-w-6xl">
      <div class="flex justify-between items-center mb-8">
        <div>
          <h1 class="text-3xl font-bold">Match History</h1>
          <p class="text-base-content/70">View all lunch matches</p>
        </div>
        <div class="flex gap-2">
          <.link navigate={~p"/admin"} class="btn btn-ghost btn-sm">
            <.icon name="hero-arrow-left" class="w-4 h-4" /> Back to Dashboard
          </.link>
        </div>
      </div>

      <%!-- Filters --%>
      <div class="flex gap-2 mb-6">
        <button
          class={"btn btn-sm #{if @filter == "all", do: "btn-primary", else: "btn-ghost"}"}
          phx-click="filter"
          phx-value-filter="all"
        >
          All Matches
        </button>
        <button
          class={"btn btn-sm #{if @filter == "upcoming", do: "btn-primary", else: "btn-ghost"}"}
          phx-click="filter"
          phx-value-filter="upcoming"
        >
          Upcoming
        </button>
        <button
          class={"btn btn-sm #{if @filter == "past", do: "btn-primary", else: "btn-ghost"}"}
          phx-click="filter"
          phx-value-filter="past"
        >
          Past
        </button>
        <button
          class={"btn btn-sm #{if @filter == "cancelled", do: "btn-primary", else: "btn-ghost"}"}
          phx-click="filter"
          phx-value-filter="cancelled"
        >
          Cancelled
        </button>
      </div>

      <div class="card bg-base-100 shadow-xl">
        <div class="card-body">
          <% filtered_matches = filter_matches(@matches, @filter) %>

          <%= if filtered_matches == [] do %>
            <div class="text-center py-12">
              <p class="text-base-content/70 text-lg">No matches found</p>
            </div>
          <% else %>
            <div class="overflow-x-auto">
              <table class="table table-zebra">
                <thead>
                  <tr>
                    <th>Date</th>
                    <th>Time Slot</th>
                    <th>User 1</th>
                    <th>User 2</th>
                    <th>Status</th>
                    <th>Created By</th>
                  </tr>
                </thead>
                <tbody>
                  <%= for match <- filtered_matches do %>
                    <tr>
                      <td>{format_date(match.date)}</td>
                      <td>
                        <div class="flex flex-col">
                          <span class="font-medium">{match.time_slot.name}</span>
                          <span class="text-xs text-base-content/60">
                            {format_time_range(match.time_slot)}
                          </span>
                        </div>
                      </td>
                      <td>
                        <div class="flex flex-col">
                          <span>{match.user1.name}</span>
                          <span class="text-xs text-base-content/60">{match.user1.email}</span>
                        </div>
                      </td>
                      <td>
                        <div class="flex flex-col">
                          <span>{match.user2.name}</span>
                          <span class="text-xs text-base-content/60">{match.user2.email}</span>
                        </div>
                      </td>
                      <td>
                        <span class={"badge #{status_badge_class(match.status)}"}>
                          {format_status(match.status)}
                        </span>
                      </td>
                      <td>
                        <span class="badge badge-ghost">
                          {match.created_by}
                        </span>
                      </td>
                    </tr>
                  <% end %>
                </tbody>
              </table>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end
end
