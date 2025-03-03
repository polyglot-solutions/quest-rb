require "forwardable"

require_relative "quest_labs/config"
require_relative "quest_labs/order"
require_relative "quest_labs/patient"
require_relative "quest_labs/insurance"
require_relative "quest_labs/provider"
require_relative "quest_labs/diagnosis"
require_relative "quest_labs/test_code"
require_relative "quest_labs/result"

module QuestLabs
  autoload :Client, "quest_labs/client"

  @config = QuestLabs::Config.new

  class << self
    attr_reader :config

    extend Forwardable

    def_delegators :@config, :client_id, :client_id=
    def_delegators :@config, :client_secret, :client_secret=
    def_delegators :@config, :grant_type, :grant_type=
    def_delegators :@config, :base_url, :base_url=
    def_delegators :@config, :app_name, :app_name=
    def_delegators :@config, :account_number, :account_number=
    def_delegators :@config, :logger, :logger=
  end
end
