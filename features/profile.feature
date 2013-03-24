Feature: Profile
  As a user
  I want to see my profile
  So that I can view my activity

  Scenario: View Profile
    Given I have a GitHub account
    And I am signed in with GitHub
    When I go to the settings profile page
    Then I should see "member for less than a minute"
