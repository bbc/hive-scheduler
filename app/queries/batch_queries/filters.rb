module BatchQueries
  class Filters
    include Virtus.model

    attribute :project_ids
    attribute :show_all, Boolean, default: true

    def scope
      scope = Batch.order(created_at: :desc)
      scope = scope.where(project_id: project_ids) if project_ids.present? && project_ids != [""]
      scope
    end
  end
end
