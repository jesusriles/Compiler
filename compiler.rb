require 'fileutils'

class Lexico

	# class variables
	@@ReservWords = ['suma',	'resta',	'multiplica',	'divide',	'guardalo',		'definir',	'dejalo',
										'mas',	'menos',	'por',				'entre',	'en',					'como'].freeze


	def readFile(fileName = "code.txt")
	'''
		Read the file and return an array with the content of the file
		splitted by words.
	'''
		@fileName = fileName
		@words = Array.new()
		file = File.open(@fileName, "r") # "r" stands for read

		counter = 0
		file.each_line do |line|
			for word in line.split(" ")
				@words[counter] = word
				counter += 1
			end
		end

		return @words

	end # end function


	def classifyWord(word)
		'''
			Return the classification of the word.

			Example on C:
				int (keyword), value (identifier), = (operator), 100 (constant) and ; (symbol).
		'''
		@word = word
		@Classif = ['keyword', 				# 0
								'identifier', 		# 1
								'operator', 			# 2
								'constant', 			# 3
								'symbol'].freeze	# 4

		# check if @word start with a letter
		if(@word[0] =~ /[A-Z]/ || @word[0] =~ /[a-z]/)
			if(@@ReservWords.include?(@word))
				return @Classif[0]	# keyword
			end
				return @Classif[1]	# identifier
		end

	end # end function

	# access controls
	public	:classifyWord, :readFile

end # end class


'''
	Start - Testing Area
'''
test = Lexico.new()

# readFile()
fileContent = Array.new()

fileContent = test.readFile()

# classifyWord()
for word in fileContent
	puts(word + "\t\tcategory:\t\t" + test.classifyWord(word).to_s)
end

'''
	Ends - Testing Area
'''
