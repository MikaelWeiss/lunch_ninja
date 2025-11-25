defmodule LunchNinja.Workers.DailyMatchWorker do
  use Oban.Worker, queue: :default

  alias LunchNinja.Scheduling
  alias LunchNinja.Emails

  @impl Oban.Worker
  def perform(_job) do
    # Get tomorrow's date
    tomorrow = Date.add(Date.utc_today(), 1)

    # Create matches for tomorrow
    {:ok, matches} = Scheduling.create_daily_matches(tomorrow)

    # Send email notifications for each match
    send_match_notifications(matches)

    {:ok, %{matches_created: length(matches), date: tomorrow}}
  end

  defp send_match_notifications(matches) do
    for match <- matches do
      # Load the match with all associations
      match = Scheduling.get_match!(match.id)

      # Send email to both users
      Emails.match_confirmation(match, match.user1) |> Emails.deliver()
      Emails.match_confirmation(match, match.user2) |> Emails.deliver()
    end
  end
end
