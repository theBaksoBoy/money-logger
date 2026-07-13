# Money Logger

A simple tool for keeping track of your expenses, placed in their own categories, like for instance "groceries", "hobbies", "other".

This readme.md is very work-in-progress.

---
TODO in readme file:
- specify that you both add and remove money in this readme file when adding an item. Adding is done with positive numbers, and removing (for purchases) is done with negative numbers
- add instructions for how to run it. Specify that you need stuff in ~/.config/money_logger/settings.txt, and how it should look. Say that the directory it points to should exit. Not sure if it creates it automatically if it doesn't, so it's safer like this. Also specify the new parameters graph_width and graph_height.
- explain what last_calculated_sum is for. That it is just there in case the file is edited manually, for if this project isn't accessible. This is so that even without the money_logger program you can still have a good idea for how much money you have left. This value isn't actually used for anything. It's updated every time the specific category is saved when using the program
- explain what the auto_add_multiplier is for, and that the remaining multiplier not covered by all categories goes into savings, which can be seen kind of as an invisible category that you always have.
