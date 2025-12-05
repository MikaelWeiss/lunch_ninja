defmodule LunchNinjaWeb.ContactSalesLive do
  use LunchNinjaWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Contact Sales")
     |> assign(:form, to_form(%{"name" => "", "email" => "", "school" => "", "message" => ""}))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen">
      <header class="flex items-center justify-between px-6 py-4 lg:px-12 xl:px-20">
        <a href={~p"/"} class="flex items-center gap-2">
          <span class="text-2xl">🥷</span>
          <span class="text-xl font-bold tracking-tight">Lunch Ninja</span>
        </a>
        <nav class="flex items-center gap-4">
          <Layouts.theme_toggle />
          <a href={~p"/sign-in"} class="btn btn-ghost">Sign In</a>
        </nav>
      </header>

      <main class="px-6 py-12 lg:px-12 xl:px-20">
        <div class="mx-auto max-w-2xl">
          <div class="text-center mb-12">
            <h1 class="text-4xl font-bold tracking-tight">Bring Lunch Ninja to Your Campus</h1>
            <p class="mt-4 text-lg text-base-content/70">
              Tell us about your school and we'll get back to you within 24 hours.
            </p>
          </div>

          <div class="bg-base-200/50 border border-base-300 rounded-2xl p-8">
            <.form for={@form} id="contact-sales-form" phx-submit="submit" class="space-y-6">
              <.input
                field={@form[:name]}
                type="text"
                label="Your Name"
                placeholder="Jane Smith"
                required
              />

              <.input
                field={@form[:email]}
                type="email"
                label="Work Email"
                placeholder="jane@university.edu"
                required
              />

              <.input
                field={@form[:school]}
                type="text"
                label="School / University"
                placeholder="Stanford University"
                required
              />

              <.input
                field={@form[:message]}
                type="textarea"
                label="Tell us about your needs"
                placeholder="How many students/faculty do you expect to participate? Any specific requirements?"
                rows="4"
              />

              <div class="pt-4">
                <button type="submit" class="btn btn-primary btn-lg w-full">
                  Send Message <.icon name="hero-paper-airplane" class="size-5 ml-2" />
                </button>
              </div>
            </.form>
          </div>

          <div class="mt-12 text-center">
            <p class="text-sm text-base-content/60">
              Already have an account?
              <a href={~p"/sign-in"} class="text-primary hover:underline ml-1">
                Sign in here
              </a>
            </p>
          </div>
        </div>
      </main>
    </div>
    """
  end

  @impl true
  def handle_event(
        "submit",
        %{"name" => name, "email" => email, "school" => school, "message" => message},
        socket
      ) do
    IO.inspect(%{name: name, email: email, school: school, message: message},
      label: "Contact Sales Submission"
    )

    {:noreply,
     socket
     |> put_flash(:info, "Thanks for reaching out! We'll be in touch within 24 hours.")
     |> assign(:form, to_form(%{"name" => "", "email" => "", "school" => "", "message" => ""}))}
  end
end
