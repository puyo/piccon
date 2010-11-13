class Dedupe < ActiveRecord::Migration

  def self.up
    ActiveRecord::Base.transaction do
      # remove player mappings from papers that don't exist
      execute("DELETE FROM players WHERE paper_id NOT IN (SELECT id FROM papers)")

      # remove posts for papers that don't exist
      execute("DELETE FROM posts WHERE paper_id NOT IN (SELECT id FROM papers)")
    end
  end

  def self.down
    # nothing necessary
  end
end
