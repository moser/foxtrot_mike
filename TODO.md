# Before release
  - accounting session
    - create: add note, that this can take long
    - do not create accounting entries w/ value 0
  - show state of own finanical account
  - main log book
    - timepicker does not work - remove??
    - main log book: try to parse times, mark field if invalid..
    - times are not sent back for pdf creation
  - group#show
    - heading
  - layout in ff3.6/windows
  - layout in ff
    - person#new
      - form fields after checkboxes are indented
  - controller role
    - create people,planes,wire\_launchers (mark as incomplete, show to admin/treasurer)
    - soft validate models
      - mark if no fin acc (do not let acc sessions finish?)
  - cost\_rule#create
    - make sure that after lastestASEnd (otherwise a rule is created, which cannot be edited)
  - filtered\_flights permalink

# medium run
  - ajaxify other pages
  - flight#history ...
  - caching
  - security: attr\_accessible
  - PAPER_TRAIL:
    - item_type should be the real class, not the superclass (STI)
      - add column real_type and keep track of the real class there
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

