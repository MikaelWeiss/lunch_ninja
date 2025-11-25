defmodule LunchNinja.Emails do
  import Swoosh.Email
  use LunchNinjaWeb, :verified_routes

  @from_email {"LunchNinja", "noreply@lunchninja.org"}

  def auth_magic_link(user, token) do
    magic_link = url(~p"/auth/verify/#{token}")

    new()
    |> to({user.name, user.email})
    |> from(@from_email)
    |> subject("Sign in to LunchNinja")
    |> html_body("""
    <html>
      <body style="font-family: sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
        <h2>Sign in to LunchNinja</h2>
        <p>Hi #{user.name},</p>
        <p>Click the link below to sign in to LunchNinja:</p>
        <p><a href="#{magic_link}" style="display: inline-block; padding: 12px 24px; background-color: #4F46E5; color: white; text-decoration: none; border-radius: 6px;">Sign In</a></p>
        <p>Or copy and paste this link into your browser:</p>
        <p style="word-break: break-all; color: #6B7280;">#{magic_link}</p>
        <p style="color: #6B7280; font-size: 14px;">This link expires in 15 minutes.</p>
        <hr style="margin: 32px 0; border: none; border-top: 1px solid #E5E7EB;">
        <p style="color: #9CA3AF; font-size: 12px;">If you didn't request this link, you can safely ignore this email.</p>
      </body>
    </html>
    """)
    |> text_body("""
    Sign in to LunchNinja

    Hi #{user.name},

    Click the link below to sign in to LunchNinja:
    #{magic_link}

    This link expires in 15 minutes.

    If you didn't request this link, you can safely ignore this email.
    """)
  end

  def match_confirmation(match, user) do
    partner = if match.user1_id == user.id, do: match.user2, else: match.user1
    date_str = Calendar.strftime(match.date, "%A, %B %-d, %Y")

    time_str =
      "#{Calendar.strftime(match.time_slot.start_time, "%-I:%M %p")} - #{Calendar.strftime(match.time_slot.end_time, "%-I:%M %p")}"

    new()
    |> to({user.name, user.email})
    |> from(@from_email)
    |> subject("You have a lunch match tomorrow!")
    |> html_body("""
    <html>
      <body style="font-family: sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
        <h2>You have a lunch match!</h2>
        <p>Hi #{user.name},</p>
        <p>You've been matched with <strong>#{partner.name}</strong> for lunch:</p>
        <div style="background-color: #F3F4F6; padding: 16px; border-radius: 8px; margin: 16px 0;">
          <p style="margin: 4px 0;"><strong>When:</strong> #{date_str}</p>
          <p style="margin: 4px 0;"><strong>Time:</strong> #{time_str}</p>
        </div>
        <p>If you need to cancel, please do so through the app.</p>
        <p><a href="#{url(~p"/home")}" style="display: inline-block; padding: 12px 24px; background-color: #4F46E5; color: white; text-decoration: none; border-radius: 6px;">View in App</a></p>
      </body>
    </html>
    """)
    |> text_body("""
    You have a lunch match!

    Hi #{user.name},

    You've been matched with #{partner.name} for lunch:

    When: #{date_str}
    Time: #{time_str}

    If you need to cancel, please do so through the app at: #{url(~p"/home")}
    """)
  end

  def match_cancelled(match, notified_user, cancelling_user) do
    date_str = Calendar.strftime(match.date, "%A, %B %-d, %Y")

    time_str =
      "#{Calendar.strftime(match.time_slot.start_time, "%-I:%M %p")} - #{Calendar.strftime(match.time_slot.end_time, "%-I:%M %p")}"

    new()
    |> to({notified_user.name, notified_user.email})
    |> from(@from_email)
    |> subject("Your lunch match was cancelled")
    |> html_body("""
    <html>
      <body style="font-family: sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
        <h2>Lunch match cancelled</h2>
        <p>Hi #{notified_user.name},</p>
        <p><strong>#{cancelling_user.name}</strong> has cancelled your lunch match:</p>
        <div style="background-color: #FEF2F2; padding: 16px; border-radius: 8px; margin: 16px 0;">
          <p style="margin: 4px 0;"><strong>When:</strong> #{date_str}</p>
          <p style="margin: 4px 0;"><strong>Time:</strong> #{time_str}</p>
        </div>
        <p>You can set your availability again to get matched with someone else.</p>
        <p><a href="#{url(~p"/home")}" style="display: inline-block; padding: 12px 24px; background-color: #4F46E5; color: white; text-decoration: none; border-radius: 6px;">Update Availability</a></p>
      </body>
    </html>
    """)
    |> text_body("""
    Lunch match cancelled

    Hi #{notified_user.name},

    #{cancelling_user.name} has cancelled your lunch match:

    When: #{date_str}
    Time: #{time_str}

    You can set your availability again to get matched with someone else at: #{url(~p"/home")}
    """)
  end

  def deliver(email) do
    with {:ok, _metadata} <- LunchNinja.Mailer.deliver(email) do
      {:ok, email}
    end
  end
end
