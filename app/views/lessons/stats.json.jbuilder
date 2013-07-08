json.array! @lesson.problems.sort_by { |p| p.position } do |p|
  json.n             (p.position + 1)
  json.avg_attempts   p.avg_incorrect_attempts(@subset)
end
