class Movie < ActiveRecord::Base
  def self.all_ratings
    %w[G PG PG-13 R]
  end

  def self.sortable_columns
    %w[title release_date]
  end

  # ratings_list: array like ['G', 'pg-13']; nil or empty returns all movies
  def self.with_ratings(ratings_list)
    return all if ratings_list.blank?

    where("UPPER(rating) IN (?)", ratings_list.map(&:upcase))
  end
end
