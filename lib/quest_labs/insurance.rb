class QuestLabs::Insurance
  attr_accessor :coverage_type, :insurance_company_name, :insurance_company_address, :group_number, :name_of_insured, :insureds_relationship_to_patient, :insureds_address, :policy_number, :guarantor_address, :guarantor_home_phone

  def initialize(coverage_type, insurance_company_name, insurance_company_address, group_number, name_of_insured, insureds_relationship_to_patient, insureds_address, policy_number, guarantor_address, guarantor_home_phone)
    @coverage_type = coverage_type
    @insurance_company_name = insurance_company_name
    @insurance_company_address = insurance_company_address
    @group_number = group_number
    @name_of_insured = name_of_insured
    @insureds_relationship_to_patient = insureds_relationship_to_patient
    @insureds_address = insureds_address
    @policy_number = policy_number
    @guarantor_address = guarantor_address
    @guarantor_home_phone = guarantor_home_phone
  end

  def to_in1_segment
    # Insurance
    in1 = HL7::Message::Segment::IN1.new

    in1.set_id = 1
    # T = Third-party bill P = Patient bill C = Client bill
    in1.coverage_type = coverage_type

    in1.insurance_company_name = insurance_company_name # Required if insurance T
    in1.insurance_company_address = insurance_company_address # Required if insurance T
    in1.group_number = group_number # Required if insurance T
    in1.name_of_insured =  name_of_insured

    # This field is required if IN1.47 (Coverage Type) is T. Valid values for this field include: 1 = Self 2 = Spouse 8 = Dependent
    in1.insureds_relationship_to_patient = insureds_relationship_to_patient

    in1.insureds_address = insureds_address # Required if insurance T

    in1.policy_number = policy_number # Required if insurance T
    in1
  end

  def to_gt1_segment
    gt1 = HL7::Message::Segment::GT1.new
    gt1.set_id =  "1"

    # Required if insurance T or P
    gt1.guarantor_address = guarantor_address
    gt1.guarantor_home_phone = guarantor_home_phone
    gt1
  end
end
