class LessonObserver < ActiveRecord::Observer
  include Rails.application.routes.url_helpers

  # Parameters sent to GitHub when creating the hook
  HOOK_PARAMS = {
    name: 'web',
    config: { content_type: 'json' }
  }

  # Lazily initializes adds {#push_lessons_url} to {HOOK_PARAMS}.
  def hook_params
    params = HOOK_PARAMS.clone
    params[:config].merge! url: push_lessons_url
    params
  end

  # Adds a webhook to the GitHub repository. If the operation failed, the
  # +github_api+ gem should raise an exception and stop the chain.
  # @param [Lesson] lesson
  # @todo FIXME make this work with orgs
  def before_create(lesson)
    auth   = lesson.user.authorizations.find_by_provider! 'github'
    github = Github.new oauth_token: auth.token
    resp   = github.repos.hooks.create auth.nickname, lesson.repo, hook_params
    lesson.hook = resp.id
  end

end
