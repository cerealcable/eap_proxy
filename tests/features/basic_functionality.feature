Feature: Basic functionality
  EAP Proxy should be able to run

  Scenario: Run EAP Proxy without arguments
     Given we launch eap proxy
      Then command help will be shown
