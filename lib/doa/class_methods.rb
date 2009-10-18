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

module Doa
  # Methods available at the context level.
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
        include Doa::InstanceMethods
      end
    end
  end
end
