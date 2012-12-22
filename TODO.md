# Before release
- filter frontend
- date range frontend
- sums/counts
- show cost
- show liabilities
- edit liabilities
- show problems
- kick delayed job -> flag & cronjob?
  - persist cost?
- cost rule view?

# really soon
- grouping
- aggegrate entries
- table views

# soon... :D
- filtered\_flights
  - permalink
  - loaded, invisible flights become visible when switching on aggregation
  - grouped + aggregated => check hover + controls
- flight
  - trigger soft validation manually
    - add problems when unfinished or plane, seat1 missing => prevent accounting of flight
- deploy ssv version
  - check youths and person category memberships
- spork!

# soon
- create cost rules (and other places where monetary values are used)
  - use ct or decimal €
- bill for lrst
  - no accounting entries for these flights
- export flights grouped by cost responsible w/ cost for group
- controller role
  - create/show stuff only as json or thru the client
  - create people,planes,wire\_launchers (mark as incomplete, show to admin/treasurer)
  - soft validate models
  - may delete flight??
- import people (with financial account data and licenses), planes as CSV

# medium run
- import csv data
  - for flights
- licenses... medical...
- ajaxify other pages
- flight#history ...
- caching
- security: attr\_accessible
- PAPER\_TRAIL:
  - item\_type should be the real class, not the superclass (STI)
    - add column real\_type and keep track of the real class there
  - show diffs or something in views
- cost rules
  - hide/collapse old rules
- member management
- winch
  - operator charts
  - log book
- deactivate groups
- online help
- phone list
- deactivate airports by location (eg lat > 50 && < 45)
- mobile stylesheet
- setup
  - shown if db is empty, asks for some details
- srss tables for every airfield (where not lat == 0 && lon == 0)

# ideas / long run
- locking for editing (optimistic?) (obj.versions.count?)
- means to delete flights safely including revisions (+ export to another db) (command line tool?)
- add concept of a update event (bundles all changes of automatic update thru a client)
  - add possibility to undo all changes
  - show changes of such an event

