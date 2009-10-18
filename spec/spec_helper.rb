$: << File.join(File.dirname(File.dirname(__FILE__)), 'lib')
$: << File.dirname(__FILE__)

require 'active_support'
require 'action_controller'
require 'action_controller/request'
require 'action_controller/rescue'
require 'initializer'

require 'spec/rails'
require 'doa'

Doa.install!
