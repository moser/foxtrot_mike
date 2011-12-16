# Before release
  - accounting session
    - add manual accountingentries
    - export them as DATEV,...
  - Create (plane|person|wirelauncher)
    - add financialaccount on the fly
  - flightcostrule create
    - WTF why create 2 objects?????
    - position create
      - localize duration/engine_duration
    - show localize towflight
  - flightcostrule edit
    - when posted, second delete link appears
  - person#show
    - add finacc, cancel misses
  - towflight#edit
    - js helpers
  - js helpers
    - leave seat1 empty on new flight
  - pdf
    - layout?? only on the deployed version
  - facebox
    - default width?
  - flight change date
    - flight#index shows wrong number on day sidebar (may even show empty day)
  - flights#index
    - big up/down button should not jump to empty day?
  - person/plane#show
    - fin\_acc add does not work properly (when existing membership is valid nil to nil??)
  - plane/person/wire\_launcher#index
    - show more info (finacc, costcategories,...)
  - main log book
    - timepicker does not work - remove??
    - main log book: try to parse times, mark field if invalid..
    - times are not sent back for pdf creation
  - cost\_rules#index
    - rm absolute positioning, float?


# medium run
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

# ideas / long run
  - locking for editing (optimistic?) (obj.versions.count?)
  - locking when stuff is booked
  - means to delete flights safely including revisions (+ export to another db) (command line tool?)
  - add concept of a update event (bundles all changes of automatic update thru a client)
    - add possibility to undo all changes
    - show changes of such an event