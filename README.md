# Ganache Quick Start Guide

This guide provides quick commands to get your CTAT project running with Ganache.

## Quick Setup Commands

### 1. Install Dependencies
```bash
npm install
```

### 2. Start Ganache
```bash
# Option 1: Use the npm script
npm run ganache

# Option 2: Use ganache-cli directly
ganache-cli --deterministic --accounts 10 --host 0.0.0.0 --port 7545 --networkId 1337
```

### 3. Compile and Deploy (in a new terminal)
```bash
# Compile contracts
npx hardhat compile

# Deploy to Ganache
npm run deploy:ganache
```

### 4. Run Tests
```bash
npm run test:ganache
```

## Default Ganache Configuration

- **RPC Server**: http://127.0.0.1:7545
- **Network ID**: 1337
- **Chain ID**: 1337
- **Gas Limit**: 6721975
- **Gas Price**: 20000000000 wei
- **Accounts**: 10 deterministic accounts
- **Default Balance**: 100 ETH per account

## MetaMask Quick Setup

1. Add Custom Network:
   - Network Name: `Ganache Local`
   - RPC URL: `http://127.0.0.1:7545`
   - Chain ID: `1337`
   - Currency: `ETH`

2. Import Account:
   - Copy private key from Ganache terminal output
   - MetaMask → Import Account → Paste private key

## Default Test Accounts

When using `--deterministic` flag, Ganache generates the same accounts every time:

**Account #0**: 
- Address: `0x627306090abaB3A6e1400e9345bC60c78a8BEf57`
- Private Key: `0xc87509a1c067bbde78beb793e6fa76530b6382a4c0241e5e4a9ec0a0f44dc0d3`

**Account #1**: 
- Address: `0xf17f52151EbEF6C7334FAD080c5704D77216b732`
- Private Key: `0xae6ae8e5ccbfb04590405997ee2d52d2b330726137b875053c36d94e974d162f`

And so on...

## Useful Commands

```bash
# Check if Ganache is running
curl -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_accounts","params":[],"id":1}' http://127.0.0.1:7545

# Get network info
npx hardhat console --network ganache

# View deployed contracts
cat deployments/unknown.json
```

## Troubleshooting

- **Port already in use**: Kill existing Ganache processes or use a different port
- **Connection refused**: Make sure Ganache is running before deployment
- **Insufficient funds**: Each account starts with 100 ETH, should be enough for testing
- **Nonce too high/low**: Reset MetaMask account or restart Ganache

