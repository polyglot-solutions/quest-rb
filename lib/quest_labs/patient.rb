class QuestLabs::Patient
  attr_accessor :patient_id, :first_name, :last_name, :dob, :address, :phone, :sex

  # Address and phone are required if insurance P or T
  def initialize(patient_id, first_name, last_name, dob, address, phone, sex)
    @patient_id = patient_id
    @first_name = first_name
    @last_name = last_name
    @dob = dob
    @address = address
    @phone = phone
    @sex = sex
  end

  def to_hl7_pid_segment
    # Patient identification
    pid = HL7::Message::Segment::PID.new
    pid.set_id =  "1" #This is always  1
    pid.patient_id = patient_id
    pid.patient_id_list = patient_id
    pid.patient_name = "#{last_name}^#{first_name}"

    pid.patient_dob = dob
    pid.admin_sex = sex

    pid.address =  address
    pid.phone_home = phone
    pid
  end
end
