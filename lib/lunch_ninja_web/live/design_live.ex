defmodule LunchNinjaWeb.DesignLive do
  use LunchNinjaWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    task_form =
      to_form(%{
        "title" => "",
        "assignee" => "",
        "priority" => "",
        "due_date" => "",
        "description" => ""
      })

    {:ok,
     assign(socket,
       selected_section: "baseline",
       sidebar_collapsed: false,
       dark_mode: false,
       task_form: task_form
     )}
  end

  @impl true
  def handle_event("select_section", %{"section" => section}, socket) do
    {:noreply, assign(socket, selected_section: section)}
  end

  def handle_event("toggle_sidebar", _params, socket) do
    {:noreply, assign(socket, sidebar_collapsed: !socket.assigns.sidebar_collapsed)}
  end

  def handle_event("toggle_dark_mode", _params, socket) do
    {:noreply, assign(socket, dark_mode: !socket.assigns.dark_mode)}
  end

  def handle_event("create_task", _params, socket) do
    {:noreply, put_flash(socket, :info, "Task created successfully!")}
  end

  def sample_stats do
    [
      %{icon: "hero-users", label: "Total Users", value: "2,345", trend: "+12%"},
      %{icon: "hero-clipboard-document-check", label: "Tasks Completed", value: "89", trend: "+5%"},
      %{icon: "hero-clock", label: "Pending Tasks", value: "23", trend: "-3%"}
    ]
  end

  def sample_tasks do
    [
      %{id: 1, title: "Design new landing page", status: "in-progress", priority: "high", assignee: "Alice"},
      %{id: 2, title: "Fix login bug", status: "completed", priority: "urgent", assignee: "Bob"},
      %{id: 3, title: "Write documentation", status: "pending", priority: "medium", assignee: "Carol"},
      %{id: 4, title: "Review pull requests", status: "in-progress", priority: "low", assignee: "Dave"}
    ]
  end

  def sample_activities do
    [
      %{user: "Alice", action: "completed task", item: "Design mockups", time: "2 mins ago"},
      %{user: "Bob", action: "commented on", item: "Bug report #123", time: "15 mins ago"},
      %{user: "Carol", action: "created task", item: "Update README", time: "1 hour ago"}
    ]
  end
end
