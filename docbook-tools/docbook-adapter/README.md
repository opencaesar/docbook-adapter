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
Args for Tag Replacement:    
```
--input, -i path/to/docbook.xml (Required)
--type, -t tag (For tag replacement, required)
--xsl, -x path/to/build/stylesheets-gen/tag/all_transformations.xsl (Required)
--frames, -f path/to/frame/directory (Required **if** a tag needing a frame was used in the DocBook) 
--original, -o path/to/original/docbook_xsl (Required for tag replacement) 
--save, -s: boolean (optional; saves src-gen/data files) 
```
Args for PDF render:    
```
--input, -i path/to/docbook.xml (Required, expects none of our defined tags)
--type, -t pdf (For pdf render)
--xsl, -x path/to/pdf.xsl (Required. Tag replacement puts one in src-gen/pdf/pdf_ext.xsl)
```
Args for HTML render:   
```
--input, -i path/to/docbook.xml (Required, expects none of our defined tags)
--type, -t html (For html render)
--xsl, -x path/to/html.xsl (Required. Tag replacement puts one in src-gen/html/html_ext.xsl)
```