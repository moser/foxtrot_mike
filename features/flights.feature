Story: Manage flights
  As an anonymous user with an account
  
  Background:
    Given two people and a plane
  
  Scenario: Create a flight.
    Given I am on the new flight page
    When I fill in the following:
      | plane | D-1234 |
      | crew1 | Foo Bar |
      | crew2 | John Doe |
      | duration | 10 |
    And I press "Submit"
    Then I should see a flight page
    
  Scenario: Delete a flight.
    Given a flight record
    And I am on the flights page
    When I follow "Destroy"
    Then I should be on the flights page
    And there should be no flights
