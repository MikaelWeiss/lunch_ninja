defmodule LunchNinjaWeb.SignInLive do
  use LunchNinjaWeb, :live_view

  alias LunchNinja.Supabase

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Sign In")
     |> assign(:form, to_form(%{"email" => ""}))
     |> assign(:submitted, false)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen flex flex-col">
      <header class="flex items-center justify-between px-6 py-4 lg:px-12 xl:px-20">
        <a href={~p"/"} class="flex items-center gap-2">
          <span class="text-2xl">🥷</span>
          <span class="text-xl font-bold tracking-tight">Lunch Ninja</span>
        </a>
        <nav class="flex items-center gap-4">
          <Layouts.theme_toggle />
        </nav>
      </header>

      <main class="flex-1 flex items-center justify-center px-6 py-12">
        <div class="w-full max-w-md">
          <div class="text-center mb-10">
            <h1 class="text-3xl font-bold tracking-tight">Welcome back</h1>
            <p class="mt-3 text-base-content/70">
              Sign in to access your Lunch Ninja account
            </p>
          </div>

          <div class="bg-base-200/50 border border-base-300 rounded-2xl p-8">
            <%= if @submitted do %>
              <div class="text-center py-6">
                <div class="w-16 h-16 mx-auto mb-6 rounded-full bg-success/10 flex items-center justify-center">
                  <.icon name="hero-envelope" class="size-8 text-success" />
                </div>
                <h2 class="text-xl font-semibold mb-2">Check your email</h2>
                <p class="text-base-content/70">
                  We sent a sign in link to your email address if it exists in our database.
                </p>
                <button
                  type="button"
                  phx-click="reset"
                  class="btn btn-ghost mt-6"
                >
                  Try a different email
                </button>
              </div>
            <% else %>
              <.form for={@form} id="sign-in-form" phx-submit="submit" class="space-y-6">
                <.input
                  field={@form[:email]}
                  type="email"
                  label="Email address"
                  placeholder="you@university.edu"
                  required
                  autocomplete="email"
                />

                <div class="pt-2">
                  <button type="submit" class="btn btn-primary btn-lg w-full">
                    Send Sign In Link <.icon name="hero-arrow-right" class="size-5 ml-2" />
                  </button>
                </div>
              </.form>

              <div class="divider my-8 text-base-content/40 text-sm">Don't have access?</div>

              <p class="text-center text-sm text-base-content/70">
                Lunch Ninja is available for schools.
                <a href={~p"/contact-sales"} class="text-primary hover:underline">
                  Contact sales
                </a>
                to get started.
              </p>
            <% end %>
          </div>
        </div>
      </main>
    </div>
    """
  end

  @impl true
  def handle_event("submit", %{"email" => email}, socket) do
    email = String.trim(email) |> String.downcase()

    redirect_url = LunchNinjaWeb.Endpoint.url() <> "/auth/callback"

    case Supabase.email_exists?(email) do
      {:ok, true} ->
        case Supabase.send_magic_link(email, redirect_url) do
          :ok ->
            {:noreply, assign(socket, :submitted, true)}

          {:error, _reason} ->
            {:noreply, assign(socket, :submitted, true)}
        end

      {:ok, false} ->
        {:noreply, assign(socket, :submitted, true)}

      {:error, _reason} ->
        {:noreply, assign(socket, :submitted, true)}
    end
  end

  @impl true
  def handle_event("reset", _params, socket) do
    {:noreply,
     socket
     |> assign(:submitted, false)
     |> assign(:form, to_form(%{"email" => ""}))}
  end
end
