Feature:
  Create a new flight

  Scenario: Create new flight
    Given I am on the flights page
    When I click the "New flight" link
    Then I wait until I see "Flug erstellen"
