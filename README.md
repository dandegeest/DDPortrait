# DDPortrait
A Data Self Portrait of Dan (DD) DeGeest

![image](/assets/ddportrait.png)
 
# Overview

***"How does one begin to define oneself in terms of information?"***<sup>(1)</sup> This was a question I certainly faced in this initial data visualization project.  My first thought of course was photographs.  In the era of smartphones and selfies surely I had a wealth of imagery that would shed light on who I am.  As I perused my 10,000+ images on Google Photos though, I realized that alone they don't necessarily say much about who I am or what I like or what I believe.  Around the same time I was having some financial issues that required me to go back seven years in my bank statements to find some payment information.  As I was doing this I was looking at other transactions, some spurred memories, and I wondered, how would the pictures I took on a given day relate to money I was making or spending on that same day?  With that in mind I decided that my data portrait would be some sort of visualization of 2 years of daily financial earning and spending juxtaposed against pictures I had taken on my phone over the same timespan. The result is DDPortrait.

# Data

Data was procured in multiple ways.  First I got credit card and bank data online from the accounts provided by the card company and my bank.  I went back 2 years since that was the maximum time period supported by my credit card.  I then grabbed the same dates from my bank. Both sites provided a CSV download.  The credit card transactions were already categorized so I chose to use those categories and wrote additional [code](/DDataETL/data-portrait-xplore.ipynb) to apply those categories to my bank transactions.  Finally I grabbed images from my [Google Photos](/photosFull) account for the same timespan using their API limiting it to 6 pictures for any given day.

All of this [ETL code](/DDataETL) was done in python 3 inside a [Jupyter Notebook](https://jupyter.org/) and produced three separate [CSV](/data) files

# Visualization

The visuualiztion took some time to figure out.  At first I was very focused on the images and tried a grid of thumbnails with data overlayed in various ways.  This became messy and uncompelling no matter what I changed in the overlayed data. I made some [cool artistic images](/ImageDD/photoTile0714.png) this way but not a great data vis.

![image](/ImageDD/photoTile1682.png)

I shifted focus to the financial data being the primary visualization and the photos a lesser focus.  This worked much better and started to show some interesting flows and trends in the financial data.

![image](/assets/live.png)

![image](/assets/work.png)

The final piece was then showing a photo with the financial data when the grid cell is selected.  In some cases the photo directly reflected the spending and in some cases there was no apparent relationship at all.

![image](/assets/buddy2.png)

# Code

The processing code is written using experiements with OOP as I was trying to learn how processing handled derivation and polymorphism.  It's pretty standard OOP however, it does not support public/private member variables and methods so it is still possible to get a bit "hacky" with the coding. See the [grid](/Grid.pde) and [thumbnail](/Thumbnail.pde) classes for the main display code. The data code is also abstracted.  I also implemented a [Sprite](/Sprite.pde) class with an x, y offset to support the scrolling grid.  Processing provides matrix transformations for drawing but they make mouse handling and other things harder, it is better to handle the drawing offset directly in the rendering code while keeping the coordinate system fixed at 0,0 for mouse events and so on.

# References

(1) Database Aesthetics Art in the Age of Information Overflow 2007 • Victoria Vesna, editor [Book](https://www.upress.umn.edu/book-division/books/database-aesthetics)
