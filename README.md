# Todo
### Cloud storage
* Implement authentication (start with email and password)
* Decide on how to handle local vs cloud storage
### Design
* Add labels to the tab bar such as "Settings" etc..
* Advanced settings view: Add incentivising descriptions for rating the app and sending emails with improvements
* Change 'lunch' in shifts to 'break', clarify that we want amount of minutes when adding/editing shifts
Change the way periods duration looks in Logger view. The emphasis should be on the month duration. Exclude year from duration dates, make it bigger, and include a smaller year string

# Known bugs

## Thoughts about database implementation
The only time we need to fetch data is when the app loads, technically. We can always keep track of what we are doing and do the same with the in memory database.
