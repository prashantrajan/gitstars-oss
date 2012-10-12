class RepoSearch

  def self.all_by_tag_ids(tag_ids, options = {})
    results = []
    options = {:page => 1, :per_page => 50}.merge(options)
    tag_ids = tag_ids.map(&:to_i).uniq.delete_if { |id| id == 0 }

    if tag_ids.present?
      results = Repo.find_by_sql(
          ["SELECT DISTINCT repos.* FROM
              (SELECT count(tags.id) AS tags_count, repos.*
               FROM repo_users INNER JOIN repos ON repo_users.repo_id = repos.id
               INNER JOIN taggings ON taggings.repo_user_id = repo_users.id
               INNER JOIN tags ON tags.id = taggings.tag_id
               WHERE tags.id IN (?) GROUP BY repos.id, repo_users.id)
            repos WHERE repos.tags_count = ? ORDER BY repos.stargazers DESC", tag_ids, tag_ids.size]
      )
    end

    Kaminari.paginate_array(results).page(options[:page]).per(options[:per_page])
  end

end
