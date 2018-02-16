#--------------------------------------------------------------------------------------------
# THE BEER-WARE LICENSE" (Revision 42): <luiz@phari.solutions> wrote this file.
# As long as you retain this notice you can do whatever you want with this stuff.
# If we meet some day, and you think this stuff is worth it, you can buy me a beer in return.
# Luiz Philippe.
#--------------------------------------------------------------------------------------------

require_relative 'Modelo.rb'
require_relative 'Rota.rb'
require_relative 'Metodo.rb'
require_relative 'MethodParam.rb'

class FileHandler
    # Reading files
    # Find a folder with the project name
    def packageExistis?(packageName)
        found = false
        package = ''
        puts'Finding project'
        puts'It may take some time...'
        Dir.glob('/**/' + packageName + '/') do |folder|
            package = folder
            found = true
            break
        end
        packagePath = package.to_s
        if found
            # Return the folder path if found
            return packagePath
        else
            # Exit if not found
            puts 'Aborting: package not found'
            exit
        end
    end

    # Read the 'README.md' file and generate descriprion
    def readProject(path)
        projectDescription = ''
        if File.exists?(path + 'README.md')
            readme = File.new(path + 'README.md')
            projectDescription = readProjectDescription(readme)
            readme.close
            projectDescription
        elsif File.exists?(path + 'readme.md')
            readme = File.new(path + 'readme.md')
            projectDescription = readProjectDescription(readme)
            readme.close
            projectDescription
        else
          puts 'Warning: No readme.md file found.'
        end
    end

    # Read models, helpers and controllers
    def readFiles(path)
        models = []
        # Find each model, helper and controller
        Dir.glob(path + 'models/*.rb') do |file|
            filename = file.to_s
            inputFile = File.new(filename)
            modelFile = File.new(filename, 'r')
            modelname = File.basename(inputFile, '.rb')
            helpername = path + 'app/helpers/' + modelname + '_helper.rb'
            controllername = path + 'app/controllers/' + modelname + '.rb'
            modelname = nameFormat(modelname)
            # Call the necessary methods for each helper, model and controller
            relations = readRelations(modelFile, modelname, filename)
            modelFile.close
            if File.exist?(helpername)
                modelHelper = File.new(helpername, 'r')
                methods = readMethods(modelHelper, helpername)
                modelHelper.close
            end
            if File.exist?(controllername)
                modelController = File.new(controllername, 'r')
                routes = readRoutes(modelController, controllername)
                modelController.close
            end
            currentModel = Modelo.new(modelname, methods, routes, relations)
            models << currentModel
            methods = nil
            routes = nil
            relations = nil
        end
        # Return models
        models
    end

    def nameFormat(name)
        name = name.capitalize
        while name.include?("/")
          name = name.slice(name.index("/")+1, name.length - name.index("/"))
          name = name.capitalize
        end
        while name.include?("_")
            prefix = name.slice(0, name.index("_"))
            sulfix = name.slice(name.index("_")+1, name.length - name.index("_"))
            name = "#{prefix.capitalize} #{sulfix.capitalize}"
        end
        while name.include?("-")
            prefix = name.slice(0, name.index("-"))
            sulfix = name.slice(name.index("-")+1, name.length - name.index("-"))
            name = "#{prefix.capitalize} #{sulfix.capitalize}"
        end
        name
    end

    # Auxiliary methods of reading

    # Generate project descriprion based on 'README.md'
    def readProjectDescription(readme)
        isCode = false
        @projectDescription = ''
        arr = IO.readlines(readme)
        # Read each line from the README
        arr.each do |line|
            # Read markdown syntax and trasform into HTML tags
            next if line.start_with?('# ') || line.start_with?('#!shell')
            line = '<h3>' + line.slice(3, line.length - 3) + '</h3>'if line.start_with?('## ')
            line = '<h4>' + line.slice(4, line.length - 4) + '</h4>' if line.start_with?('### ')
            line = '<h5>' + line.slice(6, line.length - 6) + '</h5>' if line.start_with?('##### ')
            line = '<li>' + line.slice(2, line.length - 2) + '</li>' if line.start_with?('* ')
            line = higlightText(line) while hasBetween?(line, '**', '**')
            line = italicText(line) while hasBetween?(line, '*', '*')
            if line.include?('```')
                if isCode
                    line = '</code><br><br>'
                    isCode = false
                else
                    line = '<br><br><code>'
                    isCode = true
                end
            end
            while line.include?(' [') && line.include?('](')
                line = linkText(line)
            end
            @projectDescription += line
        end
        # Return the HTML formated lines
        @projectDescription
    end

    # Verify if line contains markdown syntax like **bold**
    def hasBetween?(line, stringA, stringB)
        if line.include?(stringA)
            initial = line.index(stringA)
            len = line.length - initial
            lineSlice = line.slice(initial, len)
            return true if lineSlice.include?(stringB)
        end
        false
    end

    # Convert **bold** markdown to <b>bold</b> HTML
    def higlightText(line)
        initialIndex = line.index('**') + 2
        finalIndex = line.index('**', initialIndex)
        initialString = line.slice(0, initialIndex - 2)
        higlightedString = line.slice(initialIndex, finalIndex - initialIndex)
        finalString = line.slice(finalIndex + 2, line.length - finalIndex + 2)
        line = initialString + '<b>' + higlightedString + '</b>' + finalString
        line
    end

    # Convert *italic* markdown to <i>italic</i> HTML
    def italicText(line)
        initialIndex = line.index('*') + 1
        finalIndex = line.index('*', initialIndex)
        initialString = line.slice(0, initialIndex - 1)
        higlightedString = line.slice(initialIndex, finalIndex - initialIndex)
        finalString = line.slice(finalIndex + 1, line.length - finalIndex + 1)
        line = initialString + '<i>' + higlightedString + '</i>' + finalString
        line
    end

    # Convert [www.someaddress.com](text) markdown to <a href="www.someaddress.com">text</a> HTML
    def linkText(line)
        if line.include?(' [') && line.include?('](')
            initialContentIndex = line.index('[') + 1
            finalContentIndex = line.index(']', initialContentIndex)
            initialLinkIndex = line.index('](') + 2
            finalLinkIndex = line.index(')', initialLinkIndex)
            initialString = line.slice(0, initialContentIndex - 1)
            contentString = line.slice(initialContentIndex, finalContentIndex - initialContentIndex)
            linkString = line.slice(initialLinkIndex, finalLinkIndex - initialLinkIndex)
            finalString = line.slice(finalLinkIndex + 1, line.length - finalLinkIndex + 1)
            line = initialString + '<a href="' + linkString + '">' + contentString + '</a>' + finalString
        end
        line
    end

    # Read relations from model file
    def readRelations(modelFile, modelname, modelPath)
        lineIndex = 0
        relations = []
        begin
            arr = IO.readlines(modelFile)
            # Read each line from model
            arr.each do |line|
                lineIndex += 1
                # Verify presence of any clause
                if hasKeyword?(line, lineIndex, modelname)
                    # If it does, identify which clause it is
                    arg = decodeArgument(line)
                    keyword = arg[0]
                    argument = arg[1]
                    # Execute clause
                    case keyword
                    when 'belongs_to'
                      relation = modelname + ' belongs to ' + argument
                      relations << relation
                    when 'has_one'
                        relation = modelname + ' has one ' + argument
                        relations << relation
                    when 'has_many'
                        relation = modelname + ' has many ' + argument.pluralize
                        relations << relation
                    when 'has_and_belongs_to_many'
                        relation = modelname + ' has and belongs to many ' + argument.pluralize
                        relations << relation
                    end
                end
            end
        rescue ArgumentError => e
            # If a syntax error is found, it raises an Argument Error informing the file and line
            puts "Warning: #{modelPath}:#{lineIndex} " + e.message
        end
        relations
    end

    # Read all methods from a helper file; helper = file, helpername = file path
    def readMethods(helper, helpername)
        lineIndex = 0
        tipo = ''
        nome = ''
        descricao = ''
        inputs = {}
        outputs = {}
        methods = []
        toSent = true
        arr = IO.readlines(helper)
        # Read each line from helper
        arr.each do |line|
          lineIndex += 1
          begin
            # Verify if it has a clause
            if hasKeyword?(line, lineIndex, helpername)
                # If it does, identify which clause it is
                arg = decodeArgument(line)
                keyword = arg[0]
                argument = arg[1]
                # Execute clause
                case keyword
                when 'methods'
                    if nome != ''
                        methods << Metodo.new(nome, tipo, inputs, outputs, descricao)
                        inputs = {}
                        outputs = {}
                        toSent = false
                    end
                    tipo = argument
                when 'name'
                    if nome != '' && toSent
                        methods << Metodo.new(nome, tipo, inputs, outputs, descricao)
                        inputs = {}
                        outputs = {}
                    else
                        toSent = true
                    end
                    nome = argument
                when 'param'
                    data = dataValue(argument, inputs)
                    inputs["#{data.name}"] = data unless data.isChild
                when 'return'
                    data = dataValue(argument, outputs)
                    outputs["#{data.name}"] = data unless data.isChild
                else
                    # If a possible syntax error is found, a warning is sent informing file and linne
                    puts "Warning: in #{helpername}:#{lineIndex}: #{keyword} is not a keyword" if keyword != 'namespace'
                end
            end
            descricao = decodeDescription(line) if hasDescription?(line, lineIndex, helpername)
          rescue ArgumentError => e
              # If a syntax error is found, it raises an Argument Error informing the file and line
              puts "Warning: #{helpername}:#{lineIndex}: in #{nome} " + e.message
          end
        end
        methods << Metodo.new(nome, tipo, inputs, outputs, descricao)
        # Return a methods array
        methods
    end

    # Read all routes from a controller file; controller = file, controllername = file path
    def readRoutes(controller, controllername)
        lineIndex = 0
        tipo = ''
        requisicao = ''
        dataInput = ''
        nome = ''
        inputs = {}
        outputs = {}
        routes = []
        toSent = true
        arr = IO.readlines(controller)
        # Read each line from controller
        arr.each do |line|
          begin
            lineIndex += 1
            # Skip to next line if no clause is found
            next unless hasKeyword?(line, lineIndex, controllername)
            # If it has any clause, identify which one it is
            arg = decodeArgument(line)
            keyword = arg[0]
            argument = arg[1]
            case keyword
            # Then execute clause
            when 'route'
                if nome != ''
                    routes << Rota.new(nome, tipo, requisicao, dataInput, inputs, outputs)
                    inputs = {}
                    outputs = {}
                    toSent = false
                end
                tipo = argument
            when 'POST'
                if nome != '' && toSent
                    routes << Rota.new(nome, tipo, requisicao, dataInput, inputs, outputs)
                    inputs = {}
                    outputs = {}
                else
                    toSent = true
                end
                requisicao = keyword
                dataInput = argument
            when 'GET'
                if nome != '' && toSent
                    routes << Rota.new(nome, tipo, requisicao, dataInput, inputs, outputs)
                    inputs = {}
                    outputs = {}
                else
                    toSent = true
                end
                requisicao = keyword
                dataInput = argument
            when 'PUT'
                if nome != '' && toSent
                    routes << Rota.new(nome, tipo, requisicao, dataInput, inputs, outputs)
                    inputs = {}
                    outputs = {}
                else
                    toSent = true
                end
                requisicao = keyword
                dataInput = argument
            when 'DELETE'
                if nome != '' && toSent
                    routes << Rota.new(nome, tipo, requisicao, dataInput, inputs, outputs)
                    inputs = {}
                    outputs = {}
                else
                    toSent = true
                end
                requisicao = keyword
                dataInput = argument
            when 'name'
                nome = argument
            when 'param'
                data = dataValue(argument, inputs)
                inputs["#{data.name}"] = data unless data.isChild
            when 'return'
                data = dataValue(argument, outputs)
                outputs["#{data.name}"] = data unless data.isChild
            else
                # If a possible syntax error is found, a warning is sent informing file and linne
                # (Here in the namespace comparison, i'm doing a little mcgyver)
                puts "Warning: in #{controllername}:#{lineIndex}: #{keyword} is not a keyword" if keyword != 'namespace'
            end
          rescue ArgumentError => e
              # If a syntax error is found, it raises an Argument Error informing the file and line
              puts "Warning: #{controllername}:#{lineIndex}: in #{nome} " + e.message
          end
        end
        routes << Rota.new(nome, tipo, requisicao, dataInput, inputs, outputs)
        # Return a routes array
        routes
    end

    # Decoding clauses methods

    # Verify if a given line has any clause
    def hasKeyword?(line, lineIndex, fileName)
        if (line.include? '#') && (line.include? '@')
            for i in 0..line.index('#')-1
                if line[i].match(/^[[:alpha:]]$/)
                  return false
                end
            end
            for i in line.index('#')+1..line.index('@')-1
                if line[i].match(/^[[:alpha:]]$/)
                  lineText = line.slice(line.index('#'), line.index("\n") - line.index('#'))
                  # A warning informing file and line is sent if a possible error is found
                  puts "Warning: in #{fileName}:#{lineIndex}: #{lineText} is not a keyword"
                  return false
                end
            end
            # Return true if it does
            true
        else
            # And false if it don't
            false
        end
    end

    # The ** description clause has his own method seen that it has different syntax
    def hasDescription?(line, lineIndex, fileName)
        if (line.include? '#') && (line.include? '**')
          for i in 0..line.index('#')-1
              if line[i].match(/^[[:alpha:]]$/)
                return false
              end
          end
          for i in line.index('#')+1..line.index('**')-1
              if line[i].match(/^[[:alpha:]]$/)
                lineText = line.slice(line.index('#'), line.index("\n") - line.index('#'))
                # A warning informing file and line is sent if a possible error is found
                puts "Warning: in #{fileName}:#{lineIndex}: #{lineText} is not a description"
                return false
              end
          end
          # Return true if it has description clause
          true
        else
            # And false if it don't
            false
        end
    end

    # Decode which clause is on a given line, and which arguments
    def decodeArgument(line)
        args = []
        initialIndex = line.index('@') + 1
        sentence = line.slice(initialIndex, line.length - initialIndex)
        # Raises an Argument Error if some error is found
        raise ArgumentError.new("Sytanx error: expected 2 arguments (none given)") unless hasSomething?(sentence)
        raise ArgumentError.new("Sytanx error: expected 2 arguments (one given)") unless sentence.include?("\s")
        finalIndex = line.index("\s", line.index('@'))
        lenght = finalIndex - initialIndex
        keyword = line.slice(initialIndex, lenght)
        argument = line.slice(finalIndex + 1, line.size - finalIndex)
        raise ArgumentError.new("Sytanx error: expected 2 arguments (one given)") unless hasSomething?(argument)
        args << keyword
        args << argument
        # Return array with clause and arguments
        args
    end

    def hasSomething?(line)
        for i in 0..line.length-1
            if line[i].match(/^[[:alpha:]]$/)
              return true
            end
        end
        false
    end

    # If the clause is a param or return value, decode the name and datatype
    def dataValue(argument, objects)
        if argument.include? "\s"
            notNull = true
            isObject = false
            isCollection = false
            isChild = false
            name = argument.slice(0, argument.index("\s"))
            if name.end_with?('?')
              notNull = false
              name = name.slice(0, name.index('?'))
            end
            type = argument.slice(argument.index("\s") + 1, argument.size - 2)
            if type.include? "\s"
              example = type.slice(type.index("\s")+1, type.size-1-type.index("\s"))
              type = type.slice(0, type.index("\s"))
            end
            type = type.slice(0, type.size-1) if type.end_with?("\s") || type.end_with?("\n")
            isObject = true if type.downcase == "object"
            if name.include?(">")
              isChild = true
              path = []
              while name.include?(">")
                prefix = name.slice(0, name.index(">"))
                name = name.slice(name.index(">")+1, name.size-(name.index(">")+1))
                path << prefix
              end
              fatherObject = nil
              path.each do |object|
                raise ArgumentError, "Object #{object} does not exists!" unless objects.has_key?(object) && objects["#{object}"].isObject
                fatherObject = objects["#{object}"]
                objects = fatherObject.childAttributes
              end
            end
            data = MethodParam.new(name, type, notNull, isObject, isChild, example)
            fatherObject.addField data unless fatherObject.nil?
            # Return the data
            return data
        elsif argument.include? "nil"
            data = MethodParam.new('', 'nil', nil, nil, nil, nil)
            return data
        end
        argumentText = argument.slice(0, argument.index("\n"))
        # If any information is missing or incorrect, raises an Argument Error
        raise ArgumentError.new("Sytanx error: #{argumentText} is no data")
    end

    # Decode the text from a description clause
    def decodeDescription(line)
        initialIndex = line.index('*') + 3
        lenght = line.size - initialIndex
        description = line.slice(initialIndex, lenght)
        # Return the description text
        description
    end

    # File writing
    def writeFiles(models, projectName, projectDescription, path)
        outputFolder = path + "#{projectName}_PhariDoc/"
        FileUtils.mkdir_p(outputFolder)
        # Create the css/master.css file, which is default for any project
        FileUtils.mkdir_p(outputFolder + 'css/')
        css = File.open(outputFolder + 'css/master.css', 'w')
        writeCSS(css)
        css.close
        # Write the project main page
        projectHTML = File.open(outputFolder + 'project.html', 'w')
        writeHeader(projectHTML)
        writeProjectPage(projectName, projectHTML, models, projectDescription)
        projectHTML.close
        # Write each model's page
        FileUtils.mkdir_p(outputFolder + 'models/')
        models.each do |model|
            name = model.name.downcase
            modelHTML = File.open(outputFolder + "models/#{name}.html", 'w')
            writeHeaderInDir(modelHTML)
            writeModelPage(modelHTML, model, projectName)
            modelHTML.close
        end
    end

    # Write the css content
    def writeCSS(file)
        file.write("body{
    background-color: #2CA896;
  }
  a{
    color: #2CA896;
  }
  a:hover{
    color: #333;
  }
  li{
    padding-left: 3%;
  }
  code{
    background-color: #DDD;
    color: black;
  }
  .logo{
    margin: 5%;
  }
  .left{
    float: left;
  }
  .right{
    float: right;
  }
  .list-indexes{
    font-size: 24px;
  }")
    end

    # Write the HTML header
    def writeHeader(file)
        file.write("<!DOCTYPE html>

        <head lang='en'>
            <meta charset='UTF-8'>
            <link rel='stylesheet' href='https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css' integrity='sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u' crossorigin='anonymous'>
            <script src='https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js' integrity='sha384-Tc5IQib027qvyjSMfHjOMaLkfuWVxZxUPnCJA7l2mCWNIpG9mGCD8wGNIcPD7Txa' crossorigin='anonymous'></script>
            <link rel='stylesheet' href='css/master.css'>
        </head>

        <body>
            <nav class='navbar navbar-default navbar-fixed-top'>
                <div class='container-fluid'>
                    <div class='navbar-header'>
                      <a href='project.html'><img class='logo' src='https://lh3.googleusercontent.com/ICEHU3m_zkW_82Xq8bEBKoIYHvPA4u_O6qEc-vUaeRWNppdQbPOLO5lm_mdEl0NPTxQ5vdINr1Nr6ZVGgmR8JF4FtjqzhncUDtU8JQSeP_14Wn83-lVVH9fGjNy5znkXYMdZzJuH5pxEDT0s6nAYp3VIf2YekczAbTjy1SHcdmT57fBGg2z9Ba4sr0OYJp8b5mVFRVxedqnI__nKo3ujRI7wOZ89ILi3EOaS51THdCXWZ8Uq8RgAPGEDXTNc65oodAessPFjFbOBXtpA9lWOYM3irkwB2VvAMmebDH75pGXKY2u9e21dJOrNlYjZhNPZN-hdbSBj-BAnNeDJO89VOXRVEw0eE16VSOj9t_04-kVsw2ZJkjZc7pdphaNkG-1h-LM3G6eI7gYtDf2f-nTO9EyziFFF_UOrHLTm1CuY_HfgvUZ4b4rCV5pSokgtbhecWys8kzO5SneXSV2VYDVQYuABT9UKv50u_oEQJggtFnD3pu2HV-r9EO210U272ormArABnRtL29SQVFrEa8sBfwVtLGP2fJ4eg5sGbogi3Lz4t30rQBWS8yMN2aLtLvvU8K5FbR-5VmC-HdhAAbv4ZJZO_x7SYUzMe4GlYzDnVai7jTmwr02UGf7jwoucYKjsSsH8R-ydgsYn45T5hWmxWZwLJtOsPy3BZTr_NV6-vQ=w800-h500-no' height='50px' alt='Logo'></a>
                    </div>
                    <ul class='nav navbar-nav'>
                    </ul>
                </div>
            </nav>
            <br><br><br>")
    end

    # Write the HTML header with relative paths
    def writeHeaderInDir(file)
        file.write("<!DOCTYPE html>

        <head lang='en'>
            <meta charset='UTF-8'>
            <link rel='stylesheet' href='https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css' integrity='sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u' crossorigin='anonymous'>
            <script src='https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js' integrity='sha384-Tc5IQib027qvyjSMfHjOMaLkfuWVxZxUPnCJA7l2mCWNIpG9mGCD8wGNIcPD7Txa' crossorigin='anonymous'></script>
            <link rel='stylesheet' href='../css/master.css'>
        </head>

        <body>
            <nav class='navbar navbar-default navbar-fixed-top'>
                <div class='container-fluid'>
                    <div class='navbar-header'>
                      <a href='../project.html'><img class='logo' src='https://lh3.googleusercontent.com/ICEHU3m_zkW_82Xq8bEBKoIYHvPA4u_O6qEc-vUaeRWNppdQbPOLO5lm_mdEl0NPTxQ5vdINr1Nr6ZVGgmR8JF4FtjqzhncUDtU8JQSeP_14Wn83-lVVH9fGjNy5znkXYMdZzJuH5pxEDT0s6nAYp3VIf2YekczAbTjy1SHcdmT57fBGg2z9Ba4sr0OYJp8b5mVFRVxedqnI__nKo3ujRI7wOZ89ILi3EOaS51THdCXWZ8Uq8RgAPGEDXTNc65oodAessPFjFbOBXtpA9lWOYM3irkwB2VvAMmebDH75pGXKY2u9e21dJOrNlYjZhNPZN-hdbSBj-BAnNeDJO89VOXRVEw0eE16VSOj9t_04-kVsw2ZJkjZc7pdphaNkG-1h-LM3G6eI7gYtDf2f-nTO9EyziFFF_UOrHLTm1CuY_HfgvUZ4b4rCV5pSokgtbhecWys8kzO5SneXSV2VYDVQYuABT9UKv50u_oEQJggtFnD3pu2HV-r9EO210U272ormArABnRtL29SQVFrEa8sBfwVtLGP2fJ4eg5sGbogi3Lz4t30rQBWS8yMN2aLtLvvU8K5FbR-5VmC-HdhAAbv4ZJZO_x7SYUzMe4GlYzDnVai7jTmwr02UGf7jwoucYKjsSsH8R-ydgsYn45T5hWmxWZwLJtOsPy3BZTr_NV6-vQ=w800-h500-no' height='50px' alt='Logo'></a>
                    </div>
                    <ul class='nav navbar-nav'>
                    </ul>
                </div>
            </nav>
            <br><br><br>")
    end

    #Write the main project HTML content
    def writeProjectPage(project, file, models, description)
        file.write("<div class='container panel panel-default'>
          <div class='row'>
            <div class='panel panel-default'>
              <div class='panel-heading'>
                <h1>#{project}</h1>
              </div>
              <div class='panel-body'>
                <h2>Project Description</h2>
                #{description}
              </div>
            </div>
          </div>
          <div class='row'>
            <div class='col-md-4'>
              <ul class='list-group'>")
        unless models.nil?
            models.each do |model|
                link = model.name.downcase
                name = model.name
                file.write("\t\t<a href='models/#{link}.html' class='list-indexes list-group-item'>#{name}</a>
                ")
            end
        end
        file.write("\t</ul>
          </div>
          <div class='col-md-4 col-md-offset-2'>
            <img src='https://lh3.googleusercontent.com/0vxwJN77Sb33ktxcq2pv2jGLyhBvboPScuK6iiUnJFRFb1zfSR9_o_U1uJuMujA5lMrz2msol4oxiS5dZcmiULjbCgL54q-mVFEJZN4tFkm8G03Er8eBmCqlmlpBUu4fePmuhWcOoIVPGhdmLpN5WQOUtg8j4f98uiPuI9BhTalI7sN1H_KRLZBLY9UU22n_qXnAt2t-TsC5nr1-noJB0KSDpJMubjPPbJKhvRwPnrJINjZ9t00dTJkoeGlUCc5wS92GarlXTf1tUcEkfyYGyhwrphIqx06KpozuCKJLiFPKjLbEI_jfjx4hZEg8nR2HP-oKAv5b1tFH6tS6CmcHxWlo8iN5y7Xe1auIAosygKYG9j4lZOWaxsD7kGADf6r22J0UHj1Jyxrx5bp0J9l6QgFBg0NejB4kLkOu0yHM8TjgebOdRW1GXNfdXAcgYlzlzB5IWCDz7Iy8L7pSdDEOZsxP5Cb_7GY1LbvvXxZ68Zceg-mZGSOLXTR44XpxWZVA8xjzI6wQmONw-pSRgCycGnjPp5TWtoGNugk3OlY3ax3g7T0aGgRKthlmHqYSh4tWH6bgoBPpe41q7U6P9445VQG5gOlORuGADWQNrxbL-dzflclo7bDPlTNykfp_lmwdKg8JCYPuLGwStrpInNqk-sQQkNb30Cyk3NaaMEZWpQ=w300-h497-no' alt='Phari logo' width='100%'>
          </div>
        </div>
      </div>
    </body>")
    end

    # Write a model HTML page content
    def writeModelPage(file, model, project)
        name = model.name
        relations = model.relations
        methods = model.methods
        routes = model.routes
        file.write("<div class='container panel panel-default'>
          <div class='row'>
            <div class='panel panel-default'>
              <div class='panel-heading'>
                <h1>#{project}</h1>
              </div>
              <div class='panel-body'>
                <h2>#{name} Model</h2>
                <h4>")
                unless relations.nil?
                    relations.each do |relation|
                        file.write('<br>'+relation)
                    end
                end
                file.write("</h4>
              </div>
            </div>
          </div>
          <div class='row'>
            <div class='col-md-6'>
              <div class='panel panel-default'>
                <div class='panel-heading'>
                  <h2>Methods</h2>
                </div>
              </div>
              <ul class='list-group'>")
        unless methods.nil?
            methods.each do |method|
                type = method.type
                name = method.name
                inputs = method.inputs
                outputs = method.outputs
                description = method.description
                file.write("  <div class='list-group-item'>
                              <h4 class='list-group-item-heading'>CRUD: #{type}<br>Name: #{name}</h4>
                              <p><br>Inputs:<br><ul>")
                unless inputs.nil?
                    inputs.each do |input|
                        input = input[1]
                        file.write("<li>#{input.serialize}</li>")
                    end
                end
                file.write("</ul><br>Outputs:<br><ul>")
                unless outputs.nil?
                    outputs.each do |output|
                        output = output[1]
                        if output != 'nil'
                            file.write("<li>#{output.serialize}</li>")
                        else
                            file.write('<li>Null</li>')
                        end
                    end
                end
                file.write("</ul><br>Description: #{description}</p>
                            </div>")
            end
        end
        file.write("</ul>
      </div>
      <div class='col-md-6'>
        <div class='panel panel-default'>
          <div class='panel-heading'>
              <h2>Routes</h2>
          </div>
        </div>
        <ul class='list-group'>")
        unless routes.nil?
            routes.each do |route|
                type = route.type
                name = route.name
                request = route.request
                dataInput = route.dataInput
                inputs = route.inputs
                outputs = route.outputs
                file.write("            <div class='list-group-item'>
                              <h4 class='list-group-item-heading'>CRUD: #{type}<br>Name: #{name}</h4>
                              <p><br>Request: #{request}<br>
                              <br>Notation type: #{dataInput}<br>
                              <br>Inputs:<br><ul>")
                unless inputs.nil?
                    inputs.each do |input|
                        input = input[1]
                        file.write("<li>#{input.serialize}</li>")
                    end
                end
                file.write("</ul><br>Outputs:<br><ul>")
                unless outputs.nil?
                    outputs.each do |output|
                        output = output[1]
                        if output != 'nil'
                            file.write("<li>#{output.serialize}</li>")
                        else
                            file.write('<li>Null</li>')
                        end
                    end
                end
                file.write("</ul></p>
                            </div>")
            end
        end
        file.write("</ul>
      </div>
    </div>
  </div>
  </body>")
    end
end
