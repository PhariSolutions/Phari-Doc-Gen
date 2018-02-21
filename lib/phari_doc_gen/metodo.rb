#--------------------------------------------------------------------------------------------
# THE BEER-WARE LICENSE" (Revision 42): <luiz@phari.solutions> wrote this file.
# As long as you retain this notice you can do whatever you want with this stuff.
# If we meet some day, and you think this stuff is worth it, you can buy me a beer in return.
# Luiz Philippe.
#--------------------------------------------------------------------------------------------

require_relative 'methodParam.rb'

class Metodo
    @type = ''
    @name = ''
    @inputs = []
    @outputs = []
    @description = ''

    def initialize(givenName, givenType, inputList, outputList, givenDescription)
        @name = givenName
        @type = givenType
        @inputs = inputList
        @outputs = outputList
        @description = givenDescription
    end

    def type
        @type
    end

    def name
        @name
    end

    def inputs
        @inputs
    end

    def outputs
        @outputs
    end

    def description
        @description
    end

    def printSelf
        puts"\n\nNome: #{@name}Tipo: #{@type}Descrição: #{@description}\nInputs:"
        @inputs.each(&:printSelf)
        puts'Outputs:'
        @outputs.each do |output|
            if output != 'nil'
                output.printSelf
            else puts'nil'
            end
        end
    end
end
