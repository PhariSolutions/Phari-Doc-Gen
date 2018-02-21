#--------------------------------------------------------------------------------------------
# THE BEER-WARE LICENSE" (Revision 42): <luiz@phari.solutions> wrote this file.
# As long as you retain this notice you can do whatever you want with this stuff.
# If we meet some day, and you think this stuff is worth it, you can buy me a beer in return.
# Luiz Philippe.
#--------------------------------------------------------------------------------------------

class Modelo
    @methods = []
    @routes = []
    @relations = []
    @name = ''

    def initialize(givenName, methodList, routeList, relationsList)
        @name = givenName
        @methods = methodList
        @routes = routeList
        @relations = relationsList
    end

    def printSelf
        puts @name.to_s
        puts "#{@name} methods:"
        @methods.each(&:printSelf)
        puts "#{@name} routes:"
        @routes.each(&:printSelf)
    end

    def name
        @name
    end

    def methods
        @methods
    end

    def routes
        @routes
    end

    def relations
        @relations
    end
end
