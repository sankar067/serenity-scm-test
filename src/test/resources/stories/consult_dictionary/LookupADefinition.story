Lookup a definition
Narrative:
In order to talk better
As an English student
I want to look up word definitions

Scenario:Test1 Looking up the definition of 'apple'
Meta:
@Test1
Given the user is on the Wikionary home page
When the user looks up the definition of the word 'apple'
Then they should see the definition 'A common, round fruit produced by the tree Malus domestica, cultivated in temperate climates.'

Scenario:Test2 Looking up the definition of 'pear'
Meta:
@Test2
Given the user is on the Wikionary home page
When the user looks up the definition of the word 'pear'
Then they should see the definition 'An edible fruit produced by the pear tree, similar to an apple but typically elongated towards the stem.'
