#--------------------------------------------------------------------------------------------
# THE BEER-WARE LICENSE" (Revision 42): <luiz@phari.solutions> wrote this file.
# As long as you retain this notice you can do whatever you want with this stuff.
# If we meet some day, and you think this stuff is worth it, you can buy me a beer in return.
# Luiz Philippe.
#--------------------------------------------------------------------------------------------

class MethodParam
    attr_accessor :name, :type, :notNull, :isObject, :isCollection, :isChild, :example, :childAttributes, :serial

    def initialize(name = "", type = "", notNull = true, isObject = false, isCollection = false, isChild = false, example = nil)
      @name = name
      @type = type
      @notNull = notNull
      @isObject = isObject
      @isCollection = isCollection
      @isChild = isChild
      @example = example
      @childAttributes = {} if (@isObject || @isCollection)
    end

    def addField attribute
      raise ArgumentError, "Cannot add field to no object param" unless @isObject
      @childAttributes["#{attribute.name}"] = attribute
    end

    def setContent attribute
      raise ArgumentError, "Cannot set content of no array param" unless @isCollection
      @childAttributes["content"] = attribute
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
      elsif @isCollection
        if @childAttributes['content'].nil?
          serialized = "#{@name}: [<br><ul><li>Null</li><li>...</li></ul>"
        else
          # puts "child attributes: #{@childAttributes['content'].type}"
          serialized = "#{@name}: [<br><ul><li>#{@childAttributes['content'].serialize},</li><li>...</li>]</ul>"
        end
      else
        unless @example.nil?
          serialized = "#{@name}: #{@example}"
        else
          serialized = "#{@name}: #{@type}"
        end
      end
      serialized
    end

    def dump
      puts self.serialize
    end
end
