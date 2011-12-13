# Before release
  - Flug bearbeiten:
    - NaN:NaN bei duration
  - wkhtmltopdf
  - filtered_flights
    - bei pdf mitschicken, welche aggregated entries collapsed sind
  - Flight:
    - CostResponsible (unknow pilot)
      - Field on plane: warn about missing cost responsible
      - if set, warn if such a plane is flown by a UnknownPerson
  - accounting session
    - add manual accounting_entries
    - export them as DATEV,...
  - Create (plane|person|wire_launcher)
    - add financial_account on the fly
  - Create License
    - legalplaneclass checkboxes (CSS?)
  - planecostcategory
    - create: rm tow cost rule thing
    - show: add heading
  - flightcostrule create
    - WTF why create 2 objects?????
    - position create
      - localize duration/engine_duration
    - show localize tow_flight
  - flightcostrule edit
    - when posted, second delete link appears
  - cost rules
    - hide/collapse old rules
  - flight change date
    - check if date of towlaunch is changed too
  - hash displayed to often (flight was updated...)
  - person#show
    - add finacc, cancel misses
  - tow_flight#edit
    - js helpers


# medium run
  - PAPER_TRAIL:
    - item_type should be the real class, not the superclass (STI)
      - add column real_type and keep track of the real class there
    - show diffs or something in views

# ideas / long run
  - locking for editing (optimistic?) (obj.versions.count?)
  - locking when stuff is booked
  - means to delete flights safely including revisions (+ export to another db) (command line tool?)
  - add concept of a update event (bundles all changes of automatic update thru a client)
    - add possibility to undo all changes
    - show changes of such an event
