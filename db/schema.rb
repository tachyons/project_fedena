# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130110095412) do

  create_table "additional_exam_groups", :force => true do |t|
    t.string  "name"
    t.integer "batch_id"
    t.string  "exam_type"
    t.boolean "is_published",     :default => false
    t.boolean "result_published", :default => false
    t.string  "students_list"
    t.date    "exam_date"
  end

  create_table "additional_exam_scores", :force => true do |t|
    t.integer  "student_id"
    t.integer  "additional_exam_id"
    t.decimal  "marks",              :precision => 7, :scale => 2
    t.integer  "grading_level_id"
    t.string   "remarks"
    t.boolean  "is_failed"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "additional_exams", :force => true do |t|
    t.integer  "additional_exam_group_id"
    t.integer  "subject_id"
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer  "maximum_marks"
    t.integer  "minimum_marks"
    t.integer  "grading_level_id"
    t.integer  "weightage",                :default => 0
    t.integer  "event_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "additional_field_options", :force => true do |t|
    t.integer  "additional_field_id"
    t.string   "field_option"
    t.integer  "school_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "additional_fields", :force => true do |t|
    t.string  "name"
    t.boolean "status"
    t.boolean "is_mandatory", :default => false
    t.string  "input_type"
    t.integer "priority"
  end

  create_table "apply_leaves", :force => true do |t|
    t.integer "employee_id"
    t.integer "employee_leave_types_id"
    t.boolean "is_half_day"
    t.date    "start_date"
    t.date    "end_date"
    t.string  "reason"
    t.boolean "approved",                :default => false
    t.boolean "viewed_by_manager",       :default => false
    t.string  "manager_remark"
  end

  create_table "archived_employee_additional_details", :force => true do |t|
    t.integer "employee_id"
    t.integer "additional_field_id"
    t.string  "additional_info"
  end

  create_table "archived_employee_bank_details", :force => true do |t|
    t.integer "employee_id"
    t.integer "bank_field_id"
    t.string  "bank_info"
  end

  create_table "archived_employee_salary_structures", :force => true do |t|
    t.integer "employee_id"
    t.integer "payroll_category_id"
    t.string  "amount"
  end

  create_table "archived_employees", :force => true do |t|
    t.integer  "employee_category_id"
    t.string   "employee_number"
    t.date     "joining_date"
    t.string   "first_name"
    t.string   "middle_name"
    t.string   "last_name"
    t.string   "gender"
    t.string   "job_title"
    t.integer  "employee_position_id"
    t.integer  "employee_department_id"
    t.integer  "reporting_manager_id"
    t.integer  "employee_grade_id"
    t.string   "qualification"
    t.text     "experience_detail"
    t.integer  "experience_year"
    t.integer  "experience_month"
    t.boolean  "status"
    t.string   "status_description"
    t.date     "date_of_birth"
    t.string   "marital_status"
    t.integer  "children_count"
    t.string   "father_name"
    t.string   "mother_name"
    t.string   "husband_name"
    t.string   "blood_group"
    t.integer  "nationality_id"
    t.string   "home_address_line1"
    t.string   "home_address_line2"
    t.string   "home_city"
    t.string   "home_state"
    t.integer  "home_country_id"
    t.string   "home_pin_code"
    t.string   "office_address_line1"
    t.string   "office_address_line2"
    t.string   "office_city"
    t.string   "office_state"
    t.integer  "office_country_id"
    t.string   "office_pin_code"
    t.string   "office_phone1"
    t.string   "office_phone2"
    t.string   "mobile_phone"
    t.string   "home_phone"
    t.string   "email"
    t.string   "fax"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.binary   "photo_data",             :limit => 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "photo_file_size"
    t.string   "former_id"
    t.integer  "user_id"
  end

# Could not dump table "archived_exam_scores" because of following NoMethodError
#   undefined method `limits' for #<ActiveRecord::ConnectionAdapters::Mysql2IndexDefinition:0x0000555bbefa7070>

  create_table "archived_guardians", :force => true do |t|
    t.integer  "ward_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "relation"
    t.string   "email"
    t.string   "office_phone1"
    t.string   "office_phone2"
    t.string   "mobile_phone"
    t.string   "office_address_line1"
    t.string   "office_address_line2"
    t.string   "city"
    t.string   "state"
    t.integer  "country_id"
    t.date     "dob"
    t.string   "occupation"
    t.string   "income"
    t.string   "education"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "archived_students", :force => true do |t|
    t.string   "admission_no"
    t.string   "class_roll_no"
    t.date     "admission_date"
    t.string   "first_name"
    t.string   "middle_name"
    t.string   "last_name"
    t.integer  "batch_id"
    t.date     "date_of_birth"
    t.string   "gender"
    t.string   "blood_group"
    t.string   "birth_place"
    t.integer  "nationality_id"
    t.string   "language"
    t.string   "religion"
    t.integer  "student_category_id"
    t.string   "address_line1"
    t.string   "address_line2"
    t.string   "city"
    t.string   "state"
    t.string   "pin_code"
    t.integer  "country_id"
    t.string   "phone1"
    t.string   "phone2"
    t.string   "email"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.binary   "photo_data",           :limit => 16777215
    t.string   "status_description"
    t.boolean  "is_active",                                :default => true
    t.boolean  "is_deleted",                               :default => false
    t.integer  "immediate_contact_id"
    t.boolean  "is_sms_enabled",                           :default => true
    t.string   "former_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "photo_file_size"
    t.integer  "user_id"
  end

# Could not dump table "assessment_scores" because of following NoMethodError
#   undefined method `limits' for #<ActiveRecord::ConnectionAdapters::Mysql2IndexDefinition:0x0000555bbe643f60>

  create_table "assets", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "amount"
    t.boolean  "is_inactive", :default => false
    t.boolean  "is_deleted",  :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

# Could not dump table "attendances" because of following NoMethodError
#   undefined method `limits' for #<ActiveRecord::ConnectionAdapters::Mysql2IndexDefinition:0x0000555bbe2748a8>

  create_table "bank_fields", :force => true do |t|
    t.string  "name"
    t.boolean "status"
  end

# Could not dump table "batch_events" because of following NoMethodError
#   undefined method `limits' for #<ActiveRecord::ConnectionAdapters::Mysql2IndexDefinition:0x0000555bbe686c70>

  create_table "batch_groups", :force => true do |t|
    t.integer  "course_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

# Could not dump table "batch_students" because of following NoMethodError
#   undefined method `limits' for #<ActiveRecord::ConnectionAdapters::Mysql2IndexDefinition:0x0000555bbee91e88>

# Could not dump table "batches" because of following NoMethodError
#   undefined method `limits' for #<ActiveRecord::ConnectionAdapters::Mysql2IndexDefinition:0x0000555bbee68c18>

  create_table "cce_exam_categories", :force => true do |t|
    t.string   "name"
    t.string   "desc"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cce_grade_sets", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

# Could not dump table "cce_grades" because of following NoMethodError
#   undefined method `limits' for #<ActiveRecord::ConnectionAdapters::Mysql2IndexDefinition:0x0000555bbe93da40>

# Could not dump table "cce_reports" because of following NoMethodError
#   undefined method `limits' for #<ActiveRecord::ConnectionAdapters::Mysql2IndexDefinition:0x0000555bbed8c2b8>

  create_table "cce_weightages", :force => true do |t|
    t.integer  "weightage"
    t.string   "criteria_type"
    t.integer  "cce_exam_category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

# Could not dump table "cce_weightages_courses" because of following NoMethodError
#   undefined method `limits' for #<ActiveRecord::ConnectionAdapters::Mysql2IndexDefinition:0x0000555bbe67a8d0>

  create_table "class_designations", :force => true do |t|
    t.string   "name",                                      :null => false
    t.decimal  "cgpa",       :precision => 15, :scale => 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "marks",      :precision => 15, :scale => 2
    t.integer  "course_id"
  end

# Could not dump table "class_timings" because of following NoMethodError
#   undefined method `limits' for #<ActiveRecord::ConnectionAdapters::Mysql2IndexDefinition:0x0000555bbed03d28>

# Could not dump table "configurations" because of following NoMethodError
#   undefined method `limits' for #<ActiveRecord::ConnectionAdapters::Mysql2IndexDefinition:0x0000555bbece6160>

  create_table "countries", :force => true do |t|
    t.string "name"
  end

# Could not dump table "courses" because of following NoMethodError
#   undefined method `limits' for #<ActiveRecord::ConnectionAdapters::Mysql2IndexDefinition:0x0000555bbecae698>

# Could not dump table "courses_observation_groups" because of following NoMethodError
#   undefined method `limits' for #<ActiveRecord::ConnectionAdapters::Mysql2IndexDefinition:0x0000555bbec88e48>

# Could not dump table "delayed_jobs" because of following NoMethodError
#   undefined method `limits' for #<ActiveRecord::ConnectionAdapters::Mysql2IndexDefinition:0x0000555bbec520a0>

# Could not dump table "descriptive_indicators" because of following NoMethodError
#   undefined method `limits' for #<ActiveRecord::ConnectionAdapters::Mysql2IndexDefinition:0x0000555bbe1f1250>

  create_table "elective_groups", :force => true do |t|
    t.string   "name"
    t.integer  "batch_id"
    t.boolean  "is_deleted", :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "electives", :force => true do |t|
    t.integer  "elective_group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "employee_additional_details", :force => true do |t|
    t.integer "employee_id"
    t.integer "additional_field_id"
    t.string  "additional_info"
  end

  create_table "employee_attendances", :force => true do |t|
    t.date    "attendance_date"
    t.integer "employee_id"
    t.integer "employee_leave_type_id"
    t.string  "reason"
    t.boolean "is_half_day"
  end

  create_table "employee_bank_details", :force => true do |t|
    t.integer "employee_id"
    t.integer "bank_field_id"
    t.string  "bank_info"
  end

  create_table "employee_categories", :force => true do |t|
    t.string  "name"
    t.string  "prefix"
    t.boolean "status"
  end

  create_table "employee_department_events", :force => true do |t|
    t.integer  "event_id"
    t.integer  "employee_department_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "employee_departments", :force => true do |t|
    t.string  "code"
    t.string  "name"
    t.boolean "status"
  end

  create_table "employee_grades", :force => true do |t|
    t.string  "name"
    t.integer "priority"
    t.boolean "status"
    t.integer "max_hours_day"
    t.integer "max_hours_week"
  end

  create_table "employee_leave_types", :force => true do |t|
    t.string  "name"
    t.string  "code"
    t.boolean "status"
    t.string  "max_leave_count"
    t.boolean "carry_forward",   :default => false, :null => false
  end

  create_table "employee_leaves", :force => true do |t|
    t.integer  "employee_id"
    t.integer  "employee_leave_type_id"
    t.decimal  "leave_count",            :precision => 5, :scale => 1, :default => 0.0
    t.decimal  "leave_taken",            :precision => 5, :scale => 1, :default => 0.0
    t.date     "reset_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "employee_positions", :force => true do |t|
    t.string  "name"
    t.integer "employee_category_id"
    t.boolean "status"
  end

  create_table "employee_salary_structures", :force => true do |t|
    t.integer "employee_id"
    t.integer "payroll_category_id"
    t.string  "amount"
  end

# Could not dump table "employees" because of following NoMethodError
#   undefined method `limits' for #<ActiveRecord::ConnectionAdapters::Mysql2IndexDefinition:0x0000555bbdf015e0>

# Could not dump table "employees_subjects" because of following NoMethodError
#   undefined method `limits' for #<ActiveRecord::ConnectionAdapters::Mysql2IndexDefinition:0x0000555bbdeadaf8>

# Could not dump table "events" because of following NoMethodError
#   undefined method `limits' for #<ActiveRecord::ConnectionAdapters::Mysql2IndexDefinition:0x0000555bbde6d228>

  create_table "exam_groups", :force => true do |t|
    t.string  "name"
    t.integer "batch_id"
    t.string  "exam_type"
    t.boolean "is_published",         :default => false
    t.boolean "result_published",     :default => false
    t.date    "exam_date"
    t.boolean "is_final_exam",        :default => false, :null => false
    t.integer "cce_exam_category_id"
  end

# Could not dump table "exam_scores" because of following NoMethodError
#   undefined method `limits' for #<ActiveRecord::ConnectionAdapters::Mysql2IndexDefinition:0x0000555bbdded190>

# Could not dump table "exams" because of following NoMethodError
#   undefined method `limits' for #<ActiveRecord::ConnectionAdapters::Mysql2IndexDefinition:0x0000555bbdd7ad20>

# Could not dump table "fa_criterias" because of following NoMethodError
#   undefined method `limits' for #<ActiveRecord::ConnectionAdapters::Mysql2IndexDefinition:0x0000555bbdd1c680>

  create_table "fa_groups", :force => true do |t|
    t.string   "name"
    t.text     "desc"
    t.integer  "cce_exam_category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cce_grade_set_id"
    t.float    "max_marks",            :default => 100.0
    t.boolean  "is_deleted",           :default => false
  end

# Could not dump table "fa_groups_subjects" because of following NoMethodError
#   undefined method `limits' for #<ActiveRecord::ConnectionAdapters::Mysql2IndexDefinition:0x0000555bbdc80578>

  create_table "fee_collection_discounts", :force => true do |t|
    t.string   "type"
    t.string   "name"
    t.integer  "receiver_id"
    t.integer  "finance_fee_collection_id"
    t.decimal  "discount",                  :precision => 15, :scale => 2
    t.boolean  "is_amount",                                                :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fee_collection_particulars", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.decimal  "amount",                    :precision => 12, :scale => 2
    t.integer  "finance_fee_collection_id"
    t.integer  "student_category_id"
    t.string   "admission_no"
    t.integer  "student_id"
    t.boolean  "is_deleted",                                               :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fee_discounts", :force => true do |t|
    t.string  "type"
    t.string  "name"
    t.integer "receiver_id"
    t.integer "finance_fee_category_id"
    t.decimal "discount",                :precision => 15, :scale => 2
    t.boolean "is_amount",                                              :default => false
  end

  create_table "finance_donations", :force => true do |t|
    t.string   "donor"
    t.string   "description"
    t.decimal  "amount",           :precision => 15, :scale => 2
    t.integer  "transaction_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "transaction_date"
  end

  create_table "finance_fee_categories", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "batch_id"
    t.boolean  "is_deleted",  :default => false, :null => false
    t.boolean  "is_master",   :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

# Could not dump table "finance_fee_collections" because of following NoMethodError
#   undefined method `limits' for #<ActiveRecord::ConnectionAdapters::Mysql2IndexDefinition:0x0000555bbdaa7f80>

  create_table "finance_fee_particulars", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.decimal  "amount",                  :precision => 15, :scale => 2
    t.integer  "finance_fee_category_id"
    t.integer  "student_category_id"
    t.string   "admission_no"
    t.integer  "student_id"
    t.boolean  "is_deleted",                                             :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "finance_fee_structure_elements", :force => true do |t|
    t.decimal "amount",              :precision => 15, :scale => 2
    t.string  "label"
    t.integer "batch_id"
    t.integer "student_category_id"
    t.integer "student_id"
    t.integer "parent_id"
    t.integer "fee_collection_id"
    t.boolean "deleted",                                            :default => false
  end

# Could not dump table "finance_fees" because of following NoMethodError
#   undefined method `limits' for #<ActiveRecord::ConnectionAdapters::Mysql2IndexDefinition:0x0000555bbd9d53f0>

  create_table "finance_transaction_categories", :force => true do |t|
    t.string  "name"
    t.string  "description"
    t.boolean "is_income"
    t.boolean "deleted",     :default => false, :null => false
  end

  create_table "finance_transaction_triggers", :force => true do |t|
    t.integer "finance_category_id"
    t.decimal "percentage",          :precision => 8, :scale => 2
    t.string  "title"
    t.string  "description"
  end

  create_table "finance_transactions", :force => true do |t|
    t.string   "title"
    t.string   "description"
    t.decimal  "amount",                :precision => 15, :scale => 2
    t.boolean  "fine_included",                                        :default => false
    t.integer  "category_id"
    t.integer  "student_id"
    t.integer  "finance_fees_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "transaction_date"
    t.decimal  "fine_amount",           :precision => 10, :scale => 2, :default => 0.0
    t.integer  "master_transaction_id",                                :default => 0
    t.integer  "finance_id"
    t.string   "finance_type"
    t.integer  "payee_id"
    t.string   "payee_type"
    t.string   "receipt_no"
    t.string   "voucher_no"
  end

# Could not dump table "grading_levels" because of following NoMethodError
#   undefined method `limits' for #<ActiveRecord::ConnectionAdapters::Mysql2IndexDefinition:0x0000555bbd8703c0>

# Could not dump table "grouped_batches" because of following NoMethodError
#   undefined method `limits' for #<ActiveRecord::ConnectionAdapters::Mysql2IndexDefinition:0x0000555bbd824128>

# Could not dump table "grouped_exam_reports" because of following NoMethodError
#   undefined method `limits' for #<ActiveRecord::ConnectionAdapters::Mysql2IndexDefinition:0x0000555bbd795590>

# Could not dump table "grouped_exams" because of following NoMethodError
#   undefined method `limits' for #<ActiveRecord::ConnectionAdapters::Mysql2IndexDefinition:0x0000555bbd75da50>

  create_table "guardians", :force => true do |t|
    t.integer  "ward_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "relation"
    t.string   "email"
    t.string   "office_phone1"
    t.string   "office_phone2"
    t.string   "mobile_phone"
    t.string   "office_address_line1"
    t.string   "office_address_line2"
    t.string   "city"
    t.string   "state"
    t.integer  "country_id"
    t.date     "dob"
    t.string   "occupation"
    t.string   "income"
    t.string   "education"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "individual_payslip_categories", :force => true do |t|
    t.integer "employee_id"
    t.date    "salary_date"
    t.string  "name"
    t.string  "amount"
    t.boolean "is_deduction"
    t.boolean "include_every_month"
  end

  create_table "liabilities", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "amount"
    t.boolean  "is_solved",   :default => false
    t.boolean  "is_deleted",  :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "monthly_payslips", :force => true do |t|
    t.date    "salary_date"
    t.integer "employee_id"
    t.integer "payroll_category_id"
    t.string  "amount"
    t.boolean "is_approved",         :default => false, :null => false
    t.integer "approver_id"
    t.boolean "is_rejected",         :default => false, :null => false
    t.integer "rejector_id"
    t.string  "reason"
    t.string  "remark"
  end

  create_table "news", :force => true do |t|
    t.string   "title"
    t.text     "content"
    t.integer  "author_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "news_comments", :force => true do |t|
    t.text     "content"
    t.integer  "news_id"
    t.integer  "author_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_approved", :default => false
  end

  create_table "observation_groups", :force => true do |t|
    t.string   "name"
    t.string   "header_name"
    t.string   "desc"
    t.string   "cce_grade_set_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "observation_kind"
    t.float    "max_marks"
    t.boolean  "is_deleted",       :default => false
  end

# Could not dump table "observations" because of following NoMethodError
#   undefined method `limits' for #<ActiveRecord::ConnectionAdapters::Mysql2IndexDefinition:0x0000555bbcdd6810>

  create_table "payroll_categories", :force => true do |t|
    t.string  "name"
    t.float   "percentage"
    t.integer "payroll_category_id"
    t.boolean "is_deduction"
    t.boolean "status"
  end

# Could not dump table "period_entries" because of following NoMethodError
#   undefined method `limits' for #<ActiveRecord::ConnectionAdapters::Mysql2IndexDefinition:0x0000555bbccf1058>

# Could not dump table "previous_exam_scores" because of following NoMethodError
#   undefined method `limits' for #<ActiveRecord::ConnectionAdapters::Mysql2IndexDefinition:0x0000555bbcc34b10>

  create_table "privilege_tags", :force => true do |t|
    t.string   "name_tag"
    t.integer  "priority"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "privileges", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.integer  "privilege_tag_id"
    t.integer  "priority"
  end

# Could not dump table "privileges_users" because of following NoMethodError
#   undefined method `limits' for #<ActiveRecord::ConnectionAdapters::Mysql2IndexDefinition:0x0000555bbcb60f40>

  create_table "ranking_levels", :force => true do |t|
    t.string   "name",                                                                 :null => false
    t.decimal  "gpa",                :precision => 15, :scale => 2
    t.decimal  "marks",              :precision => 15, :scale => 2
    t.integer  "subject_count"
    t.integer  "priority"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "full_course",                                       :default => false
    t.integer  "course_id"
    t.string   "subject_limit_type"
    t.string   "marks_limit_type"
  end

# Could not dump table "reminders" because of following NoMethodError
#   undefined method `limits' for #<ActiveRecord::ConnectionAdapters::Mysql2IndexDefinition:0x0000555bbca1cf30>

  create_table "school_details", :force => true do |t|
    t.integer  "school_id"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.string   "logo_file_size"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sms_logs", :force => true do |t|
    t.string   "mobile"
    t.string   "gateway_response"
    t.string   "sms_message_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sms_messages", :force => true do |t|
    t.string   "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sms_settings", :force => true do |t|
    t.string  "settings_key"
    t.boolean "is_enabled",   :default => false
  end

# Could not dump table "student_additional_details" because of following NoMethodError
#   undefined method `limits' for #<ActiveRecord::ConnectionAdapters::Mysql2IndexDefinition:0x0000555bbc905d68>

  create_table "student_additional_field_options", :force => true do |t|
    t.integer  "student_additional_field_id"
    t.string   "field_option"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "student_additional_fields", :force => true do |t|
    t.string  "name"
    t.boolean "status"
    t.boolean "is_mandatory", :default => false
    t.string  "input_type"
    t.integer "priority"
  end

  create_table "student_categories", :force => true do |t|
    t.string  "name"
    t.boolean "is_deleted", :default => false, :null => false
  end

  create_table "student_previous_datas", :force => true do |t|
    t.integer "student_id"
    t.string  "institution"
    t.string  "year"
    t.string  "course"
    t.string  "total_mark"
  end

  create_table "student_previous_subject_marks", :force => true do |t|
    t.integer "student_id"
    t.string  "subject"
    t.string  "mark"
  end

# Could not dump table "students" because of following NoMethodError
#   undefined method `limits' for #<ActiveRecord::ConnectionAdapters::Mysql2IndexDefinition:0x0000555bbbbf3fa8>

# Could not dump table "students_subjects" because of following NoMethodError
#   undefined method `limits' for #<ActiveRecord::ConnectionAdapters::Mysql2IndexDefinition:0x0000555bbb73aa48>

  create_table "subject_amounts", :force => true do |t|
    t.integer  "course_id"
    t.integer  "amount",     :limit => 10, :precision => 10, :scale => 0
    t.string   "code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

# Could not dump table "subject_leaves" because of following NoMethodError
#   undefined method `limits' for #<ActiveRecord::ConnectionAdapters::Mysql2IndexDefinition:0x0000555bbf672e68>

# Could not dump table "subjects" because of following NoMethodError
#   undefined method `limits' for #<ActiveRecord::ConnectionAdapters::Mysql2IndexDefinition:0x0000555bbff250b0>

  create_table "time_zones", :force => true do |t|
    t.string   "name"
    t.string   "code"
    t.string   "difference_type"
    t.integer  "time_difference"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

# Could not dump table "timetable_entries" because of following NoMethodError
#   undefined method `limits' for #<ActiveRecord::ConnectionAdapters::Mysql2IndexDefinition:0x0000555bbfe84520>

# Could not dump table "timetables" because of following NoMethodError
#   undefined method `limits' for #<ActiveRecord::ConnectionAdapters::Mysql2IndexDefinition:0x0000555bbfe55770>

  create_table "user_events", :force => true do |t|
    t.integer  "event_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

# Could not dump table "users" because of following NoMethodError
#   undefined method `limits' for #<ActiveRecord::ConnectionAdapters::Mysql2IndexDefinition:0x0000555bbfd4fda8>

# Could not dump table "weekdays" because of following NoMethodError
#   undefined method `limits' for #<ActiveRecord::ConnectionAdapters::Mysql2IndexDefinition:0x0000555bbfccc818>

end
