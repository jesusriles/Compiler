require 'fileutils'

class Lexico

	# class variables
	@@ReservWords = ['suma',	'resta',	'multiplica',	'divide',	'guardalo',
										'mas',	'menos',	'por',				'entre',	'en'].freeze

	def readFile(fileName = "code.txt")
	'''
		Read the file and return an array with the content of the file
		splitted by words.
	'''
		@fileName = fileName
		@words = Array.new()
		file = File.open(@fileName, "r") # "r" stands for read

		# split the content of the file by words
		file.each_line do |line|
			for word in line.split(" ")
				@words = word
				puts(@words)
			end
		end

		return @words

	end # end function


	def classifyWord(word)
		'''
			Return the classification of the word.
		'''
		@word = word

	end # end function

	# access controls
	public	:classifyWord
	private	:readFile

end # end class
