class << ActiveRecord::Base
  def belongs_to_with_deleted(association_id, options = {})
    with_deleted = options.delete :with_deleted
    belongs_to_without_deleted(association_id, options).tap do
      if with_deleted and options[:polymorphic]
        reflection = reflect_on_association(association_id)
        association_accessor_methods(reflection,            Caboose::Acts::BelongsToWithDeletedPolymorphicAssociation)
        association_constructor_method(:build,  reflection, Caboose::Acts::BelongsToWithDeletedPolymorphicAssociation)
        association_constructor_method(:create, reflection, Caboose::Acts::BelongsToWithDeletedPolymorphicAssociation)
      elsif with_deleted
        reflection = reflect_on_association(association_id)
        association_accessor_methods(reflection,            Caboose::Acts::BelongsToWithDeletedAssociation)
        association_constructor_method(:build,  reflection, Caboose::Acts::BelongsToWithDeletedAssociation)
        association_constructor_method(:create, reflection, Caboose::Acts::BelongsToWithDeletedAssociation)
      end
    end
  end

  def has_many_without_deleted(association_id, options = {}, &extension)
    with_deleted = options.delete :with_deleted
    has_many_with_deleted(association_id, options, &extension).tap do
      if options[:through] && !with_deleted
        reflection = reflect_on_association(association_id)
        collection_reader_method(reflection, Caboose::Acts::HasManyThroughWithoutDeletedAssociation)
        collection_accessor_methods(reflection, Caboose::Acts::HasManyThroughWithoutDeletedAssociation, false)
      end
    end
  end

  def has_one_with_deleted(association_id, options = {})
    with_deleted = options.delete :with_deleted
    has_one_without_deleted(association_id, options).tap do
      if with_deleted
        reflection = reflect_on_association(association_id)
        association_accessor_methods(reflection,            Caboose::Acts::HasOneWithDeletedAssociation)
        association_constructor_method(:build,  reflection, Caboose::Acts::HasOneWithDeletedAssociation)
        association_constructor_method(:create, reflection, Caboose::Acts::HasOneWithDeletedAssociation)
      end
    end
  end

  alias_method_chain :has_one, :deleted
  alias_method_chain :belongs_to, :deleted
  alias_method :has_many_with_deleted, :has_many
  alias_method :has_many, :has_many_without_deleted
  alias_method :exists_with_deleted?, :exists?
end
ActiveRecord::Base.send :include, Caboose::Acts::Paranoid
ActiveRecord::Base.send :include, Caboose::Acts::ParanoidFindWrapper
class << ActiveRecord::Base
  alias_method_chain :acts_as_paranoid, :find_wrapper
end
