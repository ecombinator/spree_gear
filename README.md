# Spree Gear

## Known Bugs
  - product`.can_supply?` method will result in an internal error when the command is called the first time. For some reason, the second and subsequent trys will result to the proper boolean value. This has only been observed with view helpers

## Notes
  - Ruby version is 2.5.1, with rails at 5.2
  - rails cache randomly messing up file paths or boot order, a server restart + clear temporary files usually fixes it
  - Configuration to paperclip is temporary, will try replacing with active storage when we have time


## What is Spree Gear?

A global spree gem with various features

