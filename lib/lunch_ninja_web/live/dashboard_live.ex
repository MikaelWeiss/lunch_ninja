defmodule LunchNinjaWeb.DashboardLive do
  use LunchNinjaWeb, :live_view

  alias LunchNinja.Supabase

  @impl true
  def mount(_params, _session, socket) do
    access_token = socket.assigns.access_token
    user_email = socket.assigns.user_email

    user_profile =
      case Supabase.get_user_profile(user_email, access_token) do
        {:ok, profile} -> profile
        {:error, _} -> nil
      end

    {:ok,
     socket
     |> assign(:page_title, "Dashboard")
     |> assign(:user_profile, user_profile)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="space-y-8">
        <header class="flex items-center justify-between">
          <div>
            <h1 class="text-3xl font-bold tracking-tight">Welcome to Lunch Ninja</h1>
            <p class="mt-2 text-base-content/70">
              Ready to connect with someone new over lunch?
            </p>
          </div>
          <a href={~p"/sign-out"} class="btn btn-ghost btn-sm">
            <.icon name="hero-arrow-right-on-rectangle" class="size-5" /> Sign Out
          </a>
        </header>

        <div class="bg-base-200/50 border border-base-300 rounded-2xl p-6">
          <div class="flex items-center gap-4">
            <div class="w-14 h-14 rounded-full bg-gradient-to-br from-amber-400 to-orange-500 flex items-center justify-center text-white text-xl font-bold">
              {String.first(@user_email) |> String.upcase()}
            </div>
            <div>
              <p class="font-semibold text-lg">
                <%= if @user_profile && @user_profile["name"] do %>
                  {@user_profile["name"]}
                <% else %>
                  {@user_email}
                <% end %>
              </p>
              <p class="text-sm text-base-content/70">{@user_email}</p>
              <%= if @user_profile do %>
                <div class="flex items-center gap-2 mt-1">
                  <span class={[
                    "badge badge-sm",
                    @user_profile["role"] == "admin" && "badge-primary",
                    @user_profile["role"] == "professor" && "badge-secondary",
                    @user_profile["role"] == "student" && "badge-accent"
                  ]}>
                    {String.capitalize(@user_profile["role"] || "user")}
                  </span>
                  <%= if @user_profile["schools"] do %>
                    <span class="text-xs text-base-content/60">
                      {get_in(@user_profile, ["schools", "name"])}
                    </span>
                  <% end %>
                </div>
              <% end %>
            </div>
          </div>
        </div>

        <div class="grid gap-6 md:grid-cols-2">
          <div class="bg-base-200/50 border border-base-300 rounded-2xl p-6">
            <div class="flex items-center gap-3 mb-4">
              <div class="w-10 h-10 rounded-lg bg-amber-500/10 flex items-center justify-center">
                <.icon name="hero-calendar-days" class="size-5 text-amber-500" />
              </div>
              <h2 class="text-lg font-semibold">Your Availability</h2>
            </div>
            <p class="text-sm text-base-content/70 mb-4">
              Set your lunch availability for this week to get matched.
            </p>
            <button class="btn btn-primary btn-sm" disabled>
              Coming Soon
            </button>
          </div>

          <div class="bg-base-200/50 border border-base-300 rounded-2xl p-6">
            <div class="flex items-center gap-3 mb-4">
              <div class="w-10 h-10 rounded-lg bg-orange-500/10 flex items-center justify-center">
                <.icon name="hero-user-group" class="size-5 text-orange-500" />
              </div>
              <h2 class="text-lg font-semibold">Your Matches</h2>
            </div>
            <p class="text-sm text-base-content/70 mb-4">
              View your upcoming lunch matches and past connections.
            </p>
            <button class="btn btn-secondary btn-sm" disabled>
              Coming Soon
            </button>
          </div>
        </div>

        <div class="bg-gradient-to-br from-amber-500/10 to-orange-500/10 border border-amber-500/20 rounded-2xl p-6">
          <div class="flex items-start gap-4">
            <div class="w-12 h-12 rounded-lg bg-amber-500/20 flex items-center justify-center flex-shrink-0">
              <.icon name="hero-sparkles" class="size-6 text-amber-500" />
            </div>
            <div>
              <h3 class="text-lg font-semibold mb-2">Get Started</h3>
              <p class="text-base-content/70">
                We're currently building out the matching features. In the meantime, feel free to explore
                the dashboard. We'll notify you when you can start setting your availability and getting
                matched with lunch buddies!
              </p>
            </div>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
