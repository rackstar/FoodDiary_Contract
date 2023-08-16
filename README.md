## 

This project utilises Foundy, please check out the [installation](https://github.com/foundry-rs/foundry#installation) instructions if you don't have it yet.

1. Save dependencies

```bash
forge install && npm install 
```

2. Test

```bash
forge test
```

3. Build

```bash
forge build
```

4. Deploy to a local chain

Update .env
```env
export FOUNDRY_PROFILE="default"
export ANVIL_LOCAL_PK="<ANVIL_LOCAL_CHAIN_PRIVATE_KEY>"
```

Run a local chain
```bash
anvil
```

Deploy to local chain
```bash
forge script script/Deploy.s.sol --broadcast --fork-url http://127.0.0.1:8545
```

5. Run JS script that interacts with the deployed contract

Grab the contract address of the newly deployed contract

```
npm run test <CONTRACT_ADDRESS>
```








