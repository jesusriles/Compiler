# 																								#
# 	Nombre: 		Jesus Hector Gonzalez Vidaurri		#
# 	Materia: 		Lenguajes de Programacion					#
# 																								#

require 'fileutils'

$fileName = 'code.txt'.freeze


module Helper

	def readFile(fileName = $fileName)

		'''
			Read the file and return an array with the content of the file
			splitted by words.

			Lines starting with double hashtag (##) are ignored.
		'''

		@fileName = fileName
		@words = Array.new()
		file = File.open(@fileName, "r") # "r" stands for read
		@hasString = false

		file.each_line do |line|
			if line[0] == "#" && line[1] == "#"
				next
			end

			stringChar = "\""
			string = String.new()
			if line.include?("\"")
				@hasString = true
				begin
					string << line[/#{Regexp.escape(stringChar)}(.*?)#{Regexp.escape(stringChar)}/m, 1] # returns the characters between double quotes
					line.slice!(('"' + string + '"'))
				rescue
					errorMessage(line ,2)
				end
			end

			for word in line.split(" ")
				if word[-1] == ','
					@words << ","
					word.delete!(',')
				end
				@words << word
			end

			if @hasString
				@words << ('"' + string + '"')
				@hasString = false
			end
		end

		file.close()

		return @words

	end # end function


	def errorMessage(word, option = 1)

		'''
			Prints an error message.
		'''

		@word = word
		@option = option

		if option == 1
			Kernel.abort("Lexical error on: '" + @word + "', at line: " + getLine(@word).to_s + "\n")
		end

		if option == 2
			Kernel.abort('Please close double quotes ("") on line: ' + getLine(@word).to_s)
		end

		if option == 3
			Kernel.abort('Syntaxis error on line: ' + getLine(@word).to_s + '. The word "' + word + '" is misplaced.')
		end

	end # end function


		def getLine(word = '', fileName = $fileName)

		'''
			Return the number of the line where the word is found.
		'''

		@fileName = fileName
		@word = word
		file = File.open(@fileName, "r") # "r" stands for read

		counter = 1
		file.each_line do |line|
			if line.include?(@word)
				return counter
			end
			counter += 1
		end

	end # end function


end # end module


class Lexical
	include Helper
	# class variables
	@@ReservWords = ['suma',	'resta',	'multiplica',	'divide',	'guardalo',		'definir',	'dejalo',
										'mas',	'menos',	'por',				'entre',	'en',					'como'].freeze
	

	def classifyWord(word)
		
		'''
			Return the classification of the word.

			Note: Identifiers can only contain lower letters.

			Example on C:
				int (keyword), value (identifier), = (operator), 100 (constant) and ; (symbol).
		'''

		@word = word
		@Classif = ['keyword', 				# 0
								'identifier', 		# 1
								'constant', 			# 2 not used
								'symbol',					# 3
								'long',						# 4
								'double',					# 5
								'string'].freeze	# 6

		if @word[0] =~ /[a-z]/
			if @@ReservWords.include?(@word)
				return @Classif[0]	# keyword
			else
					@word.split("").each do |letter|
						if !(letter =~ /[a-z]/)
							errorMessage(@word)
						end
					end
				return @Classif[1]	# identifier
			end	

		elsif @word[0] == '"'
			return @Classif[6]	# string

		elsif @word[0] =~ /[0-9]/ || @word[0] == "." || @word[0] == "+" || @word[0] == "-"
			dot = 0
			signs = 0
			if @word[-1] == "." || @word == "-" || @word == "+"
				errorMessage(@word)
			end
			@word.split("").each do |letter|
				if letter == '.'
					dot += 1
				end
				if letter == "+" || letter == "-"
					signs += 1
				end
				if !(letter =~ /[0-9]/ || letter == "." || letter == "+" || letter == "-") || dot == 2 || signs == 2
					errorMessage(@word)
				end
			end
			if dot == 1
				return @Classif[5]	# double
			else
				return @Classif[4]	# long
			end
			
		elsif @word == ','
			return @Classif[3]	# symbol

		else
			errorMessage(@word)
		end

	end # end function
	

	def classifyAsHash

		'''
			Return a hash where the *key is the word and *value is the classification
		'''

		fileContent = Array.new()
		fileContent = readFile()
		result = Hash.new()

		for word in fileContent
			if !result.has_value?(word)
				result[word] = classifyWord(word).to_s()
			end
		end

		return result

	end # end function


	def startLexicalAnalysis

		'''
			Start lexical analysis
		'''

		return classifyAsHash

	end # end function


	# access controls
	private :classifyWord, :getLine, :classifyAsHash
	public :startLexicalAnalysis

end # end class


class Syntaxis
	include Helper

	def rules(wordsClassif, fileName = $fileName)

		'''
			Enforce rules.

			Rules:
				- keyword identifier keyword double/long/string
						example: definir a como +90.0

				- keyword identifier keyword identifier, keyword identifier
						example: suma a mas b, dejalo c
		'''

		@wordsClassif = wordsClassif
		@fileName = fileName
		@words = readFile()
		@mustBeKeyword = true

		@words.delete(",")

#		puts @words

		for word in @words
			if @wordsClassif[word] == 'keyword' && @mustBeKeyword
#				puts ("word: #{word}; classif: #{@wordsClassif[word]}")
				@mustBeKeyword = false
			elsif (@wordsClassif[word] == 'identifier' || @wordsClassif[word] == 'double' || @wordsClassif[word] == 'long' ||
							@wordsClassif[word] == 'string') && !@mustBeKeyword
#				puts ("word: #{word}; classif: #{@wordsClassif[word]}")
				@mustBeKeyword = true
			else
				errorMessage(word, 3)
			end
		end

		# # testing, print statement
		# value = 0
		# lines = 18
		# words = 0

		# while (value != nil)
		# 	puts(@linesAndWords[lines.to_s + words.to_s])
		# 	value = @linesAndWords[lines.to_s + (words + 1).to_s]
		# 	words += 1
		# end

	end # end function


	def logicalArithmetic(line)


	end # end function

	# access controls
	#public :rules
#	private :logicalArithmetic, :rules

end


'''
	Start - Testing Area
'''

lexical = Lexical.new()
syntaxis = Syntaxis.new()

wordsClassif = lexical.startLexicalAnalysis
syntaxis.rules(wordsClassif)
puts("*********************")
puts("Compiled correctly!")
puts("*********************")
'''
	Ends - Testing Area
'''
