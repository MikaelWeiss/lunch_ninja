defmodule LunchNinjaWeb.Admin.DashboardLive do
  use LunchNinjaWeb, :live_view

  alias LunchNinja.{Accounts, Scheduling}

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    school_id = user.school_id

    # Calculate stats
    total_users = length(Accounts.list_users(school_id))

    today = Date.utc_today()
    week_start = Date.beginning_of_week(today)
    week_end = Date.end_of_week(today)

    # Get all users to count matches
    users = Accounts.list_users(school_id)

    matches_this_week =
      users
      |> Enum.flat_map(fn user ->
        Scheduling.list_matches(user.id, week_start, week_end)
      end)
      |> Enum.uniq_by(& &1.id)
      |> length()

    socket =
      socket
      |> assign(:total_users, total_users)
      |> assign(:matches_this_week, matches_this_week)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8 max-w-6xl">
      <div class="flex justify-between items-center mb-8">
        <div>
          <h1 class="text-3xl font-bold">Admin Dashboard</h1>
          <p class="text-base-content/70">Manage your school's LunchNinja</p>
        </div>
        <div class="flex gap-2">
          <.link navigate={~p"/home"} class="btn btn-ghost btn-sm">
            Back to Home
          </.link>
          <.form for={%{}} action={~p"/auth/logout"} method="post">
            <button type="submit" class="btn btn-ghost btn-sm">
              Sign Out
            </button>
          </.form>
        </div>
      </div>

      <%!-- Stats Cards --%>
      <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
        <div class="stats shadow">
          <div class="stat">
            <div class="stat-figure text-primary">
              <.icon name="hero-user-group" class="w-8 h-8" />
            </div>
            <div class="stat-title">Total Users</div>
            <div class="stat-value text-primary">{@total_users}</div>
            <div class="stat-desc">Students, teachers, and admins</div>
          </div>
        </div>

        <div class="stats shadow">
          <div class="stat">
            <div class="stat-figure text-secondary">
              <.icon name="hero-calendar" class="w-8 h-8" />
            </div>
            <div class="stat-title">Matches This Week</div>
            <div class="stat-value text-secondary">{@matches_this_week}</div>
            <div class="stat-desc">Lunches scheduled</div>
          </div>
        </div>
      </div>

      <%!-- Quick Actions --%>
      <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
        <.link
          navigate={~p"/admin/users"}
          class="card bg-base-100 shadow-xl hover:shadow-2xl transition-shadow"
        >
          <div class="card-body">
            <h2 class="card-title">
              <.icon name="hero-users" class="w-6 h-6" /> Manage Users
            </h2>
            <p>Add, edit, or remove users from your school</p>
            <div class="card-actions justify-end">
              <button class="btn btn-primary btn-sm">View Users</button>
            </div>
          </div>
        </.link>

        <.link
          navigate={~p"/admin/time-slots"}
          class="card bg-base-100 shadow-xl hover:shadow-2xl transition-shadow"
        >
          <div class="card-body">
            <h2 class="card-title">
              <.icon name="hero-clock" class="w-6 h-6" /> Time Slots
            </h2>
            <p>Configure lunch time slots for your school</p>
            <div class="card-actions justify-end">
              <button class="btn btn-primary btn-sm">Configure</button>
            </div>
          </div>
        </.link>

        <.link
          navigate={~p"/admin/matches"}
          class="card bg-base-100 shadow-xl hover:shadow-2xl transition-shadow"
        >
          <div class="card-body">
            <h2 class="card-title">
              <.icon name="hero-calendar-days" class="w-6 h-6" /> View Matches
            </h2>
            <p>See all scheduled and past lunch matches</p>
            <div class="card-actions justify-end">
              <button class="btn btn-primary btn-sm">View All</button>
            </div>
          </div>
        </.link>
      </div>
    </div>
    """
  end
end
