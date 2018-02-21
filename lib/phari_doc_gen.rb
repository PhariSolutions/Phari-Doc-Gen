#--------------------------------------------------------------------------------------------
# THE BEER-WARE LICENSE" (Revision 42): <luiz@phari.solutions> wrote this file.
# As long as you retain this notice you can do whatever you want with this stuff.
# If we meet some day, and you think this stuff is worth it, you can buy me a beer in return.
# Luiz Philippe.
#--------------------------------------------------------------------------------------------

require 'fileutils'
require_relative 'phari_doc_gen/modelo.rb'
require_relative 'phari_doc_gen/rota.rb'
require_relative 'phari_doc_gen/metodo.rb'
require_relative 'phari_doc_gen/methodParam.rb'
require_relative 'phari_doc_gen/fileHandler.rb'

class PhariDocGen
  # Generate documentation for standard projects
  def self.generate (project, outputPath)
      generate = FileHandler.new
      # Ask for project name if nil
      if project.nil?
          puts "Insert project which generate documentation"
          project = gets.chomp
          while project == ''
              project = gets.chomp
          end
      end
      # Verify the existence of the project
      projectPath = generate.packageExistis?(project)
      # Get description from README.md
      projectDescription = generate.readProject(projectPath)
      # Get models with their methods and routes
      models = generate.readFiles(projectPath)
      # Specify the output path
      if outputPath.nil?
          outputPath = ''
      else
          outputPath += '/' unless outputPath.end_with?('/')
      end
      # Write documentation
      projectName = generate.nameFormat(project)
      generate.writeFiles(models, projectName, projectDescription, outputPath)
      puts 'Done!'
  end
end
