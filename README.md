This repository was imported from the previous project at GitLab. All previous work can be found [here](https://gitlab.com/LuizPPA/PhariDocGen).

Hi there buddy! I've heard you've been looking for a simple and functional documentation generator for this Ruby web app of yours. So here goes a brief tutorial on how to use this little gem developed by [Phari Solutions](http://phari.solutions).


Let's start by downloading the latest gem release with:


```
$ gem install phari_doc_gen
```


## Description

First things first. To use this gem, you'll need to be following the [sinatra](http://www.sinatrarb.com/)/[padrino](http://padrinorb.com/) patterns. If you're using these frameworks probably you already matched the requisites, otherwise, organize your folders properly. Your project tree has to be organized in a main directory called "api" that must contain another folder "app" with three other directories "models", "helpers" and "controllers" within. The files will also have to be especifically named. But we'll look further into it later.
Now, requisites aside, Phari Doc Generator will provide you an easy way to generate documentation for your projects. The result will be a project page with a description that can be written using a simplified markdown syntax that is going to be explained ahead. Also, each ruby Class will have it's own page especifying it's helper methods and controllers routes including their inputs, outputs and descriptions. The gem includes an executable file and the classes that can be used individually, providing the possibility to use the generator for **any** project structure. You can see the repository (and contribute as you wish) [here](https://github.com/PhariSolutions/Phari-Doc-Gen).

## Project Structure
Bear in mind that the whole generator can be manipulated to fit any structure you wish, soon we will be creating a tutorial about how to do so. However, if you just want to use the standard generator included on the gem, you must follow some rules...
As mentioned, this gem is mainly for sinatra/padrino projects, thus, it's standard structure is the one automatically generated by padrino. The structure consists in a root directory containing the main directory "api" with a "app" directory inside which has the three directories previously mentioned, "models", "helpers" and "controllers", within. Assuming that our project is called "sayhello", the project tree is something just like this:

```
project
├── api
|   └── app
|       ├── controllers
|       ├── helpers
|       └── models
└── README.md
```

The root directory is where you're going to create your README.md file which is going to be used to generate your project description. The api directory holds the the three directories with the project files, for each class you're going to have a file in each one of the folders. The model directory contains the ruby Classes themselves, they must be named simply like "classname(downcase).rb". The helpers directory will have the helper modules of your project, that is, the modules that deal with the data manipulation, the business layer, if you preffer, they must be named "classname(downcase)\_helper.rb". Finally, the controllers directory is where the routes are, they must be named "classname(downcase).rb" just like the models. Notice that for each class, the model, helper and controler files **must** exist in the correct directories, or else the class will be ignored by the generator. Remember, the fact that these files must be present and organized like that doesn't mean that they have to be the only files and folders in your root/api/any other folders.

Lets pretend that we have a project called sayhello. The project has a single class "Hello", which means that we'll have models/hello.rb, helpers/hello_helper.rb and controllers/hello.rb. Therefore, the project tree will look like this:


```
sayhello
├── api
|   └── app
|       ├── controllers
|       |   └── hello.rb
|       ├── helpers
|       |   └── hello_helper.rb
|       └── models
|           └── hello.rb
└── README.md
```


## Documentation Syntax
The notation syntax for the generator is quite simple. You'll just have to document the helpers and controllers files in order to generate the classes's pages. For these, we will be using seven keywords or "clauses":

* ```@(request type) (notation type \*optional):``` Indicate the request method and notation used for the next routes.
Example: @POST json
* ```@methods (method type):``` Indicate a method type relative to the class's CRUD.
Example: @methods CREATE
* ```@route (route type):``` Indicate a route type relative to the class's CRUD.
Example: @route CREATE
* ```@name (name):``` Indicate the name for a method or a route.
Example: @name greetings
* ```@param (param name) (param datatype):``` Indicate an input for a method or a route.
Example: @param yourName string
* ```@return (return name) (return datatype):``` Indicate the return value for a method or a route.
Example: @return greeting string (may also be @return nil or @return boolean)
* ```** (description):``` Indicate the description for a method or a route.
Example: ** Print "Hello (your name)" and returns the same string.

We can classify those clauses int two types: permanent clauses and temporary clauses. The @route and @methods clauses are permanent. The permanent clauses are clauses that will recieve an argument and keep it's value until the next call, that is, whenever you use one of those clauses, the designated value will be assigned for every method/route declared for now on. The remaining clauses are temporary, which means that when they are used, the designated value will be applied only for the next declared method or route.

### Declaring methods

Methods have only the @methods, @name, @param, @return and ** clauses. Methods declarations must be always on the helper files. You'll open a new method each time you use a @name clause, a it will be closed each time you call a @methods or @name clause (closing a method with @name will automatically open a new one). At the end of the file, all closed methods (and the currently open one, if any) and it's attributes will be loaded to the generator. An example of method declaration is:


```
# @methods RETRIEVE

# @name greetings
# @param yourname string
# @param daytime string
# @return greetings string
# ** Print "Hello yourname, good daytime." and return the same string
def greetings(yourname, daytime)
    greeting = "Hello #{yourname}, good #{daytime}."
    puts greeting
    return greeting
end
```

Notice that the @param clause is non-unique, which means that it can be called N times and it's value will be pushed into an array instead of overwrited. Recalling an unique clause without closing the method will cause it to overwrite.

### Declaring routes

Routes have @route, @(request type), @name, @param and @return clauses. They must be declared on the controller files. You can open a route by calling a @(request type) clause and close with @route or @(request type) clause (colsing with @(request type) will automatically open a new one). At the end of the file, all closed and routes (and the currently open one, if any) and it's attributes will be loaded to the generator. An example of route declaration is:


```
# @route RETRIEVE

# @POST json
# @name greetings
# @param yourname string
# @param daytime string
# @return greetings string
post /greetings do
    # read json params into 'params'
    greeting = Api::App:HelloHelper.greetings(params)
    return greeting
end
```

It's a good practice to always set your permanent clauses before doing anything else.

## Markdown Syntax

The markdown syntax used to write the project's description is much alike the one used in commom websites like GitHub. So frequently your repository README will require no modifications. However, the syntax used on this project has fewer resources than the usual markdown syntax.
Rules:

* **## Title 1**
* **### Title 2**
* **##### Title 3**
* **\* list**
* **\*\*bold\*\***
* **\*italic***
* **\`\`\`code\`\`\`**
* **\[Phari\]\(http://phari.solutions\)**

Remaining features not included yet. More information about [Markdown Syntax](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet).

## Generating

Once you've done documenting your code, you're ready to generate the documentation. To do so you have two options: you can either run the command:

```
$ phari_doc_gen project_name relative/output/folder/path/
```

Notice that you don't need to run the command from your project folder once the generator will search through all your folders for a matching name folder. You can also specify a path to your project to avoid ambiguity on the search. For example, if you have two folders with the same name in different locations like /home/user/documents/sayhello/ and /home/user/desktop/sayhello/ and only the desktop folder contains your project, you can use:

```
$ phari_doc_gen desktop/sayhello/ relative/output/folder/path/
```

Or alternatively you can use PhariDocGen class and call the generate method following the same rules like:

```
require 'phari_doc_gen'
docGen = PhariDocGen.new
docGen.generate('project_name', 'relative/output/folder/path/')
```
