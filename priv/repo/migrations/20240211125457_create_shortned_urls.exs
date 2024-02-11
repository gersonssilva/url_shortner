defmodule UrlShortner.Repo.Migrations.CreateShortnedUrls do
  use Ecto.Migration

  def change do
    create table(:shortned_urls) do
      add :original_url, :text
      add :slug, :text

      timestamps(type: :utc_datetime)
    end

    create index(:shortned_urls, [:slug], unique: true)
  end
end
