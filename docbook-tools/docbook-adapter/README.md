# DocBook Adapter
A tool to execute tag transformations and renders on a given DocBook.
## Run as a CLI 
MacOS/Linux: 
```
    cd docbook-tools
    ./gradlew docbook-adapter:run --args="..."    
```
Windows: 
```
    cd docbook-tools
    gradlew.bat docbook-adapter:run --args="..."    
```
Args: 
```
--input, -i path/to/docbook.xml (Required)
--result, -r path/to/result/docbook.xml (Required) 
--type, -t typeOfTransform (Required)
    -Can select tag(replaces our defined tags), pdf, or html
--frames, -f path/to/frame/directory (Required for tag type, optional otherwise)
    -Needed for tag replacement
```