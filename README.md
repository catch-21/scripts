# scripts

## many-ma.sh
Can be used to mint 1 or multiple tokens into the same UTxO. A 'clean' UTxO hash with only ADA must be provided.

Examples:

`./many-ma.sh 25918b8d802c07ff38db9a75222e0971767064138fdc7f59e30f21cfdb023ff2 10`
This will use UTxO 25918b8 and mint 10 tokens with the same policy, each with the value of 1 (default).

`./many-ma.sh 9b620bb436728585b74f55b10c59a388d6aa9ebff370c0f9e2b77b9d55de764a 100 coin 5`
This will use UTxO 9b620bb and mint 100 tokens with the same policy and its name is prefixed with "coin", each with the value of 5.

## makePolicy.sh
Used to make MA policy script.

## sign.js
Used for signing transaction to submit with Rosetta.
