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

class AssessmentScoresController < ApplicationController
  before_filter :login_required
  filter_access_to :all
  def exam_fa_groups
    @exam = Exam.find params[:id]
    @batch = @exam.subject.batch
    if @current_user.employee?
      employee = @current_user.employee_record
      privilege = @current_user.privileges.map(&:name)
      employee_subjects = employee.subjects
      unless @batch.employees.include?(employee) || employee_subjects.include?(@exam.subject) || privilege.include?('ExaminationControl') || privilege.include?('EnterResults')
        flash[:notice] = t('flash_msg4').to_s
        redirect_to controller: 'user', action: 'dashboard'
      end
    end
    @fa_groups = @exam.fa_groups
  end

  def fa_scores
    @fa_group = FaGroup.find(params[:fa_group_id])
    @fa_criterias = @fa_group.fa_criterias # .select{|m| m.descriptive_indicators.present?}
    @fa_criteria = @fa_criterias.first
    @exam = Exam.find(params[:exam_id])
    @batch = @exam.subject.batch
    if @current_user.employee?
      employee = @current_user.employee_record
      privilege = @current_user.privileges.map(&:name)
      employee_subjects = @current_user.employee_record.subjects
      unless @batch.employees.include?(employee) || employee_subjects.include?(@exam.subject) || privilege.include?('ExaminationControl') || privilege.include?('EnterResults')
        flash[:notice] = t('flash_msg4').to_s
        redirect_to controller: 'user', action: 'dashboard'
      end
    end
    subject = @exam.subject
    @students = if subject.elective_group_id.nil?
                  @batch.students.all(order: 'first_name ASC')
                else
                  subject.students
                end

    @student = if params[:student].present?
                 Student.find(params[:student])
               else
                 @students.first
               end
    @grading_levels = @batch.grading_level_list
    unless @batch.check_credit_points
      flash[:notice] = "Incomplete credit points for #{@batch.full_name}. Please assign credit points to all grades."
      redirect_to controller: 'grading_levels'
      return
    end
    di = @fa_criterias.collect(&:descriptive_indicator_ids).flatten
    @scores = Hash.new { |h, k| h[k] = Hash.new(&h.default_proc) }
    scores = AssessmentScore.find(:all, conditions: { student_id: @student.id, batch_id: @batch.id, descriptive_indicator_id: di, exam_id: @exam.id }).group_by(&:student_id)
    scores.each do |k, v|
      @scores[k] = v.group_by(&:descriptive_indicator_id)
    end
    if request.post?
      if params[:grade].present?
        AssessmentScore.transaction do
          params[:grade].each_pair do |di, point|
            @student = Student.find(params[:student_id])
            batch = @batch.id
            score = @student.assessment_score_for(di, @exam.id, batch)
            if point.blank?
              @err = 1 unless score.destroy
            else
              score.grade_points = point.to_i
              score.batch_id = batch
              @err = 1 unless score.save
            end
          end
        end
        flash[:notice] = if @err
                           'Error Occured'
                         else
                           'Grades saved successfully'
                         end
        render js: "window.location='#{fa_scores_path(exam_id: @exam.id, fa_group_id: @fa_group.id, student: @student.id)}'"
      else
        @student = Student.find(params[:student])
        render(:update) do |page|
          page.replace_html 'fa_sheet', partial: 'fa_sheet'
        end
      end
    end
  end

  def observation_groups
    @batch = Batch.find(params[:batch_id])
    if @current_user.employee?
      privilege = @current_user.privileges.map(&:name)
      employee = @current_user.employee_record
      unless @batch.employees.include?(employee) || privilege.include?('ExaminationControl') || privilege.include?('EnterResults')
        flash[:notice] = t('flash_msg4').to_s
        redirect_to controller: 'user', action: 'dashboard'
      end
    end
    @observation_groups = @batch.course.observation_groups
  end

  def observation_scores
    @batch = Batch.find(params[:batch_id])
    if @current_user.employee?
      privilege = @current_user.privileges.map(&:name)
      employee = @current_user.employee_record
      unless @batch.employees.include?(employee) || privilege.include?('ExaminationControl') || privilege.include?('EnterResults')
        flash[:notice] = t('flash_msg4').to_s
        redirect_to controller: 'user', action: 'dashboard'
      end
    end
    @observation_group = ObservationGroup.find(params[:observation_group_id])
    @observations = @observation_group.observations.find(:all, conditions: { is_active: true }, order: 'sort_order ASC')
    @students = @batch.students.all(order: 'first_name ASC')
    @student = if params[:student].present?
                 Student.find(params[:student])
               else
                 @students.first
               end
    @grading_levels = @observation_group.cce_grade_set.cce_grades
    di = @observations.collect(&:descriptive_indicator_ids).flatten
    @scores = Hash.new { |h, k| h[k] = Hash.new(&h.default_proc) }
    scores = AssessmentScore.find(:all, conditions: { student_id: @student.id, batch_id: @batch.id, descriptive_indicator_id: di }).group_by(&:student_id)
    scores.each do |k, v|
      @scores[k] = v.group_by(&:descriptive_indicator_id)
    end
    if request.post?
      if params[:grade].present?
        AssessmentScore.transaction do
          params[:grade].each_pair do |indicator, point|
            @student = Student.find(params[:student_id])
            batch = @batch.id
            score = @student.observation_score_for(indicator, batch)
            if point.blank?
              @err = 1 unless score.destroy
            else
              score.grade_points = point.to_i
              score.batch_id = batch
              @err = 1 unless score.save
            end
          end
        end
        if @err
          flash[:notice] = 'Error Occured'
          #        redirect_to :action => "observation_scores",:batch_id=>@batch.id,:observation_group_id=>observation_group.id
        else
          flash[:notice] = 'Grades saved successfully'
        end
        render js: "window.location='#{observation_scores_path(batch_id: @batch.id, observation_group_id: @observation_group.id, student: @student.id)}'"
      else
        @student = Student.find(params[:student])
        render(:update) do |page|
          page.replace_html 'observation_sheet', partial: 'observation_sheet'
        end
      end
    end
  end

  def only_privileged_employee_allowed
    @privilege = @current_user.privileges.map(&:name)
    if @current_user.employee?
      @privilege = @current_user.privileges.map(&:name)
      @employee_subjects = @current_user.employee_record.subjects
      if @employee_subjects.include?(@exam.subject) || @privilege.include?('ExaminationControl') || @privilege.include?('EnterResults')
        @allow_access = true
      else
        flash[:notice] = t('flash_msg4').to_s
        redirect_to controller: 'user', action: 'dashboard'
      end
    end
  end
end
