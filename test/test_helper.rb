ENV["RAILS_ENV"] = "test"

require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
gem 'mocha', '>=0.9.0'
require 'test_help'
require 'pp'
require 'stringio'
require 'mocha'

class Test::Unit::TestCase
  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  #
  # The only drawback to using transactional fixtures is when you actually 
  # need to test transactions.  Since your test is bracketed by a transaction,
  # any transactions started in your code will be automatically rolled back.
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...

  TEST_IMAGE_PATH = File.dirname(__FILE__) + '/fixtures/drawing.png'

  def mock_image_data
    StringIO.new(File.read(TEST_IMAGE_PATH))
  end
end


# Before each integration test, slip in and ensure a Mocha mock object will be
# returned instead of the normal fbsession.
class ActionController::IntegrationTest
  def setup
    ApplicationController.mock_session = mock
  end

  def fbsession
    ApplicationController.mock_session
  end
end

class ApplicationController
  # Don't do these things during tests.
  
  cattr_accessor :mock_session

  def fbsession
    @@mock_session
  end 

  def require_facebook_install
  end

  def require_facebook_login
  end
end
