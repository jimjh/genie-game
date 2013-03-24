RSpec::Matchers.define :validate_existence_of do |association|

  description { "require an existing #{association}" }

  @association = association
  @attribute   = "#{association}_id"

  @message_finder_factory = Shoulda::Matchers::ActiveModel::ValidationMessageFinder

  def unique_id
    ids = @model_class.pluck :id
    begin id = Random.rand(1000)
    end while ids.include? id
  end

  def message_finder
    @message_finder_factory.new(@instance, @association)
  end

  def has_messages?
    message_finder.has_messages?
  end

  def errors_for_attribute_match?
    errors_for_attribute.compact.any?
  end

  def errors_for_attribute
    message_finder.messages
  end

  match do |instance|
    @model_class = instance.class.reflect_on_association(@association).klass
    @instance = instance
    @instance.send "#{@attribute}=", unique_id
    has_messages? && errors_for_attribute_match?
  end

end
