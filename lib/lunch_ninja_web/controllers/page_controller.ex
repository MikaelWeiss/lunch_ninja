defmodule LunchNinjaWeb.PageController do
  use LunchNinjaWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
