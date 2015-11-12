require 'pry'
require 'active_record'

# Output messages from Active Record to standard out
ActiveRecord::Base.logger = Logger.new(STDOUT)

puts 'Establishing connection to database ...'
ActiveRecord::Base.establish_connection(
  adapter: 'postgresql',
  database: 'contact_list',
)
puts 'CONNECTED'

puts 'Setting up Database (recreating tables) ...'

ActiveRecord::Schema.define do
  drop_table :contacts if ActiveRecord::Base.connection.table_exists?(:contacts)
  drop_table :phones if ActiveRecord::Base.connection.table_exists?(:phones)
  create_table :contacts do |t|
    t.column :firstname, :string
    t.column :lastname, :string
    t.column :email, :string
    t.timestamps null: false
  end
  create_table :phones do |t|
    t.column :digits, :string
    t.column :label, :string
    t.column :contact_id, :integer
    t.timestamps null: false
  end
end