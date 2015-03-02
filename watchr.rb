# watchr watchr.rb
def compile_less
    %x[lessc less/bootstrap/bootstrap.less ../css/main.css --yui-compress]
end

def compile_sass
    %x[sass stylesheets/screen.sass stylesheets/screen.css]
end

def compile_coffee
    %x[coffee -c -j ../js/app.js coffee/]
end

def compile_haml
    %x[haml index.haml index.html]
end


watch('stylesheets/*.sass') { |m|
    # Recompile SASS files
    compile_sass
}

# watch('coffee/*') { |m|
#     # Recompile Coffeescripts
#     compile_coffee
# }

watch('index.haml') { |m|
    compile_haml
}
watch('templates/*') { |m|
    compile_haml
}
