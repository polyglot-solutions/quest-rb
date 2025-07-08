class QuestLabs::Provider
  attr_accessor :npi, :first_name, :last_name

  def initialize(npi, first_name, last_name)
    @npi = npi
    @first_name = first_name
    @last_name = last_name
  end

  def to_ordering_provider_s
    "#{npi}^#{last_name.upcase}^#{first_name.upcase}^^^^^^NPI"
  end
end
