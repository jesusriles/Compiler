require 'fileutils'

class Lexico

	# class variables
	@@fileContent = Array.new()	# content of the file
	@@reservWords = Array.new()	# reserverd words

	@@reservWords = ['suma',	'resta',	'multiplica',	'divide',	'guardalo',
										'mas',	'menos',	'por',				'entre',	'en']

	# read file
	def self.readFile

		counter = 0

		filename = "code.txt"
		file = File.open(filename, "r") # "r" stands for read

		# read each line of the file and store it on @@fileContent
		file.each_line do |line|
			@@fileContent[counter] = line
			counter += 1
		end

	end # end function

	def checkFileText
		
	end # end function

end # end class

Lexico.readFile()
