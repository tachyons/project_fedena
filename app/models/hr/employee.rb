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

class Employee < ActiveRecord::Base
  belongs_to  :employee_category
  belongs_to  :employee_position
  belongs_to  :employee_grade
  belongs_to  :employee_department
  belongs_to  :nationality, class_name: 'Country'
  belongs_to  :user
  belongs_to  :reporting_manager, class_name: 'Employee'

  has_many    :employees_subjects
  has_many    :subjects, through: :employees_subjects
  has_many    :timetable_entries
  has_many    :employee_bank_details
  has_many    :employee_additional_details
  has_many    :apply_leaves
  has_many    :monthly_payslips
  has_many    :employee_salary_structures
  has_many    :finance_transactions, as: :payee
  has_many    :employee_attendances

  validates_format_of :email, with: /^[A-Z0-9._%-]+@([A-Z0-9-]+\.)+[A-Z]{2,4}$/i, allow_blank: true,
                              message: t('must_be_a_valid_email_address').to_s

  validates_presence_of :employee_category_id, :employee_number, :first_name, :employee_position_id,
                        :employee_department_id, :date_of_birth, :joining_date, :nationality_id
  validates_uniqueness_of :employee_number

  validates_associated :user
  before_validation :create_user_and_validate
  before_save :status_true
  has_attached_file :photo,
                    styles: { original: '125x125#' },
                    url: '/system/:class/:attachment/:id/:style/:basename.:extension',
                    path: ':rails_root/public/system/:class/:attachment/:id/:style/:basename.:extension'

  VALID_IMAGE_TYPES = ['image/gif', 'image/png', 'image/jpeg', 'image/jpg'].freeze

  validates_attachment_content_type :photo, content_type: VALID_IMAGE_TYPES,
                                            message: 'Image can only be GIF, PNG, JPG', if: proc { |p| !p.photo_file_name.blank? }
  validates_attachment_size :photo, less_than: 512_000,\
                                    message: 'must be less than 500 KB.', if: proc { |p| p.photo_file_name_changed? }

  def status_true
    self.status = 1 unless status == 1
  end

  def create_user_and_validate
    if new_record?
      user_record = build_user
      user_record.first_name = first_name
      user_record.last_name = last_name
      user_record.username = employee_number.to_s
      user_record.password = employee_number.to_s + '123'
      user_record.role = 'Employee'
      user_record.email = email.blank? ? '' : email.to_s
      check_user_errors(user_record)
    else
      changes_to_be_checked = %w[employee_number first_name last_name email]
      check_changes = changed & changes_to_be_checked
      #      self.user.role ||= "Employee"
      unless check_changes.blank?
        emp_user = user
        emp_user.username = employee_number if check_changes.include?('employee_number')
        emp_user.password = employee_number.to_s + '123' if check_changes.include?('employee_number')
        emp_user.first_name = first_name if check_changes.include?('first_name')
        emp_user.last_name = last_name if check_changes.include?('last_name')
        emp_user.email = email.to_s if check_changes.include?('email')
        emp_user.save if check_user_errors(user)
      end
    end
  end

  def check_user_errors(user)
    user.errors.each { |attr, msg| errors.add(attr.to_sym, msg.to_s) } unless user.valid?
    user.errors.blank?
  end

  def employee_batches
    batches_with_employees = Batch.active.reject { |b| b.employee_id.nil? }
    assigned_batches = batches_with_employees.select { |e| e.employee_id.split(',').include?(id.to_s) }
    assigned_batches
  end

  def image_file=(input_data)
    return if input_data.blank?

    self.photo_filename     = input_data.original_filename
    self.photo_content_type = input_data.content_type.chomp
    self.photo_data         = input_data.read
  end

  def max_hours_per_day
    employee_grade.max_hours_day unless employee_grade.blank?
  end

  def max_hours_per_week
    employee_grade.max_hours_week unless employee_grade.blank?
  end
  alias max_hours_day max_hours_per_day
  alias max_hours_week max_hours_per_week

  def next_employee
    next_st = employee_department.employees.first(conditions: "id>#{id}", order: 'id ASC')
    next_st ||= employee_department.employees.first(order: 'id ASC')
    next_st ||= employee_department.employees.first(order: 'id ASC')
  end

  def previous_employee
    prev_st = employee_department.employees.first(conditions: "id<#{id}", order: 'id DESC')
    prev_st ||= employee_department.employees.first(order: 'id DESC')
    prev_st ||= employee_department.empoyees.first(order: 'id DESC')
  end

  def full_name
    "#{first_name} #{middle_name} #{last_name}"
  end

  def is_payslip_approved(date)
    approve = MonthlyPayslip.find_all_by_salary_date_and_employee_id(date, id, conditions: ['is_approved = true'])
    if approve.empty?
      false
    else
      true
    end
  end

  def is_payslip_rejected(date)
    approve = MonthlyPayslip.find_all_by_salary_date_and_employee_id(date, id, conditions: ['is_rejected = true'])
    if approve.empty?
      false
    else
      true
    end
  end

  def self.total_employees_salary(employees, start_date, end_date)
    salary = 0
    employees.each do |e|
      salary_dates = e.all_salaries(start_date, end_date)
      salary_dates.each do |s|
        salary += e.employee_salary(s.salary_date.to_date)
      end
    end
    salary
  end

  def employee_salary(salary_date)
    monthly_payslips = MonthlyPayslip.find(:all,
                                           order: 'salary_date desc',
                                           conditions: ["employee_id ='#{id}'and salary_date = '#{salary_date}' and is_approved = 1"])
    individual_payslip_category = IndividualPayslipCategory.find(:all,
                                                                 order: 'salary_date desc',
                                                                 conditions: ["employee_id ='#{id}'and salary_date >= '#{salary_date}'"])
    individual_category_non_deductionable = 0
    individual_category_deductionable = 0
    individual_payslip_category.each do |pc|
      individual_category_non_deductionable += pc.amount.to_f unless pc.is_deduction == true
    end

    individual_payslip_category.each do |pc|
      individual_category_deductionable += pc.amount.to_f unless pc.is_deduction == false
    end

    non_deductionable_amount = 0
    deductionable_amount = 0
    monthly_payslips.each do |mp|
      category1 = PayrollCategory.find(mp.payroll_category_id)
      non_deductionable_amount += mp.amount.to_f unless category1.is_deduction == true
    end

    monthly_payslips.each do |mp|
      category2 = PayrollCategory.find(mp.payroll_category_id)
      deductionable_amount += mp.amount.to_f unless category2.is_deduction == false
    end
    net_non_deductionable_amount = individual_category_non_deductionable + non_deductionable_amount
    net_deductionable_amount = individual_category_deductionable + deductionable_amount

    net_amount = net_non_deductionable_amount - net_deductionable_amount
    net_amount.to_f
  end

  def salary(start_date, end_date)
    MonthlyPayslip.find_by_employee_id(id, order: 'salary_date desc',
                                           conditions: ["salary_date >= '#{start_date.to_date}' and salary_date <= '#{end_date.to_date}' and is_approved = 1"]).salary_date
  end

  def archive_employee(status)
    update_attributes(status_description: status)
    employee_attributes = attributes
    employee_attributes.delete 'id'
    employee_attributes.delete 'photo_file_size'
    employee_attributes.delete 'photo_file_name'
    employee_attributes.delete 'photo_content_type'
    employee_attributes['former_id'] = id
    archived_employee = ArchivedEmployee.new(employee_attributes)
    archived_employee.photo = photo
    if archived_employee.save
      #      self.user.delete unless self.user.nil?
      employee_salary_structures = self.employee_salary_structures
      employee_bank_details = self.employee_bank_details
      employee_additional_details = self.employee_additional_details
      employee_salary_structures.each do |g|
        g.archive_employee_salary_structure(archived_employee.id)
      end
      employee_bank_details.each do |g|
        g.archive_employee_bank_detail(archived_employee.id)
      end
      employee_additional_details.each do |g|
        g.archive_employee_additional_detail(archived_employee.id)
      end
      user.soft_delete
      destroy
    end
  end

  def all_salaries(start_date, end_date)
    MonthlyPayslip.find_all_by_employee_id(id, select: 'distinct salary_date', order: 'salary_date desc',
                                               conditions: ["salary_date >= '#{start_date.to_date}' and salary_date <= '#{end_date.to_date}' and is_approved = 1"])
  end

  def self.calculate_salary(monthly_payslip, individual_payslip_category)
    individual_category_non_deductionable = 0
    individual_category_deductionable = 0
    unless individual_payslip_category.blank?
      individual_payslip_category.each do |pc|
        if pc.is_deduction == true
          individual_category_deductionable += pc.amount.to_f
        else
          individual_category_non_deductionable += pc.amount.to_f
        end
      end
    end
    non_deductionable_amount = 0
    deductionable_amount = 0
    unless monthly_payslip.blank?
      monthly_payslip.each do |mp|
        unless mp.payroll_category.blank?
          if mp.payroll_category.is_deduction == true
            deductionable_amount += mp.amount.to_f
          else
            non_deductionable_amount += mp.amount.to_f
          end
        end
      end
    end
    net_non_deductionable_amount = individual_category_non_deductionable + non_deductionable_amount
    net_deductionable_amount = individual_category_deductionable + deductionable_amount
    net_amount = net_non_deductionable_amount - net_deductionable_amount

    return_hash = { net_amount: net_amount, net_deductionable_amount: net_deductionable_amount,\
                    net_non_deductionable_amount: net_non_deductionable_amount }
    return_hash
  end

  def self.find_in_active_or_archived(id)
    employee = Employee.find(:first, conditions: "id=#{id}")
    if employee.blank?
      ArchivedEmployee.find(:first, conditions: "former_id=#{id}")
    else
      employee
    end
  end

  def has_dependency
    return true if monthly_payslips.present? || employee_salary_structures.present? || employees_subjects.present? \
      || apply_leaves.present? || finance_transactions.present? || timetable_entries.present? || employee_attendances.present?
    return true if FedenaPlugin.check_dependency(self, 'permanant').present?

    false
  end

  def former_dependency
    FedenaPlugin.check_dependency(self, 'former')
  end
end
