> This repository was imported from GitLab. All previous work can be found [here](https://gitlab.com/LuizPPA/PhariDocGen).

**A tutorial to get you started with *Phari Doc Generator*, a gem developed by [Phari Solutions](http://phari.solutions).**


[![Gem Version](https://badge.fury.io/rb/phari_doc_gen.svg)](https://badge.fury.io/rb/phari_doc_gen)

Start by downloading the latest gem release:

```
$ gem install phari_doc_gen
```


## Description

*Phari Doc Generator* follows the [sinatra](http://www.sinatrarb.com/)/[padrino](http://padrinorb.com/) file structre patterns. If you are familiar with these frameworks, you have likely already matched their requisites; if not, organize your folders as described below.

*Phari Doc Generator* provides an easy way to generate project documentation. The result will be a project page, consisting of a description written in a simplified [markdown syntax](#documentation-syntax). 

For each ruby class, the gem will generate a page that specifies the routes of its helper methods and controllers, including inputs, outputs and descriptions. Also included is an executable file, as well as the classes that can be used individually, allowing for the possibility of using the gem with **any** file structure.


## Project Structure
> Keep in mind that the generator can be manipulated to fit any file structure (a tutorial demonstrating how to do so will soon be created).

As mentioned, this gem is mainly for sinatra/padrino projects, so the standard structure of padrino is considered here. 

Inside the root directory is the main directory `api`, which contains an `app` directory - inside which are three more directories: `models`, `helpers` and `controllers`. A project called 'sayhello' should be organized like this:

```
sayhello
├── api
|   └── app
|       ├── controllers
|       ├── helpers
|       └── models
└── README.md
```

Inside the root directory, you will create a `README.md` file, which will be used to generate the project description. Also, every class will be associated with a file in each of the three sub-directories of the `app` directory.

`models` contains the ruby classes themselves, simply named `classname(downcase).rb`. `helpers` contains your project's helper modules (the 'business layer': modules that deal with data manipulation), named `classname(downcase)\_helper.rb`. Finally, `controllers` contains your routes, and must be named `classname(downcase).rb`. For a class to be recognized by the generator, its model, helper and controller files **must** exist in the correct directories (but this does not mean that they have to be the only files/folders in the given directory).

Suppose our project is called 'sayhello' and has a single class called 'Hello.' This means we'll have the files `models/hello.rb`, `helpers/hello_helper.rb` and `controllers/hello.rb`, like so:


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

When setting inputs and outputs, you can declare fields as objects, and thus, you can define the properties of this object. You can do so by adding a "(Object Name)>" sign before the field name to specify that this field belongs to the given object like:

```
[...]
# @param user object
# @param user>name string
# @param user>email string
# @param user>age number
[...]
```

This will structure a json object in your model page.

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

## Contribute

Bug reports, suggestions (please [create an issue](https://github.com/PhariSolutions/Phari-Doc-Gen/issues/new)) and pull requests are welcome.
