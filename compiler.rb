require 'fileutils'

class Lexico

	# class variables
	@@fileContent = Array.new()	# content of the file
	@@reservWords = Array.new()	# reserverd words

	@@reservWords = ['suma',	'resta',	'multiplica',	'divide',	'guardalo',
										'mas',	'menos',	'por',				'entre',	'en']


	def readFile
	'''
		Read the file and store the information on @@fileContent.
	'''
		counter = 0

		filename = "code.txt"
		file = File.open(filename, "r") # "r" stands for read

		# read each line of the file and store it on @@fileContent
		file.each_line do |line|
			@@fileContent[counter] = line.to_s()
			counter += 1
		end
		checkFileText()
	end # end function


	def checkFileText
	'''
		Check each word of the file.
	'''
		lineWords = Array.new()
		counter = 0

		for words in @@fileContent
			lineWords[counter] = words.split
			counter += 1
		end
	end # end function


	def classifyWord(word)
		'''
			Classify the word.
		'''

	end

	# access controls
	private :checkFileText

end # end class

test = Lexico.new()
test.readFile()
