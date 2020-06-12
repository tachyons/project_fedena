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

class FeeDiscount < ActiveRecord::Base
  belongs_to :finance_fee_category
  validates_presence_of :name, :discount, :type
  validates_numericality_of :discount

  def validate
    if is_amount == false
      errors.add('discount', 'must be between 0 to 100') if (discount.to_f < 0.00) || (discount.to_f > 100.00)
    elsif is_amount == true
      payable = finance_fee_category.fee_particulars.map(&:amount).compact.flatten.sum
      errors.add('discount', 'cannot be greater than total payable amount') if discount.to_f > payable.to_f
    end
  end

  def total_payable
    payable = finance_fee_category.fee_particulars.map(&:amount).compact.flatten.sum
    payable
  end

  def discount
    if is_amount == false
      super
    elsif is_amount == true
      payable = total_payable
      percentage = (super.to_f / payable.to_f).to_f * 100
      percentage
    end
  end

  def category_name
    c = StudentCategory.find(receiver_id)
    c&.name
  end

  def student_name
    s = Student.find(receiver_id)
    "#{s.first_name} (#{s.admission_no})" unless s.nil?
  end
end
