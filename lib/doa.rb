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
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.

require 'facets/hash'
require 'doa/class_methods'
require 'doa/instance_methods'

# =Setup
#
# To use this, you should place the following in your "spec/spec_helper.rb":
#
#   require 'doa'
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
#         lambda { doa }.should change(@person)
#       end
#     end
#   end
#
module Doa
  mattr_accessor :default_params

  def self.included(base)
    base.class_inheritable_accessor :default_params
    base.extend(ClassMethods)
  end

  # Install Doa into RSpec's ControllerExampleGroup.
  def self.install!
    Spec::Rails::Example::ControllerExampleGroup.class_eval do
      include Doa
    end
  end

  private

  # Given an action name such as :create, it returns the expected
  # HTTP method.
  def infer_method(action)
    case action
    when 'update' then :put
    when 'create' then :post
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
