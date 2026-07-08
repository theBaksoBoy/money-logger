# Money Logger

A simple tool for keeping track of your expenses, placed in their own categories, like for instance "groceries", "hobbies", "other".

This readme.md is very work-in-progress, since as of writing this the project is very new.

---
TODO:
- make SaveCategoryJson() sort the items according to the date before saving to file
- remember that when printing all items in a category (or just when printing items in general) that you should do it with color, like you did with multiplier percentages
- specify that you both add and remove money in this readme file when adding an item. Adding is done with positive numbers, and removing (for purchases) is done with negative numbers
- add instructions for how to run it. Specify that you need stuff in ~/.config/money_logger/settings.txt, and how it should look.
- explain what last_calculated_sum is for. That it is just there in case the file is edited manually, for if this project isn't accessible. This is so that even without the money_logger program you can still have a good idea for how much money you have left. This value isn't actually used for anything. It's updated every time the specific category is saved when using the program
- explain what the auto_add_multiplier is for

menu design and progress:
- [1] add/remove items
  + [1] add item to a category
  + *(WIP)* [2] add item to all categories with the amount of money being divided according to the percentage specified in each category (the rest goes into savings) (remember that itemr with a multiplier of 0 should not have items generated for it, and there should not be a status thing saying anything, as it having a value of 0 does not need to be logged)
  + *(WIP)* [3] delete item. Note that you should probably not store the ID of items, so that it is easier to add items when manually editing the file. Just make it sort them with the dates whenever the files are saved. IDs will be given during runtime though so that you know which one to delete. Deleting should probably list every item, but with an ID given on the left of each item.
- [2] get info
  + *(WIP)* [1] list all items in a category
  + *(WIP)* [2] get the sum of a category
  + *(WIP)* [3] make a graph of a category's sum (are you still going to have this feature? It would be pretty neat if you can)
  + [4] get the percentage of money that goes into each category when using the auto-add thing
- [3] manage categories
  + [1] create a category
  + [2] delete a category
  + [3] change the auto-add percentage thing for a category
