# Observes operations in {Lesson} and invokes callbacks.
#
# We treate {#create_hook} as more important than {#delete_hook}. If
# {#create_hook} fails, the system is inconsistent and we can't receive
# updates. However, if {#delete_hook} fails, GitHub may either have duplicate
# hooks or hooks for non-existent lessons. That is fine as long as we ignore
# these in the listeners.
#
# @todo TODO updates should also update hooks if the URL changed
class LessonObserver < ActiveRecord::Observer
  include Rails.application.routes.url_helpers

  # Parameters sent to GitHub when creating the hook.
  HOOK_PARAMS = {
    name: 'web',
    config: { content_type: 'json' }
  }

  def after_rollback(lesson)
    case lesson.action
    when :create then delete_hook lesson
    else end
  end

  def after_commit(lesson)
    case lesson.action
    when :destroy then delete_hook lesson
    else end
  end

  def before_create(lesson)
    lesson.action = :create
    create_hook lesson
  end

  def before_destroy(lesson)
    lesson.action = :destroy
  end

  def before_update(lesson)
    lesson.action = :update
  end

  private

  # Reads the user's authorization (from omniauth) and creates a Github client.
  # @param [Lesson] lesson
  # @return [Authorization, Github] authorization and github client
  def github(lesson)
    auth = lesson.user.authorizations.find_by_provider! 'github'
    return auth, Github.new(oauth_token: auth.token)
  end

  # Deletes a webhook from the GitHub repository. If the operation failed, the
  # exception is ignored by {after_rollback}.
  # @param [Lesson] lesson
  # @return [Void]
  def delete_hook(lesson)
    return if lesson.hook.blank?
    auth, client = github lesson
    client.repos.hooks.delete auth.nickname, lesson.name, lesson.hook
  end

  # Adds a webhook to the GitHub repository. If the operation failed, the
  # +github_api+ gem should raise an exception and stop the chain.
  # @param [Lesson] lesson
  # @todo FIXME make this work with orgs
  # @return [Void]
  def create_hook(lesson)
    auth, client = github lesson
    resp = client.repos.hooks.create auth.nickname, lesson.name, hook_params
    lesson.hook = resp.id
  end

  # Lazily adds {#push_lessons_url} to {HOOK_PARAMS}.
  # @return [Hash] parameters suitable for +github_api+.
  def hook_params
    params = HOOK_PARAMS.clone
    params[:config].merge! url: push_lessons_url
    params
  end

end
