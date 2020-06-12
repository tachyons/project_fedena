# Fedena
# Copyright 2011 Foradian Technologies Private Limited
#
# This product includes software developed at
# Project Fedena - http://www.projectfedena.org/
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

class Student < ActiveRecord::Base
  include CceReportMod

  belongs_to :country
  belongs_to :batch
  belongs_to :student_category
  belongs_to :nationality, class_name: 'Country'
  belongs_to :user

  has_one    :immediate_contact
  has_one    :student_previous_data
  has_many   :student_previous_subject_mark
  has_many   :guardians, foreign_key: 'ward_id'
  has_many   :finance_transactions, as: :payee
  has_many   :attendances
  has_many   :finance_fees
  has_many   :fee_category, class_name: 'FinanceFeeCategory'
  has_many   :students_subjects
  has_many   :subjects, through: :students_subjects
  has_many   :student_additional_details
  has_many   :batch_students
  has_many   :subject_leaves
  has_many   :grouped_exam_reports
  has_many   :cce_reports
  has_many   :assessment_scores
  has_many   :exam_scores
  has_many   :previous_exam_scores

  named_scope :active, conditions: { is_active: true }
  named_scope :with_full_name_only, select: "id, CONCAT_WS('',first_name,' ',last_name) AS name,first_name,last_name", order: :first_name
  named_scope :with_name_admission_no_only, select: "id, CONCAT_WS('',first_name,' ',last_name,' - ',admission_no) AS name,first_name,last_name,admission_no", order: :first_name

  named_scope :by_first_name, order: 'first_name', conditions: { is_active: true }

  validates_presence_of :admission_no, :admission_date, :first_name, :batch_id, :date_of_birth
  validates_uniqueness_of :admission_no
  validates_presence_of :gender
  validates_format_of     :email, with: /^[A-Z0-9._%-]+@([A-Z0-9-]+\.)+[A-Z]{2,4}$/i, allow_blank: true,
                                  message: t('must_be_a_valid_email_address').to_s
  validates_format_of     :admission_no, with: /^[A-Z0-9_-]*$/i,
                                         message: t('must_contain_only_letters').to_s

  validates_associated :user
  before_validation :create_user_and_validate

  before_save :is_active_true

  has_attached_file :photo,
                    styles: { original: '125x125#' },
                    url: '/system/:class/:attachment/:id/:style/:basename.:extension',
                    path: ':rails_root/public/system/:class/:attachment/:id/:style/:basename.:extension'

  VALID_IMAGE_TYPES = ['image/gif', 'image/png', 'image/jpeg', 'image/jpg'].freeze

  validates_attachment_content_type :photo, content_type: VALID_IMAGE_TYPES,
                                            message: 'Image can only be GIF, PNG, JPG', if: proc { |p| !p.photo_file_name.blank? }
  validates_attachment_size :photo, less_than: 512_000,\
                                    message: 'must be less than 500 KB.', if: proc { |p| p.photo_file_name_changed? }

  def validate
    errors.add(:date_of_birth, "#{t('cant_be_a_future_date')}.") unless date_of_birth.nil? || date_of_birth < Date.today
    errors.add(:gender, "#{t('model_errors.student.error2')}.") unless gender.nil? || %w[m f].include?(gender.downcase)
    errors.add(:admission_no, "#{t('model_errors.student.error3')}.") if admission_no == '0'
    errors.add(:admission_no, t('should_not_be_admin').to_s) if admission_no.to_s.downcase == 'admin'
  end

  def is_active_true
    self.is_active = 1 unless is_active == 1
  end

  def create_user_and_validate
    if new_record?
      user_record = build_user
      user_record.first_name = first_name
      user_record.last_name = last_name
      user_record.username = admission_no.to_s
      user_record.password = admission_no.to_s + '123'
      user_record.role = 'Student'
      user_record.email = email.blank? ? '' : email.to_s
      check_user_errors(user_record)
      return false unless errors.blank?
    else
      user.role = 'Student'
      changes_to_be_checked = %w[admission_no first_name last_name email immediate_contact_id]
      check_changes = changed & changes_to_be_checked
      unless check_changes.blank?
        user.username = admission_no if check_changes.include?('admission_no')
        user.first_name = first_name if check_changes.include?('first_name')
        user.last_name = last_name if check_changes.include?('last_name')
        user.email = email if check_changes.include?('email')
        check_user_errors(user)
      end

      if check_changes.include?('immediate_contact_id') || check_changes.include?('admission_no')
        Guardian.shift_user(self)
      end

    end
    self.email = '' if email.blank?
    return false unless errors.blank?
  end

  def check_user_errors(user)
    user.errors.each { |attr, msg| errors.add(attr.to_sym, msg.to_s) } unless user.valid?
    return false unless user.errors.blank?
  end

  def first_and_last_name
    "#{first_name} #{last_name}"
  end

  def full_name
    "#{first_name} #{middle_name} #{last_name}"
  end

  def gender_as_text
    return 'Male' if gender.downcase == 'm'
    return 'Female' if gender.downcase == 'f'

    nil
  end

  def graduated_batches
    batch_students.map(&:batch)
  end

  def all_batches
    graduated_batches + batch.to_a
  end

  def immediate_contact
    Guardian.find(immediate_contact_id) unless immediate_contact_id.nil?
  end

  def image_file=(input_data)
    return if input_data.blank?

    self.photo_filename     = input_data.original_filename
    self.photo_content_type = input_data.content_type.chomp
    self.photo_data         = input_data.read
  end

  def next_student
    next_st = batch.students.first(conditions: "id > #{id}", order: 'id ASC')
    next_st ||= batch.students.first(order: 'id ASC')
  end

  def previous_student
    prev_st = batch.students.first(conditions: "id < #{id}", order: 'admission_no DESC')
    prev_st ||= batch.students.first(order: 'id DESC')
    prev_st ||= batch.students.first(order: 'id DESC')
  end

  def previous_fee_student(date)
    fee = FinanceFee.first(conditions: "student_id < #{id} and fee_collection_id = #{date}", joins: 'INNER JOIN students ON finance_fees.student_id = students.id', order: 'student_id DESC')
    prev_st = fee.student unless fee.blank?
    fee ||= FinanceFee.first(conditions: "fee_collection_id = #{date}", joins: 'INNER JOIN students ON finance_fees.student_id = students.id', order: 'student_id DESC')
    prev_st ||= fee.student unless fee.blank?
    #    prev_st ||= self.batch.students.first(:order => "id DESC")
  end

  def next_fee_student(date)
    fee = FinanceFee.first(conditions: "student_id > #{id} and fee_collection_id = #{date}", joins: 'INNER JOIN students ON finance_fees.student_id = students.id', order: 'student_id ASC')
    next_st = fee.student unless fee.nil?
    fee ||= FinanceFee.first(conditions: "fee_collection_id = #{date}", joins: 'INNER JOIN students ON finance_fees.student_id = students.id', order: 'student_id ASC')
    next_st ||= fee.student unless fee.nil?
    #    prev_st ||= self.batch.students.first(:order => "id DESC")
  end

  def finance_fee_by_date(date)
    FinanceFee.find_by_fee_collection_id_and_student_id(date.id, id)
  end

  def check_fees_paid(date)
    particulars = date.fees_particulars(self)
    total_fees = 0
    financefee = date.fee_transactions(id)
    batch_discounts = BatchFeeCollectionDiscount.find_all_by_finance_fee_collection_id(date.id)
    student_discounts = StudentFeeCollectionDiscount.find_all_by_finance_fee_collection_id_and_receiver_id(date.id, id)
    category_discounts = StudentCategoryFeeCollectionDiscount.find_all_by_finance_fee_collection_id_and_receiver_id(date.id, student_category_id)
    total_discount = 0
    total_discount += batch_discounts.map(&:discount).sum unless batch_discounts.nil?
    total_discount += student_discounts.map(&:discount).sum unless student_discounts.nil?
    total_discount += category_discounts.map(&:discount).sum unless category_discounts.nil?
    total_discount = 100 if total_discount > 100
    particulars.map { |s| total_fees += s.amount.to_f }
    total_fees -= total_fees * (total_discount / 100)
    unless financefee.nil?
      paid_fees_transactions = FinanceTransaction.find(:all, select: 'amount,fine_amount', conditions: "FIND_IN_SET(id,\"#{financefee.transaction_id}\")")
    end
    paid_fees = 0
    paid_fees_transactions&.map { |m| paid_fees += (m.amount.to_f - m.fine_amount.to_f) }
    amount_pending = total_fees.to_f - paid_fees.to_f
    amount_pending == 0

    #    unless particulars.nil?
    #      return financefee.check_transaction_done unless financefee.nil?
    #
    #    else
    #      return false
    #    end
  end

  def has_retaken_exam(subject_id)
    retaken_exams = PreviousExamScore.find_all_by_student_id(id)
    if retaken_exams.empty?
      false
    else
      exams = Exam.find_all_by_id(retaken_exams.collect(&:exam_id))
      return true if exams.collect(&:subject_id).include?(subject_id)

      false
    end
  end

  def check_fee_pay(date)
    date.finance_fees.first(conditions: "student_id = #{id}").is_paid
  end

  def self.next_admission_no
    '' # stub for logic to be added later.
  end

  def get_fee_strucure_elements(date)
    elements = FinanceFeeStructureElement.get_student_fee_components(self, date)
    elements[:all] + elements[:by_batch] + elements[:by_category] + elements[:by_batch_and_category]
  end

  def total_fees(particulars)
    total = 0
    particulars.each do |fee|
      total += fee.amount
    end
    total
  end

  def has_associated_fee_particular?(fee_category)
    status = false
    status = true if fee_category.fee_particulars.find_all_by_admission_no(admission_no).count > 0
    if student_category_id.present? && (fee_category.fee_particulars.find_all_by_student_category_id(student_category_id).count > 0)
      status = true
    end
    status
  end

  def archive_student(status)
    student_attributes = attributes
    student_attributes['former_id'] = id
    student_attributes['status_description'] = status
    student_attributes.delete 'id'
    student_attributes.delete 'has_paid_fees'
    student_attributes.delete 'created_at'
    archived_student = ArchivedStudent.new(student_attributes)
    archived_student.photo = photo
    if archived_student.save
      guardians = self.guardians
      user.soft_delete
      guardians.each do |g|
        g.archive_guardian(archived_student.id)
      end
      destroy
      #
      #      student_exam_scores = ExamScore.find_all_by_student_id(self.id)
      #      student_exam_scores.each do |s|
      #        exam_score_attributes = s.attributes
      #        exam_score_attributes.delete "id"
      #        exam_score_attributes.delete "student_id"
      #        exam_score_attributes["student_id"]= archived_student.id
      #        ArchivedExamScore.create(exam_score_attributes)
      #        s.destroy
      #      end
      #
    end
  end

  def check_dependency
    if finance_transactions.present? || graduated_batches.present? || attendances.present? || finance_fees.present?
      return true
    end
    return true if FedenaPlugin.check_dependency(self, 'permanant').present?

    false
  end

  def former_dependency
    plugin_dependencies = FedenaPlugin.check_dependency(self, 'former')
  end

  def assessment_score_for(indicator_id, exam_id, batch_id)
    assessment_score = assessment_scores.find(:first, conditions: { student_id: id, descriptive_indicator_id: indicator_id, exam_id: exam_id, batch_id: batch_id })
    assessment_score.nil? ? assessment_scores.build(descriptive_indicator_id: indicator_id, exam_id: exam_id, batch_id: batch_id) : assessment_score
  end

  def observation_score_for(indicator_id, batch_id)
    assessment_score = assessment_scores.find(:first, conditions: { student_id: id, descriptive_indicator_id: indicator_id, batch_id: batch_id })
    assessment_score.nil? ? assessment_scores.build(descriptive_indicator_id: indicator_id, batch_id: batch_id) : assessment_score
  end

  def has_higher_priority_ranking_level(ranking_level_id, type, subject_id)
    ranking_level = RankingLevel.find(ranking_level_id)
    higher_levels = RankingLevel.find(:all, conditions: ['course_id = ? AND priority < ?', ranking_level.course_id, ranking_level.priority])
    if higher_levels.empty?
      return false
    else
      higher_levels.each do |level|
        if type == 'subject'
          score = GroupedExamReport.find_by_student_id_and_subject_id_and_batch_id_and_score_type(id, subject_id, batch_id, 's')
          unless score.nil?
            if batch.gpa_enabled?
              if (score.marks < level.gpa if level.marks_limit_type == 'upper') || (score.marks >= level.gpa if level.marks_limit_type == 'lower') || (if level.marks_limit_type == 'exact'
                                                                                               score.marks == level.gpa
                                                                                                                        end)
                return true
              end
            else
              if (score.marks < level.marks if level.marks_limit_type == 'upper') || (score.marks >= level.marks if level.marks_limit_type == 'lower') || (if level.marks_limit_type == 'exact'
                                                                                                 score.marks == level.marks 
                 end)
                return true
              end
            end
          end
        elsif type == 'overall'
          unless level.subject_count.nil?
            if level.full_course == true
              scores = GroupedExamReport.find(:all, conditions: { student_id: id, score_type: 's' })
            else
              subjects = batch.subjects
              scores = GroupedExamReport.find(:all, conditions: { student_id: id, batch_id: batch.id, subject_id: subjects.collect(&:id), score_type: 's' })
            end
            unless scores.empty?
              if batch.gpa_enabled?
                scores.select! do |s| (

                  (s.marks < level.gpa if level.marks_limit_type == 'upper') or (s.marks >= level.gpa if level.marks_limit_type == 'lower') or (if level.marks_limit_type == 'exact'
                                                                                            s.marks == level.gpa
                                                                                                                                                end))
                end
              else
                scores.select! do |s| (

                  
                  (s.marks < level.marks if level.marks_limit_type == 'upper') or (s.marks >= level.marks if level.marks_limit_type == 'lower') or (if level.marks_limit_type == 'exact'
                                                                                              s.marks == level.marks
                                                                                                                                                    end))
                end
              end
              unless scores.empty?
                sub_count = level.subject_count
                if level.subject_limit_type == 'upper'
                  return true if scores.count < sub_count
                elsif level.subject_limit_type == 'exact'
                  return true if scores.count == sub_count
                else
                  return true if scores.count >= sub_count
                end
              end
            end
          else
            if level.full_course == true
              total_student_score = 0
              avg_student_score = 0
              marks = GroupedExamReport.find_all_by_student_id_and_score_type(id, 'c')
              unless marks.empty?
                marks.map { |m| total_student_score += m.marks }
                avg_student_score = total_student_score.to_f / marks.count.to_f
                marks.first.marks = avg_student_score
                score = marks.first
              end
            else
              score = GroupedExamReport.find_by_student_id(id, conditions: { batch_id: batch.id, score_type: 'c' })
            end
            unless score.nil?
              if batch.gpa_enabled?
                if (score.marks < level.gpa if level.marks_limit_type == 'upper') || (score.marks >= level.gpa if level.marks_limit_type == 'lower') || (if level.marks_limit_type == 'exact'
                                                                                                 score.marks == level.gpa
                                                                                                                                                          end)
                  return true
                end
              else
                if (score.marks < level.marks if level.marks_limit_type == 'upper') || (score.marks >= level.marks if level.marks_limit_type == 'lower') || (if level.marks_limit_type == 'exact'
                                                                                                   score.marks == level.marks
                                                                                                                                                              end)
                  return true
                end
              end
            end
          end
        elsif type == 'course'
          unless level.subject_count.nil?
            scores = GroupedExamReport.find(:all, conditions: { student_id: id, score_type: 's' })
            unless scores.empty?
              if level.marks_limit_type == 'upper'
                scores.select! do |s| (

                  
                  (if s.student.batch.gpa_enabled?
                     (s.marks < level.gpa unless level.gpa.nil?)
                                      end) or (s.marks < level.marks unless level.marks.nil?))
                end
              elsif level.marks_limit_type == 'exact'
                scores.select! do |s| (

                  
                  (if s.student.batch.gpa_enabled?
                     (s.marks == level.gpa unless level.gpa.nil?)
                                      end) or (s.marks == level.marks unless level.marks.nil?))
                end
              else
                scores.select! do |s| (

                  
                  (if s.student.batch.gpa_enabled?
                     (s.marks >= level.gpa unless level.gpa.nil?)
                                      end) or (s.marks >= level.marks unless level.marks.nil?))
                end
              end
              unless scores.empty?
                sub_count = level.subject_count
                if level.full_course == true
                  if level.subject_limit_type == 'upper'
                    return true if scores.count < sub_count
                  elsif level.subject_limit_type == 'exact'
                    return true if scores.count == sub_count
                  else
                    return true if scores.count >= sub_count
                  end
                else
                  batch_ids = scores.collect(&:batch_id)
                  batch_ids.each do |batch_id|
                    next if batch_ids.empty?

                    count = batch_ids.count(batch_id)
                    if level.subject_limit_type == 'upper'
                      return true if count < sub_count
                    elsif level.subject_limit_type == 'exact'
                      return true if count == sub_count
                    else
                      return true if count >= sub_count
                    end
                    batch_ids.delete(batch_id)
                  end
                end
              end
            end
          else
            if level.full_course == true
              total_student_score = 0
              avg_student_score = 0
              marks = GroupedExamReport.find_all_by_student_id_and_score_type(id, 'c')
              unless marks.empty?
                marks.map { |m| total_student_score += m.marks }
                avg_student_score = total_student_score.to_f / marks.count
                if level.marks_limit_type == 'upper'
                  return true if (if batch.gpa_enabled?
                                    (avg_student_score < level.gpa unless level.gpa.nil?)
                                  end) || (avg_student_score < level.marks unless level.marks.nil?)
                elsif level.marks_limit_type == 'exact'
                  return true if (if batch.gpa_enabled?
                                    (avg_student_score == level.gpa unless level.gpa.nil?)
                                  end) || (avg_student_score == level.marks unless level.marks.nil?)
                else
                  return true if (avg_student_score >= level.gpa if batch.gpa_enabled? && level.gpa) ||
                                 (avg_student_score >= level.marks unless level.marks.nil?)
                end
              end
            else
              scores = GroupedExamReport.find(:all, conditions: { student_id: id, score_type: 'c' })
              unless scores.empty?
                if level.marks_limit_type == 'upper'
                  scores.select! do |s|
                    (if s.student.batch.gpa_enabled?
                       (s.marks < level.gpa unless level.gpa.nil?)
                     end) or (s.marks < level.marks unless level.marks.nil?)
                  end
                elsif level.marks_limit_type == 'exact'
                  scores.select! do |s|
                    (if s.student.batch.gpa_enabled?
                       (s.marks == level.gpa unless level.gpa.nil?)
                     end) or (s.marks == level.marks unless level.marks.nil?)
                  end
                else
                  scores.select! do |s|
                    (if s.student.batch.gpa_enabled?
                       (s.marks >= level.gpa unless level.gpa.nil?)
                     end) or (s.marks >= level.marks unless level.marks.nil?)
                  end
                end
                return true unless scores.empty?
              end
            end
          end
        end
      end
    end

    false
  end
end
