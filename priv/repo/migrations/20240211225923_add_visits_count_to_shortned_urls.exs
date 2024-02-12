defmodule UrlShortner.Repo.Migrations.AddVisitsCountToShortnedUrls do
  use Ecto.Migration

  def change do
    alter table(:shortned_urls) do
      add_if_not_exists :visits_count, :bigint, default: 0
    end
  end
end
