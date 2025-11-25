defmodule LunchNinjaWeb.LandingLive do
  use LunchNinjaWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-b from-base-200 to-base-100">
      <%!-- Header --%>
      <div class="navbar bg-base-100 shadow-lg">
        <div class="flex-1">
          <span class="btn btn-ghost text-xl">🥷 LunchNinja</span>
        </div>
        <div class="flex-none">
          <.link navigate={~p"/auth/login"} class="btn btn-primary">
            Sign In
          </.link>
        </div>
      </div>

      <%!-- Hero Section --%>
      <div class="hero min-h-[600px]">
        <div class="hero-content text-center">
          <div class="max-w-3xl">
            <h1 class="text-5xl font-bold mb-6">
              Match. Meet. Lunch.
            </h1>
            <p class="text-xl mb-8 text-base-content/80">
              LunchNinja randomly pairs students and professors for lunch meetings.
              Set your availability, get matched, and make meaningful connections over a meal.
            </p>

            <div class="grid grid-cols-1 md:grid-cols-3 gap-6 my-12">
              <div class="card bg-base-200">
                <div class="card-body items-center text-center">
                  <div class="text-4xl mb-2">📅</div>
                  <h3 class="card-title text-lg">Set Availability</h3>
                  <p class="text-sm">Choose when you're free for lunch each week</p>
                </div>
              </div>

              <div class="card bg-base-200">
                <div class="card-body items-center text-center">
                  <div class="text-4xl mb-2">🎲</div>
                  <h3 class="card-title text-lg">Get Matched</h3>
                  <p class="text-sm">We'll randomly pair you with someone</p>
                </div>
              </div>

              <div class="card bg-base-200">
                <div class="card-body items-center text-center">
                  <div class="text-4xl mb-2">🍱</div>
                  <h3 class="card-title text-lg">Have Lunch</h3>
                  <p class="text-sm">Meet up and make a new connection</p>
                </div>
              </div>
            </div>

            <div class="flex gap-4 justify-center">
              <.link navigate={~p"/auth/login"} class="btn btn-primary btn-lg">
                Get Started
              </.link>
            </div>
          </div>
        </div>
      </div>

      <%!-- Contact Section --%>
      <div class="bg-base-200 py-16">
        <div class="container mx-auto px-4 text-center">
          <h2 class="text-3xl font-bold mb-4">Want to get your school set up?</h2>
          <p class="text-lg mb-6">
            Contact us to add LunchNinja to your institution.
          </p>
          <a href="mailto:mike@lunchninja.org" class="btn btn-outline btn-lg">
            mike@lunchninja.org
          </a>
        </div>
      </div>
    </div>
    """
  end
end
