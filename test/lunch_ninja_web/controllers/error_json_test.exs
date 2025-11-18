defmodule LunchNinjaWeb.ErrorJSONTest do
  use LunchNinjaWeb.ConnCase, async: true

  test "renders 404" do
    assert LunchNinjaWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert LunchNinjaWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
