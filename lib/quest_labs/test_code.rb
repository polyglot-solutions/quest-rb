class QuestLabs::TestCode
  attr_accessor :code, :description

  def initialize(code, description)
    @code = code
    @description = description
  end

  def to_universal_service_id
    "^^^#{code}^#{description}"
  end
end
