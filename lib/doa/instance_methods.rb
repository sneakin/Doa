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
  # Methods available inside individual cases.
  module InstanceMethods
    # Returns the parameters to be used in a given test case.
    # The parameters are the result of merging the parameters from
    # the top most context down to the current one.
    def params
      return @_params if @_params

      p = Doa.default_params.try(:clone) ||
        HashWithIndifferentAccess.new

      p.recursive_merge!(super_params)
      p.recursive_merge!(action_params)
      p.recursive_merge!(self.instance_eval(&default_params)) if default_params
      p.recursive_merge!(shared_params)

      @_params = HashWithIndifferentAccess.new(p)
    end

    # Perform the action using the parameters that result from
    # merging the context's parameters with those that were
    # passed as an argument.
    def do_action(per_call_params = Hash.new)
      send(action_method, action_name,
           self.params.recursive_merge(per_call_params))
    end

    private

    # Merges in defaults from each parent class
    def super_params
      supers.reverse.inject(Hash.new) do |acc, klass|
        next acc unless klass.respond_to?(:default_params)

        dp = klass.default_params
        acc.recursive_merge!(self.instance_eval(&dp) || Hash.new) if dp
        acc
      end
    end
  end
end
