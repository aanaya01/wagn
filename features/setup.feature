Feature: Setting up
  In order to be able to start a new Wagn site
  As a Wagneer
  I want to setup an initial account
  
  Background:
    Given site simulates setup need
    
  Scenario: Wagneer visits site for first time
    When I go to the homepage
    Then I should see "Welcome"
    
    When I fill in "card_name" with "The Newber"
    And I enter "newb@wagn.org" into "*email"
    And I enter "newb_pass" into "*password"
    And I press "Submit"
    Then I should see "The Newber"
    
    When I go to card "The Newber\+\*roles"
    Then I should see "Administrator"

    When I follow "Sign out"
    And I follow "Sign in"
    And I enter "newb@wagn.org" into "*email"
    And I enter "newb_pass" into "*password"
    And I press "Sign in"
    Then I should see "The Newber"
  
