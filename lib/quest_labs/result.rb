class QuestLabs::Result
  def self.get_hl7_results(max_messages = "1", ack = false, processing_id="D")
    client = QuestLabs::Client.instance
    resp = client.call(:post, "hub-resource-server/oauth2/result/getResults", {resultServiceType: "HL7", requestParameters: [{parameterName: "maxMessages", parameterValue: max_messages}]}.to_json, true)

    ack_messages = []
    ack_resp = nil

    (resp["results"]||[]).each do |result|
      hl7_message = HL7::Message.new(Base64.decode64(result["hl7Message"]["message"]))
      pdf_content = hl7_message[:OBX][-1][5].split("^")[-1]
      yield [result, hl7_message, pdf_content]
      message_control_id = hl7_message[:MSH].message_control_id

      receiving_facility = hl7_message[:MSH].sending_facility
      if ack
        ack_messages << {
          message: b64_encoded_hl7_string(message_control_id, resp["requestId"], processing_id, receiving_facility),
          controlId: message_control_id
        }
      end
    end

    if ack
      data = {resultServiceType: "HL7", requestId: resp["requestId"], ackMessages: ack_messages}
      QuestLabs::Client.instance.call(:post, "hub-resource-server/oauth2/result/acknowledgeResults", data.to_json, true)
    end
  end

  private

  def self.b64_encoded_hl7_string(message_control_id, request_id, processing_id, receiving_facility)
    Base64.strict_encode64(to_hl7_str(message_control_id, request_id, processing_id, receiving_facility))
  end

  def self.to_hl7_str(message_control_id, request_id, processing_id, receiving_facility)
    hl7_msg(message_control_id, request_id, processing_id, receiving_facility).to_hl7
  end

  def self.hl7_msg(message_control_id, request_id, processing_id, receiving_facility)
    msg = HL7::Message.new()
    msg << msh_segment(message_control_id, processing_id, receiving_facility)
    msg << msa_segment(message_control_id)
    msg
  end

  def self.msh_segment(message_control_id, processing_id, receiving_facility)
    msh = HL7::Message::Segment::MSH.new
    msh.sending_app = QuestLabs.app_name
    msh.enc_chars = '^~\&'
    msh.sending_facility = QuestLabs.account_number
    msh.recv_facility = receiving_facility
    msh.time = DateTime.now
    msh.message_type  = "ACK"
    msh.message_control_id = "123"
    msh.processing_id = processing_id
    msh.version_id = "2.5.1"
    msh
  end

  def self.msa_segment(message_control_id)
    msa = HL7::Message::Segment::MSA.new
    msa.control_id = message_control_id
    msa.ack_code = "AA"
    msa
  end
end
