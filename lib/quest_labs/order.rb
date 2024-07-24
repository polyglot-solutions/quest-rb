class QuestLabs::Order
  attr_accessor :patient, :insurance, :provider, :test_codes, :diagnosis, :message_control_id, :processing_id, :patient_location, :placer_order_number, :hl7_resp

  HL7_VERSION = "2.5.1"

  DOCUMENT_TYPES = ["ABN", "AOE", "REQ"]

  # Processing ID should be set to P in production
  def initialize(patient, insurance, provider, test_codes, diagnosis, message_control_id, placer_order_number, processing_id="D", patient_location="outpatient")
    @patient = patient
    @insurance = insurance
    @provider = provider
    @test_codes = test_codes
    @diagnosis = diagnosis
    @placer_order_number = placer_order_number
    @message_control_id = message_control_id
    @processing_id = processing_id
  end

  def transmit
    client = QuestLabs::Client.instance
    resp = client.call(:post, "hub-resource-server/oauth2/order/submission/", b64_encoded_hl7_string , false)
    decoded_response = Base64.strict_decode64(resp)
    @hl7_resp = HL7::Message.new(decoded_response)
    @hl7_resp[:MSA].ack_code == "AA"
  end

  def get_order_document(document_types = DOCUMENT_TYPES)
    client = QuestLabs::Client.instance
    data = {
      'documentTypes' => document_types,
      'orderHl7' => b64_encoded_hl7_string
    }
    client.call(:post, "hub-resource-server/oauth2/order/document/", data.to_json)
  end

  def to_s
    to_hl7_str
  end

  private

  def b64_encoded_hl7_string
    Base64.strict_encode64(to_hl7_str)
  end

  def to_hl7_str
    hl7_msg.to_hl7
  end

  def hl7_msg
    msg = HL7::Message.new()
    msg << msh_segment
    msg << patient.to_hl7_pid_segment
    msg << pv1_segment
    msg << insurance.to_in1_segment
    msg << insurance.to_gt1_segment
    msg << common_order_segment
    test_codes.each_with_index do |tc, ix|
      msg << obr_segment(tc, ix)
    end
    msg << diagnosis.to_dg1_segment if diagnosis&.present?
    msg
  end

  private

  def msh_segment
    msh = HL7::Message::Segment::MSH.new
    msh.sending_app = QuestLabs.app_name
    msh.enc_chars = '^~\&'
    msh.sending_facility = QuestLabs.account_number
    msh.recv_facility = "SKB"
    msh.time = DateTime.now
    msh.message_type  = "OML^O21"
    msh.message_control_id = message_control_id
    msh.processing_id = processing_id
    msh.version_id = "2.5.1"
    msh
  end

  def pv1_segment
    pv1 = HL7::Message::Segment::PV1.new
    pv1.set_id = "1"
    pv1.assigned_location = patient_location
    pv1
  end

  def common_order_segment
    orc = HL7::Message::Segment::ORC.new
    orc.order_control = "NW" # https://hl7-definition.caristix.com/v2/HL7v2.2/Tables/0119

    orc.placer_order_number = placer_order_number
    orc.ordering_provider = provider.to_ordering_provider_s
    orc
  end

  def obr_segment(tc, ix)
    obr = HL7::Message::Segment::OBR.new
    obr.set_id =  (ix + 1).to_s
    obr.placer_order_number = placer_order_number
    obr.universal_service_id = tc.to_universal_service_id
    obr.observation_date = DateTime.now
    obr.ordering_provider = provider.to_ordering_provider_s
    obr
  end
end
