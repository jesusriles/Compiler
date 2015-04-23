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
				if word.include?(',')
					if (word.count ",") > 1
						errorMessage(',,', 4)
					end
					word.delete!(',')
					@words << word
					@words << ","
				else
					@words << word
				end
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
		@lineNumber = getLine(@word).to_s

#		if @lineNumber = -1
#			Kernel.abort("LINE NUMBER NOT FOUND!")
#		end

		if option == 1
			Kernel.abort("Lexical error on: '" + @word + "', at line: " + @lineNumber + "\n")
		end

		if option == 2
			Kernel.abort('Please close double quotes ("") on line: ' + @lineNumber)
		end

		if option == 3
#			Kernel.abort('Syntaxis error on line: ' + @lineNumber + '. The word "' + @word + '" is misplaced.')
			Kernel.abort('Syntaxis error on line: ' + @lineNumber + '. I was expecting a keyword and \'' + @word + '\' is an identifier.')
		end

		if option == 4
			Kernel.abort('Syntaxis error on line: ' + @lineNumber + '. You placed 2 commas!.')
		end

		if option == 5
			Kernel.abort('Syntaxis error on line: ' + @lineNumber + '. Comma shouldn\'t be there!')
		end

		if option == 6
			Kernel.abort('Syntaxis error on line: ' + @lineNumber + '. I was expecting an identifier and \'' + @word + '\' is a keyword.')
		end

		if option == 7
			Kernel.abort("Variable \"#{word}\" was not declared!")
		end

		if option == 8
			Kernel.abort("Variable \"#{word}\" is a string and can't be used in operations!!")
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
		return -1
	end # end function


end # end module


class Lexical
	include Helper
	# class variables
	@@ReservWords = ['suma',	'resta',	'multiplica',	'divide',	'guardalo',		'definir',	'dejalo',
										'mas',	'menos',	'por',				'entre',	'en',					'como',			'imprime'].freeze
	

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
		@mustBeKeyword = true
		@words = readFile()
		@wordsWithComma = @words.dup
		@words.delete(",")
		@comma = false

		# enforce correct order
		for word in @words
			if @mustBeKeyword
				@mustBeKeyword = false

				if @wordsClassif[word] == 'keyword'
					next
				else
					errorMessage(word, 3) 
				end
			end

			if !@mustBeKeyword
				@mustBeKeyword = true

				if @wordsClassif[word] == 'identifier' || @wordsClassif[word] == 'double' || @wordsClassif[word] == 'long' ||
							@wordsClassif[word] == 'string'
					next
				else
					errorMessage(word, 6)
				end
			end
		end

		# check commas
		for word in @wordsWithComma
			if @comma
				@comma = false
				if word == 'dejalo'
					next
				else
					errorMessage((word.to_s + ","), 5)
				end
			end
			if word == ","
				@comma = true
			end
		end

	end # end function


	def logicalArithmetic(line)
		


	end # end function

	# access controls
	public :rules
	private :logicalArithmetic

end # end class


class Others
	include Helper

	def initialize

		lexical = Lexical.new()
		@@wordsClassif = lexical.startLexicalAnalysis
		@@values = allocateValues()

	end

	def printAnswer(fileName = $fileName)

		@fileName = fileName
		file = File.open(@fileName, "r") # "r" stands for read

		file.each_line do |line|

			if line.include?("imprime")
				if @@result.has_key?(line.split[1])
					puts "#{line.split[1].to_s}: #{@@result[line.split[1]]}"
				else
					puts "#{line.split[1].to_s}: nil"
				end
			end
		end
		
	end # end function


	def calculateValue(fileName = $fileName)

		'''

		'''

		@fileName = fileName
		@lines = Array.new()
		file = File.open(@fileName, "r") # "r" stands for read

		# asegurar que todo este correcto
		file.each_line do |line|

			if line.include?("##")
				next
			end

			if line.include?("suma") || line.include?("multiplica") || line.include?("divide") || line.include?("resta")

				line = line.gsub("suma",'')
				line = line.gsub("multiplica",'')
				line = line.gsub("divide",'')
				line = line.gsub("resta",'')

				line = line.gsub("mas",'')
				line = line.gsub("por",'')
				line = line.gsub("entre",'')
				line = line.gsub("menos",'')

				line = line.gsub("dejalo", '')
				line = line.gsub(",",'')

				for word in line.split(" ")
					if @@values.has_key?(word)
						if @@wordsClassif.has_key?(@@values[word])
							#puts "#{word} | #{@@values[word]} | #{@@wordsClassif[word]}"
						else
							tempVal = ('"' + @@values[word] + '"').to_s
							if @@wordsClassif.has_key?(tempVal)
								puts "#{word} | #{@@values[word]} | #{@@wordsClassif[tempVal]}"

								if @@wordsClassif[tempVal] == 'string'
									errorMessage(word, 8)	## strings can't be used in operations
								end
							else
								puts "********* || This point should not be reached! || *********"
							end
						end
					else
						tempVal1 = @@wordsClassif[word]
						if tempVal1 == 'long' || tempVal1 == 'double' || tempVal1 == 'string'
							next
						else
							if line.split(" ")[2] == word
								puts("---------\"#{word}\" has no value!.---------")
								next
							end
							errorMessage(word, 7)	## var not declared
						end
					end
				end
			end
		end

		# aqui se hacen las operaciones
		file = nil
		file = File.open(@fileName, "r") # "r" stands for read
		temp0 = nil
		temp1 = nil
		temp2 = nil
		temp3 = nil # tipo de operacion

		file.each_line do |line|

			if line.include?("##")
				next
			end

			if line.include?("suma") || line.include?("multiplica") || line.include?("divide") || line.include?("resta")

				line = line.gsub("mas",'')
				line = line.gsub("por",'')
				line = line.gsub("entre",'')
				line = line.gsub("menos",'')

				line = line.gsub("dejalo", '')
				line = line.gsub(",",'')

				for word in line.split(" ")
					#puts word

					# checar el tipo de operacion
					if word == 'suma'
						temp3 = 'suma'
						next
					end
					if word == 'resta'
						temp3 = 'resta'
						next
					end
					if word == 'multiplica'
						temp3 = 'multiplica'
						next
					end
					if word == 'divide'
						temp3 = 'divide'
						next
					end

					# si es una variable...
					if @@values.has_key?(word)
						if word == line.split(" ")[1]
							temp0 = @@values[word].to_i
						end
						if word == line.split(" ")[2]
							temp1 = @@values[word].to_i
						end
						if word == line.split(" ")[3]
							temp2 = line.split(" ")[3].to_s
							# suma
							if temp3 == 'suma'
								@@result[temp2] = temp0.to_i + temp1.to_i
#								puts ("#{temp0} + #{temp1} = #{@@result[temp2]} temp2: #{temp2}")
							end
							# resta
							if temp3 == 'resta'
								@@result[temp2] = (temp0.to_i) - (temp1.to_i)
#								puts ("#{temp0} - #{temp1} = #{@@result[temp2]} temp2: #{temp2}")
							end
							# multiplicacion
							if temp3 == 'multiplica'
								@@result[temp2] = temp0.to_i * temp1.to_i
#								puts ("#{temp0} * #{temp1} = #{@@result[temp2]} temp2: #{temp2}")
							end
							# division
							if temp3 == 'divide'
								@@result[temp2] = temp0.to_i / temp1.to_i
#								puts ("#{temp0} / #{temp1} = #{@@result[temp2]} temp2: #{temp2}")
							end
						end
					# si es un valor...
					else
						if word == line.split(" ")[1]
							temp0 = word.to_i
						end
						if word == line.split(" ")[2]
							temp1 = word.to_i
						end
					end
				end
			end
		end

		printAnswer()

		file.close

	end # end function


	def allocateValues(fileName = $fileName)

		@fileName = fileName
		file = File.open(@fileName, "r") # "r" stands for read
		stringChar = "\""
		@@result = Hash.new()

		file.each_line do |line|
			line.slice!("definir")
			line.slice!("como")

			if line.include?("##") || line.include?("suma") || line.include?("multiplica") || line.include?("divide") || line.include?("resta")
				next
			end

			if line.include?("\"")
				string = String.new()
				begin
					string << line[/#{Regexp.escape(stringChar)}(.*?)#{Regexp.escape(stringChar)}/m, 1] # returns the characters between double quotes
					line.slice!(('"' + string + '"'))
					line = line.gsub("\t",'')
					line = line.gsub("\n",'')
					line = line.gsub(" ",'')
					@@result[line] = string.to_s()
				rescue
					errorMessage(line ,2)
				end
			else
				@@result[line.split(" ")[0]] = line.split(" ")[1].to_s()
			end
		end

		return @@result

		file.close

	end # end function

	def startExecuting

	end # end function

	# access controls
	public :startExecuting, :calculateValue, :printAnswer
	private :allocateValues


end # end class

'''
	Start - Testing Area
'''

lexical = Lexical.new()
syntaxis = Syntaxis.new()
others = Others.new()

wordsClassif = lexical.startLexicalAnalysis
#puts wordsClassif

syntaxisTest = syntaxis.rules(wordsClassif)
#puts syntaxisTest

otherTest = others.calculateValue

# compiled correctly! message
puts("*********************")
puts("Compiled correctly!")
puts("*********************")


'''
	Ends - Testing Area
'''
