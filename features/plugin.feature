Feature: Provider plugin modules

  As an Infracoder developing the vaquero command line tool
  I want to test the accuracy of the Provider plugin interactions for the PLUGIN command
  In order to maintain the users ability to use and create provider plugins for custom infrastructure targets

  Scenario: Request help with PLUGIN commands

    When I get general help for "vaquero plugin"
    Then the exit status should be 0
    And the following commands should be documented:
      |help|
      |list|
      |init|
      |install|
      |update|
      |remove|

  Scenario: List installed Providers

    Given a file named "../../lib/providers/vaquero-test-a/Providerfile.yml" with:
    """
    provider:
      name: test-installed-a
      version: 0.0.0.a
    """
    Given a file named "../../lib/providers/vaquero-test-b/Providerfile.yml" with:
    """
    provider:
      name: test-installed-b
      version: 0.0.0.b
    """
    When I run `vaquero plugin list`
    Then the exit status should be 0
    And the output should contain "test-installed-a (0.0.0.a)"
    And the output should contain "test-installed-b (0.0.0.b)"
    And I will clean up the test plugin "lib/providers/vaquero-test-a" when finished
    And I will clean up the test plugin "lib/providers/vaquero-test-b" when finished

  Scenario: New Providerfile template

    When I run `vaquero plugin init`
    Then the exit status should be 0
    And the output should contain "create  Providerfile.yml"
    And the following files should exist:
      |Providerfile.yml|
    And the file "Providerfile.yml" should contain:
    """
    provider:
      # define the plugin name that can be used to select this provider from the command line or environmental variable
      name:
      version: 0.0.0
    """

    When I run `vaquero plugin init example`
    Then the exit status should be 0
    And the output should contain "called with arguments"

  Scenario: Install new Provider

    When I run `vaquero plugin install`
    Then the exit status should be 0
    And the output should contain "called with no arguments"

    When I run `vaquero plugin install https://github.com/vaquero-io/vaquero-plugin-test.git`
    Then the exit status should be 0
    And the output should contain "Successfully installed vaquero-plugin-test"
    And the following files should exist:
      |../../lib/providers/vaquero-plugin-test/Providerfile.yml|
      |../../lib/providers/vaquero-plugin-test/vaquero_plugin_test.rb|
    And the file "../../lib/providers/vaquero-plugin-test/Providerfile.yml" should contain:
    """
    provider:
      name: vaquero-plugin-test
      version: 0.1.0.pre
      location: https://github.com/vaquero-io/vaquero-plugin-test.git
    """
    And I will clean up the test plugin "lib/providers/vaquero-plugin-test" when finished

    Given a file named "../../lib/providers/vaquero-plugin-test/Providerfile.yml" with:
    """
    provider:
      name: vaquero-plugin-test
      version: 0.1.0.pre
      location: https://github.com/vaquero-io/vaquero-plugin-test.git
    """
    When I run `vaquero plugin install https://github.com/vaquero-io/vaquero-plugin-test.git`
    Then the exit status should be 0
    And the output should contain "vaquero-plugin-test already installed"
    And I will clean up the test plugin "lib/providers/vaquero-plugin-test" when finished

  Scenario: Update installed Provider(s)

    Given a file named "../../lib/providers/vaquero-plugin-test/Providerfile.yml" with:
    """
    provider:
      name: vaquero-plugin-test
      version: 0.1.0.pre
      location: https://github.com/vaquero-io/vaquero-plugin-test.git
    """
    When I run `vaquero plugin update vaquero-plugin-test`
    Then the exit status should be 0
    And the output should contain "vaquero-plugin-test provider already at current version"
    And I will clean up the test plugin "lib/providers/vaquero-plugin-test" when finished

    Given a file named "../../lib/providers/vaquero-plugin-test/Providerfile.yml" with:
    """
    provider:
      name: vaquero-plugin-test
      version: 0.0.0.pre
      location: https://github.com/vaquero-io/vaquero-plugin-test.git
    """
    When I run `vaquero plugin update vaquero-plugin-test`
    Then the exit status should be 0
    And the output should contain "Updated vaquero-plugin-test version 0.0.0.pre -> 0.1.0.pre"
    And I will clean up the test plugin "lib/providers/vaquero-plugin-test" when finished

  Scenario: Remove Provider

    When I run `vaquero plugin remove`
    Then the exit status should be 0
    And the output should contain "called with no arguments"

    When I run `vaquero plugin remove vaquero-plugin-test`
    Then the exit status should be 1
    And the output should contain "Missing or invalid Providerfile"

    Given a file named "../../lib/providers/vaquero-plugin-test/Providerfile.yml" with:
    """
    provider:
      name: vaquero-plugin-test
      version: 0.1.0.pre
      location: https://github.com/vaquero-io/vaquero-plugin-test.git
    """
    When I run `vaquero plugin remove vaquero-plugin-test`
    Then the exit status should be 0
    And the output should contain "vaquero-plugin-test removed"
    And I will clean up the test plugin "lib/providers/vaquero-plugin-test" when finished
