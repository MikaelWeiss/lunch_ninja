defmodule LunchNinja.Organizations do
  @moduledoc """
  The Organizations context.
  """

  import Ecto.Query, warn: false
  alias LunchNinja.Repo

  alias LunchNinja.Organizations.School
  alias LunchNinja.Organizations.TimeSlot

  # Schools

  @doc """
  Returns the list of schools.
  """
  def list_schools do
    Repo.all(School)
  end

  @doc """
  Gets a single school.

  Raises `Ecto.NoResultsError` if the School does not exist.
  """
  def get_school!(id), do: Repo.get!(School, id)

  @doc """
  Gets a single school by slug.

  Raises `Ecto.NoResultsError` if the School does not exist.
  """
  def get_school_by_slug!(slug) do
    Repo.get_by!(School, slug: slug)
  end

  @doc """
  Creates a school.
  """
  def create_school(attrs \\ %{}) do
    %School{}
    |> School.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a school.
  """
  def update_school(%School{} = school, attrs) do
    school
    |> School.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a school.
  """
  def delete_school(%School{} = school) do
    Repo.delete(school)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking school changes.
  """
  def change_school(%School{} = school, attrs \\ %{}) do
    School.changeset(school, attrs)
  end

  # Time Slots

  @doc """
  Returns the list of active time slots for a school.
  """
  def list_time_slots(school_id) do
    TimeSlot
    |> where([t], t.school_id == ^school_id)
    |> where([t], is_nil(t.deleted_at))
    |> where([t], t.active == true)
    |> order_by([t], t.start_time)
    |> Repo.all()
  end

  @doc """
  Returns all time slots for a school (including inactive and deleted).
  """
  def list_all_time_slots(school_id) do
    TimeSlot
    |> where([t], t.school_id == ^school_id)
    |> order_by([t], t.start_time)
    |> Repo.all()
  end

  @doc """
  Gets a single time slot.

  Raises `Ecto.NoResultsError` if the Time slot does not exist.
  """
  def get_time_slot!(id), do: Repo.get!(TimeSlot, id)

  @doc """
  Creates a time slot.
  """
  def create_time_slot(attrs \\ %{}) do
    %TimeSlot{}
    |> TimeSlot.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a time slot.
  """
  def update_time_slot(%TimeSlot{} = time_slot, attrs) do
    time_slot
    |> TimeSlot.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Soft deletes a time slot.
  """
  def delete_time_slot(%TimeSlot{} = time_slot) do
    time_slot
    |> Ecto.Changeset.change(deleted_at: DateTime.utc_now())
    |> Repo.update()
  end

  @doc """
  Activates a time slot.
  """
  def activate_time_slot(%TimeSlot{} = time_slot) do
    time_slot
    |> Ecto.Changeset.change(active: true)
    |> Repo.update()
  end

  @doc """
  Deactivates a time slot.
  """
  def deactivate_time_slot(%TimeSlot{} = time_slot) do
    time_slot
    |> Ecto.Changeset.change(active: false)
    |> Repo.update()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking time slot changes.
  """
  def change_time_slot(%TimeSlot{} = time_slot, attrs \\ %{}) do
    TimeSlot.changeset(time_slot, attrs)
  end
end
