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

class Exam < ActiveRecord::Base
  validates_presence_of :start_time, :end_time
  validates_numericality_of :maximum_marks, :minimum_marks, allow_nil: true
  validates_presence_of :maximum_marks, :minimum_marks, if: :validation_should_present?, on: :update
  belongs_to :exam_group
  belongs_to :subject, conditions: { is_deleted: false }
  before_destroy :removable?
  before_save :update_exam_group_date

  has_one :event, as: :origin

  has_many :exam_scores
  has_many :archived_exam_scores
  has_many :previous_exam_scores
  has_many :assessment_scores
  #  has_and_belongs_to_many :cce_reports

  accepts_nested_attributes_for :exam_scores

  def validation_should_present?
    exam_group.exam_type != 'Grades'
  end

  def removable?
    exam_scores.reject { |es| es.marks.nil? and es.grading_level_id.nil? }.empty?
  end

  def validate
    errors.add_to_base(t('minmarks_cant_be_more_than_maxmarks').to_s) \
      if minimum_marks && maximum_marks && (minimum_marks > maximum_marks)
    errors.add_to_base(t('minmarks_cant_be_more_than_maxmarks').to_s) \
      if minimum_marks && maximum_marks && (minimum_marks > maximum_marks)
    unless start_time.nil? || end_time.nil?
      errors.add_to_base(t('end_time_cannot_before_start_time').to_s) if end_time < start_time
    end
  end

  def before_save
    self.weightage = 0 if weightage.nil?
    # update_exam_group_date
  end

  def after_create
    create_exam_event
  end

  def after_update
    update_exam_event
  end

  def score_for(student_id)
    exam_score = exam_scores.find(:first, conditions: { student_id: student_id })
    exam_score.nil? ? ExamScore.new : exam_score
  end

  def class_average_marks
    results = ExamScore.find_all_by_exam_id(self)
    scores = results.collect { |x| x.marks unless x.marks.nil? }
    scores.delete(nil)
    return (scores.sum / scores.size) unless scores.empty?

    0
  end

  def fa_groups
    subject.fa_groups.select { |fg| fg.cce_exam_category_id == exam_group.cce_exam_category_id }
  end

  private

  def update_exam_group_date
    group = exam_group
    if !group.exam_date.nil? && (start_time.to_date < group.exam_date)
      group.update_attribute(:exam_date, start_time.to_date)
    end
  end

  def create_exam_event
    if event.blank?
      new_event = Event.create do |e|
        e.title       = t('exam_text').to_s
        e.description = "#{exam_group.name} #{t('for')} #{subject.batch.full_name} - #{subject.name}"
        e.start_date  = start_time
        e.end_date    = end_time
        e.is_exam     = true
        e.origin      = self
      end
      batch_event = BatchEvent.create do |be|
        be.event_id = new_event.id
        be.batch_id = exam_group.batch_id
      end
      # self.event_id = new_event.id
      update_attributes(event_id: new_event.id)
    end
  end

  def update_exam_event
    event.update_attributes(start_date: start_time, end_date: end_time) unless event.blank?
  end
end
