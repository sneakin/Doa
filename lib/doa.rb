# Copyright (C) 2009 SemanticGap(R)
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following
# conditions:

# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.

require 'facets/hash'

# =Setup
#
# To use this, you should place the following in your `spec/spec_helper.rb`
# after loading the module:
#
#   Doa.install!
#   Doa.default_params = { :css => 'desktop', :format => 'html' }
#
# =Usage
#
# And your specs can then resemble:
#
#   describe SomeController do
#     action :update do
#       before(:each) do
#         @person = people(:bob)
#       end
#
#       params do
#         { :id => @person, :name => 'Robert' }
#       end
#
#       it "updates bob" do
#         Person.should_receive(:find).with(params[:id]).and_return(@person)
#         lambda { do_action }.should change(@person)
#       end
#     end
#   end
#
# =Misc
#
# The following instance methods are generated for use in your specs:
#
#   #params       Access the parameter hash for the current request
#   #do_action    Performs the action under test
#
module Doa
  mattr_accessor :default_params

  def self.included(base)
    base.class_inheritable_accessor :default_params
    base.extend(ClassMethods)
  end

  def self.install!
    Spec::Rails::Example::ControllerExampleGroup.class_eval do
      include Doa
    end
  end

  module ClassMethods
    # Initialize the parameters to be used within a context inheriting
    # those of the surrounding contexts. Takes a block which must
    # return a Hash.
    #
    # Usage:
    #   params do
    #     { :id => @user.id }
    #   end
    def params(&block)
      self.default_params = block
    end

    # Setup a context to test a controller's action using #do_action.
    # It takes the action's name and an optional HTTP method,
    # evaluating the supplied block in the created context.
    def action(name, method = nil, &block)
      d = describe "\##{name}" do
        do_action name, method
      end

      d.instance_eval(&block)
      d
    end

    # Infrastructure method used by #action to generate the methods
    # available within a test case.
    def do_action(action_name, method = nil, params = Hash.new, &block)
      # Locking in the arguments with closures
      define_method("action_method") do
        method || infer_method(action_name)
      end

      define_method("action_name") do
        action_name
      end

      define_method("shared_params") do
        return instance_eval(&block) if block
        return Hash.new
      end

      define_method("action_params") do
        params
      end

      # Now the methods we really want to use
      class_eval do
        # Returns the parameters to be used in a given test case.
        # The parameters are the result of merging the parameters from
        # the top most context down to the current one.
        def params
          return @_params if @_params

          p = Doa.default_params.try(:clone) ||
            HashWithIndifferentAccess.new

          # merge in defaults from each parent class
          supers.reverse.each do |klass|
            dp = klass.default_params if klass.respond_to?(:default_params)
            p.recursive_merge!(self.instance_eval(&dp) || Hash.new) if dp
          end

          p.recursive_merge!(action_params)
          p.recursive_merge!(self.instance_eval(&default_params)) if default_params
          p.recursive_merge!(shared_params)

          @_params = HashWithIndifferentAccess.new(p)
        end

        # Perform the action using the parameters that result from
        # merging the context's parameters with those that were
        # passed as an argument.
        def do_action(per_call_params = Hash.new)
          p = self.params.recursive_merge(per_call_params)
          send(action_method, action_name, p)
        end
      end
    end
  end

  private

  # Given an action name such as :create, it returns the expected
  # HTTP method.
  def infer_method(action)
    case action.to_sym
    when :update then :put
    when :create then :post
    else :get
    end
  end

  # Returns the superclasses of an object
  def supers
    klass = self.class
    supers = Array.new
    while(klass)
      supers << klass
      klass = klass.superclass
    end

    supers
  end
end
