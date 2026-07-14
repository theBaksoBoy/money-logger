# Money Logger

A simple terminal tool for keeping track of your expenses, where you are able to add and remove money in different categories, with logs showing when money was added or removed, how much, and why. To simplify the process of distributing money to all the different categories, each category can be assigned a percentage of money that they receive when using the "auto-add" feature. If you for instance have a category named "general" assigned at 50%, and a category named "hobby" assigned at 30%, where you then auto-add 1000 of a currency, then "general" will get 500, "hobby" will get 300, and the remaining 200 (20%) will go into an implied "savings" category. When saying "implied", it means in the sense that the category doesn't actually exist, and no logs are stored for it. It just says how much money would be moved to it for aid with managing actual banking tools.

## How to use
This tool was intended to be used for Linux. Due to how Linux stores configuration files, if this was to be made for Windows the filepath checked would probably have to be modified before compiling. To make the program able to be run, you need to create the file `~/.config/money_logger/settings.txt`, where you need these following lines:
```
category_directory=/example/directory/
graph_width=150
graph_height=30
```
- `category_directory` is the directory where all the categories are stored. Make sure that the directory exists before running the program. 
- `graph_width` and `graph_height` is for how many characters the graphing feature will take up. You want to ensure that the width isn't more than the amount of characters wide your terminal is able to print.

Note that in the json file of each category there is a value named `last_calculated_sum`. This is a value that is updated every time a category is updated with the program, however it doesn't have any purpose. The reason for this existing is so that you are able to tell how much money is approximately left in a category from just looking at the json files, for if you don't have access to the program itself. This was implemented since I sync my files to different devices. Since I don't know how to get this program to run on my phone, if I ever need to change the logs when on my phone I can with relative ease just manually edit the synced json files, where I will then be able to see the most important information, which thus is how much money is available in a category.
