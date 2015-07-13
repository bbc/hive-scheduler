#https://github.com/radar/paranoia/issues/109#issuecomment-40121884

module Paranoia

  # Adds with_deleted to belongs_to
  module Associations
    def self.included(base)
      base.extend ClassMethods
      class << base
        alias_method_chain :belongs_to, :deleted
      end
    end

    module ClassMethods
      def belongs_to_with_deleted(target, options = {})
        with_deleted = options.delete(:with_deleted)
        result = belongs_to_without_deleted(target, options)

        if with_deleted
          result.with_indifferent_access[target].options[:with_deleted] = with_deleted
          unless method_defined? "#{target}_with_unscoped"
            class_eval <<-RUBY, __FILE__, __LINE__
              def #{target}_with_unscoped(*args)
                association = association(:#{target})
                return nil if association.options[:polymorphic] && association.klass.nil?
                return #{target}_without_unscoped(*args) unless association.klass.paranoid?
                association.klass.with_deleted.scoping { #{target}_without_unscoped(*args) }
              end
              alias_method_chain :#{target}, :unscoped
            RUBY
          end
        end

        result
      end
    end
  end

  # Loads associations correct with includes
  module PreloaderAssociation
    def self.included(base)
      base.class_eval do
        def build_scope_with_deleted
          scope = build_scope_without_deleted
          scope = scope.with_deleted if options[:with_deleted] && klass.respond_to?(:with_deleted)
          scope
        end

        alias_method_chain :build_scope, :deleted
      end
    end
  end

end

ActiveRecord::Base.send :include, Paranoia::Associations
ActiveRecord::Associations::Preloader::Association.send :include, Paranoia::PreloaderAssociation
