#--------------------------------------------------------------------------------------------
# THE BEER-WARE LICENSE" (Revision 42): <luiz@phari.solutions> wrote this file.
# As long as you retain this notice you can do whatever you want with this stuff.
# If we meet some day, and you think this stuff is worth it, you can buy me a beer in return.
# Luiz Philippe.
#--------------------------------------------------------------------------------------------

class MethodParam
    attr_accessor :name, :type, :notNull, :isObject, :isChild, :example, :childAttributes, :serial

    def initialize(name = "", type = "", notNull = true, isObject = false, isChild = false, example = nil)
        @name = name
        @type = type
        @notNull = notNull
        @isObject = isObject
        @isChild = isChild
        @example = example
        @childAttributes = {} if @isObject
        @serial = self.serialize
    end

    def addField attribute
        @childAttributes["#{attribute.name}"] = attribute
        @serial = self.serialize
    end

    def serialize
        if @type == 'nil'
          serialized = "Null"
        elsif @isObject
          serialized = "#{@name}: {<br><ul>"
          @childAttributes.each do |attribute|
            serialized = serialized + "<li>#{attribute[1].serialize}</li>"
          end
          serialized = serialized + "</ul>}"
        else
          unless @example.nil?
            serialized = "#{@name}: #{@example}"
          else
            serialized = "#{@name}: #{@type}"
          end
        end
        serialized
    end

    def printSelf
      puts self.serialize
    end
end
