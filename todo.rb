#Modules
module Menu
	def start
		"Help yourself to one of the following by typing '1', '2', or 'q': \n    1) Start New List\n    2) Open Saved List \n    Q) Quit "
	end

	def options
		"Options: \n    1) Complete Task\n    2) Add Task\n    3) Edit Task\n    4) Delete Task\n    5) View Completed Tasks\n    6) Save List\n    7) Exit Quickly\n    Q) Go Back to Menu"
	end
end

module Promptable
	def prompt(message = 'What would you like to do?', symbol = '>> ')
		puts message
		print symbol
		gets.chomp
	end
end

#Class
class Task
	attr_reader :description
	def initialize(description)
		@description = description
	end
	def to_s
		description
	end
end

class List
	attr_reader :all_tasks
	def initialize
		@all_tasks = []
	end
	def add(task)
		unless task.to_s.chomp.empty?
			all_tasks << task
		end
	end
	def delete(task_number)
		all_tasks.delete_at(task_number-1)
	end
	def edit(task_number, task)
		all_tasks[task_number-1] = task.description
	end
	def show
		all_tasks.map.with_index { |l, i| "#{i.next}) #{l}" }
	end
end

#Methods
def output_main(my_list)
	puts 'To-Do List:'
	if my_list.all_tasks.length == 0
		puts 'List is empty! Add some tasks to get started!'
	else
		puts my_list.show
	end
	puts
	prompt(options)
end

def output_completion(completed_list)
	puts 'Tasks Completed:'
	if completed_list.all_tasks.length == 0
		puts 'No tasks completed! Go accomplish something!'
	else
		puts completed_list.show
	end
end

def write_to_file(filename, my_list, completed_list)
	IO.write(filename, "To-Do List: \n" + my_list.all_tasks.map(&:to_s).join("\n") + "\nCompleted:\n" + completed_list.all_tasks.map(&:to_s).join("\n"))
end

def read_from_file(filename, my_list, completed_list)
	lines = File.open(filename).read.split("\n")
	for i in 0..lines.length-1
		if IO.readlines(filename)[i] == "Completed:\n"
			break_index = i
		end
	end
	for i in 1..(break_index-1)
		my_list.add(Task.new(lines[i]).description)
	end
	for i in (break_index+1)..(lines.length-1)
		completed_list.add(Task.new(lines[i]).description)
	end
	return my_list, completed_list
end

def run_main(my_list, completed_list)
	system 'clear'
	until ['q'].include?(user_input2 = output_main(my_list))
		case user_input2
		when '1' # Complete
			system 'clear'
			puts 'Which task number would you like to complete?'
			puts
			puts my_list.show
			input_task_num = prompt('').to_i
			if input_task_num > my_list.all_tasks.length || input_task_num < 1
				system 'clear'
				puts "That task number doesn't exist!"
				puts
				prompt('Press enter to go back.')
				system 'clear'
			else
				completed_list.add(my_list.all_tasks[input_task_num-1])
				my_list.delete(input_task_num)
				system 'clear'
				puts 'Completed!'
				puts
				prompt('Press enter to go back.')
				system 'clear'
			end
		when '2' # Add
			system 'clear'
			my_list.add(Task.new(prompt('What is would you like to add?')).description)
			system 'clear'
		when '3' # Edit
			system 'clear'
			if my_list.all_tasks.length == 0
				puts "There's nothing to edit!"
				puts
				prompt('Press enter to go back.')
				system 'clear'
			else
				puts 'Enter which task number to change.'
				puts
				puts my_list.show
				input_task_num = prompt('').to_i
				if input_task_num > my_list.all_tasks.length || input_task_num < 1
					system 'clear'
					puts "That task number doesn't exist!"
					puts
					prompt('Press enter to go back.')
					system 'clear'
				else
					my_list.edit(input_task_num, Task.new(prompt("What's the new task?")))
					system 'clear'
				end
			end
		when '4' # Delete
			system 'clear'
			if my_list.all_tasks.length == 0
				puts "There's nothing to delete!"
				puts
				prompt('Press enter to go back.')
				system 'clear'
			else
				puts 'Which task number would you like to delete?'
				puts
				puts my_list.show
				input_task_num = prompt('').to_i
				if input_task_num > my_list.all_tasks.length || input_task_num < 1
					system 'clear'
					puts "That task number doesn't exist!"
					puts
					prompt('Press enter to go back.')
					system 'clear'
				else
					my_list.delete(input_task_num)
					system 'clear'
				end
			end
		when '5' # View Completed Tasks
			system 'clear'
			output_completion(completed_list)
			puts
			prompt('Press enter to return to menu.')
			system 'clear'
		when '6' # Save
			system 'clear'
			write_to_file(prompt("Save as?"), my_list, completed_list)
			system 'clear'
		when '7' # Go Back to Menu
			system 'clear'
			exit
		else # Error
			system 'clear'
			puts "Sorry, I don't recognize that command."
		end
	end
	system 'clear'
end

#Actions
if __FILE__ == $PROGRAM_NAME
	include Menu
	include Promptable
	system 'clear'
	puts 'Welcome to the Great To-Do List!'
	0.times {puts ''}
	until ['q'].include?(user_input1 = prompt(start).downcase)
		case user_input1
		when '1' # New List
			my_list = List.new
			completed_list = List.new
			run_main(my_list, completed_list)
		when '2' # Saved List
			my_list = List.new
			completed_list = List.new
			system 'clear'
			begin
				filename = prompt("What is the name of the list you want to open?\n(Type 'back' to return to start.)")
				if filename != 'back'
					todoList = read_from_file(filename, my_list, completed_list)
					my_list = todoList[0]
					completed_list = todoList[1]
					run_main(my_list, completed_list)
				end
			rescue Errno::ENOENT
				system 'clear'
				puts 'File name not found, please verify your file name and path.'
				puts
				prompt("Press enter to go back. ")
			end
			system 'clear'
		else
			system 'clear'
			puts 'Sorry, I did not understand.'
		end
	end
	system 'clear'
	puts 'Thanks for stopping by!'
	sleep(1)
	system 'clear'
end