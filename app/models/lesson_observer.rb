# Observes operations in {Lesson} and invokes callbacks to compile lessons and
# register web hooks with GitHub.
#
# We treate {#create_hook} as more important than {#delete_hook}. If
# {#create_hook} fails, the system is inconsistent and we can't receive
# updates. However, if {#delete_hook} fails, GitHub may either have duplicate
# hooks or hooks for non-existent lessons. That is fine as long as we ignore
# these in the listeners.
#
# @todo TODO reconnect lamp_client on failure
# @todo TODO updates should also update hooks if the URL changed
class LessonObserver < ActiveRecord::Observer

  include LampConcern
  include FayeConcern
  include Rails.application.routes.url_helpers

  # Parameters sent to GitHub when creating the hook.
  HOOK_PARAMS = {
    name: 'web',
    config: { content_type: 'json' }
  }

  def after_rollback(lesson)
    if :create == lesson.action
      delete_hook  lesson
      delete_files lesson
    end
  end

  def after_commit(lesson)
    case lesson.action
    when :destroy
      delete_hook  lesson
      delete_files lesson
    when :create
      # this needs to be here so that the callback url can be given an ID
      create_files lesson
    end
  end

  def before_destroy(lesson)
    lesson.action = :destroy
  end

  def before_create(lesson)
    lesson.action = :create
    create_hook lesson
  end

  def after_publish(lesson)
    # TODO
    # faye_client.publish user_lesson_path(lesson.user, lesson),
    #  lesson.to_json(methods: :status)
  end

  def after_fail(lesson)
    # TODO
  end

  def after_push(lesson)
    create_files lesson
  end

  private

  # Reads the user's authorization (from omniauth) and creates a Github client.
  # @param [Lesson] lesson
  # @return [Github::Client] github client
  def github(lesson)
    auth = lesson.user.authorizations.find_by_provider! 'github'
    Github.new(oauth_token: auth.token)
  end

  # Deletes a webhook from the GitHub repository. If the operation failed, the
  # exception is ignored by {after_rollback} or {after_destroy}.
  # @param [Lesson] lesson
  # @return [void]
  def delete_hook(lesson)
    return if lesson.hook.blank?
    client = github lesson
    client.repos.hooks.delete lesson.owner, lesson.name, lesson.hook
  end

  # Tells compiler to delete lesson files.
  # @param [Lesson] lesson
  # @return [void]
  def delete_files(lesson)
    Rails.logger.info ">> lamp remove #{lesson.path.to_s}"
    lamp_client.transport.open
    lamp_client.remove lesson.path.to_s, gone_lesson_url(lesson.id)
  rescue Lamp::RPCError => e
    Rails.logger.error 'Unable to remove lesson %s using lamp.' % lesson.path
    raise e
  ensure
    lamp_client.transport.close
  end

  # Adds a webhook to the GitHub repository. If the operation fails, the
  # +github_api+ gem should raise an exception and stop the chain, rolling back
  # the transaction. Otherwise, the hook ID is saved with the lesson.
  # @param [Lesson] lesson
  # @todo FIXME make this work with organizations
  # @return [void]
  def create_hook(lesson)
    client = github lesson
    resp = client.repos.hooks.create lesson.owner, lesson.name, hook_params
    lesson.hook = resp.id
  end

  # Tells compiler to clone and compile the lesson. If the operation fails,
  # sets the lesson's status to +failed+ and propagates the exception.
  # @param [Lesson] lesson
  # @return [void]
  def create_files(lesson)
    Rails.logger.info ">> lamp create #{lesson.url} #{lesson.path.to_s}"
    lamp_client.transport.open
    lamp_client.create lesson.url,
      lesson.path.to_s,
      ready_lesson_url(lesson.id), {}
  rescue Thrift::Exception => e
    Rails.logger.error 'Unable to create lesson %s using lamp.' % lesson.path
    lesson.reload.failed base: ['lesson.lamp.rpc'] # abandon create
    raise e
  ensure
    lamp_client.transport.close
  end

  # Lazily adds {#push_lessons_url} to {HOOK_PARAMS}.
  # @return [Hash] parameters suitable for +github_api+.
  def hook_params
    user     = Rails.application.config.github[:username]
    password = Rails.application.config.github[:password]
    params   = HOOK_PARAMS.clone
    params[:config].merge! url: push_lessons_url(user: user, password: password)
    params
  end

end
