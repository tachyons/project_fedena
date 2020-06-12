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

class Event < ActiveRecord::Base
  validates_presence_of :title, :description, :start_date, :end_date

  named_scope :holidays, conditions: { is_holiday: true }
  named_scope :exams, conditions: { is_exam: true }
  has_many :batch_events, dependent: :destroy
  has_many :employee_department_events, dependent: :destroy
  has_many :user_events, dependent: :destroy
  belongs_to :origin, polymorphic: true

  def validate
    unless start_date.nil? || end_date.nil?
      errors.add(:end_time, t('can_not_be_before_the_start_time').to_s) if end_date < start_date
    end
  end

  def is_student_event(student)
    flag = false
    base = origin
    unless base.blank?
      if base.respond_to?('batch_id')
        if base.batch_id == student.batch_id
          finance = base.fee_table
          if finance.present?
            flag = true if finance.map(&:student_id).include?(student.id)
          end
        end
      end
    end
    user_events = self.user_events
    unless user_events.nil?
      flag = true if user_events.map(&:user_id).include?(student.user.id)
    end
    flag
  end

  def is_employee_event(user)
    user_events = self.user_events
    unless user_events.nil?
      return true if user_events.map(&:user_id).include?(user.id)
    end
    false
  end

  def is_active_event
    flag = false
    if origin.nil?
      flag = true
    else
      if origin.respond_to?('is_deleted')
        flag = true unless origin.is_deleted
      else
        flag = true
      end
    end
    flag
  end

  def dates
    (start_date.to_date..end_date.to_date).to_a
  end

  class << self
    def is_a_holiday?(day)
      return true if Event.holidays.count(:all, conditions: ['start_date <=? AND end_date >= ?', day, day]) > 0

      false
    end
  end
end
