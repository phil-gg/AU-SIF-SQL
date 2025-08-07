# Process for creating the Entity Relationship Diagrams here

 1. Run **"Drop-then-Create-SIF-tables.sql"** into a Microsoft SQL database.

 2. Connect DBeaver to that database, and save the ERD as a graphml file.

 3. Open the graphml file with https://www.yworks.com/yed-live/.

 4. Automatically apply an improved layout with the "yEd live" web-app.  I like the following settings:

     (i)    Orthogonal Layout, with Style "Normal".

     (ii)   Substructure Trees checked, Chains, and Cycles, both unchecked.

     (iii)  Default 15 values, and everything below that unchecked/none.

 5. Export from "yEd live" web-app as SVG.  Half the default scale it gives you.

 6. Use the web-app https://svgtopdf.com/ to turn the SVG from "yEd live" into a PDF.

 7. If you can't zoom in enough on the PDF, use https://www.pdf2go.com/resize-pdf to change the PDF page size to A0.
 