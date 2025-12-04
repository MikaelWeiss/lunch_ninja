defmodule LunchNinjaWeb.DesignLive do
  use LunchNinjaWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    form =
      to_form(%{
        "text" => "",
        "email" => "",
        "password" => "",
        "number" => "",
        "search" => "",
        "url" => "",
        "tel" => "",
        "date" => "",
        "time" => "",
        "textarea" => "",
        "select" => "",
        "checkbox1" => false,
        "checkbox2" => true,
        "error" => "invalid@value",
        "disabled" => "Disabled"
      })

    {:ok,
     assign(socket,
       form: form,
       selected_section: "baseline",
       sidebar_collapsed: false
     )}
  end

  @impl true
  def handle_event("select_section", %{"section" => section}, socket) do
    {:noreply, assign(socket, selected_section: section)}
  end

  def handle_event("toggle_sidebar", _params, socket) do
    {:noreply, assign(socket, sidebar_collapsed: !socket.assigns.sidebar_collapsed)}
  end

  def sample_users do
    [
      %{"id" => 1, "name" => "Alice Johnson", "email" => "alice@example.com", "role" => "Admin"},
      %{"id" => 2, "name" => "Bob Smith", "email" => "bob@example.com", "role" => "User"},
      %{"id" => 3, "name" => "Carol White", "email" => "carol@example.com", "role" => "Editor"}
    ]
  end

  def color_samples do
    [
      {"Base 100", "bg-base-100"},
      {"Base 200", "bg-base-200"},
      {"Base 300", "bg-base-300"},
      {"Primary", "bg-primary"},
      {"Secondary", "bg-secondary"},
      {"Accent", "bg-accent"},
      {"Success", "bg-success"},
      {"Warning", "bg-warning"},
      {"Error", "bg-error"},
      {"Info", "bg-info"}
    ]
  end

  def sample_icons do
    [
      "hero-home",
      "hero-user",
      "hero-plus",
      "hero-minus",
      "hero-x-mark",
      "hero-pencil",
      "hero-trash",
      "hero-arrow-left",
      "hero-arrow-right",
      "hero-chevron-up",
      "hero-chevron-down",
      "hero-check",
      "hero-exclamation-circle",
      "hero-information-circle",
      "hero-bell",
      "hero-moon",
      "hero-sun",
      "hero-heart",
      "hero-star",
      "hero-calendar"
    ]
  end
end
