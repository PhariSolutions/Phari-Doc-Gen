#--------------------------------------------------------------------------------------------
# THE BEER-WARE LICENSE" (Revision 42): <luiz@phari.solutions> wrote this file.
# As long as you retain this notice you can do whatever you want with this stuff.
# If we meet some day, and you think this stuff is worth it, you can buy me a beer in return.
# Luiz Philippe.
#--------------------------------------------------------------------------------------------

class Rota
    @type = ''
    @name = ''
    @request = ''
    @dataInput = ''
    @inputs = []
    @outputs = []

    def initialize(givenName, givenType, givenRequest, givenDataInput, inputList, outputList)
        @type = givenType
        @name = givenName
        @request = givenRequest
        @dataInput = givenDataInput
        @inputs = inputList
        @outputs = outputList
    end

    def type
        @type
    end

    def name
        @name
    end

    def request
        @request
    end

    def dataInput
        @dataInput
    end

    def inputs
        @inputs
    end

    def outputs
        @outputs
    end

    def printSelf
        puts"\n\nNome: #{@name}Tipo: #{@type}\nInputs:"
        @input.each(&:printSelf)
        puts'Outputs:'
        @output.each do |output|
            if output != 'nil'
                output.printSelf
            else puts'nil'
            end
        end
    end
end
