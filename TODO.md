# Before release
  - accounting session
    - create: add note, that this can take long
    - manual entries
    - warn about flights w/o accounting session before the start date of new accounting sessions
      - alt: only set end date of accounting session
  - manual cost
    - add to flight ?
  - layout in ff3.6/windows
  - layout in ff
    - person#new
      - form fields after checkboxes are indented
  - controller role
    - create/show stuff only as json or thru the client
    - create people,planes,wire\_launchers (mark as incomplete, show to admin/treasurer)
    - soft validate models
      - mark if no fin acc (do not let acc sessions finish?)
  - cost\_rule#create
    - make sure that after lastestASEnd (otherwise a rule is created, which cannot be edited)
  - filtered\_flights permalink
  - filtered flights PDF
    - aggregated entry, not visible...
  - export flights grouped by cost responsible w/ cost for group

# I18n
  - license create
    - legal plane classes
  - personcc show
    - people now
  - people show
    - lvb member state
  - plane#\_form
    - warn when no cost rule
  - cost rules index
    - title
  - main log book pdf
    - title
  - account

# medium run
  - licenses... medical...
  - ajaxify other pages
  - flight#history ...
  - caching
  - security: attr\_accessible
  - PAPER\_TRAIL:
    - item\_type should be the real class, not the superclass (STI)
      - add column real\_type and keep track of the real class there
    - show diffs or something in views
  - filteredflights
    - bei pdf mitschicken, welche aggregated entries collapsed sind
  - cost rules
    - hide/collapse old rules
  - ajax/stay on page for people, planes,...
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
  - accounting session
    - add manual accountingentries
  - locking for editing (optimistic?) (obj.versions.count?)
  - locking when stuff is booked
  - means to delete flights safely including revisions (+ export to another db) (command line tool?)
  - add concept of a update event (bundles all changes of automatic update thru a client)
    - add possibility to undo all changes
    - show changes of such an event

