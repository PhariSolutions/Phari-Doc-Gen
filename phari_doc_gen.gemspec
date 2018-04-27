Gem::Specification.new do |s|
  s.name        = 'phari_doc_gen'
  s.version     = '3.2.2'
  s.licenses    = ['MIT', 'BEERWARE']
  s.summary     = "Ruby documentation generator"
  s.description = "Phari Doc Generator provides an easy way to generate project documentation for sinatra/padrino file structure patterns."
  s.authors     = ["Luiz Philippe", "Phari Solutions"]
  s.email       = 'luiz@phari.solutions'
  s.files       = [ "lib/phari_doc_gen.rb",
                    "lib/phari_doc_gen/fileHandler.rb",
                    "lib/phari_doc_gen/meta.rb",
                    "lib/phari_doc_gen/methodParam.rb",
                    "lib/phari_doc_gen/metodo.rb",
                    "lib/phari_doc_gen/modelo.rb",
                    "lib/phari_doc_gen/rota.rb",
                    "lib/phari_doc_gen/templates/model.html.erb",
                    "lib/phari_doc_gen/templates/project.html.erb",
                    "lib/phari_doc_gen/templates/style.css"]
  s.executables << 'phari_doc_gen'
  s.required_ruby_version = '~> 2.0'
  s.add_runtime_dependency 'activesupport', '~> 5.2'
  s.add_runtime_dependency 'erubis', '~> 2.7'
  s.add_runtime_dependency 'rubysl-erb', '~> 2.0', '>= 2.0.2'
  s.homepage    = 'https://github.com/PhariSolutions/Phari-Doc-Gen'
  s.metadata    = { "source_code_uri" => "https://github.com/PhariSolutions/Phari-Doc-Gen" }
end
