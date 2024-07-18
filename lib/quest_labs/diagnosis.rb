class QuestLabs::Diagnosis
  attr_accessor :coding_method, :code, :description

  def initialize(coding_method, code, description)
    @coding_method = coding_method
    @code = code
    @description = description
  end

  def to_dg1_segment
    dg1 = HL7::Message::Segment::DG1.new
    dg1.set_id = "1"
    dg1.diagnosis_coding_method = coding_method
    dg1.diagnosis_code = code
    dg1.diagnosis_description  = description
    dg1
  end
end
