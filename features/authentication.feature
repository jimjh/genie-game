Feature: Authentication
  As a user
  I want to sign in with GitHub
  So that I can be identified on the system

  Scenario: Sign in via GitHub
    Given I have a GitHub account
    When I sign in with GitHub
    Then I should see my name

  Scenario: Sign out
    Given I have a GitHub account
    And I am signed in with GitHub
    When I sign out
    Then I should not see my name
