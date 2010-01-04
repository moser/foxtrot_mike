Story: Manage flights
  As an anonymous user with an account
  
  Scenario: Create a flight.
    Given I am on the new flight page
    When I fill in "duration" with "10"
    And I press "Submit"
    Then I should see a flight page
    
  Scenario: Delete a flight.
    Given there is a flight
    And I am on the flights page
    When I follow "Destroy"
    Then I should be on the flights page
    And there should be no flights
