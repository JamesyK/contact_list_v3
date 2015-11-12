require 'io/console'
require 'active_record'
require_relative 'contact'
require_relative 'phone'

ActiveRecord::Base.establish_connection(
  adapter: 'postgresql',
  database: 'contact_list'
)

OPTION = ARGV[0]
INFO = ARGV[1]

class ContactList

  def main
    case OPTION
    when 'help' then help
    when 'new' then new_contact
    when 'list' then list
    when 'show' then show
    when 'find_email' then find_email
    when 'find_first_name' then find_first_name
    when 'find_last_name' then find_last_name
    else help
    end
  end

  def help
    puts "Here is a list of available commands:"
    puts "    new - Create new contact"
    puts "    list - List all contacts"
    puts "    show id - Show a contact by id"
    puts "    find_email email - Find a contact by email"
    puts "    find_first_name name - Find contacts by first name"
    puts "    find_last_name name - Find contacts by last name"
  end

  def new_contact
    prompt = '> '
    puts "Enter the first name of the new contact:", prompt
    first_name = $stdin.gets.chomp.capitalize
    puts "Enter the last name of the new contact:", prompt
    last_name = $stdin.gets.chomp.capitalize
    puts "Enter the email of the new contact:", prompt
    email = $stdin.gets.chomp
    add_contact(first_name, last_name, email)
  end

  def add_contact(first_name, last_name, email)
    @new_contact = Contact.create(firstname: first_name, lastname: last_name, email: email)
    if @new_contact.errors.any?
      @new_contact.errors.full_messages.each { |error| puts error }
    else
      ask_add_phone
    end
  end

  def ask_add_phone
    prompt = '> '
    puts "Would you like to add a phone number? [Y/N]", prompt
    yes_or_no = $stdin.gets.chomp
    case yes_or_no.downcase
    when 'y' then add_phone
    when 'n' then goodbye
    else
      puts "Please enter either Y or N"
      ask_add_phone
    end
  end

  def add_phone
    prompt = '> '
    puts "Enter a phone number for the contact", prompt
    digits = $stdin.gets.chomp
    puts "Enter a label for that phone number", prompt
    label = $stdin.gets.chomp.capitalize
    new_phone = @new_contact.phones.create(digits: digits, label: label)
    if new_phone.errors.any?
      new_phone.errors.full_messages.each { |error| puts error }
      ask_add_phone
    else
      ask_another_phone
    end
  end

  def ask_another_phone
    prompt = '> '
    puts "Would you like to add another phone number? [Y/N]", prompt
    yes_or_no = $stdin.gets.chomp
    case yes_or_no.downcase
    when 'y' then add_phone
    when 'n' then puts goodbye
    else
      puts "Please enter either Y or N"
      ask_another_phone
    end
  end

  def list
    total = Contact.all.length
    contact_list = Contact.all.to_a
    puts_list(contact_list, total)
  end

  def show
    contact = Contact.find(INFO)
    puts_contact(contact)
  end

  def find_email
    contacts_found = Contact.where(email: INFO).to_a
    paginate(contacts_found)
  end

  def find_first_name
    contacts_found = Contact.where(firstname: INFO).to_a
    paginate(contacts_found)
  end

  def find_last_name
    contacts_found = Contact.where(lastname: INFO).to_a
    paginate(contacts_found)
  end

  def paginate(contacts)
    contacts.shift(5).each { |contact| puts_contact(contact) }
    until contacts.empty?
      puts "---Press space to continue---" 
      paginate(contacts) if STDIN.getch == " "
    end
  end

  def puts_list(contacts, total)
    paginate(contacts)
    puts "---"
    puts "#{total} records total"
  end

  def puts_contact(contact)
    first_name = contact.firstname
    last_name = contact.lastname
    email = contact.email
    id = contact.id
    list_numbers = ""
    if contact.phones.empty?
      puts "#{id}: #{first_name} #{last_name} (#{email})"
    else
      contact.phones.each do |phone_number|
        digits = phone_number.digits
        label = phone_number.label
        list_numbers << "#{label}: #{digits}, "
      end
      puts "#{id}: #{first_name} #{last_name} (#{email}) #{list_numbers}".strip.chop
      list_numbers = ""
    end
  end

  def goodbye
    puts "Goodbye!"
  end

end

ContactList.new.main
