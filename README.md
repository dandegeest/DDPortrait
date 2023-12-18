# DDPortrait
A Data Self Portrait of Dan (DD) DeGeest

![image](/assets/ddportrait.png)
 
# Overview

***"How does one begin to define oneself in terms of information?"***<sup>(1)</sup> This was a question I certainly faced in this initial data visualization project.  My first thought of course was photographs.  In the era of smartphones and selfies surely I had a wealth of imagery that would shed light on who I am.  As I perused my 10,000+ images on Google Photos though, I realized that alone they don't necessarily say much about who I am or what I like or what I believe.  Around the same time I was having some financial issues that required me to go back seven years in my bank statements to find some payment information.  As I was doing this I was looking at other transactions, some spurred memories, and I wondered, how would the pictures I took on a given day relate to money I was making or spending on that same day?  With that in mind I decided that my data portrait would be some sort of visualization of 2 years of daily financial earning and spending juxtaposed against camera pictures I had taken over the same timespan. The result is DDPortrait.

# Data

Data was procured in multiple ways.  First I got credit card and bank data online from the accounts provided by the card company and my bank.  I went back 2 years since that was the maximum time period supported by my credit card.  I then grabbed the same dates from my bank.  The credit card transactions were already categorized so I chose to use those categories and wrote additional code to apply those categories to my bank transactions.  Finally I grabbed images from my Google Photos account for the same timespan using their API.

All of this [ETL code](/DDataETL) was done in python 3 inside a [Jupyter Notebook](https://jupyter.org/) and produced three separate [CSV](/data) files

# Visualization

The visuualiztion took some time to figure out.  At first I was very focused on the images and tried a grid of thumbnails with data overlayed in various ways.  This became messy and uncompelling no matter what I changed in the overlayed data.

![image](/ImageDD/photoTile1682.png)

I shifted focus to the financial data being the primary visualization and the photos a lesser concern.  This worked much better and started to show some interesting flows and trends in the data.

![image](/assets/live.png)

![image](/assets/work.png)

The final piece was then showing a photo with the financial data when the grid cell is selected.

![image](/assets/buddy2.png)

# Code

The processing code is written using experiements with OOP as I was trying to learn how processing handled derivation and polymorphism.  It's pretty standard however it does not support public/private member variables and methods so it is still possible to get a bit "hacky" with the coding. See the grid and thumbnail classes for the main display code.

# References

(1) Database Aesthetics Art in the Age of Information Overflow 2007 • Victoria Vesna, editor [Book](https://www.upress.umn.edu/book-division/books/database-aesthetics)
