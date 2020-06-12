module TimetablesHelper
  def formatted_timetable_cell(tt)
    ## Produces view for one particular timetable entry cell
    unless tt.blank?
      "#{tt.subject.code}\n" unless tt.subject.blank?
    end
  end

  def formatted_timetable_cell_2(tt, emp)
    ## Produces view for one particular timetable entry cell
    unless tt.blank?
      unless tt.subject.blank?
        if tt.subject.elective_group.nil?
          "#{tt.subject.code}\n"
        else
          sub = tt.subject.elective_group.subjects.select { |s| s.employees.include?(emp) }
          "#{sub.first.code}\n" unless sub.empty?
        end
      end
    end
  end

  def subject_name(tt)
    ## Produces view for one particular timetable entry cell
    unless tt.blank?
      "#{tt.subject.name}\n" unless tt.subject.blank?
    end
  end

  def timetable_batch(tt)
    ## Produces view for one particular timetable entry cell
    unless tt.blank?
      tt.batch.full_name.to_s unless tt.batch.blank?
    end
  end

  def employee_name(tt)
    ## Produces view for one particular timetable entry cell
    unless tt.blank?
      tt.employee.first_name.to_s unless tt.employee.blank?
    end
  end

  def employee_full_name(tt)
    ## Produces view for one particular timetable entry cell
    unless tt.blank?
      tt.employee.full_name.to_s unless tt.employee.blank?
    end
  end
end
