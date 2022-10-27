# Gas measurement of smart contracts (Foundry)

This is about the comparison of different smart contract based access control methods by measuring their gas consumption of the deployment and execution of the smart contracts. 
In order to measure these. We use truffle on a local blockchain to measure the consumption during deployment and we use Foundry to measure the consumption during execution and added Fuzzing with 10000 runs.

To measure gas with foundry install it on your system with 'forge install' and use 'forge test --gas-report' in the project folder.