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

class Weekday < ActiveRecord::Base
  belongs_to :batch
  has_many :timetable_entries, dependent: :destroy
  default_scope order: 'weekday asc'
  named_scope   :default, conditions: { batch_id: nil, is_deleted: false }
  named_scope   :for_batch, ->(b) { { conditions: { batch_id: b.to_i, is_deleted: false } } }

  def self.weekday_by_day(batch_id)
    days = {}
    weekdays = Weekday.find_all_by_batch_id(batch_id)
    weekdays = Weekday.default if weekdays.empty?
    days = weekdays.group_by(&:day_of_week)
  end

  def deactivate
    update_attribute(:is_deleted, true)
  end

  def self.add_day(batch_id, day)
    if batch_id == 0
      if Weekday.find_by_batch_id_and_day_of_week(nil, day).nil?
        w = Weekday.new
        w.day_of_week = day
        w.weekday = day
        w.is_deleted = false
        w.save
      else
        Weekday.find_by_batch_id_and_day_of_week(nil, day).update_attributes(is_deleted: false, day_of_week: day)
      end
    else
      if Weekday.find_by_batch_id_and_day_of_week(batch_id, day).nil?
        w = Weekday.new
        w.day_of_week = day
        w.weekday = day
        w.batch_id = batch_id
        w.is_deleted = false
        w.save
      else
        Weekday.find_by_batch_id_and_day_of_week(batch_id, day).update_attributes(is_deleted: false, day_of_week: day)
      end
    end
  end
end
