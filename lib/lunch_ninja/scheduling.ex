defmodule LunchNinja.Scheduling do
  @moduledoc """
  The Scheduling context.
  """

  import Ecto.Query, warn: false
  alias LunchNinja.Repo

  alias LunchNinja.Scheduling.Availability
  alias LunchNinja.Scheduling.Match
  alias LunchNinja.Accounts.User

  # Availability

  @doc """
  Gets user availability for a date range.
  """
  def get_user_availability(user_id, start_date, end_date) do
    Availability
    |> where([a], a.user_id == ^user_id)
    |> where([a], a.date >= ^start_date and a.date <= ^end_date)
    |> preload(:time_slot)
    |> order_by([a], [a.date, fragment("? ASC", a.time_slot_id)])
    |> Repo.all()
  end

  @doc """
  Sets a user as available for a time slot on a specific date.
  """
  def set_availability(user_id, time_slot_id, date) do
    attrs = %{
      user_id: user_id,
      time_slot_id: time_slot_id,
      date: date
    }

    %Availability{}
    |> Availability.changeset(attrs)
    |> Repo.insert(on_conflict: :nothing)
  end

  @doc """
  Removes a user's availability for a time slot on a specific date.
  """
  def remove_availability(user_id, time_slot_id, date) do
    Availability
    |> where([a], a.user_id == ^user_id)
    |> where([a], a.time_slot_id == ^time_slot_id)
    |> where([a], a.date == ^date)
    |> Repo.delete_all()
  end

  @doc """
  Clears all availability for a user on a specific date.
  """
  def clear_availability(user_id, date) do
    Availability
    |> where([a], a.user_id == ^user_id)
    |> where([a], a.date == ^date)
    |> Repo.delete_all()
  end

  # Matches

  @doc """
  Lists matches for a user within a date range.
  """
  def list_matches(user_id, start_date, end_date) do
    Match
    |> where([m], m.user1_id == ^user_id or m.user2_id == ^user_id)
    |> where([m], m.date >= ^start_date and m.date <= ^end_date)
    |> where([m], m.status != :cancelled_by_both)
    |> preload([:time_slot, :user1, :user2])
    |> order_by([m], [m.date, fragment("? ASC", m.time_slot_id)])
    |> Repo.all()
  end

  @doc """
  Gets a single match.
  """
  def get_match!(id) do
    Match
    |> preload([:time_slot, :user1, :user2])
    |> Repo.get!(id)
  end

  @doc """
  Cancels a match for a specific user.
  """
  def cancel_match(%Match{} = match, user_id) do
    new_status =
      cond do
        match.user1_id == user_id and match.status == :cancelled_by_user2 ->
          :cancelled_by_both

        match.user2_id == user_id and match.status == :cancelled_by_user1 ->
          :cancelled_by_both

        match.user1_id == user_id ->
          :cancelled_by_user1

        match.user2_id == user_id ->
          :cancelled_by_user2

        true ->
          match.status
      end

    match
    |> Ecto.Changeset.change(status: new_status)
    |> Repo.update()
  end

  @doc """
  Creates a manual match (admin-created).
  """
  def create_manual_match(time_slot_id, date, user1_id, user2_id) do
    {ordered_user1_id, ordered_user2_id} = order_user_ids(user1_id, user2_id)

    attrs = %{
      time_slot_id: time_slot_id,
      date: date,
      user1_id: ordered_user1_id,
      user2_id: ordered_user2_id,
      created_by: :admin,
      status: :scheduled
    }

    %Match{}
    |> Match.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Finds potential matches for a given time slot and date.

  Returns list of users who are available and not yet matched.
  """
  def find_potential_matches(time_slot_id, date) do
    matched_user_ids_query =
      from m in Match,
        where: m.time_slot_id == ^time_slot_id,
        where: m.date == ^date,
        where: m.status == :scheduled,
        select: fragment("ARRAY[?, ?]", m.user1_id, m.user2_id)

    from(u in User,
      join: a in Availability,
      on: a.user_id == u.id,
      where: a.time_slot_id == ^time_slot_id,
      where: a.date == ^date,
      where: is_nil(u.deleted_at),
      where:
        fragment(
          "NOT EXISTS (SELECT 1 FROM unnest(?::uuid[]) AS matched_id WHERE matched_id = ?)",
          subquery(matched_user_ids_query),
          u.id
        ),
      preload: [:school]
    )
    |> Repo.all()
  end

  @doc """
  Creates daily matches for a specific date.

  Groups users by school and time slot, then randomly pairs them.
  """
  def create_daily_matches(date) do
    time_slots =
      from(ts in LunchNinja.Organizations.TimeSlot,
        where: ts.active == true,
        where: is_nil(ts.deleted_at),
        select: ts.id
      )
      |> Repo.all()

    results =
      for time_slot_id <- time_slots do
        users = find_potential_matches(time_slot_id, date)

        users_by_school =
          users
          |> Enum.group_by(& &1.school_id)

        for {_school_id, school_users} <- users_by_school do
          create_matches_for_group(time_slot_id, date, school_users)
        end
      end

    {:ok, List.flatten(results)}
  end

  # Private functions

  defp create_matches_for_group(time_slot_id, date, users) do
    users
    |> Enum.shuffle()
    |> Enum.chunk_every(2)
    |> Enum.flat_map(fn
      [user1, user2] ->
        {ordered_user1_id, ordered_user2_id} = order_user_ids(user1.id, user2.id)

        case create_match(time_slot_id, date, ordered_user1_id, ordered_user2_id) do
          {:ok, match} -> [match]
          {:error, _} -> []
        end

      [_single_user] ->
        []
    end)
  end

  defp create_match(time_slot_id, date, user1_id, user2_id) do
    attrs = %{
      time_slot_id: time_slot_id,
      date: date,
      user1_id: user1_id,
      user2_id: user2_id,
      created_by: :system,
      status: :scheduled
    }

    %Match{}
    |> Match.changeset(attrs)
    |> Repo.insert()
  end

  defp order_user_ids(id1, id2) when id1 < id2, do: {id1, id2}
  defp order_user_ids(id1, id2), do: {id2, id1}
end
