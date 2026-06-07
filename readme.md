# Money Logger

A simple tool for keeping track of your expenses, placed in their own categories, like for instance "groceries", "hobbies", "other".

This readme.md is very work-in-progress, since as of writing this the project is very new.

---
TODO:
- you are done with all options in option [3] in the main menu. Now you need to do [1] and [2]
- specify that you both add and remove money here. Adding is done with positive numbers, and removing (for purchases) is done with negative numbers
- add instructions for how to run it. Specify that you need stuff in ~/.config/money_logger/settings.txt
- explain what last_calculated_sum is for
- explain what the auto_add_multiplier is for

menu design:
- [1] add/remove items
  + [0] go back
  + [1] add item to a category
  + [2] add item to all categories with the amount of money being divided according to the percentage specified in each category (the rest goes into savings) (remember that itemr with a multiplier of 0 should not have items generated for it, and there should not be a status thing saying anything, as it having a value of 0 does not need to be logged)
  + [3] delete item. Note that you should probably not store the ID of items, so that it is easier to add items when manually editing the file. Just make it sort them with the dates whenever the files are saved. IDs will be given during runtime though so that you know which one to delete. Deleting should probably list every item, but with an ID given on the left of each item.
- [2] get info
  + [0] go back
  + [1] list all items in a category
  + [2] get the sum of a category
  + [3] make a graph of a category's sum (are you still going to have this feature? It would be pretty neat if you can)
  + [4] get the percentage of money that goes into each category when using the auto-add thing. Note that it should also mention how much goes into savings, which should be formulated as something like "(15% remains, which go into savings)"
- [3] manage categories
  + [0] go back
  + [1] create a category
  + [2] delete a category
  + [3] change the auto-add percentage thing for a category

json format for each category:
[
"auto_add_factor": 0.25,
"items": [
    "2026-07-05 -10000 banana",
    "2026-07-06 -2 house",
    "2026-07-07 3248923749827239847 won the lottery, yayyy"
    ],
"last_calculated_sum": 3248923749827229845
]

note that last_calculated_sum is just there in case the file is edited manually, for if this project isn't accessible. This is so that even without the money_logger program you can still have a good idea for how much money you have left. This value isn't actually used for anything
